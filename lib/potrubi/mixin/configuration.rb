
# potrubi mixin configuration

# support configuration from YAML and Ruby file

require_relative '../core'

requireList = %w(util persistence)
requireList.each {|r| require_relative "#{r}"}

###require 'yaml'

mixinContent = Module.new do

  include Potrubi::Mixin::Util
  include Potrubi::Mixin::Persistence
  
  # so common
  
  def set_attributes_or_croak(attrArgsNom, &attrBlok)
    eye = :'s_attrs'
    mustbe_hash_or_croak(attrArgsNom, eye)
    attrArgsNrm = Kernel.block_given? ? potrubi_util_apply_proc_to_hash_or_croak(attrArgsNom, &attrBlok) : attrArgsNom
    attrArgsNrm.each {|k,v| __send__("#{k}=", v) }
    ###puts("SET ATTRS attrArgs >#{attrArgs}<")
    self
  end

  def set_attributes_from_configuration_sources_list_or_croak(*srceArgs, &srceBlok)
    eye = 's_attr_fr_cfg_srcs_lst'

    $DEBUG && logger_me(eye, logger_fmt_kls(srceArgs: srceArgs, srceBlok: srceBlok))

    srceArgs.each { | srceArg | set_attributes_or_croak(read_configuration_source_or_croak(srceArg, &srceBlok)) }
      
    $DEBUG && logger_mx(eye, logger_fmt_kls(srceArgs: srceArgs, srceBlok: srceBlok))

    self
  end


  # If has key value is external source e.g. yaml
  # read it and set_attributes with it
  # Else raise exception unless blok is given
  
  def set_attributes_from_configuration_sources_or_croak(srceArgs, &srceBlok)
    eye = :s_attrs_fr_cfg_srces

    $DEBUG && logger_me(eye, logger_fmt_kls_only(srceArgs: srceArgs), logger_fmt_kls(srceBlok: srceBlok))

    mustbe_hash_or_croak(srceArgs, eye, "srceArgs not hash")
    
    srceArgs.each do | srceName, srceValue |
      case
      when (p = is_value_configuration_source?(srceValue)) then set_attributes_or_croak(read_configuration_source_or_croak(srceValue))
      else
        Kernel.block_given? ? srceBlok.call(srceName, srceValue) : potrubi_bootstrap_surprise_exception(srceValue, eye, "srceName >#{srceName}< srceValue not a configuration source")
      end
    end

    $DEBUG && logger_mx(eye, logger_fmt_kls_only(srceArgs: srceArgs), logger_fmt_kls(srceBlok: srceBlok))
    
    self
    
  end
  alias_method :set_attributes_from_configuration_files_or_croak, :set_attributes_from_configuration_sources_or_croak
  

  def set_attributes_using_specification_or_croak(attrSpec, attrData,  &attrBlok)
    eye = :'s_attrs_using_spec'

    $DEBUG && logger_me(eye, logger_fmt_kls(attrSpec: attrSpec, attrBlok: attrBlok), logger_fmt_kls(attrData: attrData))

    mustbe_hash_or_croak(attrSpec, eye, "attrSpec failed contract")
    mustbe_hash_or_croak(attrData, eye, "attrData failed contract")
    
    attrData.each do | attrName, attrValue |

      #attrProc = mustbe_key_or_nil_or_croak(attrSpec, attrName, eye, "attrName >#{attrName}< not in attrSpec >#{attrSpec}<")
      attrProc = attrSpec[attrName]
      
      $DEBUG && logger_ms(eye, 'WHAT ATTR', logger_fmt_kls(attrName: attrName, attrProc: attrProc), logger_fmt_kls(attrValue: attrValue))
      
      case attrProc
      when NilClass then
        $DEBUG && logger_ms(eye, 'SEND ATTR', logger_fmt_kls(attrName: attrName, attrProc: attrProc), logger_fmt_kls(attrValue: attrValue))
        self.__send__("#{attrName}=", attrValue)
      when Proc then
        $DEBUG && logger_ms(eye, 'PROC ATTR', logger_fmt_kls(attrName: attrName, attrProc: attrProc), logger_fmt_kls(attrValue: attrValue))
        instance_exec(attrName, attrValue, &attrProc)        
      else
        surprise_exception(attrProc, eye, "attrProc is what?")
      end
      
    end

    $DEBUG && logger_mx(eye, logger_fmt_kls(attrSpec: attrSpec, attrBlok: attrBlok), logger_fmt_kls(attrData: attrData))    

    self
    
  end
  
end


mixinConstant = Potrubi::Core.assign_mixin_constant_or_croak(mixinContent, :Potrubi, :Mixin, :Configuration)

__END__

