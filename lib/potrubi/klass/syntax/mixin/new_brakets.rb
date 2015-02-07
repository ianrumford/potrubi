
# potrubi contract dsl

# syntax methods for brakets

# to ease the creation of new methods using text manipulation

#require_relative '../../bootstrap'

#requireList = %w(base)
#requireList.each {|r| require_relative "#{r}"}
###require "potrubi/klass/syntax/braket"

instanceMethods = Module.new do

  #include Potrubi::Klass::Syntax::Mixin::Base

  def braket_klass
    @braket_klass ||= Potrubi::Klass::Syntax::Braket
  end
  alias_method :braket_method_klass, :braket_klass
  alias_method :braket_statement_klass, :braket_klass
  alias_method :braket_snippet_klass, :braket_klass
  
  # Braket Methods
  # ##############
  
  def mustbe_braket_method_or_croak(braketMethod)
    braketMethod.is_a?(braket_method_klass) ? braketMethod : potrubi_bootstrap_surprise_exception(braketMethod, :mustbe_bkt_mth, "braketMethod not a braket method")
  end
  
  def new_braket_method
    braket_method_klass.new_method
  end

  # Statement Braket Methods
  # ########################

  def new_braket_statement
    #puts("NEW BRAKET STATEMENT ")
    #stateKls = braket_statement_klass
    #puts("NEW BRAKET STATEMENT kls >#{stateKls.class}< >#{stateKls}<")
    braket_statement_klass.new_statement
  end
  
  def mustbe_braket_statement_or_croak(braketStatement)
    braketStatement.is_a?(braket_statement_klass) ? braketStatement : potrubi_bootstrap_surprise_exception(braketStatement, :mustbe_bkt_stm, "braketStatement not a braket statetment")
  end

  # Snippet Braket Methods
  # ########################

  def new_braket_snippet
    #puts("NEW BRAKET SNIPPET ")
    #stateKls = braket_snippet_klass
    #puts("NEW BRAKET SNIPPET kls >#{stateKls.class}< >#{stateKls}<")
    braket_snippet_klass.new_snippet
  end
  
  def mustbe_braket_snippet_or_croak(braketSnippet)
    braketSnippet.is_a?(braket_snippet_klass) ? braketSnippet : potrubi_bootstrap_surprise_exception(braketSnippet, :mustbe_bkt_stm, "braketSnippet not a braket snippet")
  end
  
end

module Potrubi
  class Klass
    module Syntax
      module Mixin
        module NewBrakets
        end
      end
    end
  end
end

Potrubi::Klass::Syntax::Mixin::NewBrakets.__send__(:include, instanceMethods)  # Instance Methods


__END__

Potrubi::Klass::Syntax::Super.extend(classMethods)  # Class Methods

__END__

m = Potrubi::DSL::Syntax::Super.new

__END__

