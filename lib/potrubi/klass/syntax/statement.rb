
# potrubi contract dsl

# syntax methods

# to ease the creation of new statements using text snippets

#require_relative '../../bootstrap'

requireList = %w(super)
requireList.each {|r| require_relative "#{r}"}
###require "potrubi/klass/syntax/braket"

instanceMethods = Module.new do

  ###include Potrubi::Bootstrap
  
  def to_s
    syntax
  end
  
  def inspect
    ###potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLSynMth'),  potrubi_bootstrap_logger_fmt(n: name))
    @to_inspect ||= potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLSynStm'))
  end
  
  def elements
    @elements ||= []
  end
  
  def add_elements_or_croak(*newElements)
    eye = :'PotKlsSynStm::a_eles'

    #newElementsNrm = newElements.flatten.compact.map {|s| mustbe_braket_element_or_croak(s) }
    newElementsNrm = newElements.flatten.compact

    elements.concat(newElementsNrm)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(newEles: newElementsNrm))

    self
  end
  alias_method :add_elements, :add_elements_or_croak
  
  def syntax
    eye = :'PotKlsSynStm::syn'

    braketStatement = new_braket_statement.push(elements)
    
    syntaxStatement = braketStatement.to_s
    
    ###puts("#{eye} STM SYN #{syntaxStatement}")
    
    #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who_only(self: self, size: elements.size, synStm: syntaxStatement))

    syntaxStatement

  end


  
end

module Potrubi
  class Klass
    module Syntax
      class Statement < Super
      end
    end
  end
end

Potrubi::Klass::Syntax::Statement.__send__(:include, instanceMethods)  # Instance Methods

__END__


classMethods = Module.new do

  include Potrubi::Bootstrap
  
end

Potrubi::Klass::Syntax::Statement.extend(classMethods)  # Class Methods

__END__

m = Potrubi::DSL::Syntax::Method.new_method

__END__

