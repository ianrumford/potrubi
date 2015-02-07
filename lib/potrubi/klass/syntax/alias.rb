
# potrubi contract dsl

# syntax methods

# to ease the creation of new methods using text snippets

#require_relative '../../bootstrap'

requireList = %w(super ./mixin/new_statements ./mixin/statement_management)
requireList.each {|r| require_relative "#{r}"}
###require "potrubi/klass/syntax/braket"



instanceMethods = Module.new do

  include Potrubi::Bootstrap
  ##include Potrubi::Mixin::Util
  include Potrubi::Klass::Syntax::Mixin::NewStatements
  #include Potrubi::Klass::Syntax::Mixin::NameGeneration
  include Potrubi::Klass::Syntax::Mixin::StatementManagement
  
  ###attr_accessor :name, :type, :key, :value, :variant, :spec, :edit,
  ###:blok, :key_names, :default
  
  attr_accessor :source_name, :target_name
  
  def to_s
    syntax
  end

  def inspect
    @to_inspect ||= potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLSynAli'))
  end

  # Accessor Methods
  # ################

  # Name Methods
  # ###########

  def set_source_name(nameValue)
    self.source_name = nameValue
    self # fluent
  end

  def set_target_name(nameValue)
    self.target_name = nameValue
    self # fluent
  end


  # New to Add Statements Mapping
  # #############################
  
  newToAddMap = [
                 :method_alias,
                ]


  newToAddTexts = newToAddMap.map {|s| "def add_statement_#{s}(*a, &b); add_statements_or_croak(new_statement_#{s}(*a, &b)); end;"}
  ###newToAddTexts << "def add_statement(*a, &b); add_statements_or_croak(new_statement(*a, &b)); end;"
  newToAddText = newToAddTexts.flatten.compact.join("\n")
  puts("ALIAS NEW TO ADD STATEMENT MAP >\n#{newToAddText}")
  module_eval(newToAddText)
  
  
  # Syntax Methods
  # ##############
  
  def syntax
    eye = :'PotKlsSynAli::syn'
    eyeTaleME = '>>>>>>>>>>>>>>>>>> SYN ALI'
    eyeTaleMX = '<<<<<<<<<<<<<<<<<< SYN ALI'
    ###nameMethod = name
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTaleME)

    aliasStms = statements
    
    syntaxAliases = case
                   when aliasStms.empty? then nil
                   else

                     braketAliases = new_braket_snippet
                     
                     braketAliases.push(###make_syntax_def,
                                       ###make_syntax_eye,
                                       ###statements.map {|s| s.syntax },
                                       aliasStms,
                                       ###make_syntax_result,
                                       ###make_syntax_end

                                       )
                     
                     braketAliases.to_s
                     
                   end
    
    puts("#{eye} SYNTAX ALIAS syntax \n#{syntaxAliases}")
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTaleMX, potrubi_bootstrap_logger_fmt_who_only(synAli: syntaxAliases))

    syntaxAliases
  end


  

  
end

module Potrubi
  class Klass
    module Syntax
      class Alias < Super
      end
    end
  end
end

Potrubi::Klass::Syntax::Alias.__send__(:include, instanceMethods)  # Instance Methods

__END__

Potrubi::Klass::Syntax::Alias.extend(classMethods)  # Class Methods

__END__

m = Potrubi::DSL::Syntax::Method.new_method

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

