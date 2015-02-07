
# potrubi mixin persistence

# various file, etc methods

require_relative '../core'

requireList = %w(util filesys)
requireList.each {|r| require_relative "#{r}"}

require 'yaml'

mixinContent = Module.new do

  include Potrubi::Mixin::Filesys

  def write_ruby_script_or_croak(rubyArgs)
    eye = :w_ruby
    mustbe_hash_or_croak(rubyArgs, eye)

    mustbe_subset_or_croak(rubyArgs.keys, [:ruby, :path, :permissions, :text], eye, "unexpected keys")

    scriptPath = mustbe_string_key_or_croak(rubyArgs, :path, eye)
    scriptPermissions = mustbe_fixnum_key_or_nil_or_croak(rubyArgs, :permissions, eye)
    
    rubyTextNom = mustbe_not_nil_or_croak(rubyArgs[:text], eye)

    # may not want the header line
    
    rubyPath =  rubyArgs.has_key?(:ruby) ? resolve_ruby_exe_path_or_croak(rubyArgs) : nil
    
    rubyTextNrm = [rubyPath && "#!#{rubyPath}\n", rubyTextNom].flatten.compact.join

    File.open(scriptPath, 'w', scriptPermissions) {|f| f.puts(rubyTextNrm) }

    self
    
  end
  
    
  def write_yaml_file_or_croak(yamlPath, yamlData, yamlOpts=nil)
    eye = :w_yaml
    
    yamlPermissions = nil
    yamlOpts && begin
                  mustbe_hash_or_croak(yamlOpts, eye)
                  mustbe_subset_or_croak(yamlOpts.keys, [:permissions], eye)
                  yamlPermissions = yamlOpts[:permissions]
                end

    yamlPermissions = yamlOpts[:permissions]
    File.directory?(yamlPath) || create_path_directory_or_croak(yamlPath)
    File.open(yamlPath, 'w', yamlPermissions) {|yamlHndl|  YAML.dump(yamlData, yamlHndl) }
    self
  end

  def read_yaml_file_or_croak(yamlPath, &yamlBlok)
    eye = :r_yaml
    
    yamlData = case
               when (p = is_value_yaml_path?(yamlPath)) then YAML.load(File.read(p))
               else
                 missing_exception(yamlPath, eye, 'yamlPath not found / not a file')
               end
    
    r = Kernel.block_given? ? yamlBlok.call(yamlData) : yamlData
    
    $DEBUG && logger_ca(eye, logger_fmt_kls(:yamlPath => yamlPath), logger_fmt_kls_only(:yamlData => r))
    
    r
  end

  # 'reading' a ruby configuration sources mean instance_eval-ing the
  # code and returning the final value
  
  def read_ruby_configuration_source_or_croak(rubyPath, &rubyBlok)
    eye = :r_ruby
    
    rubyText = case
               when (p = is_value_ruby_configuration_source?(rubyPath)) then File.open(p).readlines.join("\n")
               else
                 missing_exception(rubyPath, eye, 'rubyPath not found / not a file')
               end

    rubyData = instance_eval(rubyText)
    
    r = Kernel.block_given? ? rubyBlok.call(rubyData) : rubyData
    
    $DEBUG && logger_ca(eye, logger_fmt_kls(:rubyPath => rubyPath), logger_fmt_kls(:rubyData => r))

    r
  end
  
  # generalises configuration sources
  # #################################
  
  # Recirsives resolves the config sources
  # Takes hash:  source name and value pairs
  # If value is a config source, and returns a hash, recursivesly resolves any config source values in it
  # If value is a array, maps any configur sources
  
  def read_recursive_configuration_sources_or_croak(srceArgs, &srceBlok)
    eye = :r_rcv_cfg_srces

    $DEBUG && logger_me(eye, logger_fmt_kls(srceArgs: srceArgs), logger_fmt_kls(srceBlok: srceBlok))

    srceData = potrubi_util_map_hash_v(srceArgs) do | srceName, srceValue |

      r = read_configuration_source_or_croak(srceValue, &srceBlok)

      case r
      when Hash then read_recursive_configuration_sources_or_croak(r, &srceBlok)
      when Array then read_recursive_configuration_sources_list_or_croak(*r, &srceBlok)
      else
        r
      end
      
      ###r.is_a?(Hash) ? read_recursive_configuration_sources_or_croak(r, &srceBlok) : r
      
    end
    
    $DEBUG && logger_mx(eye, logger_fmt_kls(srceData: srceData))
    
    mustbe_hash_or_croak(srceData, eye, "srceData not hash")
    
  end

  # Tolerate non-sources

  def read_recursive_maybe_configuration_sources_or_croak(srceArgs)
    read_recursive_configuration_sources_or_croak(srceArgs) {|v| v}
  end
  
  # Read configuration sources
  # Takes hash: source name and value pairs
  # Take hard line and raise exception if value not a source
  # Unless block is given and returns result of block
  
  def read_configuration_sources_or_croak(srceArgs, &srceBlok)
    eye = :r_cfg_srces

    $DEBUG && logger_me(eye, logger_fmt_kls(srceArgs: srceArgs), logger_fmt_kls(srceBlok: srceBlok))

    srceData = potrubi_util_map_hash_v(srceArgs) do | srceName, srceValue |
      ##is_value_configuration_source?(srceValue) ? read_configuration_source_or_croak(srceValue) : (Kernel.block_given? ? srceBlok.call(srceName, srceValue) : potrubi_bootstrap_surprise_exception(srceValue, eye, "srceName >#{srceName}< srceValue not a configuration source"))
      read_configuration_source_or_croak(srceValue, &srceBlok)
    end
    
    $DEBUG && logger_mx(eye, logger_fmt_kls(srceData: srceData))
    
    mustbe_hash_or_croak(srceData, eye, "srceData not hash")
    
  end
  alias_method :read_configuration_files_or_croak, :read_configuration_sources_or_croak

  # Tolerate non-sources
  
  def read_maybe_configuration_sources_or_croak(srceArgs)
    read_configuration_sources_or_croak(srceArgs) {|v| v}
  end
  
  # Read the actual source
  
  def read_configuration_source_or_croak(srceSpec, &srceBlok)
    eye = :'r_cfg_src'

    $DEBUG && logger_me(eye, logger_fmt_kls(srceSpec: srceSpec), logger_fmt_kls(srceBlok: srceBlok))

    srceType = is_value_configuration_source?(srceSpec)

    srceData = case srceType
               when Symbol
                 case srceType
                 when :HASH then srceSpec # nothing to do
                 when :YAML then read_yaml_file_or_croak(srceSpec)
                 when :RUBY then read_ruby_configuration_source_or_croak(srceSpec)
                 else
                   surprise_exception(srceType, eye, "srceType not a known symbol")
                 end
               else
                 Kernel.block_given? ? srceBlok.call(srceSpec) : potrubi_bootstrap_surprise_exception(srceSpec, eye, "srceSpec not a configuration source")
               end

    $DEBUG && logger_mx(eye, logger_fmt_kls_only(srceType: srceType),  logger_fmt_kls(srceBlok: srceBlok), logger_fmt_kls_only(srceData: srceData))    

    srceData
  end

  # same semantics as for hash sources
  
  def read_maybe_configuration_sources_list_or_croak(*srceArgs)
    read_configuration_sources_list_or_croak(*srceArgs) {|v| v}
  end
  
  def read_configuration_sources_list_or_croak(*srceArgs, &srceBlok)
    eye = 'r_cfg_srcs_lst'

    # srceBlok is used on hash merges for duplicate keys
    
    $DEBUG && logger_me(eye, logger_fmt_kls(srceArgs: srceArgs, srceBlok: srceBlok))

    srceData = srceArgs.map { | srceArg | read_configuration_source_or_croak(srceArg, &srceBlok)}

    $DEBUG && logger_mx(eye, logger_fmt_kls(srceData: srceData, srceBlok: srceBlok))

    mustbe_array_or_croak(srceData, eye, "srceData not array")

  end

  def read_recursive_configuration_sources_list_or_croak(*srceArgs, &srceBlok)
    eye = 'r_rcv_cfg_srcs_lst'

    # srceBlok is used on hash merges for duplicate keys
    
    $DEBUG && logger_me(eye, logger_fmt_kls(srceArgs: srceArgs, srceBlok: srceBlok))

    srceData = srceArgs.map do | srceArg |

      r = read_configuration_source_or_croak(srceArg, &srceBlok)

      case r
      when Hash then read_recursive_configuration_sources_or_croak(r, &srceBlok)
      when Array then read_recursive_configuration_sources_list_or_croak(*r, &srceBlok)
      else
        r
      end

    end

    $DEBUG && logger_mx(eye, logger_fmt_kls(srceData: srceData, srceBlok: srceBlok))

    mustbe_array_or_croak(srceData, eye, "srceData not array")

  end

  def read_recursive_maybe_configuration_sources_list_or_croak(*srceArgs)
    read_recursive_configuration_sources_list_or_croak(*srceArgs) {|v| v}
  end

    
  # is_value predicates
  # ##################
  
  def is_value_configuration_source?(srceArgs)
    eye = :'is_val_cfg_src?'
    srceType = case
               when srceArgs.is_a?(Hash) then :HASH 
               when (r = is_value_yaml_path?(srceArgs)) then :YAML
               when (r = is_value_ruby_configuration_source?(srceArgs)) then :RUBY
               else
                 nil
               end
    $DEBUG && logger_ca(eye, logger_fmt_kls(srceType: srceType), logger_fmt_kls(srceArgs: srceArgs), )
    srceType
  end
  
  # specific source type tests  (TODO: xml?)
  
  def is_value_yaml_path?(yamlPathNom, &yamlBlok)
    eye = :is_yaml_path?

    yamlPathNrm = case
                    #when is_value_file?(yamlPathNom) then yamlPathNom
                  when is_value_file?(yamlPathNom) && ((File.extname(yamlPathNom) == '.yaml') || (File.extname(yamlPathNom) == '.yml')) then yamlPathNom
                  when is_value_file?(r = "#{yamlPathNom}.yml") then r
                  when is_value_file?(r = "#{yamlPathNom}.yaml") then r
                  else
                    nil
                  end

    r = Kernel.block_given? ? yamlBlok.call(yamlPathNrm) : yamlPathNrm
    
    $DEBUG && logger_ca(eye, logger_fmt_kls(yamlPath: yamlPathNrm, yamlPathNom: r))
    
    r
  end

  def is_value_ruby_configuration_source?(rubyPathNom, &rubyBlok)
    eye = :is_ruby_path?

    rubyPathNrm = case
                  when (is_value_file?(rubyPathNom) && (File.extname(rubyPathNom) == '.rb'))  then rubyPathNom
                  else
                    nil
                  end

    rubyPathMap = Kernel.block_given? ? rubyBlok.call(rubyPathNrm) : rubyPathNrm
    
    $DEBUG && logger_ca(eye, logger_fmt_kls(rubyPathMap: rubyPathMap, rubyPathNrm: rubyPathNrm, rubyPathNom: rubyPathNom))
    
    rubyPathMap
  end
end

mixinConstant = Potrubi::Core.assign_mixin_constant_or_croak(mixinContent, :Potrubi, :Mixin, :Persistence)

__END__
