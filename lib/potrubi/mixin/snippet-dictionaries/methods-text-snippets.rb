
# potrubi method text snippets

# dynamic methods dictionary

# Procs

Proc.new do
  
  isvaluecontractcollectionwithnilvaluesProc = ->(spec) {
    eye = :'is_val_con_col'
    
    require 'potrubi/klass/syntax/braket'
    
    targetModule = potrubi_bootstrap_mustbe_module_or_croak(spec[:target], eye)
    
    specEdit = potrubi_bootstrap_mustbe_hash_or_croak(spec[:edit], eye)

    mustbeContracts = potrubi_bootstrap_mustbe_hash_or_croak(specEdit[:VALUE_CONTRACTS], eye, 'CONTRACT_RECIPES not hash')

    braketKls = Potrubi::Klass::Syntax::Braket

    braketMethod = braketKls.new_method

    braketDefBeg = braketKls.new_statement.push('def is_value_MUSTBE_NAME?(testValue)')

    braketCollection = braketKls.new_statement.push('testValue.is_a?(Hash) &&')

    braketItems = mustbeContracts.map do | key, contract |

      #  if value is nil don't test
      
      braketKls.new_statement.push(
                                   '((r = testValue[:',
                                   key,
                                   ']) ? ',
                                   'is_value_',
                                   key,
                                   '?(r) : true)',
                                   ' && '
                                   )

    end

    braketResult = braketKls.new_statement.push('testValue')

    braketDefEnd = braketKls.new_statement.push('end')
    
    braketMethod.push(braketDefBeg,
                      braketCollection,
                      braketItems,
                      braketResult,
                      braketDefEnd,
                      )
    
    specText = braketMethod.to_s

    # Generate the contracts for the allowed values
    Potrubi::Mixin::ContractRecipes.recipe_mustbes(targetModule, mustbeContracts)

    {edit: specEdit, spec: specText}
    
  }




