
# potrubi contract dsl

# syntax mixin: statements

# to ease the creation of new methods using text snippets

#require_relative '../../bootstrap'
require_relative '../../../mixin/util'

#requireList = %w(base brakets)
#requireList.each {|r| require_relative "#{r}"}
###require "potrubi/klass/syntax/braket"

instanceMethods = Module.new do

  #include Potrubi::Klass::Syntax::Mixin::Base
  include Potrubi::Mixin::Util
  
  # New Statement Methods
  # #####################

  def statement_klass
    @statement_klass ||= Potrubi::Klass::Syntax::Statement
  end

  def new_statements(*statements, &stmBlok)
    eye = :'PotKlsSynMixNewStms::n_stms'

    #puts("NEW STMS")

    newStms = statements.map {|s| new_statement(s) }

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who_only(newStms: newStms), potrubi_bootstrap_logger_fmt_who_only(statements: statements, stmBlok: stmBlok))

    newStms
    #STOPHERENEWSTMEXIT
  end
  
  def new_statement(*stmArgs, &stmBlok)
    eye = :'PotKlsSynMixNewStms::n_stm'

    #puts("NEW STM")

    newStatement = statement_klass.new(&stmBlok)

    stmArgs.empty? || newStatement.add_elements(*stmArgs)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who_only(newStm: newStatement), potrubi_bootstrap_logger_fmt_who_only(stmArgs: stmArgs, stmBlok: stmBlok))

    newStatement
    #STOPHERENEWSTMEXIT
  end

  def new_statement_method_call(methodName, *stmArgs, &stmBlok)
    eye = :'PotKlsSynMixNewStms::n_stm_mtd_call'

    #puts("NEW STM MTH CALL ")

    newStatement = new_statement(methodName, &stmBlok)

    stmArgs.empty? || newStatement.add_elements('(', stmArgs.flatten.compact.join(','), ')')

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who_only(newStm: newStatement), potrubi_bootstrap_logger_fmt_who_only(methodName: methodName, stmArgs: stmArgs, stmBlok: stmBlok))

    newStatement
    #STOPHERENEWSTMMTHCALLEXIT
  end

  def new_statement_method_alias(srcMethod, tgtMethod)
    eye = :'PotKlsSynMixNewStms::n_stm_mtd_alias'
    newStm = new_statement("alias_method :'",
                           tgtMethod,
                           "', :'",
                           srcMethod,
                           "'",
                           )
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who_only(newStm: newStm), potrubi_bootstrap_logger_fmt_who_only(srcMethod: srcMethod, tgtMethod: tgtMethod))
    newStm
    #STOPHERENEWSTMMTHCALLEXIT
  end
  
  # New Statements Assignments
  # ##########################

  def new_statement_assign(varName, *statementElements)
    eye = :'PotKlsSynMixNewStms::n_stm_agn'
    #newStm = new_statement(varName, ' = ', statementElements)
    #newStm = new_statement(varName, ' = ', new _statement_in_parentheses(statementElements))

    newStm = new_statement(varName,
                           ' = ',
                           (statementElements.size > 1) ? new_statement_in_parentheses(statementElements) : new_statement(statementElements)

                           )
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(varName: varName, newStm: newStm, statementElements: statementElements))
    #STOPHEREAGNINSTVAR
    newStm
  end

  def new_statement_assign_if_not_set(varName, *statementElements)
    eye = :'PotKlsSynMixNewStms::n_stm_agn_not_set'
    #newStm = new_statement(varName, ' ||= ', statementElements)
    #newStm = new_statement(varName, ' ||= ', new_statement_in_parentheses(statementElements))

    newStm = new_statement(varName,
                           ' ||= ',
                           (statementElements.size > 1) ? new_statement_in_parentheses(statementElements) : new_statement(statementElements)
                           )
   
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(varName: varName, newStm: newStm, statementElements: statementElements))
    #STOPHEREAGNINSTVAR
    newStm
  end
  
  def new_statement_assign_instance_variable(varName, *statementElements)
    eye = :'PotKlsSynMixNewStms::n_stm_agn_inst_var'
    newStm = new_statement_assign("@#{varName}", statementElements)
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(varName: varName, newStm: newStm, statementElements: statementElements))
    #STOPHEREAGNINSTVAR
    newStm
  end

  def new_statement_assign_instance_variable_if_not_set(varName, *statementElements)
    eye = :'PotKlsSynMixNewStms::n_stm_agn_inst_var_if_not_set'
    newStm = new_statement_assign_if_not_set("@#{varName}", statementElements)
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(varName: varName, newStm: newStm, statementElements: statementElements))
    newStm
  end

  def new_statement_assign_local_variable(varName, *statementElements)
    eye = :'PotKlsSynMixNewStms::n_stm_agn_locl_var'
    newStm = new_statement_assign("#{varName}", statementElements)
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(varName: varName, newStm: newStm, statementElements: statementElements))
    #STOPHEREAGNINSTVAR
    newStm
  end
  
  # New Statements Logger
  # #####################
  
  def new_statement_logger_method_entry(loggerArgs=nil)
    new_statement_logger_call(:me, loggerArgs)
  end

  def new_statement_logger_method_exit(loggerArgs=nil)
    new_statement_logger_call(:mx, loggerArgs)
  end

  def new_statement_logger_method_call(loggerArgs=nil)
    new_statement_logger_call(:ca, loggerArgs)
  end
  
  def new_statement_logger_call(loggerMth, loggerArgs=nil)
    eye = :'PotKlsSynMixNewStms::n_stm_lgr_call'

    loggerFmts =
      case loggerArgs
      when NilClass then nil
      when Hash then
        
        potrubi_bootstrap_mustbe_hash_or_croak(loggerArgs, eye)
        
        loggerArgs.map do | lgrMth, lgrArg |
        ['potrubi_bootstrap_logger_fmt_',
         lgrMth,
         '(',
         new_statement_logger_args_stringify(lgrArg),
         #lgrArg.to_s,
         ')']
      end

      else
        potrubi_bootstrap_surprise_exception(loggerArgs, eye, "loggerArgs is what?")
      end
    
    newStatement = new_statement('$DEBUG && potrubi_bootstrap_logger_',
                  loggerMth,
                  '(eye,',
                  loggerFmts,
                  ')'
                  )

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(loggerMth: loggerMth, newStm: newStatement, loggerArgs: loggerArgs))

    newStatement
    #STOPHEREADDSTMLGRCALLEXIT
  end

  # to_s no good for this
  def new_statement_logger_args_stringify(loggerArgs=nil)
    eye = :'PotKlsSynMixNewStms::n_stm_lgr_args_stringify'

    loggerFmts = case loggerArgs
                 when NilClass then nil
                 when Hash
                   
                   ###potrubi_bootstrap_mustbe_hash_or_croak(loggerArgs, eye)
                   
                   loggerFmt1 = loggerArgs.map { | lgrEye, lgrArg | [lgrEye, ': ', lgrArg, ','] }.flatten
                   loggerFmt1.pop # last comma
                   ['{', loggerFmt1, '}'].flatten.compact.join('')

                 else
                   potrubi_bootstrap_surprise_exception(loggerArgs, eye, "loggerArgs is what?")
                 end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(loggerFmts: loggerFmts, loggerArgs: loggerArgs))

    loggerFmts
    
  end

  # New Statements Contracts
  # ########################

  def new_statement_contracts(conTracts=nil)
    eye = :'PotKlsSynMixNewStms::n_stm_ctxs'
    potrubi_bootstrap_mustbe_hash_or_croak(conTracts, eye)

    newStatements = conTracts.map do | varName, ctxName |
      
      new_statement('potrubi_bootstrap_mustbe_',
                                  ctxName.to_s.downcase,
                                  '_or_croak(',
                                  varName,
                                  ', eye)',
                                  )
    end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(conTracts: conTracts))

    newStatements
    
  end

  # New Statements Exceptions
  # #########################

  def new_statement_exception(exceptionType, exceptionVar, *exceptionTelltales)
    exceptionMethod = ["potrubi_bootstrap", exceptionType.to_s, 'exception'].join('_').downcase
    new_statement_method_call(exceptionMethod, exceptionVar, *exceptionTelltales)
  end

  def new_statement_surprise_exception(*a, &b)
    new_statement_exception(:surprise, *a, &b)
  end

  def new_statement_missing_exception(*a, &b)
    new_statement_exception(:missing, *a, &b)
  end
  
  def new_statement_duplicate_exception(*a, &b)
    new_statement_exception(:duplicate, *a, &b)
  end

  # New Statements If
  # #################

  def new_statement_if_ternary(predicate, clauseTrue, clauseFalse)
    new_statement(new_statement_in_parentheses(predicate),
                  ' ? ',
                  new_statement_in_parentheses(clauseTrue),
                  ' : ',
                  new_statement_in_parentheses(clauseFalse),
                  )
  end
  
  # New Predicate and Exception
  # ###########################

  def new_statement_predicate_and_exception(predicate, exceptionType, *exceptionTelltales)
    new_statement(new_statement_in_parentheses(predicate),
                  ' && ',
                  new_statement_exception(exceptionType, *exceptionTelltales),
                  )
  end

  def new_statement_predicate_and_surprise_exception(predicate, exceptionVar='self', *exceptionTelltales)
    new_statement_predicate_and_exception(predicate, :surprise, exceptionVar, :eye, *exceptionTelltales)
  end

  def new_statement_predicate_and_duplicate_exception(predicate, exceptionVar='self', *exceptionTelltales)
    new_statement_predicate_and_exception(predicate, :duplicate, exceptionVar, :eye, *exceptionTelltales)
  end

  def new_statement_predicate_and_missing_exception(predicate, exceptionVar='self', *exceptionTelltales)
    new_statement_predicate_and_exception(predicate, :missing, exceptionVar, :eye, *exceptionTelltales)
  end
  
  # New Predicate and Action
  # ########################

  def new_statement_predicate_and_action(predicate, action)
    new_statement(new_statement_in_parentheses(predicate),
                  ' && ',
                  new_statement_in_parentheses(action),
                  )
  end  


  
  # New Statements Misc
  # ###################

  def new_statement_end
    new_statement(:end)
  end

  def new_statement_self
    new_statement(:self)
  end

  def new_statement_rescue(*a)
    new_statement(:rescue, ' ', *a)
  end

  def new_statement_rescue_nil
    new_statement_rescue(:nil)
  end

  def new_statement_in_parentheses(*a)
    new_statement('(', *a, ')')
  end
  

  # New Statements Iterators
  # ########################

  def new_statement_iterator_read(iterName, *iterArgs, &iterBlok)
    eye = :'PotKlsSynMixNewStms::iter_read'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(iterName: iterName, iterArgs: iterArgs, iterBlok: iterBlok))

    iterKeys = [:source, :key, :value]
    
    iterCtrl = new_statement_iterator_args(iterKeys,  *iterArgs)

    iterSrc = potrubi_bootstrap_mustbe_symbol_or_croak(iterCtrl[:source], eye, 'no source given')

    blokArgs = [:key, :value].map {|a| r = iterCtrl[a]; r ? potrubi_bootstrap_mustbe_symbol_or_croak(r, eye, "no >#{a}<  given") : nil}.compact 

    iterStm = new_statement(iterSrc,
                            '.',
                            iterName,
                            ' do | ',
                            blokArgs.join(', '),
                            ' |'
                            )

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(iterStm: iterStm, iterName: iterName, iterArgs: iterArgs, iterBlok: iterBlok))  
    
    iterStm  
  end
  alias_method :new_statement_iterator_each, :new_statement_iterator_read

  def new_statement_iterator_rite(iterName, *iterArgs, &iterBlok)
    eye = :'PotKlsSynMixNewStms::iter_rite'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(iterName: iterName, iterArgs: iterArgs, iterBlok: iterBlok))

    iterKeys = [:source, :key, :value, :target]
    
    iterCtrl = new_statement_iterator_args(iterKeys,  *iterArgs)

    iterSrc = potrubi_bootstrap_mustbe_symbol_or_croak(iterCtrl[:source], eye, 'no source given')
    iterTgt = potrubi_bootstrap_mustbe_symbol_or_croak(iterCtrl[:target], eye, 'no target given')

    blokArgs = [:key, :value].map {|a| r = iterCtrl[a]; r ? potrubi_bootstrap_mustbe_symbol_or_croak(r, eye, "no >#{a}<  given") : nil}.compact 

    iterRite = new_statement(iterSrc,
                            '.',
                            iterName,
                            ' do | ',
                            blokArgs.join(', '),
                            ' |'
                            )

    iterStm = new_statement_assign(iterTgt, iterRite)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(iterStm: iterStm, iterName: iterName, iterArgs: iterArgs, iterBlok: iterBlok))  
    
    iterStm  
  end
  alias_method :new_statement_iterator_map, :new_statement_iterator_rite

  def new_statement_iterator_rite_with_object(iterName, *iterArgs, &iterBlok)
    eye = :'PotKlsSynMixNewStms::iter_rite_with_oject'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(iterName: iterName, iterArgs: iterArgs, iterBlok: iterBlok))

    iterKeys = [:source, :key, :value, :target, :object, :object_init]
    
    iterCtrl = new_statement_iterator_args(iterKeys,  *iterArgs)

    iterSrc = potrubi_bootstrap_mustbe_symbol_or_croak(iterCtrl[:source], eye, 'no source given')
    iterTgt = potrubi_bootstrap_mustbe_symbol_or_croak(iterCtrl[:target], eye, 'no target given')
    iterObj = potrubi_bootstrap_mustbe_symbol_or_croak(iterCtrl[:object], eye, 'no object given')
    iterObjInit = potrubi_bootstrap_mustbe_symbol_or_croak(iterCtrl[:object_init], eye, 'no object_init given')

    blokArgs = [:key, :value].map {|a| r = iterCtrl[a]; r ? potrubi_bootstrap_mustbe_symbol_or_croak(r, eye, "no >#{a}<  given") : nil}.compact 

    iterRite = new_statement(iterSrc,
                             '.',
                             iterName,
                             '(',
                             iterObjInit,
                             ')',
                             ' do | ',
                             if blokArgs.size > 1 then
                               ['(', blokArgs.join(', '), ')'].join
                             else
                               blokArgs[0]
                             end,
                             ', ',
                             
                             iterObj,
                             ' |'
                             )

    iterStm = new_statement_assign(iterTgt, iterRite)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(iterStm: iterStm, iterName: iterName, iterArgs: iterArgs, iterBlok: iterBlok))  
    
    iterStm  
  end
  alias_method :new_statement_iterator_each_with_object, :new_statement_iterator_rite_with_object

  
  
  
  # make sense of the args
  def new_statement_iterator_args(iterKeys, *iterArgs, &iterBlok)
    eye = :'PotKlsSynMixNewStms::iter_args'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(iterKeys: iterKeys, iterArgs: iterArgs, iterBlok: iterBlok))

    potrubi_bootstrap_mustbe_array_or_croak(iterKeys, eye)

    (iterKeys.size >= iterArgs.size) || potrubi_bootstrap_missing_exception(iterKeys, eye, "iterKeys >#{iterKeys}< iterArgs >#{iterArgs}< too few or many of each")

    iterCtrl = potrubi_util_merge_hashes_or_croak(new_statement_iterator_args_mapper(iterKeys, *iterArgs, &iterBlok))

    potrubi_bootstrap_mustbe_empty_or_croak(iterCtrl.keys - iterKeys, eye, "unexpected keys >#{iterCtrl}<")
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(iterCtrl: iterCtrl, iterKeys: iterKeys, iterArgs: iterArgs, iterBlok: iterBlok))  
    
    potrubi_bootstrap_mustbe_hash_or_croak(iterCtrl, eye) 
  end
  
  # recursive
  # produces an array of hases with the nex key mapped to new args
  def new_statement_iterator_args_mapper(iterKeys, *iterVals, &iterBlok)
    eye = :'PotKlsSynMixNewStms::iter_args_mapr'
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(iterKeys: iterKeys, iterVals: iterVals, iterBlok: iterBlok))
    potrubi_bootstrap_mustbe_array_or_croak(iterKeys, eye)
    
    iterResult =
      case
      when iterKeys.empty? || iterVals.empty? then nil
      else
        iterNextVal = iterVals[0]
        case iterNextVal
        when Hash then [iterNextVal] # last values
        else
          
        ###when Symbol then
          iterKey = potrubi_bootstrap_mustbe_symbol_or_croak(iterKeys[0], eye)
          [ {iterKey => iterVals[0]},
            new_statement_iterator_args_mapper(iterKeys[1 .. -1], *iterVals[1 .. -1], &iterBlok)
          ].flatten

        ###else
          ###potrubi_bootstrap_surprise_exception(iterNextVal, eye, "iterNextVal is what?")
        end
      end

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, potrubi_bootstrap_logger_fmt_who(iterResult: iterResult, iterKeys: iterKeys, iterVals: iterVals, iterBlok: iterBlok))

    iterResult ? potrubi_bootstrap_mustbe_array_or_croak(iterResult, eye) : nil

  end
  
