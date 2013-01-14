
# potrubi paths and names methods

require_relative '../bootstrap'

#requireList = %w(bootstrap)
#requireList.each {|r| require_relative "#{r}"}

mixinContent = Module.new do

  # Fundamental Methods
  # ###################
  
  #=begin
  def transform_pathandname_or_croak(transformSpec, *transformData)
    eye = :tfm_pan

    logrArgs = potrubi_bootstrap_logger_fmt_who(:spec => transformSpec, :data => transformData)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, logrArgs)

    transformDefs = case transformSpec
                    when Proc, Symbol, Array then [*transformSpec].compact
                      #when Array then transformSpec
                      ###mustbe_hashs_or_croak(transformSpec)
                    else
                      potrubi_bootstrap_surprise_exception(transformSpec, eye, "transformSpec is what?")
                    end


    transformResult = transformDefs.inject(transformData) do |s, transformCode|
      ###transformCode = transformDef[:transform]
      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye,"INJ BEG", potrubi_bootstrap_logger_fmt_who(:transformCode => transformCode, :s => s))
      case transformCode
      when Proc then transformCode.call(s)
      when Symbol then __send__(transformCode, s)
      when Array then
        case
        when transformCode.last.is_a?(Proc) then
          transformArgs = transformCode[0, transformCode.size - 1]
          $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye,"PROC ON METHOD", potrubi_bootstrap_logger_fmt_who(:transformArgs => transformArgs))
          s.__send__(*transformArgs, &(transformCode.last))
        else
          s.__send__(*transformCode)
        end
      else
        potrubi_bootstrap_surprise_exception(transformCode, eye, "transformCode is what?")
      end
    end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(:result => transformResult), logrArgs)

    transformResult
    
  end
  #=end


  # Core Methods
  # ############

  #=begin
  def normalise_pathandname_names_syntax_or_croak(*names, &block)
    eye = :nrm_pan_ns_syn
    
    nameNorm = names.flatten.compact.join('::').gsub('\\','::').gsub('/','::').gsub(':::', '::').sub(/(\.\w*)?\Z/,'')
    
    potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(:name => nameNorm, :names => names))

    nameNorm
    
  end
  #=end
  
  #=begin
  def normalise_pathandname_hier_drop_while(*names, &block)
    r = names.flatten.compact.drop_while(&block)
    potrubi_bootstrap_logger_ca(:nrm_pan_drop_while, potrubi_bootstrap_logger_fmt_who(:r => r, :names => names))
    r
  end
  #=end
  
  #=begin
  def normalise_pathandname_hier_split_at(*names, &splitBlok)
    a = names.flatten
    i = a.find_index(&splitBlok)

    r = case i
        when NilClass then [a] # not found: all are "before"
        when Fixnum then
          [a[0, i], a[i+1, a.size - i - 1], a[i], i] # before, after, match value and index
        else
          potrubi_bootstrap_surprise_exception(i, eye, "a >#{a}< i is what?")
        end
    
    potrubi_bootstrap_logger_ca(:nrm_pan_h_split_at, potrubi_bootstrap_logger_fmt_who(:r => r, :names => names))
    
    r
  end
  #=end

  #=begin
  def normalise_pathandname_hier_from_lib(*names) # from as in after
    r =  normalise_pathandname_hier_split_at(*names) {|v| v.downcase == 'lib' }
    q = case
        when r.size == 1 then r.first # no match; use all
        else
          r[1] # the after
        end
    potrubi_bootstrap_logger_ca(:nrm_pan_h_from_lib, potrubi_bootstrap_logger_fmt_who(:q => q, :r => r, :names => names))
    q
  end
  #=end
  
  #=begin
  def normalise_pathandname_names_elements(*names)
    versionSuffixRegexp = Regexp.new('(.+)_v\d+.*\Z')
    r = names.flatten.compact.map {|n| m = n.to_s; (mD = m.to_s.match(versionSuffixRegexp)) ? mD[1] : m}.map {|n| p = n.split('_'); p.map {|q| q[0] = q.chr.upcase; q}.join }
    potrubi_bootstrap_logger_ca(:nrm_pan_ns_eles, potrubi_bootstrap_logger_fmt_who(:r => r, :names => names))
    r
  end
  #=end

  #=begin
  def normalise_pathandname_paths_or_croak(*paths, &block)
    eye = :nrm_pan_ps
    pathNorm = begin
                 pathNomn = paths.flatten.compact.join('/').gsub('\\', '/').gsub('::', '/').gsub('//', '/')
                 #pathFull = (pathNomn =~ /\A\./) ? ::File.expand_path(pathNomn) : pathNomn
                 File.expand_path(pathNomn)
               end
    
    potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(:pathNorm => pathNorm, :paths => paths))
    pathNorm
  end
  alias_method :normalise_pathandname_path_or_croak, :normalise_pathandname_paths_or_croak
  #=end
  
  #=begin
  def normalise_pathandname_names_to_hier_or_croak(*names, &block)
    eye = :nrm_pan_ns_2_h
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(:names => names))

    nameHier = transform_pathandname_or_croak([:normalise_pathandname_names_syntax_or_croak,
                                               [:split, '::'],
                                               :normalise_pathandname_hier_from_lib,
                                               :normalise_pathandname_names_elements,
                                               Kernel.block_given? ? [:map, block] : nil,
                                              ], *names)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(:hier => nameHier, :names => names))
    
    potrubi_bootstrap_mustbe_array_or_croak(nameHier, eye)
    
  end
  alias_method :normalise_pathandname_name_to_hier_or_croak, :normalise_pathandname_names_to_hier_or_croak
  #=end

  #=begin
  def normalise_pathandname_paths_to_hier_or_croak(*paths, &block)
    eye = :nrm_pan_ps_2_h
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, "paths >#{paths}<")

    pathHier = transform_pathandname_or_croak([:normalise_pathandname_paths_or_croak,
                                               [:split, '/'],
                                               Kernel.block_given? ? [:map, block] : nil,
                                              ], *paths)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, "pathhier >#{pathHier.whoami?}< >#{pathHier}< paths >#{paths}<")
    
    potrubi_bootstrap_mustbe_array_or_croak(pathHier, eye)
    
  end
  alias_method :normalise_pathandname_path_to_hier_or_croak, :normalise_pathandname_paths_to_hier_or_croak
  #=end

  # Derivative Methods
  # ##################
  
  #=begin
  def normalise_pathandname_names_or_croak(*names, &block)
    eye = :nrm_pan_ns
    nameNorm = normalise_pathandname_names_to_hier_or_croak(*names, &block).join('::')
    potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(:name => nameNorm, :names => names))
    nameNorm
  end
  alias_method :normalise_pathandname_name_or_croak, :normalise_pathandname_names_or_croak
  #=end
  
  #=begin
  def find_pathandname_names_hier_from_lib_or_croak(*names, &block)
    eye = :f_pan_ns_hier_fr_lib
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(:names => names))
    
    nameHier = normalise_pathandname_names_to_hier_or_croak(*names)
    
    libHierNom = nameHier.reverse.drop_while {|v| (v.downcase != 'Lib') }.reverse
    
    libHierNom.shift  # the lib

    libHierMap = Kernel.block_given? ? libHierNom.map {|m| block.call(m)} : libHierNom     

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(:libHierMap => libHierMap, :libHierNom => libHierNom, :name_hier => nameHier, :names => names))
    
    potrubi_bootstrap_mustbe_array_or_croak(libHier)

  end
  #=end
  
end

module Potrubi
  module Mixin
    module PathAndNames
    end
  end
end

Potrubi::Mixin::PathAndNames.__send__(:include, mixinContent)  # Instance Methods


__END__

