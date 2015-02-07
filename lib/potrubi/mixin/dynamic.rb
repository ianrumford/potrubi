
# potrubi mixin dynamic

# dynamic method, etc generation

require_relative '../bootstrap'

metaclassMethods = Module.new do

  include Potrubi::Bootstrap

  #=begin
  def dynamic_apply_edits(editSpecInput, *textValues, &block)
    eye = :dyn_apy_edts
    eyeTale = '"TEXT EDITS'

    editSpec = case editSpecInput
               when Hash then editSpecInput
               when Array then dynamic_merge_edits(editSpecInput)
                 when NilClass then nil 
               else
                 potrubi_bootstrap_surpise_exception(editSpecInput, eye, "editSpecInput not has, array or nil")
               end

    editSpec && potrubi_bootstrap_mustbe_hash_or_croak(editSpec, "editSpec not hash")

    potrubi_bootstrap_logger_me(eye, eyeTale, "editSpec", editSpec, "textValues >\n#{textValues}")

    textValue = textValues.flatten.compact.join("\n")

    textFinal = case editSpec
                when NilClass then textValue
                else
                  
                  newtextValue = nil

                  recurseMax = 16
                  recurseCnt = 0
                  until (textValue == newtextValue)

                    ((recurseCnt +=1) <= recurseMax) || potrubi_bootstrap_surprise_exception(recurseCnt, eye, "recurseMax >#{recurseMax}< exceeded")
                    
                    textValue = newtextValue || textValue

                    newtextValue = editSpec.inject(textValue) { |txt, (key, val)| txt.gsub(/#{key.to_s}/,"#{val}") }

                  end

                  newtextValue
                  
                end

    #potrubi_bootstrap_logger_mx(eye, eyeTale, "textFinal >#{textFinal.class}< >\n#{textFinal}\n<")

    textFinal
    
  end
  
  def dynamic_merge_edits(*edits, &editBlok)
    r = edits.flatten.compact.inject({}) {|s, h| s.merge(potrubi_bootstrap_mustbe_hash_or_croak(h), &editBlok)}
    r.empty? ? nil : r
  end

  def dynamic_define_methods(targetModule, methodDefs, dynArgs=nil, &dynBlok)
    eye = :dyn_def_mtds
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{methodDefs.class}< >#{methodDefs}< dynArgs >#{dynArgs.class}< >#{dynArgs}< dynBlok >#{dynBlok}<")

    potrubi_bootstrap_mustbe_module_or_croak(targetModule, eye, "targetModule not module")

    potrubi_bootstrap_mustbe_hash_or_croak(methodDefs, eye, "methodDefs not hash")

    dynArgs && potrubi_bootstrap_mustbe_hash_or_croak(dynArgs, eye, "dynArgs not hash")
    
    editArgs = dynArgs && dynArgs[:edit]
    
    dynSpecsAll = methodDefs.map do | mtdKey, mtdVal |
      
      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, "BEG MTH mtdKey >#{mtdKey.class}< >#{mtdKey}< mtdVal >#{mtdVal.class}< >#{mtdVal.class}< editArgs >#{editArgs .class}< >#{editArgs}<")

      mtdValCollection = case mtdVal
                         when Array then mtdVal
                         when Hash, String, Symbol, Proc then [mtdVal]
                         when NilClass then [mtdKey]
                         else
                           potrubi_bootstrap_surprise_exception(mtdVal, eye, "mtdVal is what?")
                         end

      dynResultsBlok = Kernel.block_given? ? mtdValCollection.map {|v| dynBlok.call(mtdKey, v) } : mtdValCollection
      
      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, "CASE GEN mtdKey >#{mtdKey.class}< >#{mtdKey}< mtdVal >#{mtdVal.class}< >#{mtdVal}< dynResultsBlok >#{dynResultsBlok.class}< >#{dynResultsBlok}<")

      editMtd = nil  # no default edits
    
      dynSpecs = dynamic_define_methods_normalise_specifications(mtdKey, *dynResultsBlok) do | dynResult |
        
        editAll = case
                  when dynResult.has_key?(:edit) then # edit key set?
                    editLocal = dynResult[:edit]
                    # if edit key is nil =>  NO EDITS AT ALL
                    editLocal ? [editMtd, editArgs, editLocal] : nil
                  else
                    # wants defaults; there was no point returning hash
                    [editMtd, editArgs] 
                  end
        
        editAll ? dynResult.merge({:edit => editAll}) : dynResult

      end
      
      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "FIN MTH mtdKey >#{mtdKey.class}< >#{mtdKey}< dynSpecs >#{dynSpecs.class}< >#{dynSpecs}<")

      dynSpecs
      
    end

    dynamic_define_methods_apply(targetModule, dynSpecsAll)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{methodDefs.class}< >#{methodDefs.class}< dynArgs >#{dynArgs.class}< >#{dynArgs}<")

    self
    
  end

  def dynamic_define_methods_normalise_specifications(specName, *specsNom, &specBlok)
    eye = :ddm_nrm_specs
    eyeTale = 'DDM NRM SPEC'
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "specName >#{specName}< specsNom >#{specsNom.class}< >#{specsNom.size}< >#{specsNom}< specBlok >#{specBlok}<")

    specsMap = specsNom.flatten(1).map.with_index do | specNom, specNdx |

      case specNom
      when NilClass then nil # convenient to allow nil
      when Array then
        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "CASE ARRAY specName >#{specName.class}< >#{specName}< specNom >#{specNom.class}< >#{specNom}<")
        specNom # expected to have got is all right
      when String, Symbol then
        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "CASE STRING, SYMBOL specName >#{specName.class}< >#{specName}< specNom >#{specNom.class}< >#{specNom}<")
        #{:edit => [editMtd, editArgs], :spec => specNom}
        {spec: specNom}
      when Proc then
        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "CASE PROC specName >#{specName.class}< >#{specName}< specNom >#{specNom.class}< >#{specNom}<")
        {name: specName, spec: specNom}
        #STOPHERECASEPROC
      when Hash then
        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "CASE HASH specName >#{specName.class}< >#{specName}< specNom >#{specNom.class}< >#{specNom}<")
        specNom # expected to have gotten it right
      else
        potrubi_bootstrap_surprise_exception(specNom, eye, "specName >#{specName.class}< >#{specName}< specNom is what?")
      end
      
    end.flatten.compact

    dynamic_define_methods_validate_specifications(*specsMap)

    specsNrm = Kernel.block_given? ? specsMap.map {|s| specBlok.call(s)} : specsMap

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, "specName >#{specName}< specsNrm >#{specsNrm.class}< >#{specsNrm.size}< >#{specsNrm.class}< specBlok >#{specBlok}<")
    potrubi_bootstrap_mustbe_array_or_croak(specsNrm, eye)

  end

  # reduction in this context is consolidating edist
  # alos resolving snippets
  
  def dynamic_define_methods_reduce_specifications(targetModule, *specsNom, &specBlok)
    eye = :ddm_rdc_specs
    eyeTale = 'DDM RDC SPEC'
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "specsNom >#{specsNom.class}< >#{specsNom.size}< >#{specsNom.class}< specBlok >#{specBlok}<")

    specsVal = dynamic_define_methods_validate_specifications(*specsNom)
    
    specsNrm = specsVal.map do | specNom |

      specEdit = specNom[:edit]
      specSpec = specNom[:spec]

      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "EDIT & SPEC specEdit >#{specEdit}< specSpec >#{specSpec.class}< >#{specSpec}<")

      # Resolve any snippets
      specSnippets = Potrubi::Mixin::SnippetManager.map_snippets_or_croak(:dynamic_methods, *specSpec)
      
      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "SNIP",  potrubi_bootstrap_logger_fmt_kls_size(specSnippets: specSnippets))

      snipEdits = dynamic_merge_edits(specEdit) # cummlative edits
      
      snipItems = specSnippets.map do | snipItem |

        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "SNIP BEG",  potrubi_bootstrap_logger_fmt_kls(snipItem: snipItem))
        
        snipList = case snipItem
                   when Hash

                    if snipItem.has_key?(:edit) then
                      # collect any edits e.g. defaults. specEdit takes prescedence of snipEdits
                      snipEdits = dynamic_merge_edits(snipEdits, snipItem[:edit], specEdit)
                     end

                     case
                     when snipItem.has_key?(:proc) then
                       r = dynamic_define_methods_apply_procs(nil, snipItem.merge({edit: snipEdits, target: targetModule}))
                       dynamic_define_methods_reduce_specifications(targetModule, *r) # recurse
                     else
                       snipItem.merge({edit: snipEdits}) # roll up all edits
                     end
                     
                   when String then {edit: snipEdits, spec: snipItem}
                   when Proc then specNom.merge({spec: snipItem})
                   else
                     potrubi_bootstrap_surprise_exception(snipItem, eye, "snipItem unexpected")
                   end

        
        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "SNIP FIN", potrubi_bootstrap_logger_fmt_kls(snipList: snipList))

        snipList

      end
      
    end.flatten

    dynamic_define_methods_validate_specifications(*specsNrm)
    
    specsRdc = Kernel.block_given? ? specsNrm.map {|s| specBlok.call(s)} : specsNrm

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, "specsRdc >#{specsRdc.class}< >#{specsRdc.size}< >#{specsRdc.class}< specBlok >#{specBlok}<")

    potrubi_bootstrap_mustbe_array_or_croak(specsRdc, eye)

  end
  
  def dynamic_define_methods_validate_specifications(*specsNom, &specBlok)
    eye = :ddm_val_specs
    eyeTale = 'DDM VAL SPEC'
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "specsNom >#{specsNom.class}< >#{specsNom.size}< >#{specsNom.class}< specBlok >#{specBlok}<")

    specKeys = [:edit, :spec, :name, :proc, :target]
    
    specsNrm = specsNom.flatten.map.with_index do | specNom, specNdx |

      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, "specNdx >#{specNdx}< spceSize >#{specNom.size}<",  potrubi_bootstrap_logger_fmt_kls(specNom: specNom))

      potrubi_bootstrap_mustbe_hash_or_croak(specNom, eye)

      potrubi_bootstrap_mustbe_empty_or_croak(specNom.keys - specKeys, eye)

      specNom

    end
    
    specsVal = Kernel.block_given? ? specsNrm.map {|s| specBlok.call(s)} : specsNrm

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, "specsNom >#{specsVal.class}< >#{specsVal.size}< >#{specsVal.class}< specBlok >#{specBlok}<")

    potrubi_bootstrap_mustbe_array_or_croak(specsVal, eye)

  end
  
  # expects an array of normalised and validated hashes
  
  def dynamic_define_methods_apply(targetModule, *methodSpecsNom, &dynBlok)
    eye = :ddm_apl
    eyeTale = 'DDM APL'
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{methodSpecsNom.class}< >#{methodSpecsNom.size}< >#{methodSpecsNom.class}< dynBlok >#{dynBlok}<")

    # validate specs
    methodSpecsRdc = dynamic_define_methods_reduce_specifications(targetModule, *methodSpecsNom)
    
    # any methods specs with logic to apply?
    methodSpecs = methodSpecsRdc
    
    # try to merge all the text methods together

    textMethods = []
    
    methodSpecs.each_with_index do | methodSpec, methodNdx |

      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, "methodNdx >#{methodNdx}< methodSpec >#{methodSpec.class}< >#{methodSpec.class}<")

      potrubi_bootstrap_mustbe_hash_or_croak(methodSpec)
      
      case (specType = methodSpec[:spec])
      when Proc then

        specName = potrubi_bootstrap_mustbe_string_or_croak((r = methodSpec[:name]) ? r.to_s : nil, eye, "proc name is nil")
        specProc = specType # potrubi_bootstrap_mustbe_proc_or_croak(mustbe_key_or_croak(methodSpec, :proc))
        
        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "PROC BEG specName >#{specName.class}< >#{specName}< specProc >#{specProc.class}< >#{specProc}<")

        if (! textMethods.empty?) then      # any text methods "waiting"; must be defined before proc
          dynamic_define_methods_apply_texts(targetModule, *textMethods)
          textMethods.clear  # none wating now
        end
        
        targetModule.__send__(:define_method, specName.to_sym, &specProc) 

        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "PROC FIN specName >#{specName.class}< >#{specName}< specProc >#{specProc.class}< >#{specProc}<")

      when String then textMethods << methodSpec 
      when Array then textMethods << methodSpec
      else
        potrubi_bootstrap_surprise_exception(specType, "methodSpec >#{methodSpec.class}< >#{methodSpec.class}< specType >#{specType.class}< is what?")
      end

    end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "TXTSZ", potrubi_bootstrap_logger_fmt_kls(textMethods: textMethods))
    
    textMethods.empty? || dynamic_define_methods_apply_texts(targetModule, *textMethods)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{methodSpecs.class}< >#{methodSpecs.size}<")

    self
    
  end

  # do any of the method specification have a proc key?
  # Implies pass whole method meth to proc and use result
  # allow for logic in e.g. method text createion
  # result must be array of method spec hashes
  
  def dynamic_define_methods_apply_procs(targetModule, *specsNom, &specBlok)
    eye = :ddm_apl_prcs
    eyeTale = 'DDM APL PROCS'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{specsNom.class}< >#{specsNom}<")

    specsVal = dynamic_define_methods_validate_specifications(*specsNom)
    
    specsNrm = specsVal.map.with_index do | specNom, specNdx |
      
      puts("#{eye} #{eyeTale} specNdx >#{specNdx}< specNom >#{specNom.class}< >#{specNom}<")
      
      case
      when specNom.has_key?(:proc) then
        r = potrubi_bootstrap_mustbe_proc_or_croak(specNom[:proc], eye).call(specNom)
      else
        specNom
      end

    end.flatten.compact
    
    dynamic_define_methods_validate_specifications(*specsNrm)
    
    specsPrc = Kernel.block_given? ? specsNrm.map {|s| specBlok.call(s)} : specsNrm

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, "targetModule >#{targetModule.class}< >#{targetModule}< specsPrc >#{specsPrc.class}< >#{specsPrc.size}<")

    specsPrc.each_with_index {|s,i| puts("#{eye} #{eyeTale} i >#{i}< s >#{s.class}< >#{s}<") }
    
    potrubi_bootstrap_mustbe_array_or_croak(specsPrc, eye)

  end
    
  def dynamic_define_methods_apply_texts(targetModule, *methodSpecsNom, &dynBlok)
    eye = :ddm_apl_txt
    eyeTale = 'DDM APL TXTS'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "targetModule >#{targetModule.class}< >#{targetModule}<",  potrubi_bootstrap_logger_fmt_kls_size(specs: methodSpecsNom))

    methodSpecs = dynamic_define_methods_validate_specifications(*methodSpecsNom)
    
    begin

      methodTexts = methodSpecs.map do | specHash |

        #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "BEG specHash >#{specHash.class}< >#{specHash}<\n\n\n")
        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "BEG",  potrubi_bootstrap_logger_fmt_kls_size(specHash: specHash))

        potrubi_bootstrap_mustbe_hash_or_croak(specHash)

        specEdit = specHash[:edit]
        specSpec = specHash[:spec]

        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "EDIT & SPEC specEdit >#{specEdit}< specSpec >#{specSpec.class}< >#{specSpec.class}<")
        #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "EDIT & SPEC specEdit >#{specEdit}< specSpec >#{specSpec.class}< >#{specSpec}<")

        specText = dynamic_apply_edits(specEdit, specSpec) # note order of edits

        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "FIN specEdit >#{specEdit}< specText >#{specText}<\n\n\n")

        specText
        
      end.flatten.compact.join("\n")
    rescue Exception => e
      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye,"exception >#{e}<")
      stopINDYNAPP3RESCUE
    end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "METHODS targetModule >#{targetModule.class}< >#{targetModule}< methodTexts >#{methodTexts.class}< >\n#{methodTexts}\n<")
    ###puts("#{eye} #{eyeTale} METHODS targetModule >#{targetModule.class}< >#{targetModule}< methodTexts >#{methodTexts.class}< >\n#{methodTexts}\n<")

    methodTexts && targetModule.module_eval(methodTexts)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{methodSpecs.class}< >#{methodSpecs.size}<")

    self
    
  end

end

module Potrubi
  module Mixin
    module Dynamic
    end
  end
end

Potrubi::Mixin::Dynamic.extend(metaclassMethods) # Module methods
Potrubi::Mixin::Dynamic.__send__(:include, metaclassMethods)  # Instance Methods

# must be after dynamic is up

requireList = %w(snippet-manager)
requireList.each {|r| require_relative "#{r}"}

__END__

