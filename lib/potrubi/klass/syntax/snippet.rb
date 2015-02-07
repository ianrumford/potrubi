
# potrubi contract dsl

# syntax methods: snippets

# to ease the creation of new methods using text snippets

#require_relative '../../bootstrap'

requireList = %w(super ./mixin/new_aliases  ./mixin/new_methods ./mixin/new_statements ./mixin/name_generation ./mixin/synel_management)
#requireList = %w(super ./mixin/new_methods)
defined?(requireList) && requireList.each {|r| require_relative "#{r}"}

#__END__

instanceMethods = Module.new do

  include Potrubi::Bootstrap
  ##include Potrubi::Mixin::Util
  include Potrubi::Klass::Syntax::Mixin::NewStatements
  include Potrubi::Klass::Syntax::Mixin::NameGeneration
  include Potrubi::Klass::Syntax::Mixin::SynelManagement
  
  ###attr_accessor :name, :type, :key, :value, :variant, :spec, :edit,
  ###:blok, :key_names, :default

  # Note the parent is the *delegate's* parent
  attr_accessor :parent, :delegate
  
  def to_s
    syntax
  end

  def inspect
    ###potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLSynMth'),  potrubi_bootstrap_logger_fmt(n: name))
    @to_inspect ||= potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLSynSnp'))
  end

  def find_parent_or_croak
    potrubi_bootstrap_mustbe_not_nil_or_croak(parent)
  end

  def call_parent_or_croak(mthName, *mthArgs, &mthBlok)
    find_parent_or_croak.__send__(mthName, *mthArgs, &mthBlok)
  end
  
  def find_delegate_or_croak
    potrubi_bootstrap_mustbe_not_nil_or_croak(delegate)
  end

  def call_delegate_or_croak(mthName, *mthArgs, &mthBlok)
    find_delegate_or_croak.__send__(mthName, *mthArgs, &mthBlok)
  end
  
  def method_missing(mthName, *mthArgs, &mthBlok)
    #(mthName == :to_ary) && (return super)
    (mthName == :to_ary) && super
    eye = :'PotKlsSynSnp::mth_mis'
    eyeTaleME = '>>>>>>>>>>>>>>>>>>> SNIPPET MM'
    eyeTaleMX = '<<<<<<<<<<<<<<<<<<< SNIPPET MM'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTaleME, potrubi_bootstrap_logger_fmt_who_only(mthName: mthName, mthArgs: mthArgs, mthBlok: mthBlok))

    
    mthResult = nil
    #STOPHERESNIPPETMETHODMISSINGENTR

    mthResult = case
                when mthName == :to_ary then super
                when (r = delegate) && r.respond_to?(mthName) then r.__send__(mthName, *mthArgs, &mthBlok)
                else
                  potrubi_bootstrap_missing_exception(mthName, eye, "METHOD MISSING mthName >#{mthName}< mthArgs >#{mthArgs}< not found")
                end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTaleMX, potrubi_bootstrap_logger_fmt_who_only(mthName: mthName, mthArgs: mthArgs, mthBlok: mthBlok, mthResult: mthResult))

    mthResult
  end

  # Snippet Methods
  # ###############

  # def new_snippets(*snippets, &snipBlok)
  #   snippets.map {|s| new_statement(s) }
  # end

  # Call Direct Mapping
  # #####################

  # These are verbs that map directly to the direct
  
  callDirectMap = {
    contracts: nil,
    assign_expression: :new_statement_assign,
    ####assign: nil,
    assign_instance_variable: nil,
    assign_local_variable: nil,
    ###assign_if_not_set: nil,
    name: :set_name,
    eye: :set_eye,
    ################################result: :set_result,
    logger_call: :new_statement_logger_method_call,
    logger_entry: :new_statement_logger_method_entry,
    logger_exit: :new_statement_logger_method_exit,

    #####if_ternary: :new_statement_if_ternary,

    snippet: :new_statements,
    snippets: :new_statements,

    
  }


  callDirectTexts = callDirectMap.map do |srcMth, tgtMth|
    tgtMthNrm = tgtMth || "new_statement_#{srcMth}"
    
    #"def #{srcMth}(*a, &b); add_statements_or_croak(find_direct_or_croak.#{tgtMthNrm}(*a, &b)); end;"
    #"def #{srcMth}(*a, &b); add_synels_or_croak(direct.#{tgtMthNrm}(*a, &b)); end;"
    "def #{srcMth}(*a, &b); add_synels_or_croak(#{tgtMthNrm}(*a, &b)); end;"
    
  end
  
  ###callDirectTexts << "def add_statement(*a, &b); add_statements_or_croak(new_statement(*a, &b)); end;"
  callDirectText = callDirectTexts.flatten.compact.join("\n")
  puts("SNIPPET CALL DIRECT MAP >\n#{callDirectText}")
  module_eval(callDirectText)

  #SUPHEREDELEGATEMAP

  # Passthru to Delegate
  # #####################

  # Delegate must handle
  
  callPassthruMap = {
    set_name: nil,
    set_eye: nil,
    set_result: nil,
    name: :set_name,
    eye: :set_eye,
    result: :set_result,
    set_signature: nil,
    get_signature: nil,
    ###signature: :set_signature,
    generic_signature: :set_signature_generic,
    iterator: :iterator_block,
    ####assign_expression: :assign,

    ###snippet: :add_statements,
    ###snippets: :add_statements,
  }

  callPassthruTexts = callPassthruMap.map do |srcMth, tgtMth|
    tgtMthNrm = case tgtMth
                when NilClass then srcMth
                else
                  tgtMth
                end
     "def #{srcMth}(*a, &b); delegate.#{tgtMthNrm}(*a, &b); end;"
  end
  
  callPassthruText = callPassthruTexts.flatten.compact.join("\n")
  puts("CALL PASSTHRU MAP >\n#{callPassthruText}")
  module_eval(callPassthruText)

  #STOPHEREPOSTNEWTOADDMAP

  # Assign Verbs
  # ############

  def assign(assignTarget, assignExpression, *assignArgs, &assignBlok)
    #STOPHERESNIPASSIGNENTR
    # case assignExpression
    # when Symbol then 
    assign_expression(assignTarget, expression(assignExpression, *assignArgs, &assignBlok))
    # else
    #   assign_expression(assignTarget, assignExpression, *assignArgs, &assignBlok)
    # end
    self # fluent
  end

  def zzzassign_expression(*a, &b)
    puts("AGN EXPRE a >#{a}<")
    #add_statement_asign(*a)
    add_synels_or_croak(new_staement_assign(*a))
    STOPHEREASSIGNEXPREENTR
  end
  
  # Other Verbs
  # ###########

  def croak_name(*a, &b)
    set_name(name_builder_method_or_croak(*a, &b))
  end
  
  def getter_name(*a, &b)
    set_name(name_builder_method_getter(*a, &b))
  end

  def setter_name(*a, &b)
    set_name(name_builder_method_setter(*a, &b))
  end

  def getter_eye(*a, &b)
    set_eye(name_builder_eye_getter(*a, &b))
  end
  
  def setter_eye(*a, &b)
    set_eye(name_builder_eye_setter(*a, &b))
  end

  def named_expression(exprName, *a, &b)
    exprMth = "new_statement_#{exprName}"
    expression(__send__(exprMth, *a, &b))
  end
  
  def zzzzzzexpression(*a, &b)
    #new_statement_in_parentheses(*a)
    new_statement(*a)
  end

  def expression(exprName, *a, &b)
    new_statement(maybe_call_specific(self, :new_statement, exprName, *a))
  end

  def instance_variable(*a)
    name_builder_instance_variable(*a)
  end

  def method_name(*a, &b)
    name_builder_method(*a)
  end

  def signature(sigName, *sigArgs)
    maybe_call_specific(delegate, :set_signature, sigName, *sigArgs)
  end
  
  def maybe_call_specific(mthTarget, mthPrefix, mthName, *mthArgs)
    mthMethod = case mthName
    when Symbol then "#{mthPrefix}_#{mthName}"
    else
      nil
    end
    (mthMethod && mthTarget.respond_to?(mthMethod)) ? mthTarget.__send__(mthMethod, *mthArgs) : __send__(mthPrefix, mthName, *mthArgs)
  end      
  
  # Syntax Methods
  # ##############


  def syntax
    eye = :'PotKlsSynSnp::syn'
    eyeTaleME = '>>>>>>>>>>>>>>>>>> SYN SNIP'
    eyeTaleMX = '<<<<<<<<<<<<<<<<<< SYN SNIP'
    ###nameMethod = name
    
    snippetSyns = synels

    ###puts("#{eye} SNIPPETR SYNELS >#{snippetSyns.class}<")

    snippetSyns.raw_debug("#{eye} SNIPPET SYNTAX")
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTaleME, potrubi_bootstrap_logger_fmt_who_only(snippetSyns: snippetSyns))
    
    syntaxSnippets = case
                     when snippetSyns.empty? then nil
                     else

                       braketSnippets = new_braket_snippet
                       
                       braketSnippets.push(###make_syntax_def,
                                           ###make_syntax_eye,
                                           ###statements.map {|s| s.syntax },
                                           snippetSyns,
                                           ###make_syntax_result,
                                           ###make_syntax_end

                                           )
                       
                       braketSnippets.to_s
                       
                     end
    
    puts("#{eye} SYNTAX SNIPPET syntax \n#{syntaxSnippets}")
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTaleMX, potrubi_bootstrap_logger_fmt_who_only(synAli: syntaxSnippets))

    syntaxSnippets
  end


 
  
end

module Potrubi
  class Klass
    module Syntax
      class Snippet < Super
      end
    end
  end
end

Potrubi::Klass::Syntax::Snippet.__send__(:include, instanceMethods)  # Instance Methods

__END__
Potrubi::Klass::Syntax::Snippet.extend(classMethods)  # Class Methods

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

    classMethods = Module.new do

  include Potrubi::Bootstrap
  
  # let the class be able to call new_methiod
  include Potrubi::Klass::Syntax::Mixin::NewMethods
  
end
  def zzzsignature(sigName, *sigArgs)
    case sigName
    when Symbol
      sigMethod = "set_signature_#{sigName}"
      delegate.respond_to?(sigMethod) ? delegate.__send__(sigMethod, *sigArgs) : set_signature(sigName, *sigArgs)
    else
      set_signature(sigName, *sigArgs)
    end
  end
