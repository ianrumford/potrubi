
# potrubi dsl super

# to ease the creation of verbs, accessors, etc in class bodies

# Uses conventions for names etc dedined by (in) verb mixin

requireList = %w(mixin/util)
requireList.each {|r| require_relative "../#{r}"}

classMethods = Module.new do

  include Potrubi::Bootstrap
  include Potrubi::Mixin::Util
  
  def default_new_verb_args
    @default_new_verb_args ||= {verb: :Super}
  end
  
  def new_verb(*dslArgs, &dslBlok) # class method
    eye = :'DSLSpr::n_verb'
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(dslArgs: dslArgs, dslBlok: dslBlok))

    dslArgsWork = potrubi_util_merge_hashes_or_croak(default_new_verb_args, dslArgs.flatten.compact)

    dslVerb = potrubi_bootstrap_mustbe_symbol_or_croak(dslArgsWork && dslArgsWork[:verb], eye).to_s.downcase.to_sym

    dslClass = case dslVerb
               when :super then Potrubi::DSL::Super
               when :contract then
                 require_relative("contract")
                 Potrubi::DSL::Contract
               when :accessor then
                 require_relative('accessor')
                 Potrubi::DSL::Accessor
               when :cache_2d then 
                 # IS 2D, etc
                 require_relative('cache_2d')
                 Potrubi::DSL::Cache2D
               else
                 potrubi_bootstrap_surprise_exception(dslVerb, eye, "dslVerb is what?")
               end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, potrubi_bootstrap_logger_fmt_who(dslVerb: dslVerb, dslClass: dslClass, dslArgsWork: dslArgsWork))

    newVerb = dslClass.new(dslArgsWork, &dslBlok)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(newVerb: newVerb), potrubi_bootstrap_logger_fmt_who(dslArgs: dslArgs, dslBlok: dslBlok))

    newVerb

  end

  def contract_defaults
    @contract_defaults ||= {
      verb: :contract,
      builder: Potrubi::Mixin::Contract::Recipes,
      builder_data: :recipe_variant_mustbe,
      spec: :package_mustbe,
    }
  end

  def accessor_defaults
    @accessor_defaults ||= {
      verb: :accessor,
      type: :accessor,
      builder: Potrubi::Mixin::Contract::Recipes,
      builder_data: :recipe_variant_accessor,
      spec: :package_accessor,
    }
  end

  def cache_defaults
    @cache_defaults ||= {
      verb: :cache_2d,  # SHOULD BE 'CACHE' BUT LEAVE FOR NOW
      type: :d2,
    }
  end
  
end

