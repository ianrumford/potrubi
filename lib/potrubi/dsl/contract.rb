
# potrubi contract dsl

# to ease the creation of contracts, accessors, etc in class bodies

# Uses conventions for names etc dedined by (in) contract mixin

#require_relative '../../bootstrap'

requireList = %w(super ../mixin/util)
requireList.each {|r| require_relative "#{r}"}
require "potrubi/klass/syntax/braket"

classContent = Module.new do

  include Potrubi::Bootstrap
  include Potrubi::Mixin::Util

  attr_accessor :key, :value, :spec, :edit, :blok, :key_names, :default

  def assert_self
    eye = 'DSLCtx:assert_self'
    eyeTale = to_s
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale)

    ctxSelf = self
    ctxType = type
    
    case ctxType
    when NilClass then
      potrubi_bootstrap_surprise_exception(ctxType, eye, "self >#{self} ctxType can not be nil")
    else

      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_beg(eye, 'MAKE VERB', eyeTale, "ctxType >#{ctxType}<")

      ctxSpec = spec
      (ctxEdit = edit) && potrubi_boostrap_mustbe_hash_or_croak(ctxEdit, eye)
      (ctxBlok = blok) && potrubi_boostrap_mustbe_proc_or_croak(ctxBlok, eye)

      (ctxBldr = builder) && potrubi_bootstrap_mustbe_module_or_croak(ctxBldr, eye)

      # target for contract
      (ctxTgt = target) && potrubi_bootstrap_mustbe_module_or_croak(ctxTgt, eye)

      # builder_data is the method name in the builder
      
      (ctxBldrMth = builder_data) && potrubi_bootstrap_mustbe_symbol_or_croak(ctxBldrMth, eye)

      ctxDesc = express_or_croak

      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, 'DESC VERB', eyeTale, potrubi_bootstrap_logger_fmt_who(ctxBldrMth: ctxBldrMth, ctxEdit: ctxEdit, ctxSpec: ctxSpec, ctxBlok: ctxBlok, ctxDesc: ctxDesc, ctxTgt: ctxTgt, ctxBldr: ctxBldr))
      
      ctxBldr.__send__(ctxBldrMth, ctxTgt, ctxDesc, ctxSpec, &ctxBlok)
      
      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_fin(eye, 'MADE VERB', eyeTale)
      
    end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale)

    self
  end

  def to_s
    @to_s ||= potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLCtx'),  potrubi_bootstrap_logger_fmt(n: name))
  end
  
  # Find Methods
  # ############
  
  def find_key_type_or_croak
    potrubi_bootstrap_mustbe_not_nil_or_croak(key)
  end

  def find_value_type_or_croak
    potrubi_bootstrap_mustbe_not_nil_or_croak(value)
  end

  # Contract Descriptions
  # #####################
  
  # This *only* makes the immediate (self) contract's description
  
  def make_contract_description_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLCtx::m_ctx_desc'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    contractType = type

    descContract = case contractType
                   when NilClass then nil
                   else
                     contractHandler = case contractType
                                         #when Symbol then find_type_handler_or_default_or_croak(contractType)
                                       when Symbol then find_type_handler_or_croak(contractType)
                                       when String then 'make_contract_description_default_or_croak'
                                       else
                                         potrubi_bootstrap_surprise_exception(contractType, eye, "contractType is what?")
                                       end
                     
                     __send__(contractHandler, descArgs, &descBlok)
                     
                   end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(descContract: descContract, descArgs: descArgs, descBlok: descBlok))

    descContract
    
  end

  # Contract Types
  # ##############

  def type_handlers
    @type_handlers ||=
      begin

        baseHandlers = [:default,
                        # :any,
                        :proc,
                        :enumerator,
                        :string,
                        :symbol,
                        :array,
                        :hash,
                        :fixnum,
                        :file,
                        :directory
                       ].each_with_object({}) {|a, h| h[a] = :default }
        
        baseHandlers.merge(
                           {
                             contract_collection: :contract_collection,
                             contract_2d: :contract_collection,

                             contract_collection_with_nil_values: :contract_collection_with_nil_values,
                             contract_2d_with_nil_values: :contract_collection_with_nil_values,
                             
                             typed_collection: :typed_collection,
                             typed_hash: :typed_collection,

                             typed_collection_with_nil_values: :typed_collection_with_nil_values,
                             #typed_collection_with_nil_values: :typed_collection, # TESTING
                             typed_2d_with_nil_values: :typed_collection_with_nil_values,
                             
                             typed_array: :typed_array,
                             
                             collection_with_keys: :collection_with_keys,
                             hash_with_keys: :collection_with_keys,

                             typed_collection_with_keys: :typed_collection_with_keys,
                             typed_hash_with_keys: :typed_hash_with_keys,
                             
                           }).each_with_object({}) {|(k,v), h| h[k] = "make_contract_description_#{v}_or_croak".to_sym }
      end
  end

  
  # Contract Handlers
  # #################

  def make_contract_description_default_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLCtx::m_ctx_desc_dflt'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    descContract = {name => type}

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, 'CHECK', 'KEY', 'NAME', potrubi_bootstrap_logger_fmt_who(key_name: key_name))

    descContract =
      if (r = key_name) then
        #{name => {edit: {MUSTBE_KEY_NAME: r}}}
        {name => {edit: {MUSTBE_KEY_NAME: r}, other: {type: type, key_name: r}}}
      else
        {name => type}
      end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descContract: descContract, descArgs: descArgs, descBlok: descBlok))

    descContract

  end
  
  def make_contract_description_typed_collection_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLCtx::m_ctx_desc_type_coll'

    keyType = find_key_type_or_croak
    valueType = find_value_type_or_croak

    descContracts = make_contract_description_top_blok_or_croak do | descArgs |
      {name => {spec: :method_mustbe_is_value_typed_collection, edit: {KEY_TYPE: keyType, VALUE_TYPE: valueType}}}
    end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descContracts: descContracts, descArgs: descArgs, descBlok: descBlok))

    descContracts

  end

  def make_contract_description_typed_collection_with_nil_values_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLCtx::m_ctx_desc_type_coll_with_nil_values'

    keyType = find_key_type_or_croak
    valueType = find_value_type_or_croak

    descContracts = make_contract_description_top_blok_or_croak do | descArgs |
      {name => {spec: :method_mustbe_is_value_typed_collection, edit: {KEY_TYPE: keyType, VALUE_TYPE: valueType, VALUE_IS_NIL_RESULT: 'true'}}}
    end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descContracts: descContracts, descArgs: descArgs, descBlok: descBlok))

    descContracts

  end
  
  def make_contract_description_typed_collection_with_keys_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLCtx::m_ctx_desc_type_coll_with_keys'

    keyType = find_key_type_or_croak
    valueType = find_value_type_or_croak
    keyNames = key_names
    
    descContracts = make_contract_description_top_blok_or_croak do | descArgs |
      {name => {spec: :method_mustbe_is_value_typed_collection_with_keys, edit: {KEY_TYPE: keyType, VALUE_TYPE: valueType, KEY_NAMES: keyNames}}}
    end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descContracts: descContracts, descArgs: descArgs, descBlok: descBlok))

    descContracts

  end
  
  def make_contract_description_contract_collection_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLCtx::m_ctx_desc_ctx_coll'

    descContracts = make_contract_description_is_value_collection_or_croak(descArgs) do | key, contract, braKet |

      # any explicit key?
      keyName = potrubi_util_find_hash_keys(contract, :other, :key_name)
      
      braKet.new_statement.push(
                                '((r = testValue[:',
                                keyName || key,
                                ']).nil? ? false : ',
                                'is_value_',
                                key,
                                '?(r))',
                                ' && '
                                )


    end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descContracts: descContracts, descArgs: descArgs, descBlok: descBlok))
    
    descContracts

  end
  
  def make_contract_description_contract_collection_with_nil_values_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLCtx::m_ctx_desc_ctx_coll_with_nil_values'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    descContracts = make_contract_description_is_value_collection_or_croak(descArgs) do | key, contract, braKet |

      # any explcit key name?
      #keyName = potrubi_util_find_hash_keys_or_croak(contract, :other, :key_name)
      keyName = potrubi_util_find_hash_keys(contract, :other, :key_name)

      r = braKet.new_statement.push(
                                    '((r = testValue[:',
                                    keyName || key,
                                    ']).nil? ? true : ',
                                    'is_value_',
                                    key,
                                    '?(r))',
                                    ' && '
                                    )

      r
    end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(descContracts: descContracts, descArgs: descArgs, descBlok: descBlok))
    
    descContracts

  end

  def make_contract_description_collection_with_keys_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLCtx::m_ctx_desc_coll_w_keys'

    keyNames = potrubi_bootstrap_mustbe_not_nil_or_croak(key_names, eye)
    
    descContracts = make_contract_description_top_blok_or_croak do | descArgs |
      {name => {spec: :method_mustbe_is_value_collection_with_keys, edit: {KEY_NAMES: keyNames}}}
    end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descContracts: descContracts, descArgs: descArgs, descBlok: descBlok))

    descContracts

  end

  def make_contract_description_typed_array_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLCtx::m_ctx_desc_typed_array'

    valueType = potrubi_bootstrap_mustbe_not_nil_or_croak(value, eye)
    
    descContracts = make_contract_description_top_blok_or_croak do | descArgs |
      {name => {spec: :method_mustbe_is_value_typed_array, edit: {VALUE_TYPE: valueType}}}
    end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descContracts: descContracts, descArgs: descArgs, descBlok: descBlok))

    descContracts

  end
  
  # Contract Handler Support Methods
  # ################################

  def make_contract_description_top_blok_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLCtx::m_ctx_desc_top_blok'

    descName = name
    
    potrubi_bootstrap_mustbe_proc_or_croak(descBlok, eye)
    
    descContract = descBlok.call(descArgs)

    $DEBUG_POTRUBI_BOOTSTRAP && show_verb_expression_or_croak(descContract, "TOP BLOK descName >#{descName}< DESC CONTRACTS")
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descContract: descContract, descArgs: descArgs, descBlok: descBlok))

    descContract

  end
  

  def make_contract_description_is_value_collection_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLCtx::m_ctx_desc_is_value_col'
    
    descsImmedSubverbs = find_subverbs_expression_or_croak
    
    descContract = make_contract_description_is_value_method_or_croak(name, descsImmedSubverbs, &descBlok)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descContract: descContract, descArgs: descArgs, descBlok: descBlok))
    
    descContract

  end

  # Takes name of the is_value method, the subcontracts,
  # and build an is_value method to test all the values
  # Note the test is buildt by the provided blok
  
  def make_contract_description_is_value_method_or_croak(descName, descCtxs, &descBlok)
    eye = :'DSLCtx::m_ctx_desc_is_value_mth'
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descName: descName, descCtxs: descCtxs, descBlok: descBlok))

    potrubi_bootstrap_mustbe_hash_or_croak(descCtxs, eye, 'descCts failed contract')
    potrubi_bootstrap_mustbe_proc_or_croak(descBlok, eye)
    
    braketKls = Potrubi::Klass::Syntax::Braket

    braketMethod = braketKls.new_method

    braketDefBeg = braketKls.new_statement.push('def is_value_', descName, '?(testValue)')

    braketCollection = braketKls.new_statement.push('testValue.is_a?(Hash) &&')

    braketItems = descCtxs.map { | key, contract | descBlok.call(key, contract, braketKls) }

    braketResult = braketKls.new_statement.push('testValue')

    braketDefEnd = braketKls.new_statement.push('end')
    
    braketMethod.push(braketDefBeg,
                      braketCollection,
                      braketItems,
                      braketResult,
                      braketDefEnd,
                      )
    
    descText = braketMethod.to_s

    descContract = {descName => {spec: descText}}

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(descName: descName, descContract: descContract))

    potrubi_bootstrap_mustbe_hash_or_croak(descContract, eye)

  end
  
