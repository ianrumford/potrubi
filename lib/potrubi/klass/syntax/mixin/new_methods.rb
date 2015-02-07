
# potrubi contract dsl

# syntax methods: method

# to ease the creation of new methods using text manipulation

#require_relative '../../bootstrap'



#__END__

instanceMethods = Module.new do

  #include Potrubi::Klass::Syntax::Mixin::Base
  include Potrubi::Klass::Syntax::Mixin::NewSnippets

  # New Method Methods
  # ##################


  def method_klass
    @method_klass ||= Potrubi::Klass::Syntax::Method
  end
  
  def new_method(dslArgs=nil, &dslBlok)
    eye = :'PotKlsSynMixNewMths::n_mth'
    puts("NEW METHOD USING SNIPPETS X1")
    #potrubi_bootstrap_mustbe_symbol_or_croak(dslAttr, eye, "dslAttr is what?")

    newMethod = method_klass.new(dslArgs)
        puts("NEW METHOD USING SNIPPETS X2")
    #newSnippet = snippet_klass.new(parent: newMethod.parent, delegate: newMethod, &dslBlok)
    # use same synels collection
    newSnippet = snippet_klass.new(synels: newMethod.synels, parent: newMethod.parent, delegate: newMethod, &dslBlok)

        puts("NEW METHOD USING SNIPPETS X3")
    #STOPHERENEWMETHODPOSTNEWSNIPOET
    #newMethod.statements = newSnippet.statements
    #newMethod.add_statements_or_croak(newSnippet.statements)

    snipSyns = newSnippet.synels
    #STOPHEREPREX3A
    puts("NEW METHOD USING SNIPPETS X3a SYNELS >#{snipSyns.class}< >\n#{snipSyns.to_s}<")
    #STOPHEREPOISTX3Q
    
    #newMethod.add_synels_or_croak(newSnippet.synels)
    #newMethod.synels = newSnippet.synels
    
    puts("NEW METHOD USING SNIPPETS X4")
    #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(newMethod: newMethod), potrubi_bootstrap_logger_fmt_who_only(dslAttr: dslAttr, dslArgs: dslArgsNrm, dslBlok: dslBlok))
    newMethod
    #STOPHERENEWMETHODEXIT
  end

  def keepkeepkeep_new_method(dslArgs=nil, &dslBlok)
    eye = :'PotKlsSynSpr::n_mth'
    #puts("NEW METHOD")
    #potrubi_bootstrap_mustbe_symbol_or_croak(dslAttr, eye, "dslAttr is what?")
    newMethod = method_klass.new(dslArgs, &dslBlok)
    #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(newMethod: newMethod), potrubi_bootstrap_logger_fmt_who_only(dslAttr: dslAttr, dslArgs: dslArgsNrm, dslBlok: dslBlok))
    newMethod
    ###STOPHERENEWMETHODEXIT
  end


  
  def new_method_rescue(*methodNames)
    eye = :n_mth_rsc

    newMethod = new_method do

      methodNameRescue = name_builder_method(*methodNames)
      methodNameCroak  = name_builder_method_or_croak(methodNameRescue)
      
      set_name(methodNameRescue)
      set_signature_generic
      add_statement(
                    new_statement_method_call(methodNameCroak, get_signature),
                    ' ',
                    new_statement_rescue_nil,
                    #' rescue nil'
                    )
    end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(newMethod: newMethod, name: methodNames))
    #STOPHERENEWMETHODRESCUE

    newMethod
  end


  def new_method_caller_callee(callArgs, &callBlok)
    eye = :n_mth_caller_callee
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who_only(callArgs: callArgs, callBlok: callBlok))

    potrubi_bootstrap_mustbe_hash_or_croak(callArgs, eye)

    newMethod = new_method do
      
      nameCallee =  name_builder_method(callArgs[:callee])
      nameCaller =  name_builder_method(callArgs[:caller])
      
      potrubi_bootstrap_mustbe_string_or_croak(nameCaller, eye)
      potrubi_bootstrap_mustbe_string_or_croak(nameCallee, eye)

      signCaller =  callArgs[:caller_sig]
      argsCalleeNom =  callArgs[:callee_args]

      argsCallee = case
                   when Kernel.block_given? then callBlok.call(signCaller)
                   when (! argsCalleeNom.nil?) then argsCalleeNom
                   else
                     potrubi_bootstrap_surprise_exception(nameCaller, eye, "no args for caller")
                   end
      
      

      set_name(nameCaller)
      set_signature(signCaller)
      add_statement_method_call(nameCallee,
                                *argsCallee,
                                )

    end

    #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(newMethod: newMethod), potrubi_bootstrap_logger_fmt_who_only(nameCaller: nameCaller, nameCallee: nameCallee, signCaller: signCaller, argsCallee: argsCallee))
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(newMethod: newMethod), potrubi_bootstrap_logger_fmt_who_only(callArgs: callArgs, callBlok: callBlok))
    #STOPHERENEWMETHODCALLMULTFROMSINGLE

    newMethod
  end
  
  
end



module Potrubi
  class Klass
    module Syntax
      module Mixin
        module NewMethods
        end
      end
    end
  end
end

Potrubi::Klass::Syntax::Mixin::NewMethods.__send__(:include, instanceMethods)  # Instance Methods

requireList = %w(../method)
defined?(requireList) && requireList.each {|r| require_relative "#{r}"}
###require "potrubi/klass/syntax/braket"

__END__

