
# potrubi contract dsl

# syntax methods

# to ease the creation of new methods using text snippets

#require_relative '../../bootstrap'

requireList = %w(super ./mixin/new_statements ./mixin/name_generation ./mixin/synel_management)
#requireList = %w(super)
defined?(requireList) && requireList.each {|r| require_relative "#{r}"}

#__END__

classMethods = Module.new do

  include Potrubi::Bootstrap
  
  # let the class be able to call new_method
  include Potrubi::Klass::Syntax::Mixin::NewMethods
  
end

instanceMethods = Module.new do

  include Potrubi::Bootstrap
  ##include Potrubi::Mixin::Util
  include Potrubi::Klass::Syntax::Mixin::NewSnippets
  include Potrubi::Klass::Syntax::Mixin::NewStatements
  include Potrubi::Klass::Syntax::Mixin::NameGeneration
  #include Potrubi::Klass::Syntax::Mixin::StatementManagement
  include Potrubi::Klass::Syntax::Mixin::SynelManagement
  
  ###attr_accessor :name, :type, :key, :value, :variant, :spec, :edit,
  ###:blok, :key_names, :default
  
  attr_accessor :name, :eye, :signature, :result
  
  def to_s
    syntax
  end

  def inspect
    ###potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLSynMth'),  potrubi_bootstrap_logger_fmt(n: name))
    @to_inspect ||= potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLSynMth'))
  end

  # Accessor Methods
  # ################

  #alias_method :set_name, :'name='
  #alias_method :set_eye, :'eye='
  #alias_method :set_signature, :'signature='
  alias_method :get_signature, :'signature'
  #alias_method :set_result, :'result='
  alias_method :get_result, :'result'

  # Iterator Methods
  # ################

  def iterator_block(iterName, *iterArgs, &iterBlok)
    eye =  :'PotKlsSynMth::iter_blok'
    eyeTale = 'ITER BLOK'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, potrubi_bootstrap_logger_fmt_who_only(iterName: iterName, iterArgs: iterArgs, iterBlok: iterBlok))

    #snipInst = new_snippet(parent: parent, delegate: delegate)
    snipInst = new_snippet(parent: parent, delegate: self)

    ##iterSource = potrubi_bootstrap_mustbe_symbol_or_croak(iterArgs.shift, eye)

    #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, 'ITER SNIP', potrubi_bootstrap_logger_fmt_who(iterName: iterName, iterSource: iterSource, snipInst: snipInst))
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, 'ITER SNIP', potrubi_bootstrap_logger_fmt_who(iterName: iterName, snipInst: snipInst))

    iterNewStmMethod = "new_statement_iterator_#{iterName}"

    
    #iterEachStm = __send__(iterNewStmMethod, iterSource, *iterArgs, &iterBlok)
    iterEachStm = __send__(iterNewStmMethod, iterName, *iterArgs, &iterBlok)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, 'ITER SNIP EACH', potrubi_bootstrap_logger_fmt_who(iterName: iterName, iterEachStm: iterEachStm, snipInst: snipInst))

    #STOPHEREITERX1
         
    Kernel.block_given? && snipInst.instance_eval(&iterBlok)
    
    snipInst.cons_west_synels(iterEachStm)
    snipInst.tail_east_synels(new_statement_end) # add end of block    

    #SYOPHEREITERBLOKX1

    puts("##{eye} #{eyeTale} SYN SYN SYN >>>>>>>>>>>>>>>>>>> >\n#{snipInst.syntax}<")

            #SYOPHEREITERBLOKX2

    add_synels_or_croak(snipInst)  # now add to the method

    #SYOPHEREITERBLOKX3
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye,  potrubi_bootstrap_logger_fmt_who(snipInst: snipInst), potrubi_bootstrap_logger_fmt_who_only(iterArgs: iterArgs, iterBlok: iterBlok))
    self # fluent
    #SYOPHEREITERBLOKEXIT
  end



    
  # Name Methods
  # ###########

  def set_name(*nameValues)
    self.name = name_builder_method(*nameValues)
    self # fluent
  end

  # Eye Methods
  # ###########

  def set_eye(*eyeValues)
    self.eye = name_builder_eye(*eyeValues)
    self # fluent
  end
  
  # Result Methods
  # ##############

  def set_result(resultValue)
    self.result = resultValue
    self # fluent
  end

  def set_result_self
    set_result('self')
  end

  # Signature Methods
  # #################

  def set_signature(*signatures)
    self.signature = signatures.flatten.compact.join(',')
    self # fluent
  end

  def set_signature_values_and_blok(*names)
    sigKey = name_creator('', *names)
    set_signature("*#{sigKey}Values", "&#{sigKey}Blok")
  end
  alias_method :set_signature_values_and_block, :set_signature_values_and_blok

  def set_signature_generic
    set_signature('*a', '&b')
  end
  
  def set_signature_args_and_blok(*names)
    sigKey = name_creator('', *names)
    set_signature("#{sigKey}Args=nil", "&#{sigKey}Blok")
  end
  alias_method :set_signature_args_and_block, :set_signature_args_and_blok
  
  # # Snippet Methods
  # # ###############

  # def new_snippets(*snippets, &snipBlok)
  #  snippets.map {|s| new_statement(s) }
  # end

  # def new_snippet(*snips, &snipBlok)
  #  new_statement(*snips)
  # end
  
  # # New to Add Snippets Mapping
  # # ###########################
  
  # newToAddMap = [:snippet,
  #                :snippets,
  #                ]


  # newToAddTexts = newToAddMap.map {|s| "def add_#{s}(*a, &b); add_statements_or_croak(new_#{s}(*a, &b)); end;"}
  # ###newToAddTexts << "def add_snippet(*a, &b); add_statements_or_croak(new_snippet(*a, &b)); end;"
  # newToAddText = newToAddTexts.flatten.compact.join("\n")
  # puts("NEW TO ADD SNIPPET MAP >\n#{newToAddText}")
  # module_eval(newToAddText)  
  # #STOPHEREADDTONEWSNIPPETMETHODS
  


  # New to Add Statements Mapping
  # #############################
  
  newToAddMap = [
                 :logger_method_entry,
                 :logger_method_exit,
                 :logger_method_call,
                 :logger_call,
                 :logger_method_entry,
                 :assign,
                 :assign_if_not_set,
                 :assign_instance_variable,
                 :assign_instance_variable_if_not_set,
                 :assign_local_variable,
                 :method_call,
                 ###:snippets,
                 :in_parentheses,
                 :if_ternary,
                 :end,
                 :self,
                 :rescue,
                 :rescue_nil,
                 :surprise_exception,
                 :missing_exception,
                 :duplicate_exception,
                 :predicate_and_exception,
                 :predicate_and_surprise_exception,
                 :predicate_and_duplicate_exception,
                 :predicate_and_missing_exception,
                 :contracts,
                ]


  newToAddTexts = newToAddMap.map {|s| "def add_statement_#{s}(*a, &b); add_synels_or_croak(new_statement_#{s}(*a, &b)); end;"}
  newToAddTexts << "def add_statement(*a, &b); add_synels_or_croak(new_statement(*a, &b)); end;"
  newToAddTexts << "def add_statements(*a, &b); add_synels_or_croak(new_statements(*a, &b)); end;"
  newToAddText = newToAddTexts.flatten.compact.join("\n")
  puts("NEW TO ADD STATEMENT MAP >\n#{newToAddText}")
  module_eval(newToAddText)

  #STOPHEREPOSTNEWTOADDMAP
  
  # Syntax Methods
  # ##############
  
  def syntax
    eye = :'PotKlsSynMth::syn'
    eyeTaleME = '>>>>>>>>>>>>>>>>>> SYN MTH'
    eyeTaleMX = '<<<<<<<<<<<<<<<<<< SYN MTH'
    nameMethod = name

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTaleME, potrubi_bootstrap_logger_fmt_who_only(nameMethod: nameMethod))

    syntaxMethod = case nameMethod
                   when NilClass then nil
                   else

                     braketMethod = new_braket_method
                     
                     braketMethod.push(make_syntax_def,
                                       make_syntax_eye,
                                       ###statements.map {|s| s.syntax },
                                       ###statements,
                                       synels,
                                       make_syntax_result,
                                       make_syntax_end

                                       )
                     
                     #braketMethod.to_s
                                          braketMethod.to_s.gsub(/\n+/, "\n")
                     
                   end
    
    puts("#{eye} SYNTAX METHOD NAME >#{nameMethod}< syntax \n#{syntaxMethod}")
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTaleMX, potrubi_bootstrap_logger_fmt_who_only(nameMethod: nameMethod, synMth: syntaxMethod))

    #STOPHEREMETHODSYNTAXEXIT
    
    syntaxMethod
  end

  def make_syntax_def
    #eye = :'PotKlsSynMth::m_syn_def'
    nameMethod = name
    syntaxSignature = make_syntax_signature
    new_statement('def ', nameMethod, syntaxSignature)
  end

  def make_syntax_signature
    #eye = :'PotKlsSynMth::m_syn_sig'
    signatureMethod = signature
    case signatureMethod
    when NilClass then nil
    else
      new_statement_in_parentheses(signatureMethod)
    end
  end
  
  def make_syntax_end
    :end
  end
  
  def make_syntax_eye
    eyeLocal = eye
    eyeLocal ? new_statement("eye = :'", eyeLocal, "'") : nil
  end
  
  def make_syntax_result
    resultLocal = result
    #resultLocal ? new_statement(resultLocal) : new_statement_self
    resultLocal ? new_statement(resultLocal) : nil
  end

  

  
