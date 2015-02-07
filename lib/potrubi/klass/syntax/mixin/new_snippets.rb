
# potrubi contract dsl

# syntax methods: method

# to ease the creation of new methods using text manipulation

#require_relative '../../bootstrap'



#__END__

instanceMethods = Module.new do

  #include Potrubi::Klass::Syntax::Mixin::Base

  def snippet_klass
    @snippet_klass ||= Potrubi::Klass::Syntax::Snippet
  end
  
  # New Snippet Methods
  # ###################

  def new_snippet(snipArgs=nil, &snipBlok) # class snippet
    eye = :'PotKlsSynMixSni::n_snippet'
    #puts("NEW SNIPPET")
    newSnippet = snippet_klass.new(snipArgs, &snipBlok)
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(newSnippet: newSnippet), potrubi_bootstrap_logger_fmt_who_only(snipArgs: snipArgs, snipBlok: snipBlok))
    newSnippet
    #STOPHERENEWSNIPPETEXIT
  end

end

module Potrubi
  class Klass
    module Syntax
      module Mixin
        module NewSnippets
        end
      end
    end
  end
end

Potrubi::Klass::Syntax::Mixin::NewSnippets.__send__(:include, instanceMethods)  # Instance Methods

requireList = %w(../snippet)
defined?(requireList) && requireList.each {|r| require_relative "#{r}"}

__END__

  def new_snippets(snippetDefs)
    eye = :n_snippetes

    potrubi_bootstrap_mustbe_hash_or_croak(snippetDefs)

    newSnippet = new_snippet do

      snippetDefs.each do | srcMth, tgtMth |

        add_statement_method_snippet(srcMth, tgtMth)

      end

    end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(newSnippet: newSnippet, snippetDefs: snippetDefs))
    #STOPHERENEWMETHODRESCUE

    newSnippet
    
  end
