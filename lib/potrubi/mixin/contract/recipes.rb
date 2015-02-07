
# potrubi contract recipes

# to ease the creation of contracts, accessors, etc in class bodies

#  These are *mixin* ('class') methods; not instance ones

# Uses conventions for names etc dedined by (in) contract mixin

require_relative '../../bootstrap'

requireList = %w(util)
requireList.each {|r| require_relative "../#{r}"}

mixinContent = Module.new do

  include Potrubi::Bootstrap
  include Potrubi::Mixin::Util
  
  def standard_accessor_edit(k, v)
    {ACCESSOR_NAME: k, ACCESSOR_CONTRACT: k,  MUSTBE_NAME: k, MUSTBE_SPEC: k, MUSTBE_KEY_NAME: k}
  end

  def standard_mustbe_edit(k, v)
    {MUSTBE_NAME: k, MUSTBE_SPEC: k, MUSTBE_KEY_NAME: k}
  end

  def keyname_mustbe_edit(k, v, n)
    {MUSTBE_NAME: k, MUSTBE_SPEC: k, MUSTBE_KEY_NAME: n}
  end
  
  # convenience methods
  
  def merge_edits(*edits)
    Potrubi::Mixin::Dynamic.dynamic_merge_edits(*edits)
  end

  def merge_specs(*specs)
    specs.flatten.compact
  end

  def merge_spec_and_edit(spec, edit)
    {edit: edit, spec: spec}
  end


  def standard_syntax_value_test(v, t='testValue')
    eye = :'standard_syntax_value_test'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, 'PRE', 'VALUE', 'TEST', potrubi_bootstrap_logger_fmt_who(v: v, t: t))
    r = case v
        when Symbol then  "is_value_#{v}?(#{t})"
        when Class, String then "#{t}.is_a?(#{v})"
        when NilClass then "#{t}"
        when Proc then value.call
        else
          potrubi_bootstrap_surprise_exception(v, eye, "v >#{v}< spec not expected")
        end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, 'POST', 'VALUE', 'TEST', potrubi_bootstrap_logger_fmt_who(v: v, r: r))

    r

  end
  
  
  # This method is peculiar to accessors & mustbes
  # not general purpose as e.g. hash treatment makes assumptions
  
  def standard_case_statement(k, v, s, edit, spec)
    eye = :'rcp_std_case'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(k: k, v: v, edit: edit))
    r = case v
          ##when Symbol then  merge_spec_and_edit(spec, merge_edits(edit, {IS_VALUE_TEST: "testValue.is_a?(#{v.to_s.capitalize})"}))
        when Symbol then  merge_spec_and_edit(spec, merge_edits(edit, {IS_VALUE_TEST: "is_value_#{v}?(testValue)"}))
        when Class, String then merge_spec_and_edit(spec, merge_edits(edit, {IS_VALUE_TEST: "testValue.is_a?(#{v})"}))
        when NilClass then  merge_spec_and_edit(spec, merge_edits(edit, {IS_VALUE_TEST: 'testValue'}))
        when Array then v # dynamic_define_methods will parse
        when Proc then
          [ merge_spec_and_edit(spec, merge_edits(edit, {IS_VALUE_TEST: 'false'})), # error on default isValueText
            {name: "is_value_#{k}?", spec: v}, # ... but override is_value method
          ]
        when Hash then v.merge(merge_spec_and_edit(merge_specs([spec, v[:spec]]), merge_edits(edit,  {IS_VALUE_TEST: 'false'}, v[:edit])))
        else
          potrubi_bootstrap_surprise_exception(v, eye, "accessor name >#{k}< spec not expected")
        end
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(k: k, v: v, edit: edit), potrubi_bootstrap_logger_fmt_who(spec: spec), potrubi_bootstrap_logger_fmt_who(RRRRRRRRRRRRRRRRRRRRRRRRRr: r))
    r
  end

  def standard_accessor_recipe_block(s) # returns a lambda
    ->(k, v) do
      edit = standard_accessor_edit(k, v)
      spec = s
      r = standard_case_statement(k, v, s, edit, spec)
      r
    end
  end

  def standard_derived_edits_assign(s, srcKey, tgtKey, tgtText)
    eye = :'standard_derived_edits_assign'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(srcKey: srcKey, tgtKey: tgtKey, tgtText: tgtText, s: s))
    # does the target key already exist?
    potrubi_bootstrap_mustbe_hash_or_croak(s)
    r = if s.has_key?(tgtKey) then
          # yes; nothing to do
          s
        else
          # no; does the source key exist?. if use use to set target key
          if s.has_key?(srcKey) then
            s[tgtKey] = standard_syntax_value_test(s[srcKey], tgtText)
            s
          else
            s
          end
        end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(srcKey: srcKey, tgtKey: tgtKey, r: r))
    potrubi_bootstrap_mustbe_hash_or_croak(r, eye, 'POST', 'EDITS', 'ASSIGN')
    #r
  end

  def standard_derived_edits(edits={})
    eye = :'standard_derived_edits'

    derivedMap =
      {
      IS_COLLECTION_VALUE_TEST: {key: :VALUE_TYPE, target: 'v'},
      IS_COLLECTION_KEY_TEST: {key: :KEY_TYPE, target: 'k'},
    }

    editsDerived =
      if edits then
        potrubi_bootstrap_mustbe_hash_or_croak(edits)
        derivedMap.reduce(edits) do | s, (tgtKey, srcSpec) |
        srcKey = srcSpec[:key]
        tgtText = srcSpec[:target]
        standard_derived_edits_assign(s, srcKey, tgtKey, tgtText)
      end
      else
        nil
      end
    
    editsDerived && potrubi_bootstrap_mustbe_hash_or_croak(editsDerived)

  end

  def standard_mustbe_recipe_block(s) # returns a lambda
    ->(k, v) {

      spec = s
      
      r = case v
          when Hash then

            o = v[:other] || {}

            # any key name?
            key_name = o[:key_name]
            
            eKeyName = keyname_mustbe_edit(k, v, key_name || k)

            eDerived = standard_derived_edits(v[:edit])

            e = merge_edits(eKeyName, eDerived)
            
            # any type?
            t = o[:type]
            
            r = standard_case_statement(k, t || v, s, e, spec)

            
          else
            e = keyname_mustbe_edit(k, v, k)
            ###spec = {spec: s}
            
            r = standard_case_statement(k, v, s, e, spec)
          end
      
      r
    }
  end
  
  def resolve_recipe_texts(*recipeTexts)
    recipeTexts.flatten
  end
  

  def recipe_accessors(attrTarget, attrDefs, *attrTexts, &attrBlok)
    eye = :'rcp_accessors'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(attrTarget: attrTarget, attrDefs: attrDefs, attrTexts: attrTexts))

    textDefs = resolve_recipe_texts(attrTexts.empty? ? :package_accessor_with_contract : attrTexts) # default is contract accessor

    procBlok = Kernel.block_given? ? attrBlok : standard_accessor_recipe_block(textDefs)
    
    Potrubi::Mixin::Dynamic.dynamic_define_methods(attrTarget, attrDefs, &procBlok)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(attrTarget: attrTarget, attrDefs: attrDefs, attrTexts: attrTexts))

    self

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



  def recipe_variant_accessor(attrTarget, attrDefs, *attrTexts, &attrBlok)
    eye = :'rcp_var_acc'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(attrTarget: attrTarget, attrDefs: attrDefs, attrTexts: attrTexts))

    textDefs = resolve_recipe_texts(attrTexts)

    procBlok = Kernel.block_given? ? attrBlok : standard_accessor_recipe_block(textDefs)
    
    Potrubi::Mixin::Dynamic.dynamic_define_methods(attrTarget, attrDefs, &procBlok)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(attrTarget: attrTarget, attrDefs: attrDefs, attrTexts: attrTexts))

    self

  end
  


  def recipe_variant_mustbe(attrTarget, attrDefs, *attrTexts, &attrBlok)
    eye = :'rcp_var_mustbe'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(attrTarget: attrTarget, attrDefs: attrDefs, attrTexts: attrTexts))

    textDefs = resolve_recipe_texts(attrTexts.compact.empty? ? :package_mustbe : attrTexts) # default is contract accessor

    procBlok = Kernel.block_given? ? attrBlok : standard_mustbe_recipe_block(textDefs)
    
    Potrubi::Mixin::Dynamic.dynamic_define_methods(attrTarget, attrDefs, &procBlok)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(attrTarget: attrTarget, attrDefs: attrDefs, attrTexts: attrTexts))

    self

  end


end

module Potrubi
  module Mixin
    module Contract
      module Recipes
      end
    end
  end
end

Potrubi::Mixin::Contract::Recipes.extend(mixinContent) # Make mixin methods

__END__

# quick tests

$LOAD_PATH.unshift('../../../.') # ensure get code not gem

$LOAD_PATH.each {|p| puts("LOAD PATH >#{p}<")}
#STOPHERELOADPATH
require '../../core'
require "potrubi/klass/syntax/braket"

$DEBUG = true
$DEBUG_POTRUBI_BOOTSTRAP = true

testClass2 = Class.new do

  Potrubi::Mixin::Contract::Recipes.recipe_dsl(self) do

    #accessor :x1, default: 10
    #accessor :x2, default: 'default-for-x2'
    #accessor :x3, default: :x3_def_is_a_symbol

    #    accessor :riemann_host, :string
    accessor :riemann_port, type: :fixnum, default: 5555
    #accessor :riemann_interval, type: :fixnum, default: 10
    
    
  end
  

end

__END__

