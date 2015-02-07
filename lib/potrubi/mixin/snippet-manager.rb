
# potrubi text snippets

# looks up snippets by name in dictionaries

# values normally code to be dynamically dused by e.g. Dynamic and COntract

require_relative '../bootstrap'

mixinContent = Module.new do
  
  include Potrubi::Bootstrap

  # Dictionary Methods
  # ##################

  def dictionary_index
    @dictionary_index ||= {}
  end
  def dictionary_index=(dictNew)
    @dictionary_index = potrubi_bootstrap_mustbe_hash_or_croak(dictNew)
  end

  def add_dictionaries_to_index(snipDicts)
    potrubi_bootstrap_mustbe_hash_or_croak(snipDicts)
    snipIndex = dictionary_index
    newsnipIndex = snipIndex.merge(snipDicts.each_with_object({}) {|(k,v),h| h[normalise_dictionary_name(k)] = potrubi_bootstrap_mustbe_hash_or_croak(v) })
    self.dictionary_index = newsnipIndex
  end
  
  def normalise_dictionary_name(dictName)
    dictName.to_s.to_sym
  end
  
  def is_value_dictionary_name?(dictName)
    dictionary_index[normalise_dictionary_name(dictName)]
  end

  def find_dictionary_home_or_croak
    eye = :'f_dict_home'
    dictHome = File.expand_path(__FILE__ + "/../snippet-dictionaries")
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, "dictHome >#{dictHome.class}< >#{dictHome}<")
    dictHome
  end
  
  def find_dictionary_or_croak(dictName, &dictBlok)
    eye = :'f_dict'
    eyeTale = 'FIND SNIP DICT'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "dictName >#{dictName.class}< >#{dictName.class}< dictBlok >#{dictBlok}<")

    dictHash = case dictName
               when Hash then dictName
               when String, Symbol then
                 case
                 when (r = is_value_dictionary_name?(dictName)) then r
                 else
                 potrubi_bootstrap_surprise_exception(dictName, "dictName is not a dictionary")
                 end
               else
                 potrubi_bootstrap_surprise_exception(dictName, "dictName is what?")
               end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, "dictName >#{dictName.class}< >#{dictName}< dictHash >#{dictHash.size}<")

    # dictionaries must be hashes
    
    potrubi_bootstrap_mustbe_hash_or_croak(dictHash, eye, "dictName >#{dictName}< not a hash")
    
  end

  def load_home_dictionaries_or_croak(snipDicts)
    dictHome = find_dictionary_home_or_croak
    snipDictsHome = potrubi_bootstrap_mustbe_hash_or_croak(snipDicts).each_with_object({}) { | (k,v), h| h[k] = File.join(dictHome, "#{v}.rb") }
    load_dictionaries_or_croak(snipDictsHome)
  end
  
  def load_dictionaries_or_croak(snipDicts)
    potrubi_bootstrap_mustbe_hash_or_croak(snipDicts).each {|k,v| load_dictionary_or_croak(k, v) }
  end
  
  def load_dictionary_or_croak(dictName, dictPath, &dictBlok)
    eye = :'l_dict'
    eyeTale = 'LOAD DICT FILE'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "dictName >#{dictName.class}< >#{dictName}< dictPath >#{dictPath.class}< >#{dictPath}< dictBlok >#{dictBlok}<")

    ### let require work it ok potrubi_bootstrap_mustbe_file_or_croak(dictPath, eye, "dictPath not a file")

    dictResult = instance_eval(File.read(dictPath))

    dictHash = case dictResult
               when Hash then dictResult
               when Proc then dictResult.call
               else
                 potrubi_bootstrap_surprise_exception(dictResult, eye, "dictResult is what?")
               end

    potrubi_bootstrap_mustbe_hash_or_croak(dictHash, eye)
    
    dictNameNrm = normalise_dictionary_name(dictName)
    
    add_dictionaries_to_index(dictNameNrm => dictHash)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, "dictName >#{dictNameNrm.class}< >#{dictNameNrm}< dictHash >#{dictHash.size}< >#{dictHash}<")
    
    dictHash
    
  end

  # Snippet Methods
  # ###############
  
  def map_snippets_or_croak(dictName, *snippetList, &snipBlok)
    eye = :'map_snippets'
    eyeTale = 'MAP SNIPPETS'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "dictName >#{dictName}< snippetList >#{snippetList}<  snipBlok >#{snipBlok}<")

    snippetHash = find_snippets_or_croak(dictName, *snippetList)

    snippetMaps = snippetList.flatten(1).map { | snippetName | snippetHash.has_key?(snippetName) ? snippetHash[snippetName] : snippetName }
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, "dictName >#{dictName}<", potrubi_bootstrap_logger_fmt_kls_size(snippetMaps: snippetMaps))
    
    potrubi_bootstrap_mustbe_array_or_croak(snippetMaps, eye)
    
  end

  # looks up a array of possible snippets
  # retruns a hash of snippetName, snippetValue pairs

  # if snippetName not Symbol, ignores

  # if snippetName not present, calls block if given, else exception
  
  def find_snippets_or_croak(dictName, *snippetList, &snipBlok)
    eye = :f_snips
    eyeTale = 'FIND SNIPPETS'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, "dictName >#{dictName}< snippetList >#{snippetList}<  snipBlok >#{snipBlok}<")

    dictHash = find_dictionary_or_croak(dictName)

    snippetMaps = snippetList.flatten(1).uniq.each_with_object({}) do | snippetName, h |
      case snippetName
      when Symbol then
        case
        when dictHash.has_key?(snippetName) then
          snippetValueNom = dictHash[snippetName]
          snippetValueNrm = case snippetValueNom
                            when Proc then
                              dictHash[snippetName] = snippetValueNom.call # update dict
                            else
                              snippetValueNom
                            end
          h[snippetName] = snippetValueNrm
        else
          h[snippetName] = Kernel.block_given? ? snipBlok.call(dictHash, snippetName) : potrubi_bootstrap_mustbe_not_nil_or_croak(dictHash[snippetName], eye, "snippetName >#{snippetName}< not found")
        end
      else
        ###snippetName   # ignore 
      end
    end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, "dictName >#{dictName}< snippetMaps >#{snippetMaps.size}<")
    
    potrubi_bootstrap_mustbe_hash_or_croak(snippetMaps, eye)
    
  end

  
end

module Potrubi
  module Mixin
    module SnippetManager
    end
  end
end

##Potrubi::Mixin::SnippetManager.__send__(:include, mixinContent)  # Instance Methods
Potrubi::Mixin::SnippetManager.extend(mixinContent)  # Module  Methods

# load some dictionaries

#$DEBUG = true
#$DEBUG_POTRUBI_BOOTSTRAP = true


snipDicts = {dynamic_methods: :'methods-text-snippets'}
Potrubi::Mixin::SnippetManager.load_home_dictionaries_or_croak(snipDicts)

__END__