end


module Potrubi
  class Klass
    module Syntax
      module Mixin
        module NewStatements
        end
      end
    end
  end
end

Potrubi::Klass::Syntax::Mixin::NewStatements.__send__(:include, instanceMethods)  # Instance Methods


requireList = %w(../statement)
defined?(requireList) && requireList.each {|r| require_relative "#{r}"}

__END__


      ##iterator :each, :addValues, :nVal, :vVal, :fred # fails as expected
      iterator :each, :addValues, :nVal, :vVal
      iterator :each, :addValues, :nVal
      iterator :each, source: :addValues, key: :nVal, value: :vVal

      iterator :each, :addValues, :nVal, :vVal do

        puts("#{eye} IN ITER BODY")
        
      end

      iterator :map, :addValues, :nVal, :vVal, :mapValues
      ##iterator :map, :addValues, :nVal, :mapValues # will fail on value / target confusion
      iterator :map, :addValues, :nVal, target: :mapValues


      iterator :each_with_object, :addValues, :nVal, :vVal, :mapValues, :h, :'{}'

            iterator :each_with_object, :addValues, :nVal, target: :mapValues, object: :h, object_init: :'{}'
      
      STOPHERETESTINGITER
      
      iterator :map, :addValues, :nVal

            iterator :each_with_hash, :zzzzaddValues, :nVal
      