end

module Potrubi
  class DSL
    class Contract < Potrubi::DSL::Super
    end
  end
end

Potrubi::DSL::Contract.__send__(:include, classContent)  # Instance Methods

__END__

Potrubi::DSL::Contract.extend(classMethods)  # Class Methods

__END__

























# def make_contract_descriptions_or_croak(descArgs=nil, &descBlok)
#   eye = :'DSLCtx::m_ctx_descs'

#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, to_s, potrubi_bootstrap_logger_fmt_who(subverbs: get_subverbs.size, descArgs: descArgs, descBlok: descBlok))

#   ###STOPHEREMAKECONTRACTDESCSENTR

#   descSubverbs = nil
#   #show_subverbs(eye, "MAKE SUBCTX DESCS #{to_s}")
#   #descsSubverbs = make_subcontracts_descriptions_or_croak(descArgs, &descBlok)
#   #show_subverbs(eye, "MADE SUBCTX DESCS #{to_s}")

#   #descContract = type.nil? ? nil : make_contract_description_or_croak(descArgs, &descBlok)
#   descContracts = case type
#                   when NilClass then find_subverbs_description_or_croak(descArgs, &descBlok)
#                   else
#                     find_contract_description_or_croak(descArgs, &descBlok)
#                   end


#   show_verb_expression_or_croak(descContracts, eye, "M CTX DESCS descName >#{name}<")
  