# Texts

        mustbeMethodOneArgText = <<-'ENDOFMUSTBESCALARMETHOD'
        def mustbe_MUSTBE_NAME_or_croak(testValue, *tellTales)
          is_value_MUSTBE_NAME?(testValue) ? testValue : contract_exception(testValue, "value failed is_value_MUSTBE_NAME?", *tellTales)
        end;
        ENDOFMUSTBESCALARMETHOD

        mustbeArrayWithProcText = <<-'ENDOFMUSTBEARRAYMETHOD'
        def mustbe_MUSTBE_NAME_with_proc_or_croak(testValue, *tellTales, &procBlok)
          r =  mustbe_MUSTBE_NAME_or_croak(testValue, *tellTales)
          Kernel.block_given? ? r.map {|v| procBlok.call(v) } : r
        end;
        def mustbe_MUSTBE_NAME_key_or_nil_with_proc_or_croak(testValue, keyName, *tellTales, &procBlok)
          (r = is_value_key?(testValue, keyName)) && mustbe_MUSTBE_NAME_with_proc_or_croak(r, *tellTales, &procBlok)
        end;
        ENDOFMUSTBEARRAYMETHOD

        mustbeHashWithProcText = <<-'ENDOFMUSTBEHASHMETHOD'
        def mustbe_MUSTBE_NAME_with_proc_or_croak(testValue, *tellTales, &procBlok)
          r = mustbe_MUSTBE_NAME_or_croak(testValue, *tellTales, &procBlok)
          Kernel.block_given? ? r.each_with_object({}) {|(k,v), h| h[k] = procBlok.call(v) } : r
        end;
        def mustbe_MUSTBE_NAME_key_or_nil_with_proc_or_croak(testValue, keyName, *tellTales, &procBlok)
           (r = is_value_key?(testValue, keyName)) && mustbe_MUSTBE_NAME_with_proc_or_croak(r, *tellTales, &procBlok)
        end;
        ENDOFMUSTBEHASHMETHOD
        
        mustbeMethodResultText = <<-'ENDOFMUSTBERESULTMETHOD'
        def mustbe_MUSTBE_NAME_or_croak(testValue, *tellTales)
          (r = is_value_MUSTBE_NAME?(testValue)) ? r : contract_exception(testValue, "value failed is_value_MUSTBE_NAME? test", *tellTales)
        end;
        ENDOFMUSTBERESULTMETHOD
        
        mustbeMethodCollectionsText = <<-'ENDOFHERE'
        def mustbe_MUSTBE_NAME_list_or_croak(testValues, &procBlock)  # collections
          haveBlock = Kernel.block_given? && procBlock
           testValues.map {|v| mustbe_MUSTBE_NAME_or_croak((haveBlock ? haveBlock.call(v) : v), 'mustbe_MUSTBE_NAME') }
        end;                                    
        ENDOFHERE

        mustbeMethodOneArgOrNilText = <<-'ENDOFHERE'
        def mustbe_MUSTBE_NAME_or_nil_or_croak(argOne, *tellTales) # or nil method
          argOne && mustbe_MUSTBE_NAME_or_croak(argOne, *tellTales)
        end;
        ENDOFHERE
        
        mustbeMethodTwoArgOrNilText = <<-'ENDOFHERE'
        def mustbe_MUSTBE_NAME_or_nil_or_croak(argOne, argTwo, *tellTales) # or nil method
          argOne && mustbe_MUSTBE_NAME_or_croak(argOne, argTwo, *tellTales)
        end;
        ENDOFHERE
        
        mustbeCommonText = [mustbeMethodOneArgOrNilText, mustbeMethodCollectionsText].join
        
        mustbeMethodOneArgOrNilWithProcText = <<-'ENDOFHERE'
        def mustbe_MUSTBE_NAME_or_nil_with_proc_or_croak(argOne, *tellTales, &procBlok) # or nil method
          argOne && mustbe_MUSTBE_NAME_with_proc_or_croak(argOne, *tellTales, &procBlok)
        end;                                    
        ENDOFHERE
        
        isvalueMethodText = <<-'ENDOFISVALUEMETHOD'
        def is_value_MUSTBE_NAME?(testValue)
          r = IS_VALUE_TEST ? testValue : nil
         end;
        ENDOFISVALUEMETHOD

        isvaluecollectionwithkeysMethodText = <<-'ENDOFHERE'
        def is_value_MUSTBE_NAME?(testValue)
           testValue.is_a?(Hash) && is_value_subset?(testValue.keys, KEY_NAMES) && testValue
        end;
        ENDOFHERE

        isvaluetypedarrayMethodText = <<-'ENDOFHERE'
        def is_value_MUSTBE_NAME?(testValue)
           testValue.is_a?(Array) && (testValue.all? {|v| v ? is_value_VALUE_TYPE?(v) : VALUE_IS_NIL_RESULT }) && testValue
        end;
        ENDOFHERE
        
         isvaluetypedcollectionMethodText = <<-'ENDOFHERE'
        def is_value_MUSTBE_NAME?(testValue)
           testValue.is_a?(Hash) && (testValue.all? {|k,v|  IS_COLLECTION_KEY_TEST && (v ? IS_COLLECTION_VALUE_TEST : VALUE_IS_NIL_RESULT) }) && testValue
        end;
        ENDOFHERE
         
        isvaluetypedcollectionwithkeysMethodText = <<-'ENDOFHERE'
        def is_value_MUSTBE_NAME?(testValue)
           (testValue.is_a?(Hash) && is_value_subset?(testValue.keys, KEY_NAMES) && (testValue.all? {|k,v| is_value_KEY_TYPE?(k) && (v ? is_value_VALUE_TYPE?(v) : VALUE_IS_NIL_RESULT) })) ? testValue : nil
        end;
        ENDOFHERE
        
        isvaluevalueisAliasText = <<-'ENDOFISVALUEALIAS'        
        alias_method :'value_is_MUSTBE_NAME?', :'is_value_MUSTBE_NAME?'
        ENDOFISVALUEALIAS

        isvaluevalueisAliasText = '' # TURN OFF ALIAS - TOO DNAGEROUS IF IS_VALUE OVERRIDDEN

        mustbeMethodKeyText = <<-'ENDOFMUSTBEKEYMETHOD'
        def mustbe_MUSTBE_NAME_key_or_croak(testValue, keyName, *tellTales)
          mustbe_MUSTBE_NAME_or_croak(mustbe_key_or_croak(testValue, keyName, *tellTales), *tellTales)
        end;
        def mustbe_MUSTBE_NAME_key_or_nil_or_croak(testValue, keyName, *tellTales)
          (r = is_value_key?(testValue, keyName)) && mustbe_MUSTBE_NAME_or_nil_or_croak(r, *tellTales)
        end;
        ENDOFMUSTBEKEYMETHOD

        findMethodKeyText = <<-'ENDOFHERE'
        def find_MUSTBE_NAME_key_or_croak(testValue, *tellTales)
          mustbe_MUSTBE_NAME_or_croak(mustbe_key_or_croak(testValue, :MUSTBE_KEY_NAME, *tellTales), *tellTales)
        end;
        def find_MUSTBE_NAME_key_or_nil_or_croak(testValue, *tellTales)
          mustbe_MUSTBE_NAME_key_or_nil_or_croak(testValue, :MUSTBE_KEY_NAME, *tellTales)
        end;
        ENDOFHERE

        setMethodKeyText = <<-'ENDOFHERE'
        def set_MUSTBE_NAME_key_or_croak(setHash, setValue, *tellTales)
          mustbe_hash_or_croak(setHash)[:MUSTBE_KEY_NAME] = mustbe_MUSTBE_NAME_or_croak(setValue, *tellTales)
          setHash
        end;
        ENDOFHERE

        getMethodKeyNameText = <<-'ENDOFHERE'
        def get_MUSTBE_NAME_key_name
          :MUSTBE_KEY_NAME
        end;
        ENDOFHERE
        
        mergeMethodKeyText = <<-'ENDOFHERE'
        def merge_MUSTBE_NAME_key_or_croak(mergeHash, mergeValue, *tellTales)
          mustbe_hash_or_croak(mergeHash).merge(:MUSTBE_KEY_NAME => mustbe_MUSTBE_NAME_or_croak(mergeValue, *tellTales))
        end;
        ENDOFHERE
        
        mustbeMethodSubsetText = <<-'ENDOFMUSTBESUBSETMETHOD'
        def mustbe_subset_or_croak(subSet, superSet, *tellTales)
          (r = is_value_subset?(subSet, superSet)) ? r : contract_exception(subSet, "value failed is_value_subset? test on superSet >#{superSet}<", *tellTales)
        end;
        def is_value_subset?(subSet, superSet)
          subSet.is_a?(Array) && superSet.is_a?(Array) && (subSet - superSet).empty? && subSet
        end
        ENDOFMUSTBESUBSETMETHOD
        
        mustbeMethodTwoArgText = <<-'ENDOFMUSTBEMETHODS'
        def mustbe_MUSTBE_NAME_or_croak(argOne, argTwo, *tellTales)
          (r = is_value_MUSTBE_NAME?(argOne, argTwo)) ? r : contract_exception(argTwo, "argOne >#{argOne.class}< argTwo failed is_value_MUSTBE_NAME?", *tellTales)
        end;
        ENDOFMUSTBEMETHODS


        mustbeMethodCompareText = <<-'ENDOFMETHOD'
          def mustbe_MUSTBE_NAME_or_croak(arg1, arg2, *args)
            arg1.is_a?(arg2.class) || contract_exception(arg1, :MUSTBE_NAME, "DIFFERNT CLASSES arg1 >#{arg1.class}< >#{arg1}< arg2 >#{arg2.class}< >#{arg2}< opr >MUSTBE_SPEC<", *args)
            argC = (arg1 MUSTBE_SPEC arg2)
            argC ? arg1 : contract_exception(argC, "argC >#{argC.class}< >#{argC}< arg1 >#{arg1.class}< >#{arg1}< arg2 >#{arg2.class}< >#{arg2}< opr >MUSTBE_SPEC<", *args)
          end;                            
          ENDOFMETHOD

        # accessors

        snippetBaseAccessor = <<-'ENDOFHERE'
          def ACCESSOR_NAME
            @ACCESSOR_NAME ||= ACCESSOR_DEFAULT
          end;
          def reset_ACCESSOR_NAME
            @ACCESSOR_NAME = nil
          end;         
          alias_method :'get_ACCESSOR_NAME', :'ACCESSOR_NAME'
        ENDOFHERE

        snippetAccessor = <<-'ENDOFHERE'
           def ACCESSOR_NAME=(value)
            @ACCESSOR_NAME = value
          end;
          alias_method :'set_ACCESSOR_NAME', :'ACCESSOR_NAME='
        ENDOFHERE
          
        snippetAccessorWithContractText = <<-'ENDOFHERE'
          def ACCESSOR_NAME=(value)
            @ACCESSOR_NAME = mustbe_ACCESSOR_CONTRACT_or_croak(value, :s_ACCESSOR_NAME, "value not ACCESSOR_CONTRACT")
          end;
          alias_method :'set_ACCESSOR_NAME', :'ACCESSOR_NAME='
          def find_ACCESSOR_NAME_or_croak
            mustbe_ACCESSOR_CONTRACT_or_croak(ACCESSOR_NAME, :f_ACCESSOR_NAME, "value not ACCESSOR_CONTRACT")
          end;
        ENDOFHERE

          accessorEdits = {
            'MUSTBE_NAME' => 'ACCESSOR_NAME',
            'MUSTBE_SPEC' => 'ACCESSOR_CONTRACT',
            'MUSTBE_KEYS' => 'ACCESSOR_KEYS',
          }

          valueisnilresultEdits = {VALUE_IS_NIL_RESULT: 'false'}  # default for typed collections is not ok if nil
          
          packageMustbeText = [mustbeMethodOneArgText, mustbeMethodKeyText, findMethodKeyText, setMethodKeyText, getMethodKeyNameText, mergeMethodKeyText, mustbeCommonText, isvalueMethodText, isvaluevalueisAliasText].flatten.join

          packageAccessorSpec = [snippetBaseAccessor, snippetAccessor].flatten
          
          packageAccessorWithContractBaseSpec = [mustbeMethodOneArgText, mustbeMethodKeyText,  mustbeMethodOneArgOrNilText, isvaluevalueisAliasText].flatten
          packageAccessorWithContractSpec = [isvalueMethodText, packageAccessorWithContractBaseSpec].flatten
          packageAccessorWithContractNoIsValueSpec = packageAccessorWithContractBaseSpec
          
          packageAccessorText = Potrubi::Mixin::Dynamic::dynamic_apply_edits(accessorEdits, packageAccessorSpec)
          packageAccessorWithContractText = Potrubi::Mixin::Dynamic::dynamic_apply_edits(accessorEdits, snippetBaseAccessor, snippetAccessorWithContractText, packageAccessorWithContractSpec)
          packageAccessorWithContractNoIsValueText = Potrubi::Mixin::Dynamic::dynamic_apply_edits(accessorEdits, snippetBaseAccessor, snippetAccessorWithContractText, packageAccessorWithContractNoIsValueSpec) 

          packageAccessorEdit = {
            'ACCESSOR_DEFAULT' => 'nil',
          }
          
          dynamicMethodTexts = {

            # accessors
            
            package_accessor: {edit: packageAccessorEdit, spec: packageAccessorText},
            package_accessor_with_contract: {edit: packageAccessorEdit, spec: packageAccessorWithContractText},
            package_accessor_with_contract_no_is_value: {edit: packageAccessorEdit, spec: packageAccessorWithContractNoIsValueText},

            method_accessor_is_value_collection_with_keys: {edit: valueisnilresultEdits, spec: Potrubi::Mixin::Dynamic::dynamic_apply_edits(accessorEdits, isvaluecollectionwithkeysMethodText)},
            method_accessor_is_value_typed_collection: {edit: valueisnilresultEdits, spec: Potrubi::Mixin::Dynamic::dynamic_apply_edits(accessorEdits, isvaluetypedcollectionMethodText)},
            method_accessor_is_value_typed_collection_with_keys: {edit: valueisnilresultEdits, spec: Potrubi::Mixin::Dynamic::dynamic_apply_edits(accessorEdits, isvaluetypedcollectionwithkeysMethodText)},

            method_accessor_is_value_typed_hash: {edit: valueisnilresultEdits, spec: Potrubi::Mixin::Dynamic::dynamic_apply_edits(accessorEdits, isvaluetypedcollectionMethodText)},
            method_accessor_is_value_typed_hash_with_keys: {edit: valueisnilresultEdits, spec: Potrubi::Mixin::Dynamic::dynamic_apply_edits(accessorEdits, isvaluetypedcollectionwithkeysMethodText)},
            
            method_accessor_is_value_typed_array: {edit: valueisnilresultEdits, spec: Potrubi::Mixin::Dynamic::dynamic_apply_edits(accessorEdits, isvaluetypedarrayMethodText, mustbeArrayWithProcText)},
            
            # contracts
            
            package_mustbe: packageMustbeText,
            method_mustbe_one_arg_or_nil: mustbeMethodOneArgOrNilText,
            method_mustbe_one_arg: mustbeMethodOneArgText,
            method_mustbe_two_arg: mustbeMethodTwoArgText,
            method_mustbe_key: mustbeMethodKeyText,
            method_mustbe_one_arg_or_nil: mustbeMethodOneArgOrNilText,

            method_mustbe_is_value_collection_with_keys: {edit: valueisnilresultEdits, spec: isvaluecollectionwithkeysMethodText},
            method_mustbe_is_value_typed_collection: {edit: valueisnilresultEdits, spec: isvaluetypedcollectionMethodText},

            method_mustbe_is_value_hash_with_keys: {edit: valueisnilresultEdits, spec: isvaluecollectionwithkeysMethodText},
            method_mustbe_is_value_typed_hash: {edit: valueisnilresultEdits, spec: isvaluetypedcollectionMethodText},

            method_mustbe_is_value_typed_array: {edit: valueisnilresultEdits, spec: [isvaluetypedarrayMethodText, mustbeArrayWithProcText]},
            
            method_mustbe_is_value_typed_collection_with_keys: {edit: valueisnilresultEdits, spec: isvaluetypedcollectionwithkeysMethodText},

            method_mustbe_is_value_contract_collection_with_nil_values: {proc: isvaluecontractcollectionwithnilvaluesProc},
            
            method_mustbe_hash_with_proc: mustbeHashWithProcText,
            method_mustbe_array_with_proc: mustbeArrayWithProcText,
            method_mustbe_one_arg_or_nil_with_proc: mustbeMethodOneArgOrNilWithProcText,
            method_mustbe_subset: mustbeMethodSubsetText,
            method_mustbe_compare: mustbeMethodCompareText,
            
            method_mustbe_collections: mustbeMethodCollectionsText,

            # assertion
            
            method_is_value: isvalueMethodText,

            # aliases
            
            alias_is_value_value_is: isvaluevalueisAliasText,
            
            # testing

            test1: 'def ACCESSOR_NAME(testValue); IS_VALUE_TEST ? 99 : nil; end;',
          }

          dynamicMethodTexts  # return value
          


end
__END__