end

module Potrubi
  class Klass
    module Syntax
      class Method < Potrubi::Klass::Syntax::Super
      end
    end
  end
end

Potrubi::Klass::Syntax::Method.__send__(:include, instanceMethods)  # Instance Methods
Potrubi::Klass::Syntax::Method.extend(classMethods)  # Class Methods

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

 def new_method(*a, &b)
    self.class.new_method(*a, &b)
  end

  def new_statement(*a)
    puts("METHOD NEW STATEMNET")
    bktStm = new_braket_statement
    a.empty? || bktStm.push(*a)
    ##:wouldbeanewstat
    bktStm
  end
  

  def new_method(dslArgs=nil, &dslBlok) # class method
    eye = :'PotKlsSynMth::n'
    puts("NEW METHOD")
    #potrubi_bootstrap_mustbe_symbol_or_croak(dslAttr, eye, "dslAttr is what?")
    newMethod = new(dslArgs, &dslBlok)
    #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(newMethod: newMethod), potrubi_bootstrap_logger_fmt_who(dslAttr: dslAttr, dslArgs: dslArgsNrm, dslBlok: dslBlok))
    newMethod
    ###STOPHERENEWMETHODEXIT
  end

    def zzzadd_statement(*statementElements)
    eye = :'PotKlsSynMth::a_stm'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(statementElements: statementElements))

    newStatement = new_statement(statementElements)

    add_statements_or_croak(newStatement)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who_only(newStatement: newStatement, statementElements: statementElements))

    self # allows for "fluent interface"
    
  end

    
  def zzzziterator_block_each(*iterArgs, &iterBlok)
    eye = :'iter_blok'
    eyeTale = 'ITER BLOK'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, potrubi_bootstrap_logger_fmt_who_only(iterArgs: iterArgs, iterBlok: iterBlok))

    #snipInst = new_snippet(parent: parent, delegate: delegate)
    snipInst = new_snippet(parent: parent)


    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, 'SNIP INST', potrubi_bootstrap_logger_fmt_who(snipInst: snipInst))

    iterMethod = potrubi_bootstrap_mustbe_symbol_or_croak(iterArgs[0], eye)
    iterSource = potrubi_bootstrap_mustbe_symbol_or_croak(iterArgs[1], eye)

    iterStm = case iterMethod
              when :each, :map, :each_with_hash, :each_with_array then

                blokArgs = iterArgs[2 ... iterArgs.size].join(',')

                iterMethodArgs = case iterMethod
                                 when :each_with_hash then '{}'
                                 when :each_with_array then '[]'
                                 else
                                   nil
                                 end
                

                new_statement(iterSource,
                              '.',
                              iterMethod,
                              iterMethodArgs && "(#{iterMethodArgs})",
                              ' do | ',
                              blokArgs,
                              ' |',
                              )
                
                
              else
                potrubi_bootstrap_surprise_excepton(iterMethod, eye, "iterMethod is what?")
              end
    
    
    snipInst.cons_west_synels(iterStm)
    snipInst.tail_east_synels(new_statement_end) # add end of block    

    #SYOPHEREITERBLOKENTR


    puts("##{eye} #{eyeTale} SYN >\n#{snipInst.syntax}<")
    
    add_synels_or_croak(snipInst)  # now add to the method
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye,  potrubi_bootstrap_logger_fmt_who(snipInst: snipInst), potrubi_bootstrap_logger_fmt_who_only(iterArgs: iterArgs, iterBlok: iterBlok))
    self # fluent
       # SYOPHEREITERBLOKEXIT
  end
