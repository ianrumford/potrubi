
# potrubi contract dsl

# syntax methods: method

# to ease the creation of new methods using text manipulation

#require_relative '../../bootstrap'

instanceMethods = Module.new do

  #include Potrubi::Klass::Syntax::Mixin::Base

  def alias_klass
    @alias_klass ||= Potrubi::Klass::Syntax::Alias
  end
  
  # New Alias Methods
  # #################

  def new_alias(dslArgs=nil, &dslBlok) # class alias
    eye = :'PotKlsSynMixAli::n_alias'
    #puts("NEW ALIAS")
    newAlias = alias_klass.new(dslArgs, &dslBlok)
    #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(newAlias: newAlias), potrubi_bootstrap_logger_fmt_who_only(newAlias: newAlias, dslArgs: dslArgsNrm, dslBlok: dslBlok))
    newAlias
    ###STOPHERENEWALIASEXIT
  end

  
  def new_aliases(aliasDefs)
    eye = :n_aliases

    potrubi_bootstrap_mustbe_hash_or_croak(aliasDefs)

    newAlias = new_alias do

      aliasDefs.each do | srcMth, tgtMth |

        add_statement_method_alias(srcMth, tgtMth)

      end

    end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(newAlias: newAlias, aliasDefs: aliasDefs))
    #STOPHERENEWMETHODRESCUE

    newAlias
    
  end
 
  
end



module Potrubi
  class Klass
    module Syntax
      module Mixin
        module NewAliases
        end
      end
    end
  end
end

Potrubi::Klass::Syntax::Mixin::NewAliases.__send__(:include, instanceMethods)  # Instance Methods


requireList = %w(../alias)
defined?(requireList) && requireList.each {|r| require_relative "#{r}"}

__END__

