
# potrubi dsl

# to ease the creation of verbs, accessors, etc in class bodies

# Uses conventions for names etc dedined by (in) verb mixin

require_relative './bootstrap'

requireList = %w(mixin/util dsl/super)
requireList.each {|r| require_relative "#{r}"}

classMethods = Module.new do

  include Potrubi::Bootstrap
  include Potrubi::Mixin::Util
  
  def dsl(dslTarget, dslDefs=nil, &dslBlok)
    eye = :'DSL::dsl'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(dslTarget: dslTarget, dslDefs: dslDefs, dslBlok: dslBlok))

    require_relative "dsl"
    
    potrubi_bootstrap_mustbe_module_or_croak(dslTarget, eye)
    
    dslDefs && potrubi_bootstrap_mustbe_hash_or_croak(dslDefs, eye)

    if Kernel.block_given? then

      dslVerb = Potrubi::DSL::Super.new_verb({target: dslTarget, verb: :Super}, dslDefs, &dslBlok)

      dslVerb.assert
      
    end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(dslTarget: dslTarget, dslDefs: dslDefs))

    self
    
  end
  
end

instanceMethods = Module.new do

  include Potrubi::Bootstrap
  
  def to_s
    @to_s ||= potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('PotDSL'))
  end
  
  # Initialization
  # ##############
  
  def initialize(dslArgs=nil, &dslBlok)
    eye = :'ctx_dsl i'

    dslAttr = 'wantbeused'
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(dslArgs: dslArgs, dslBlok: dslBlok))

    case dslArgs
    when NilClass then nil
    when Hash then potrubi_bootstrap_mustbe_hash_or_croak(dslArgs, eye).each {|k, v| __send__("#{k}=", v) }
    else
      potrubi_bootstrap_surprise_exception(dslArgs, eye, "dslArgs is what?")
    end
    
    Kernel.block_given? && instance_eval(&dslBlok)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(subVerbs: get_subverbs.size, dslArgs: dslArgs, dslBlok: dslBlok))
    
  end

end

module Potrubi
  class DSL
  end
end

Potrubi::DSL.__send__(:include, instanceMethods)  # Instance Methods
Potrubi::DSL.extend(classMethods)  # Class Methods

__END__
