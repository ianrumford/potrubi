
# potrubi contract dsl

# syntax methods: method

# to ease the creation of new methods using text manipulation

#require_relative '../../bootstrap'

#requireList = %w(base )
#requireList.each {|r| require_relative "#{r}"}
###require "potrubi/klass/syntax/braket"


instanceMethods = Module.new do

  # Statement Management
  # ####################
  
  def statements
    @statements ||= []
  end

  def statements=(*newStms)
    newStmsNrm = newStms.flatten.compact.map {|s| mustbe_statement_or_croak(s) }
    @statements = newStmsNrm
  end
  
  def add_statements_or_croak(*newStatements)
    eye = :'PotKlsSynMth::a_stms'
    eyeTale = 'ADD STMS'
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, potrubi_bootstrap_logger_fmt_who_only(newStatements: newStatements))

    newStms = newStatements.flatten.compact
    sizStm = newStms.size
    newStms.each_with_index do | newStm, ndxStm|
      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, ">#{ndxStm}< of >#{sizStm}<", potrubi_bootstrap_logger_fmt_who(newStm: newStm), "SYN >#{newStm.inspect}<")
      mustbe_statement_or_croak(newStm)
    end
    
    newStatementsNrm = newStms.map {|s| mustbe_statement_or_croak(s) }
    statements.concat(newStatementsNrm)
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, potrubi_bootstrap_logger_fmt_who_only(newStms: newStatementsNrm))
    self
    #SYOPHEREADDSTMSEXIT
  end
  ###alias_method :add_statement, :add_statements
  
end



module Potrubi
  class Klass
    module Syntax
      module Mixin
        module StatementManagement
        end
      end
    end
  end
end

Potrubi::Klass::Syntax::Mixin::StatementManagement.__send__(:include, instanceMethods)  # Instance Methods


__END__

