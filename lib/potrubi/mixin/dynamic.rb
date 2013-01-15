
# potrubi mixin dynamic

# dynamic method, etc generation

require_relative '../bootstrap'

metaclassMethods = Module.new do

  include Potrubi::Bootstrap

  #=begin
  def dynamic_apply_edits(editSpecInput, *textValues, &block)
    eye = :dyn_apy_edts
    #eyeTale = '"TEXT EDITS'
    
    #editSpec.is_a?(Hash) || editSpec.is_a?(Enumerator) || (raise ArgumentError,"editSpec >#{editSpec.class}< >#{editSpec}< not hash")
    editSpec = case editSpecInput
               when Hash then editSpecInput
               when Array then dynamic_merge_edits(editSpecInput)
                 when NilClass then nil 
               else
                 potrubi_bootstrap_surpise_exception(editSpecInput, eye, "editSpecInput not has, array or nil")
                 ###nil # will error
               end

    editSpec && potrubi_bootstrap_mustbe_hash_or_croak(editSpec, "editSpec not hash")

    #potrubi_bootstrap_logger_me(eye, eyeTale, "editSpec", editSpec, "textValues >\n#{textValues}")

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
                    newtextValue = editSpec.inject(textValue) { |txt, (key, val)| txt.gsub(/#{key}/,"#{val}") }
                    ###puts("APY EDTS recurseCnt >#{recurseCnt}< newtestValue >#{newtextValue}<")
                  end

                  newtextValue
                  
                end

    # support for uniquenesses needed?
    
    #while (textFinal =~ /METHOD_UNIQUENESS/) 
    #  textFinal = textFinal.sub(/METHOD_UNIQUENESS/, rand(1000000000000).to_s)  # Each UNQIUENESS is unique!
    #end
    
    #potrubi_bootstrap_logger_mx(eye, eyeTale, "textFinal >#{textFinal.class}< >\n#{textFinal}\n<")

    textFinal
    
  end
  #=end
  
  #=begin
  def dynamic_merge_edits(*edits)
    r = edits.flatten.compact.inject({}) {|s, h| s.merge(potrubi_bootstrap_mustbe_hash_or_croak(h))}
    r.empty? ? nil : r
  end
  #=end

  #=begin
  def dynamic_define_methods(targetModule, methodDefs, dynArgs=nil, &dynBlok)
    eye = :dyn_def_mtds
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{methodDefs.class}< >#{methodDefs}< dynArgs >#{dynArgs.class}< >#{dynArgs}< dynBlok >#{dynBlok}<")

    potrubi_bootstrap_mustbe_module_or_croak(targetModule, eye, "targetModule not module")

    potrubi_bootstrap_mustbe_hash_or_croak(methodDefs, eye, "methodDefs not hash")

    dynArgs && potrubi_bootstrap_mustbe_hash_or_croak(dynArgs, eye, "dynArgs not hash")
    
    editArgs = dynArgs && dynArgs[:edit]
    
    #methodTexts = nil  # will hold texts for methods, if any (could be all define_methods)
    
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

      dynResultsNorm = [dynResultsBlok].flatten(1).map do | dynResult |
        case dynResult
        when NilClass then nil
        when Array then
          $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "CASE ARRAY mtdKey >#{mtdKey.class}< >#{mtdKey}< dynResult >#{dynResult.class}< >#{dynResult}<")
          dynResult # expected to have got is all right
        when String, Symbol then
          $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "CASE STRING, SYMBOL mtdKey >#{mtdKey.class}< >#{mtdKey}< dynResult >#{dynResult.class}< >#{dynResult}<")
          #{:edit => [editMtd, editArgs], :spec => dynResult}
          {spec: dynResult}
        when Proc then
          $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "CASE PROC mtdKey >#{mtdKey.class}< >#{mtdKey}< dynResult >#{dynResult.class}< >#{dynResult}<")
          {name: mtdKey, spec: dynResult}
        when Hash then
          $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "CASE HASH mtdVal >#{mtdKey.class}< >#{mtdKey}< dynResult >#{dynResult.class}< >#{dynResult}<")
          dynResult # expected to have gotten it right
        else
          potrubi_bootstrap_surprise_exception(dynResult, eye, "dynResult is what?")
        end
        
      end.flatten.compact


      dynSpecs = [*dynResultsNorm].map do | dynResult |
        
        potrubi_bootstrap_mustbe_hash_or_croak(dynResult, eye, "dynResult not hash")
        
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


      #dynamic_define_methods_apply(targetModule, dynSpecs)
      dynSpecs
    end

    dynamic_define_methods_apply(targetModule, dynSpecsAll)

    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{methodDefs.class}< >#{methodDefs.class}< dynArgs >#{dynArgs.class}< >#{dynArgs}<")
    self
    
  end
  #=end

  #=begin
  def dynamic_define_methods_apply(targetModule, *methodSpecs, &dynBlok)
    eye = :ddm_apl
    eyeTale = 'DDM APL'
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{methodSpecs.class}< >#{methodSpecs.size}< >#{methodSpecs.class}< dynBlok >#{dynBlok}<")

    # try to merge all the text methods together

    textMethods = []
    
    methodSpecs.flatten.compact.each_with_index do | methodSpec, methodNdx |

      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, "methodNdx >#{methodNdx}< methodSpec >#{methodSpec.class}< >#{methodSpec}<")

      potrubi_bootstrap_mustbe_hash_or_croak(methodSpec)
      
      case (specType = methodSpec[:spec])
      when Proc then

        specName = potrubi_bootstrap_mustbe_string_or_croak((r = methodSpec[:name]) ? r.to_s : nil)
        specProc = specType # potrubi_bootstrap_mustbe_proc_or_croak(mustbe_key_or_croak(methodSpec, :proc))
        
        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "PROC BEG specName >#{specName.class}< >#{specName}< specProc >#{specProc.class}< >#{specProc}<")

        textMethods.empty? || begin      # any text methods "waiting"; must be serial defined before proc
                                dynamic_define_methods_apply_texts(targetModule, *textMethods)
                                textMethods.clear  # none wating now
                              end
        
        targetModule.__send__(:define_method, specName.to_sym, &specProc) 

        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "PROC FIN specName >#{specName.class}< >#{specName}< specProc >#{specProc.class}< >#{specProc}<")
        
      when String, Symbol then textMethods << methodSpec
      when Array then textMethods << methodSpec
      else
        potrubi_bootstrap_surprise_exception(specType, "methodSpec >#{methodSpec.class}< >#{methodSpec.class}< specType >#{specType.class}< is what?")
      end

    end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "TXTS textMethods >#{textMethods.class}< >#{textMethods}<")
    
    textMethods.empty? || dynamic_define_methods_apply_texts(targetModule, *textMethods)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{methodSpecs.class}< >#{methodSpecs.size}<")

    self
    
  end
  #=end

  def dynamic_define_methods_apply_texts(targetModule, *methodSpecs, &dynBlok)
    eye = :ddm_apl_txt
    eyeTale = 'DDM APL TXTS'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{methodSpecs.class}< >#{methodSpecs}<")

    #STOPAPPLYTEXTS
    
    begin

      methodTexts = methodSpecs.flatten.compact.map do | methodSpec |

        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "BEG methodSpec >#{methodSpec.class}< >#{methodSpec}<\n\n\n")

        potrubi_bootstrap_mustbe_hash_or_croak(methodSpec)

        ###methodTextNom = potrubi_bootstrap_mustbe_string_or_croak([methodSpec[:spec]].flatten.compact.join)

        methodEdit = methodSpec[:edit]
        methodText = methodSpec[:spec]

        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "EDIT & SPEC methodEdit >#{methodEdit}< methodText >#{methodText.class}< >#{methodText}<")

        #STOPEDITANDTEXT
        
        # Resolve any snippets
      
        #methodSnipNom = potrubi_bootstrap_mustbe_string_or_croak(Potrubi::Mixin::TextSnippets.map_snippets_or_croak(:dynamic_methods, *methodText).flatten.compact.join)
        methodSnippets = Potrubi::Mixin::TextSnippets.map_snippets_or_croak(:dynamic_methods, *methodText)
        
        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "SNIP methodSnippets >#{methodSnippets.class}< >#{methodSnippets}<")

        #STOPMETHODSNIPNOM
        
        snipEdits = []
        
        snipTexts = methodSnippets.inject([]) do | textList, snipItem |

          ###puts("\nSNIP ITEM >#{snipItem.class}< >#{snipItem}<")
               
          textList << case snipItem
                      when Hash
                        snipEdits << snipItem[:edit] # collect any edits e.g. defaults
                        ###potrubi_bootstrap_mustbe_string_or_croak(snipItem[:spec]) # return the text
                        snipItem[:spec]
                      when String then snipItem
                      else
                        potrubi_bootstrap_surprise_exception(methodTextNom, eye, "methodTextNom unexpected")
                      end

        end
      
        methodText = dynamic_apply_edits([snipEdits, methodEdit], snipTexts) # note order of edits

        $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "FIN methodEdit >#{methodEdit}< snipEdits >#{snipEdits}< methodText >#{methodText}<\n\n\n")

        #STOPMETHODFIN
        
        methodText
        
      end.flatten.compact.join("\n")
    rescue Exception => e
      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye,"exception >#{e}<")
      stopINDYNAPP3RESCUE
    end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "METHODS targetModule >#{targetModule.class}< >#{targetModule}< methodTexts >#{methodTexts.class}< >\n#{methodTexts}\n<")

    methodTexts && targetModule.module_eval(methodTexts)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger(eye, eyeTale, "targetModule >#{targetModule.class}< >#{targetModule}< specs >#{methodSpecs.class}< >#{methodSpecs.size}<")

    self
    
  end
  #=end

end
#=end

module Potrubi
  module Mixin
    module Dynamic
    end
  end
end

Potrubi::Mixin::Dynamic.extend(metaclassMethods) # Module methods
Potrubi::Mixin::Dynamic.__send__(:include, metaclassMethods)  # Instance Methods

# must be after dynamic is up

requireList = %w(text-snippets)
requireList.each {|r| require_relative "#{r}"}

__END__