#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, to_s, potrubi_bootstrap_logger_fmt_who(descContracts: descContracts, descArgs: descArgs, descBlok: descBlok))

#   potrubi_bootstrap_mustbe_hash_or_croak(descContracts, eye)

#   #STOPHEREMAKECONTRACTDESCSEXIT
# end
# def make_subcontracts_descriptions_or_croak(descArgs=nil, &descBlok)
#   eye = :'DSLCtx::m_subctxs_descs'

#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, to_s, potrubi_bootstrap_logger_fmt_who(subverbs: get_subverbs.size, descArgs: descArgs, descBlok: descBlok))

#   ###STOPHEREMAKECONTRACTDESCSENTR

#   #descSubverbs = nil
#   #show_subverbs(eye, "MAKE SUBCTX DESCS #{to_s}")
  
#   descsSubverbs = case
#                   when has_subverbs? then get_subverbs.map {|c| c.make_contract_descriptions_or_croak(descArgs, &descBlok) }.flatten.compact
#                   else
#                     nil
#                   end
  
#   #show_subverbs(eye, "MADE SUBCTX DESCS #{to_s}")

#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, to_s, potrubi_bootstrap_logger_fmt_who(descsSubverbs: descsSubverbs, descArgs: descArgs, descBlok: descBlok))

