
# potrubi constants methods

moduleContent = Module.new do

  include Potrubi::Bootstrap
  
  def normalise_module_constant_names_or_croak(*names, &nrmBlok)
    eye = :nrm_mod_cnst_ns
    
    moduleNamesNom = case
                     when respond_to?(:normalise_pathandname_names_to_hier_or_croak) then normalise_pathandname_names_to_hier_or_croak(*names)
                     else
                       names.flatten.compact
                     end

    moduleNamesNrm = Kernel.block_given? ? moduleNamesNom.map(&nrmBlok) : moduleNamesNom

    potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(:names_norm => moduleNamesNrm, :names => names))

    moduleNamesNrm
    
  end

  def assign_class_constant_or_croak(classConstant, *names, &asgBlok)
    r = classConstant.is_a?(Class) ? classConstant : create_class_constant_or_croak(*classConstant)
    potrubi_bootstrap_mustbe_class_or_croak(assign_module_constant_or_croak(r, *names, &asgBlok))
  end
  alias_method :assign_class_constant, :assign_class_constant_or_croak
  
  def assign_module_constant_or_croak(moduleConstant, *names, &asgBlok)
    eye = :asg_mod_cnst
    
    moduleNames = normalise_module_constant_names_or_croak(*names)
    
    $DEBUG_POTRUBI_BOOTSTRAP && begin
                                  logrArgs = potrubi_bootstrap_logger_fmt_who(:constant => moduleConstant, :moduleNames => moduleNames, :names => names, :self => self)
                                  potrubi_bootstrap_logger_me(eye, logrArgs)
                                end
    
    moduleName = moduleNames.pop
    
    moduleParent = case
                   when moduleNames.empty? then Object
                   else
                     moduleNames.inject(Object) {| mC, mN |  mC.const_defined?(mN, false) ? mC.const_get(mN) : mC.const_set(mN, Module.new)}
                   end
    
    potrubi_bootstrap_mustbe_module_or_croak(moduleParent, eye)
    
    currentConstant = moduleParent.const_defined?(moduleName, false)

    currentConstant && begin
                         $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, potrubi_bootstrap_logger_fmt_who(:moduleParent => moduleParent, :moduleName => moduleName), "exists already")
                         potrubi_bootstrap_duplicate_exception(moduleName, "moduleName exists already")
                       end
    
    moduleParent.const_set(moduleName, moduleConstant.is_a?(Module) ? moduleConstant : create_module_constant_or_croak(*moduleConstant))
    
    moduleConstantFound = moduleParent.const_get(moduleName)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(:constant_found => moduleConstantFound), logrArgs)

    potrubi_bootstrap_mustbe_module_or_croak(moduleConstantFound, eye)

  end
  alias_method :assign_module_constant, :assign_module_constant_or_croak
  alias_method :assign_mixin_constant_or_croak, :assign_module_constant_or_croak
  alias_method :assign_mixin_constant, :assign_mixin_constant_or_croak

  def find_class_constant(*a, &b)
    find_class_constant_or_croak(*a, &b) rescue nil
  end
  def find_class_constant_or_croak(*a, &b)
    potrubi_bootstrap_mustbe_class_or_croak(find_module_constant_or_croak(*a, &b))
  end

  def find_or_require_class_constant_or_croak(*a, &b)
    eye = :for_kls_con
    find_class_constant(*a, &b) || begin

                                     modNames = normalise_module_constant_names_or_croak(*a, &b)

                                     $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(:modNames => modNames))
                                     potrubi_bootstrap_mustbe_not_empty_or_croak(modNames, eye)

                                     requireName = File.join(*modNames.map(&:downcase))
                                     $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(:modNames => modNames, :requireName => requireName))                                     

                                     require requireName
                                     
                                     find_class_constant_or_croak(*a, &b)
                                   end
    
  end
  
  def find_module_constants_or_croak(*names, &findBlok)
    names.map {|n| find_module_constant_or_croak(n, &findBlok) }
  end

  def find_module_constant(*a, &b)
    find_module_constant_or_croak(*a, &b) rescue nil
  end
  
  def find_module_constant_or_croak(*names, &findBlok)
    eye = :f_mod_cnst
    
    modNames = normalise_module_constant_names_or_croak(*names)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(:modNames => modNames))
    potrubi_bootstrap_mustbe_not_empty_or_croak(modNames, eye)
    
    modCon =
      case
      when modNames.empty? then Object
      when (modNames.size == 1) && (modNames.first.is_a?(Module)) then modNames.first # nothing to do
      else
        modNames.join('::').split('::').inject(Object) do | mC, mN |
        potrubi_bootstrap_mustbe_module_or_croak(mC, eye, "mC not module mN >#{mN}<")
        mC.const_defined?(mN, false) ? mC.const_get(mN) : nil
      end
      end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "modCon >#{modCon.class}< >#{modCon}< modNames >#{modNames}<")

    potrubi_bootstrap_mustbe_module_or_croak(modCon)

    modResult = Kernel.block_given? ? findBlok.call(modCon) : modCon

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, potrubi_bootstrap_logger_fmt_who(:modResult => modResult, :modCon => modCon, :modNames => modNames))

    modResult # can not tell what this could be as block could do anything
    
  end
  alias_method :find_mixin_constant_or_croak, :find_module_constant_or_croak

  def find_peer_class_constant_or_croak(*peerNames)
    thisHier = self.class.name.split('::')
    thisHier.pop
    find_class_constant_or_croak(thisHier, peerNames)
  end

  def create_class_constant_or_croak(*names, &cratBlok)
    initValue = names.flatten.first.is_a?(Class) ? nil : Class.new # Must ALWAYS have a class first
    potrubi_bootstrap_mustbe_class_or_croak(create_module_constant_or_croak(initValue, *names, &cratBlok))
  end
  alias_method :enhance_class_constant_or_croak, :create_class_constant_or_croak

  def create_module_constant_or_croak(*names, &cratBlok)
    eye = :cr_mod_cnst
    
    moduleNames = names

    logrArgs = potrubi_bootstrap_logger_fmt_who(:names => moduleNames)
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, logrArgs)
    
    moduleConstants = normalise_module_contents_or_croak(*moduleNames)
    
    moduleConstantFirst = moduleConstants.first
    
    moduleInitValue = case moduleConstantFirst
                      when Class then moduleConstants.shift  # Must use the class as the init value to inject
                      when Module then Module.new # start from scratch
                      else
                        logic_exception(moduleConstantFirst, eye, "moduleConstantFirst is what?")
                      end
    
    moduleConstant = moduleConstants.inject(moduleInitValue) { | wC, mC | wC.__send__(:include, mC) }
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(:constant => moduleConstant, :includes => moduleConstants), logrArgs)

    potrubi_bootstrap_mustbe_module_or_croak(moduleConstant)

  end
  
  def extend_receiver_or_croak(receiverValue, *mixinContents)  
    eye = :ext_rcv
    eyeTale = 'EXTEND RCV'

    logrArgs = dynamic_potrubi_bootstrap_logger_fmt_who(:receiver => receiverValue, :mixins => mixinContents)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, logrArgs)
    
    mixinConstants = normalise_mixin_contents_or_croak(*mixinContents)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, logrArgs, potrubi_bootstrap_logger_fmt_who(:mixin_constants => mixinConstants))
    
    value_is_empty? ||
      begin
        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, 'EXTENDNG', logrArgs)

        mixinConstants.each do |mixinConstant|

        receiverValue.extend(mixinConstant)  # Add the instance methods, etc of mixin to receiver

      end

        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, 'EXTENDED', logrArgs)

      end

    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, logrArgs)

    self
    
  end

  def normalise_mixin_contents_or_croak(*nomMixins) 
    eye = :nrm_mxn_cnts
    eyeTale = 'NRM MXN CONTENTS'
    
    logrArgs = potrubi_bootstrap_logger_fmt_who(:nomMixins => nomMixins)
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, logrArgs)
    
    nrmMixins = nomMixins.flatten(1).compact.map.with_index do | mV, mN |

      logrNormArgs = potrubi_bootstrap_logger_fmt_who(:mN => mN, :mV => mV)
      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_beg(eye, eyeTale, "NORM", logrNormArgs)
      
      mC = case mV
           when Module then mV # nothing to to
           when Proc then Module.new(&mV)
           when String, Symbol then find_mixin_constant_or_croak(mV)
           when Array then # Array ONLY way to pass text
             mVMod = Module.new
             mVMod.module_eval([*mV].flatten.compact.join)
             mVMod
           when Hash then resolve_module_constants_or_croak(mV).values
           else
             potrubi_bootstrap_surprise_exception(mV,"mN >#{mN}< mV is what?")
           end

      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_fin(eye, eyeTale, "NORM", logrNormArgs, potrubi_bootstrap_logger_fmt_who(:mC => mC))
      
      mC
      
    end.flatten.compact

    nrmMixins.each {|m| potrubi_bootstrap_mustbe_module_or_croak(m, eye) }

    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, potrubi_bootstrap_logger_fmt_who(:nrmMixins => nrmMixins))
    

    potrubi_bootstrap_mustbe_array_or_croak(nrmMixins, eye)
  end
  alias_method :normalise_module_contents_or_croak, :normalise_mixin_contents_or_croak
  
end

#  Make the methods both instance and class

module Potrubi
  module Mixin
    module Konstant
    end
  end
end

Potrubi::Mixin::Konstant.extend(moduleContent)
Potrubi::Mixin::Konstant.__send__(:include, moduleContent)  # Instance Methods

__END__