instanceMethods = Module.new do

  include Potrubi::Bootstrap
  include Potrubi::Mixin::Util

  attr_accessor :name, :type, :target, :verb, :builder, :builder_data

  attr_accessor :key_name
  
  def to_s
    @to_s ||= potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLSpr'),  potrubi_bootstrap_logger_fmt(n: name))
  end
  
  # Initialization
  # ##############
  
  def initialize(dslArgs=nil, &dslBlok)
    eye = :'DSLSpr::i'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(dslArgs: dslArgs, dslBlok: dslBlok))

    case dslArgs
    when NilClass then nil
    when Hash then potrubi_util_set_attributes_or_croak(self, dslArgs)
    else
      potrubi_bootstrap_surprise_exception(dslArgs, eye, "dslArgs is what?")
    end
    
    Kernel.block_given? && instance_eval(&dslBlok)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(subVerbs: get_subverbs.size, dslArgs: dslArgs, dslBlok: dslBlok))

  end

  # DSL Verbs
  # #########

  # These are the "verbs" that can appear in a dsl statement
  # e.g. contract, accessor

  def contract(dslAttr, dslArgs=nil, &dslBlok)
    eye = :'DSLSpr::ctx'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(dslAttr: dslAttr, dslArgs: dslArgs, dslBlok: dslBlok))

    require 'potrubi/mixin/contract/recipes'

    dslArgsNrm = normalise_verb_args_or_croak(dslArgs)

    dslArgsHere = {name: dslAttr, target: target}
    
    dslArgsDefs = self.class.contract_defaults

    newVerb = make_and_add_new_verb(dslArgsDefs, dslArgsHere, dslArgsNrm, &dslBlok)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(newVerb: newVerb, dslAttr: dslAttr, dslArgs: dslArgs, dslBlok: dslBlok))

    newVerb
    
  end

  def accessor(dslAttr, dslArgs=nil, &dslBlok)
    eye = :'DSLSpr::acc'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(dslAttr: dslAttr, dslArgs: dslArgs, dslBlok: dslBlok))

    require 'potrubi/mixin/contract/recipes'
    
    dslArgsNrm = normalise_verb_args_or_croak(dslArgs)

    dslArgsHere = {name: dslAttr, target: target}
    
    # If no arguments then simple accessor

    dslArgsBase = self.class.accessor_defaults

    dslArgsNoCtx = dslArgsBase
    dslArgsWithCtx = dslArgsBase.merge(spec: :package_accessor_with_contract)
    
    newVerbs =
      case dslArgsNrm
      when NilClass then make_and_add_new_verb(dslArgsNoCtx, dslArgsHere, dslArgsNrm, &dslBlok) # default is no contract
        
      when Hash then
        case
        when dslArgsNrm.has_key?(:type)

          # get rid of accessor-specifc keys
          ctxDeselectAttrs = [:default]
          ctxArgs = dslArgsNrm.select{|k,v| ! ctxDeselectAttrs.include?(k) }
          
          # make two verbs:  simple accessor, and the contract
          [make_and_add_new_verb(dslArgsWithCtx, dslArgsHere, dslArgsNrm), # contract accessor - note NO block
           contract(dslAttr, ctxArgs, &dslBlok) # ... and the contract WITH the block
          ]

        else
          make_and_add_new_verb(dslArgsNoCtx, dslArgsHere, dslArgsNrm, &dslBlok) # default is no contract
        end
        
      else
        #{variant: :accessor, name: dslAttr, spec: :package_accessor_with_verb}
        potrubi_bootstrap_surprise_exception(dslArgs, eye, "dslArgs is what?")
      end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(newVerbs: newVerbs, dslAttr: dslAttr, dslArgs: dslArgs, dslBlok: dslBlok))

    newVerbs
    
  end

  def cache(dslName, dslArgs=nil, &dslBlok)
    eye = :'DSLSpr::cache'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(dslName: dslName, dslArgs: dslArgs, dslBlok: dslBlok))

    dslArgsNrm = normalise_verb_args_or_croak(dslArgs)

    dslArgsHere = {name: dslName, target: target}
    
    dslArgsDefs = self.class.cache_defaults

    newVerb = make_and_add_new_verb(dslDefs, dslArgsHere, dslArgsNrm, &dslBlok)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(newVerb: newVerb, dslName: dslName, dslArgs: dslArgs, dslBlok: dslBlok))

    newVerb
    
  end
  
  # Verb Assertion - will be overridden likely
  # ##############

  # Verbs assert themselves by "executing" their expressions
  # What execution means its up to the type (class) of verb

  # e.g. for a contract verb, "execution" is the creation
  # of the contract's  methods

  def assert_self_first
    eye = :'DSLSpr::assert_self_first'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(self: self))
    assert_self
    subverbs.each {|v| v.assert}
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(self: self))
    self
  end

  def assert_self_last
    eye = :'DSLSpr::assert_self_last'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(self: self))
    subverbs.each {|v| v.assert}
    assert_self
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(self: self))
    self
  end

  def assert_subverbs
    eye = :'DSLSpr::assert_subverbs'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(self: self))
    subverbs.each {|v| v.assert}
    assert_self
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(self: self))
    self
  end
  
  # just express - likely overide
  def assert_self
    eye = :'DSLSpr::assert_self'
    exprVerb = express
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(self: self, exprVerb: exprVerb))
    exprVerb
  end
  alias_method :assert_self_only, :assert_self

  # default is subverbs first, then self
  alias_method :assert, :assert_self_last

  # Verb Expression
  # ###############

  # Verbs express themselves by calling the handler for their type

  # the expression of a e.g. contract verb is the description
  # of the contract e.g. {edit: etc spec: :package_mustbe}

  # note expression is *only* for the immediate verb; not its subverbs
  # c.g. assertion which descends the whole subverb tree
  
  # does nothing - override likely
  #def express_or_croak(*a, &b)
  #  nil
  #end

  def express_or_croak(exprArgs=nil, &exprBlok)
    eye = :'DSLSpr::expr'
    eyeTale = to_s

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, potrubi_bootstrap_logger_fmt_who(exprArgs: exprArgs, exprBlok: exprBlok))

    typeVerb = type

    exprVerb = case typeVerb
               when NilClass then nil
               else
                 verbHndl = find_type_handler_or_default_or_croak(typeVerb)

                 $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, 'CALLING VERB HANDLER', potrubi_bootstrap_logger_fmt_who(verbHndl: verbHndl, exprArgs: exprArgs, exprBlok: exprBlok))

                 __send__(verbHndl, exprArgs, &exprBlok)
                 
               end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, potrubi_bootstrap_logger_fmt_who(exprVerb: exprVerb, exprArgs: exprArgs, exprBlok: exprBlok))

    exprVerb
    
  end
  alias_method :express, :express_or_croak

  def find_expression_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLSpr::f_expr'
    exprVerb = (@verb_expression ||= express_or_croak(descArgs, &descBlok))
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(exprVerb: exprVerb), potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))
    exprVerb
  end

  # produces an array on one k-v pair hashes; one for each subverb
  
  def express_subverbs_or_croak(exprArgs=nil, &exprBlok)
    eye = :'DSLCtx::expr_subverbs'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, to_s, potrubi_bootstrap_logger_fmt_who(subverbs: get_subverbs.size, exprArgs: exprArgs, exprBlok: exprBlok))

    exprsSubverbs = case
                    when has_subverbs? then get_subverbs.map {|c| c.express_or_croak(exprArgs, &exprBlok) }.flatten.compact
                    else
                      nil
                    end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, to_s, potrubi_bootstrap_logger_fmt_who(exprsSubverbs: exprsSubverbs, exprArgs: exprArgs, exprBlok: exprBlok))

    exprsSubverbs && potrubi_bootstrap_mustbe_array_or_croak(exprsSubverbs, eye)

  end
  
  def find_subverbs_expressions_or_croak(exprArgs=nil, &exprBlok)
    eye = :'DSLSpr::f_subverbs_expr'
    exprSubverbs = (@subverbs_expression ||= express_subverbs_or_croak(exprArgs, &exprBlok))
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(exprSubverbs: exprSubverbs), potrubi_bootstrap_logger_fmt_who(exprArgs: exprArgs, exprBlok: exprBlok))
    exprSubverbs
  end

  # reduce / merge the individual verb expressions into a single hash
  
  def find_subverbs_expression_or_croak(exprArgs=nil, &exprBlok)
    eye = :'DSLSpr::f_subverbs_expr'
    r =  express_subverbs_or_croak(exprArgs, &exprBlok)
    exprSubverbs = reduce_verb_expressions_or_croak(*r)
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, to_s, potrubi_bootstrap_logger_fmt_who(exprSubverbs: exprSubverbs, exprArgs: exprArgs, exprBlok: exprBlok))
    exprSubverbs
  end
  
  # reduce / merge the individual verb expressions into a single hash
  # BUT check for duplicate keys
  
  def reduce_verb_expressions_or_croak(*exprVerbs, &exprBlok)
    eye = :'DSLSpr::rdc_verb_exprs'
    exprReduce = potrubi_util_reduce_hashes_or_croak(*exprVerbs) {|k, oldV, newV| potrubi_bootstrap_duplicate_exception(k, eye, "subverb name >#{k} seen twice") }
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, to_s, potrubi_bootstrap_logger_fmt_who(exprReduce: exprReduce, exprVerbs: exprVerbs, exprBlok: exprBlok))
    exprReduce && potrubi_bootstrap_mustbe_hash_or_croak(exprReduce)
  end



  # Verb Collections Administration
  # ###############################
  
  def has_subverbs?
    ! get_subverbs.empty?
  end
  
  def subverbs
    @subverbs ||= []
  end

  def flatten
    [self, subverbs.map {|c| c.flatten }].flatten.compact
  end
  
  def subverbs=(subVerbs)
    @subverbs = potrubi_bootstrap_mustbe_array_or_croak(subVerbs)
  end

  alias_method :get_subverbs, :subverbs
  alias_method :set_subverbs, :'subverbs='
  
  def add_subverbs(*addVerbs)
    eye = :'DSLSpr::a_sub_verbs'
    r = get_subverbs.concat(addVerbs.flatten.compact)  # concat updates self
    r =  get_subverbs
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt(addVerbs: addVerbs), potrubi_bootstrap_logger_fmt(subVerbs: r))
    r
  end

  def make_and_add_new_verb(*dslArgs, &dslBlok)
    eye = :'DSLSpr::m_and_a_n_verb'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(dslArgs: dslArgs, dslBlok: dslBlok))

    dslArgsNrm = potrubi_util_reduce_hashes_or_croak(*dslArgs)
    
    newVerb = self.class.new_verb(dslArgsNrm, &dslBlok)
    
    add_subverbs(newVerb)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(newVerb: newVerb, dslArgsNrm: dslArgsNrm, dslArgs: dslArgs, dslBlok: dslBlok))

    newVerb
    
  end

  def normalise_verb_args_or_croak(verbArgsNom)
    eye = :'DLSSpr::nrm_verb_args'
    verbArgsNrm = case verbArgsNom
                  when NilClass then nil
                  when Symbol, String then {type: verbArgsNom}
                  when Hash then verbArgsNom
                  else
                    potrubi_bootstrap_surprise_exception(verbArgsNom, eye, "verbArgsNom is what?")
                  end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(verbArgsNrm: verbArgsNrm, verbArgsNomNrm: verbArgsNom))

    verbArgsNrm

  end

  def find_subverb_names
    get_subverbs.map {|c| c.name }
  end
  
  def find_subverb_types
    get_subverbs.map {|c| c.type }.uniq
  end

  # could be overriden
  def find_type_handler_or_croak(verbType, verbTypeHandlers=nil)
    eye = :'DSLSpr::f_type_hndl'

    vTH = potrubi_bootstrap_mustbe_hash_or_croak(verbTypeHandlers || type_handlers)

    typeHndl = vTH.has_key?(verbType) ? vTH[verbType] : potrubi_bootstrap_missing_exception(verbType, :f_ctx_hndl, "verbType >#{verbType.class}< >#{verbType}< not known in vTH >#{vTH.class}<")

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(verbType: verbType), potrubi_bootstrap_logger_fmt_who(typeHndl: typeHndl))

    typeHndl
  end

  def find_type_handler_or_default_or_croak(typeType)
    begin
      find_type_handler_or_croak(typeType)
    rescue
      find_type_handler_or_croak(:default)
    end
  end

  def find_subverbs_key_type_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLSpr::f_subctxs_key_type'

    keyType = case
              when (r = key) then r
              else # find key type from the subverbs
                descSubverbs = find_subverbs_expression_or_croak(descArgs, &descBlok)
                keyTypes = descSubverbs.map {|(k,v)| k.class}.uniq
                if keyTypes.size == 1 then
                  keyTypes.first.name.downcase.to_sym
                else
                  :any # no consistency
                end
                
              end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(keyType: keyType), potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))
    
    keyType
  end


  # Diagnostics
  # ###########

  def show(*tellTales)
    eye = :show

    cummulative_tellTale = potrubi_bootstrap_logger_fmt(*tellTales, to_s)
    case
    when has_subverbs? then show_subverbs(cummulative_tellTale)
    else
      potrubi_bootstrap_logger_ms(eye, cummulative_tellTale)
    end
    
    self
    
  end
  
  def show_subverbs(*tellTales)
    has_subverbs? &&
      begin
        cummulative_tellTale = potrubi_bootstrap_logger_fmt(*tellTales)
        get_subverbs.each_with_index {|c, i| c.show(cummulative_tellTale, "index >#{i}<") }
      end
    self
  end
  
  def show_verb_expression_or_croak(descVerb, *tellTales)
    eye = :'DSLSpr::show_verb_expr'
    potrubi_bootstrap_mustbe_hash_or_croak(descVerb)
    descVerb.each.with_index {|(k,v), i| potrubi_bootstrap_logger_ca(eye, *tellTales, "index >#{i}<", potrubi_bootstrap_logger_fmt_who(k: k),  potrubi_bootstrap_logger_fmt_who(v: v))}
    self
  end
  
end

module Potrubi
  class DSL
    class Super
    end
  end
end

Potrubi::DSL::Super.__send__(:include, instanceMethods)  # Instance Methods
Potrubi::DSL::Super.extend(classMethods)  # CLass Methods

__END__
