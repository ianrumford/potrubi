
# potrubi contract recipes

# to ease the creation of contracts, accessors, etc in class bodies

#  These are *mixin* ('class') methods; not instance ones

# Uses conventions for names etc dedined by (in) contract mixin

require_relative '../bootstrap'

requireList = %w(contract util)
requireList.each {|r| require_relative "#{r}"}

mixinContent = Module.new do

  include Potrubi::Bootstrap
  include Potrubi::Mixin::Util
  
  def standard_accessor_edit(k, v)
    {ACCESSOR_NAME: k, ACCESSOR_CONTRACT: k}
  end

  def standard_mustbe_edit(k, v)
    {MUSTBE_NAME: k, MUSTBE_SPEC: k}
  end

  # convenience methods
  
  def merge_edits(*edits)
    Potrubi::Mixin::Dynamic.dynamic_merge_edits(*edits)
  end

  def merge_specs(*specs)
    specs.flatten
  end

  def merge_spec_and_edit(spec, edit)
    { edit: edit, spec: spec}
  end
  
  # This method is peculair to accessors & mustbes
  # not general purpose as e.g. hash treatment makes assumptions
  
  def standard_case_statement(k, v, s, edit, spec)
    eye = :'rcp_std_case'
    r = case v
        when Symbol then  merge_spec_and_edit(spec, merge_edits(edit, {IS_VALUE_TEST: "testValue.is_a?(#{v.to_s.capitalize})"}))
        when Class, String then merge_spec_and_edit(spec, merge_edits(edit, {IS_VALUE_TEST: "testValue.is_a?(#{v})"}))
        when NilClass then  merge_spec_and_edit(spec, merge_edits(edit, {IS_VALUE_TEST: 'testValue'}))
        when Array then v # dynamic_define_methods will parse
        when Proc then
          [ merge_spec_and_edit(spec, merge_edits(edit, {IS_VALUE_TEST: 'false'})), # error on default isValueText
           {name: "is_value_#{k}?", spec: v}, # ... but override is_value method
          ]
        when Hash then merge_spec_and_edit(merge_specs([spec, v[:spec]]), merge_edits(edit,  {IS_VALUE_TEST: 'false'}, v[:edit]))
        else
          potrubi_bootstrap_surprise_exception(v, eye, "accessor name >#{k}< spec not expected")
        end
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(k: k, v: v, edit: edit), potrubi_bootstrap_logger_fmt_who(spec: spec), potrubi_bootstrap_logger_fmt_who(r: r))
    r
    #STOPCASEEXIT
  end

  def standard_accessor_recipe_block(s) # returns a lambda
    ->(k, v) {
      edit = standard_accessor_edit(k, v)
      ###spec = {spec: s}
      spec = s
      r = standard_case_statement(k, v, s, edit, spec)
      #puts("\n\n\nACCE RCP BLOK r >#{r}<\n\n\n")
      r
      #STOPACCEBLOK
    }
  end

  def standard_mustbe_recipe_block(s) # returns a lambda
    ->(k, v) {
      edit = standard_mustbe_edit(k, v)
      ###spec = {spec: s}
      spec = s
      r = standard_case_statement(k, v, s, edit, spec)
      #puts("\n\n\nMUSTBE RCP BLOK r >#{r}<")
      r
    }
  end
  

  def resolve_recipe_texts(*recipeTexts)
    eye = :'rslv_rcp_texts'

    utilityText = Potrubi::Mixin::Contract::CONTRACT_TEXTS
    
    resolvedTexts = recipeTexts.flatten.map do  | recipeText |
      puts("recipeText >#{recipeText.class}< >#{recipeText}<")
      case recipeText
      when Symbol then utilityText[recipeText]
      when Proc then recipeText
      else
        potrubi_bootstrap_surprise_exception(recipeText, eye, "recipeText is what?")
        ###recipeText
      end
    end

    resolvedTexts
    
  end
  def resolve_recipe_texts(*recipeTexts)
    recipeTexts.flatten
  end
  

  def recipe_accessors(attrTarget, attrDefs, *attrTexts, &attrBlok)
    eye = :'rcp_accessors'

    ###STOPHEREACCS
    
    #puts("K0")
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(attrTarget: attrTarget, attrDefs: attrDefs, attrTexts: attrTexts))

    #puts("K1")
    
    #textDefs = resolve_recipe_texts(attrTexts)
    textDefs = resolve_recipe_texts(attrTexts.empty? ? :package_accessor_with_contract : attrTexts) # default is contract accessor

    #puts("TEXT DEFS >#{textDefs.class}< >#{textDefs}<")

    procBlok = Kernel.block_given? ? attrBlok : standard_accessor_recipe_block(textDefs)
    
    Potrubi::Mixin::Dynamic.dynamic_define_methods(attrTarget, attrDefs, &procBlok)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(attrTarget: attrTarget, attrDefs: attrDefs, attrTexts: attrTexts))

    self

    ##STOPHEREACCSEXIT
  end

  def recipe_mustbes(attrTarget, attrDefs, *attrTexts, &attrBlok)
    eye = :'rcp_mustbes'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(attrTarget: attrTarget, attrDefs: attrDefs, attrTexts: attrTexts))

    textDefs = resolve_recipe_texts(attrTexts.empty? ? :package_mustbe : attrTexts) # default is standard mustbe

    procBlok = Kernel.block_given? ? attrBlok : standard_mustbe_recipe_block(textDefs)
    
    Potrubi::Mixin::Dynamic.dynamic_define_methods(attrTarget, attrDefs, &procBlok)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(attrTarget: attrTarget, attrDefs: attrDefs, attrTexts: attrTexts))

    self
    
  end
  