#   descsSubverbs && potrubi_bootstrap_mustbe_array_or_croak(descsSubverbs, eye)

#   #STOPHEREMAKECONTRACTDESCSEXIT
# end

# # merge the individual contract descs into a single hash
# # BUT check for duplicate keys

# def reduce_contract_descriptions_or_croak(*descContracts, &descBlok)
#   eye = :'DSLCtx::rdc_ctx_descs'
#   descReduce = potrubi_util_reduce_hashes_or_croak(*descContracts) {|k, oldV, newV| potrubi_bootstrap_duplicate_exception(k, eye, "subcontract name >#{k} seen twice") }
#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, to_s, potrubi_bootstrap_logger_fmt_who(descReduce: descReduce, descContracts: descContracts, descBlok: descBlok))
#   descReduce && potrubi_bootstrap_mustbe_hash_or_croak(descReduce)
# end

# # merge the individual contract into a single hash

# def make_subcontracts_description_or_croak(descArgs=nil, &descBlok)
#   eye = :'DSLCtx::m_subctxs_desc'
#   r =  make_subcontracts_descriptions_or_croak(descArgs, &descBlok)
#   descSubverbs = reduce_contract_descriptions_or_croak(*r)
#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, to_s, potrubi_bootstrap_logger_fmt_who(descSubverbs: descSubverbs, descArgs: descArgs, descBlok: descBlok))
#   descSubverbs
# end


# # Diagnostics
# # ###########


# def show(*tellTales)
#   eye = :show

#   #if $DEBUG_POTRUBI_BOOTSTRAP then
#   ##cummulative_tellTale = potrubi_bootstrap_logger_fmt(*tellTales, potrubi_bootstrap_logger_fmt(name: name, type: type))
#   cummulative_tellTale = potrubi_bootstrap_logger_fmt(*tellTales, to_s)
#   case
#   when has_subverbs? then show_subverbs(cummulative_tellTale)
#   else
#     potrubi_bootstrap_logger_ms(eye, cummulative_tellTale)
#   end
#   #end
  
#   self
  
# end


# classMethods = Module.new do

#   def new_contract(dslArgs=nil, &dslBlok) # class method
#     eye = :'DSLCtx::KLS new_cxt'
#     #potrubi_bootstrap_mustbe_symbol_or_croak(dslAttr, eye, "dslAttr is what?")
#     newContract = self.new(dslArgs, &dslBlok)
#     #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(newContract: newContract), potrubi_bootstrap_logger_fmt_who(dslAttr: dslAttr, dslArgs: dslArgsNrm, dslBlok: dslBlok))
#     newContract
#     ###STOPHERENEWCONTRACTEXIT
#   end
# end






# def make_contract_description_accessor_or_croak(descArgs=nil, &descBlok)
#   eye = :'DSLCtx::m_ctx_desc_acc'

#   #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

#   #descContract = {name => type}
#   #descContract = {name => {edit: {ACCESSOR_DEFAULT: 9099}}}

#   descContract = case
#                  when (descDefault = default) then
#                    #descDefault = descArgs.default
#                    descDefaultText = case descDefault
#                                      when NilClass then 'nil'
#                                      when String then "'#{descDefault}'" # need quotes
#                                      when Symbol then ":#{descDefault}" # need to supply :
#                                      else
#                                        descDefault.to_s
#                                      end
#                    {name => {edit: {ACCESSOR_DEFAULT: descDefaultText}, spec: type}}
                   
