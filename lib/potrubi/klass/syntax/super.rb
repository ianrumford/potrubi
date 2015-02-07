
# potrubi contract dsl

# syntax method

# to ease the creation of new methods using text manipulation

#require_relative '../../bootstrap'

requireList = %w(./mixin/new_brakets ../../mixin/initialize)
requireList.each {|r| require_relative "#{r}"}
###require "potrubi/klass/syntax/braket"



instanceMethods = Module.new do

  include Potrubi::Bootstrap
  include Potrubi::Mixin::Initialize
  ###include Potrubi::Klass::Syntax::Mixin::Base
  include Potrubi::Klass::Syntax::Mixin::NewBrakets
  
  ##include Potrubi::Mixin::Util

  ###attr_accessor :name, :eye, :signature, :result
  
  def to_s
    @to_s ||= potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLSynSpr'),  potrubi_bootstrap_logger_fmt(n: name))
  end

  def mustbe_statement_or_croak(statementValue)
    statementValue.is_a?(statement_klass) ? statementValue : potrubi_bootstrap_surprise_exception(statementValue, :mustbe_stm, "statementValue not a statement")
  end

  def mustbe_method_or_croak(methodValue)
    methodValue.is_a?(method_klass) ? methodValue : potrubi_bootstrap_surprise_exception(methodValue, :mustbe_stm, "methodValue not a statetment")
  end



  
end

module Potrubi
  class Klass
    module Syntax
      class Super
      end
    end
  end
end

Potrubi::Klass::Syntax::Super.__send__(:include, instanceMethods)  # Instance Methods

__END__


classMethods = Module.new do

  include Potrubi::Bootstrap

end

Potrubi::Klass::Syntax::Super.extend(classMethods)  # Class Methods

__END__

m = Potrubi::DSL::Syntax::Super.new

__END__

classMethods = Module.new do

  def new_contract(dslArgs=nil, &dslBlok) # class method
    eye = :'DSLAcc::KLS new_cxt'
    #potrubi_bootstrap_mustbe_symbol_or_croak(dslAttr, eye, "dslAttr is what?")
    newContract = self.new(dslArgs, &dslBlok)
    #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(newContract: newContract), potrubi_bootstrap_logger_fmt_who(dslAttr: dslAttr, dslArgs: dslArgsNrm, dslBlok: dslBlok))
    newContract
    ###STOPHERENEWCONTRACTEXIT
  end
end

Potrubi::Mixin::Contract::DSL.extend(classMethods)  # CLass Methods

__END__