end

module Potrubi
  module Mixin
    module ContractRecipes
    end
  end
end

Potrubi::Mixin::ContractRecipes.extend(mixinContent) # Make mixin methods

__END__

# quick tests

require '../core'

$DEBUG = true
$DEBUG_POTRUBI_BOOTSTRAP = true

testClass = Class.new do

  include Potrubi::Core
  
  attrAccessors = {
    #jmx_user: :string,
    #jmx_pass: :string,
    #jmx_host: :string,
    ###jmx_port: :string,
    #jmx_port: :fixnum,
    #jmx_connection: nil,
    #jmx_connection: 'JMX::MBeanServerConnectionProxy',
    #beans_attributes: :hash,
    #beans_specifications: :hash,
    #jmx_host: ->(h) {h.is_a?(String)},

    #jmx_orts: {spec: 'def is_value_jmx_orts?(v); v.is_a?(String); end'},

    #jmx_keys: {edit: {ACCESSOR_KEYS: 'self.class.accessor_keys'},
    #spec: :method_accessor_is_value_and_keys}

    jmx_users1: {edit: {KEY_TYPE: :string, VALUE_TYPE: :jmx_user}, spec: :method_accessor_is_value_typed_collection},
    jmx_users2: {edit: {KEY_TYPE: :string, VALUE_TYPE: :jmx_user, VALUE_IS_NIL_RESULT: 'true', KEY_NAMES: [:a, :b, :c]}, spec: :method_accessor_is_value_typed_collection_with_keys}

    
  }

  attraccessorTexts = [:package_accessor_with_contract]

  Potrubi::Mixin::ContractRecipes.recipe_accessors(self, attrAccessors, attraccessorTexts)


  mustbeContracts = {
    what1: :string,
    what2: :hash,
    what3: 'Riemann::Feed::Feeder'
  }

  #Potrubi::Mixin::ContractRecipes.recipe_mustbes(self, mustbeContracts)
  
end

testInst = testClass.new

#testInst.mustbe_jmx_host_or_croak('A string')
#testInst.mustbe_jmx_host_or_croak(:symbol)
#testInst.mustbe_jmx_orts_or_croak('A string')
#testInst.mustbe_jmx_orts_or_croak(:symbol)
__END__