#                  else
#                    {name => type}
#                  end

  
#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descContract: descContract, descArgs: descArgs, descBlok: descBlok))

#   descContract
#   #STOPHEREMAKECTXDESCACCEXIT
# end












































# # Initialization
# # ##############

# def initialize(dslArgs=nil, &dslBlok)
#   eye = :'DSLCtx::i'

#   dslAttr = 'wantbeused'
  
#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(dslArgs: dslArgs, dslBlok: dslBlok))

#   #STOPHEREINITDSL

#   case dslArgs
#   when NilClass then nil
#   when Hash then potrubi_bootstrap_mustbe_hash_or_croak(dslArgs, eye).each {|k, v| __send__("#{k}=", v) }
#     ###when Symbol then  self.type = dslArgs # syntax sugar for the contract type
#   else
#     potrubi_bootstrap_surpirse_exception(dslArgs, eye, "dslArgs is what?")
#   end
  
#   Kernel.block_given? && instance_eval(&dslBlok)

#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(subverbs: get_subverbs.size, dslArgs: dslArgs, dslBlok: dslBlok))
  
# end




# def zzznew_subcontract(dslAttr, dslArgsNom=nil, &dslBlok)
#   eye = :'DSLCtx::new_sub_cxt'
#   #potrubi_bootstrap_mustbe_symbol_or_croak(dslAttr, eye, "dslAttr is what?")
#   dslArgsNrm = case dslArgsNom
#                when NilClass, Hash then dslArgsNom
#                when Symbol then {type: dslArgsNom}  # syntax sugar for type
#                else
#                  potrubi_bootstrap_surprise_exception(dslArgsNom, eye, "dslArgsNom is what?")
#                end
#   subContract = self.class.new_contract(potrubi_util_merge_hashes_or_croak(dslArgsNrm, {name: dslAttr}), &dslBlok)
  
#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(subContract: subContract), potrubi_bootstrap_logger_fmt_who(dslAttr: dslAttr, dslArgs: dslArgsNrm, dslBlok: dslBlok))
  
#   subContract
# end

# def xxxaccessor_with_contract(dslAttr, dslArgs=nil, &dslBlok)
#   eye = :'DSLCtx::acc_w_ctx'

#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(dslAttr: dslAttr, dslArgs: dslArgs, dslBlok: dslBlok))

#   dslDefs = {variant: :accessor, name: dslAttr, spec: :package_accessor_with_contract}

#   newContract = make_and_add_new_contract(dslDefs, dslArgs, &dslBlok)
  
#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(newContract: newContract, dslAttr: dslAttr, dslArgs: dslArgs, dslBlok: dslBlok))

#   newContract
  
# end

# def zzzassert
#   eye = :'DSLCtx::assert'
#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(self: self))
#   assert_self
#   subverbs.each {|v| v.assert}

#   dslVerbs = dslVerb.subverbs

#   #puts("\n\n\n#{eye} MADE VERBS dslVerbs >#{dslVerbs}<")
#   dslVerb.flatten.each_with_index {|v, i| puts("\n#{eye} INST VERBS >#{i}<  >#{v.class}< >#{v}<") }


#   #STOPHEREMADECTXS

#   dslVerb.flatten.each_with_index do | ctx, ndx |

#     $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_beg(eye, 'MAKE VERB', potrubi_bootstrap_logger_fmt_who(ndx: ndx, ctx: ctx))

#     (ctxVariant = ctx.variant) &&
#       begin
        
#         potrubi_bootstrap_mustbe_symbol_or_croak(ctxVariant, eye)

#         ctxSpec = ctx.spec
#         (ctxEdit = ctx.edit) && potrubi_boostrap_mustbe_hash_or_croak(ctxEdit, eye)
#         (ctxBlok = ctx.blok) && potrubi_boostrap_mustbe_proc_or_croak(ctxBlok, eye)

#         ctxRecipe = "recipe_variant_#{ctxVariant}"

#         ctxDesc = ctx.make_verb_description_or_croak

#         $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, 'DESC VERB', potrubi_bootstrap_logger_fmt_who(ctxRecipe: ctxRecipe, ctxEdit: ctxEdit, ctxSpec: ctxSpec, ctxBlok: ctxBlok, ctxDesc: ctxDesc))
#         __send__(ctxRecipe, dslTarget, ctxDesc, ctxSpec, &ctxBlok)

#       end
    
#     $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_fin(eye, 'MADE VERB', potrubi_bootstrap_logger_fmt_who(ndx: ndx, ctx: ctx))

#   end

  
#   $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(self: self))
#   self
# end
