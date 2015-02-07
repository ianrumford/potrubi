
# potrubi mixin dynamic

# dynamic method, etc generation

require_relative '../bootstrap'
require_relative 'dynamic'

metaclassMethods = Module.new do

  include Potrubi::Bootstrap
  include Potrubi::Mixin::Dynamic
  
  def recipe_new(tgtMod, newSpecs, &block)
    dynamic_define_methods(tgtMod, newSpecs) do | newName, newKlass |

      edits = {
        :et_new_name => newName.to_s.downcase,
        :et_new_class => newKlass.to_s,
        :et_new_eyecatcher => "new_#{newName}".downcase,
      }

      newText = <<-'ENDOFMETHOD'
	def new_et_new_name_or_croak(*a, &b)
          r = et_new_class.new(*a, &b)
          logger_ca(:et_new_eyecatcher, logger_fmt_who(:'et_new_name' => r))
          r
        end
        ENDOFMETHOD

        {:edit => edits, :spec => newText}
        
      end
    end

    def recipe_rescue_croak(tgtMod, croakSpecs, &block)
      dynamic_define_methods(tgtMod, croakSpecs) { | rescueName, rescueValue | "def #{rescueName}(*a, &b); #{rescueName}_or_croak(*a, &b) rescue #{rescueValue || 'nil'}; end\n" }
    end

  def recipe_aliases(tgtMod, aliasSpecs, &block)
    dynamic_define_methods(tgtMod, aliasSpecs) { | aliasName, realName | "alias_method :'#{aliasName}', :'#{realName}';\n" }
  end

  def recipe_croak_rescue(targetModule, croakArgs={}, &croakBlok)
    eye = :rcp_crk_rsc
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, "targetModule >#{targetModule.class}< >#{targetModule}< croakArgs >#{croakArgs}<")

    potrubi_bootstrap_mustbe_module_or_croak(targetModule, eye)
    
    knownMethods = targetModule.instance_methods.map(&:to_s)

    includeMethods = (r = croakArgs[:include]) ? [r].flatten.compact.uniq.map(&:to_s) : knownMethods
    excludeMethods = (r = croakArgs[:exclude]) ? [r].flatten.compact.uniq.map(&:to_s) : []

    wantedMethods = includeMethods - excludeMethods

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "wantedMethods >#{wantedMethods}< knownMethods >#{knownMethods}< includeMethods >#{includeMethods}< excludeMethods >#{excludeMethods}<")
    
    croakRegexp = Regexp.new(/(.*)_or_croak\?*/)
    croakMethods = wantedMethods.map {|m| (mD = m.match(croakRegexp)) ? mD[1] : nil }.compact

    croakUndefinedMethods = croakMethods.reject {|m| knownMethods.include?(m) } # method already defined?
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, "croakUndefinedMethods >#{croakUndefinedMethods.class}< >#{croakUndefinedMethods}< croakMethods >#{croakMethods}<")

    croakUndefinedMethodsHash = Hash[*croakUndefinedMethods.map {|m| [m, nil]}.flatten]
    
    recipe_rescue_croak(targetModule, croakUndefinedMethodsHash)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, "targetModule >#{targetModule.class}< >#{targetModule}< croakUndefinedMethods >#{croakUndefinedMethodsHash}<")

    self
  end

end

module Potrubi
  module Mixin
    module DynamicRecipes
    end
  end
end

Potrubi::Mixin::DynamicRecipes.extend(metaclassMethods)
Potrubi::Mixin::DynamicRecipes.__send__(:include, metaclassMethods)  # Instance Methods


__END__

