
# potrubi contract dsl

# to ease the creation of a 2d cache (e.g. hash) with named methods
# and using contracts

# Uses conventions for names etc dedined by (in) contract mixin

requireList = %w(../klass/syntax/builder ../mixin/util ../klass/syntax/method)
requireList.each {|r| require_relative "#{r}"}

classMethods = Module.new do

  def prepare_order(*a, &b)
    @prepare_order ||= {
      validate: :validate,
      name: :prepare_name,
      scope: :prepare_scope,
    }.each_with_object({}) {|(k,v),h| h[k] = "#{v}_or_croak".to_sym }
  end

  def syntax_order(*a, &b)
    @syntax_order ||= {
      scope: :scope,
      add: :add,
      delete: :delete,
      each: :each,
      select: :select,
      size: :size,
    }.each_with_object({}) {|(k,v),h| h[k] = "make_syntax_#{v}_or_croak".to_sym }
  end
  
  def syntax_builder
    @syntax_builder ||= Potrubi::Klass::Syntax::Builder
  end
  
end

instanceMethods = Module.new do

  include Potrubi::Mixin::Util

  attr_accessor :singular_name, :plural_name
  attr_accessor :scope
  attr_accessor :key, :key_n, :key_v, :key_validate_method, :key_normalise_method 
  attr_accessor :value, :value_n, :value_v, :value_validate_method, :value_normalise_method
  attr_accessor :cache_variable, :cache_container, :cache_validate_method, :cache_new_method, :cache_instance_variable, :cache_local_variable

  # Find Accessor Methods
  # #####################

  findAttrs = {
    name: :symbol,
    singular_name: :symbol,
    plural_name: :symbol,
    key_v: :symbol,
    value_v: :symbol,
  }

  findAttrsTexts = findAttrs.map do | attrName, attrCtx |
    "def find_#{attrName}_or_croak
       r = potrubi_bootstrap_mustbe_#{attrCtx}_or_croak(#{attrName}, :'f_#{attrName}')
       $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(:'f_#{attrName}', potrubi_bootstrap_logger_fmt_who('#{attrName}' => r))
       r
     end
    "
  end

  findAttrsText  = findAttrsTexts.flatten.compact.join("\n")

  module_eval(findAttrsText)

  findNames = {
    singular: :symbol,
    plural: :symbol,
  }

  findNamesTexts = findNames.map do | nameName, nameCtx |
    "
     def find_#{nameName}_or_croak_method_name_or_croak(*names)
       r = syntax_builder.name_builder_method_or_croak(*names, find_#{nameName}_name_or_croak)
       $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(:'f_#{nameName}_or_croak_method_name', potrubi_bootstrap_logger_fmt_who('#{nameName}' => r))
       r
     end
     def find_#{nameName}_method_name_or_croak(*names)
       r = syntax_builder.name_builder_method(*names, find_#{nameName}_name_or_croak)
       $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(:'f_#{nameName}_method_name', potrubi_bootstrap_logger_fmt_who('#{nameName}' => r))
       r
     end
    "
  end

  findNamesText  = findNamesTexts.flatten.compact.join("\n")

  module_eval(findNamesText)
  
  def edits
    @edits ||= []
  end
  
  def specs
    @specs ||= []
  end

  def add_edits_or_croak(*newEdits)
    eye = :a_edits
    newEditsNrm = newEdits.flatten.compact
    newEdistNrm.each {|a| potrubi_bootstrap_mustbe_hash_or_croak(a) } # validate
    curEdits = edits.concat(newEditsNrm) # concat updates self
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(curEdits: curEdits, newEdits: newEditsNrm))
    curEdits
  end

  def add_specs_or_croak(*newSpecs)
    eye = :a_specs
    newSpecsNrm = newSpecs.flatten.compact
    newSpecsNrm.each {|a| potrubi_bootstrap_mustbe_hash_or_croak(a) } # validate
    curSpecs = specs.concat(newSpecsNrm) # concat updates self
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(curSpecs: curSpecs, newSpecs: newSpecsNrm))
    curSpecs
  end

  def reduce_specs_or_croak
    eye = :'rdc_specs'

    specHash = potrubi_util_reduce_hashes_or_croak(*specs)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(specHash: specHash))
    
    specHash
  end

  def make_syntax_specs_or_croak
    eye = 'DSL:C2d:m_syn_specs'

    syntaxSpecs = reduce_specs_or_croak.values.map {|s| s.to_s }.join("\n")

    syntaxSpecs
    
  end
  
    
  def to_s
    potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLC2d'),  potrubi_bootstrap_logger_fmt(n: name))
  end
  

  def type_handlers
    @type_handlers ||=
      begin
        {
        d2: :prepare,
      }.each_with_object({}) {|(k,v), h| h[k] = "#{v}_or_croak".to_sym }
      end
  end

  def assert_self
    prepare_or_croak
    express
  end
  
  def express
    make_syntax_or_croak
  end
  


  # Prepare Methods
  # ###############


  def prepare_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::pro'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    prepareOrder = self.class.prepare_order(type)

    prepareOrder.each {|k, v| __send__(v, k) }
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    self

  end

  def normalise_cache_name_or_croak(cacheName=nil)
    cacheName ? cacheName.to_s.to_sym : nil
  end

  def pluralise_cache_name_or_croak(cacheSingularName)
    "#{cacheSingularName}_plu_name"
  end

  def singularise_cache_name_or_croak(cachePluralName)
    "#{cachePluralName}_snl_name"
  end
  
  
  def prepare_name_or_croak(prcsArgs=nil, &prcsBlok)
    eye = :'DSLC2d::pre_name'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(prcsArgs: prcsArgs, prcsBlok: prcsBlok))

    cacheName = find_name_or_croak

    cacheSingularName = normalise_cache_name_or_croak(singular_name)
    cachePluralName = normalise_cache_name_or_croak(plural_name)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, 'PRE  NORM', potrubi_bootstrap_logger_fmt_who(cacheName: cacheName, cacheSingularName: cacheSingularName, cachePluralName: cachePluralName))

    # cache name expected to be the plural name
    
    cachePluralName ||= cacheName
    
    cacheSingularName ||= singularise_cache_name_or_croak(cachePluralName)


    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, 'POST NORM', potrubi_bootstrap_logger_fmt_who(cacheName: cacheName, cacheSingularName: cacheSingularName, cachePluralName: cachePluralName))
    
    cacheSingularNameNrm = normalise_cache_name_or_croak(cacheSingularName)
    cachePluralNameNrm = normalise_cache_name_or_croak(cachePluralName)

    potrubi_bootstrap_mustbe_symbol_or_croak(cacheSingularNameNrm)
    potrubi_bootstrap_mustbe_symbol_or_croak(cachePluralNameNrm)
    
    (cacheSingularNameNrm == cachePluralNameNrm) && potrubi_bootstrap_duplicate_exception(cacheSingularNameNrm, eye, "singular and plural names the same")

    self.singular_name = cacheSingularNameNrm
    self.plural_name = cachePluralNameNrm
    
    self

  end
  
  def prepare_scope_or_croak(prcsArgs=nil, &prcsBlok)
    eye = :'DSLC2d::pro_scope'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(prcsArgs: prcsArgs, prcsBlok: prcsBlok))

    cacheName  = name
    cacheScope = scope

    scopeVariable = case cacheScope
                    when :local then "@LOCAL_CACHE_VARIABLE_#{cacheName}_#{rand(1000000000)}".downcase
                    when :global then "$POTRUBI_GLOBAL_CACHE_VARIABLE_#{cacheName}".upcase
                    else
                      potrubi_bootstrap_surprise_exception(cacheScope, eye, "cacheScope >#{cacheScope}< is what?")
                    end

    self.cache_variable = scopeVariable

    self.cache_instance_variable ||= :cache_store # name of the instance variable holding the cache in getter/setter
    self.cache_local_variable ||= :cacheStore # name of the local variable for the cache 

    cacheContainer = (cache_container || :hash).to_s.capitalize

    case cacheContainer
    when 'Hash' then
      self.cache_validate_method ||= 'potrubi_bootstrap_mustbe_hash_or_croak'
      self.cache_new_method ||= '{}'
    else
      self.cache_new_method ||= "#{cacheContainer}.new"
    end
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(cacheName: cacheName, scopeVariable: scopeVariable, cacheScope: cacheScope))

    self

  end  


  # Syntax Methods
  # ##############

  def make_syntax_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxOrder = self.class.syntax_order(type)

    syntaxOrder.each {|k, v| __send__(v, k) }

    make_syntax_specs_or_croak
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    self

  end

  # Scope Syntax Methods
  # ####################
  
  def make_syntax_scope_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_scope'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder
    
    cacheName = find_name_or_croak

    cacheVariable = cache_variable
    cacheInstanceVariable = cache_instance_variable
    cacheNewMethod = cache_new_method
    cacheValidateMethod = cache_validate_method
    
    syntaxScopeGetter = syntaxBuilder.new_method do 

      getter_name cacheName

      getter_eye cacheName

      syntaxCacheVariable = named_expression :assign_if_not_set, cacheVariable, cacheNewMethod
      
      assign_instance_variable cacheInstanceVariable, syntaxCacheVariable

      syntaxCacheInstanceVariable = instance_variable cacheInstanceVariable

      logger_call who_only: {cacheInstanceVariable =>  syntaxCacheInstanceVariable}
      
      result syntaxCacheInstanceVariable

    end
    
    syntaxScopeSetter = nil

    syntaxScopeSetter = syntaxBuilder.new_method do
      
      setter_name cacheName
      
      setter_eye cacheName
      
      signature :newCache

      syntaxCacheInstanceVariable = instance_variable cacheInstanceVariable
      
      assign_instance_variable cacheInstanceVariable,
                               named_expression(:method_call, cacheValidateMethod, get_signature)
                                                                       

      logger_call who_only: {cacheInstanceVariable =>  syntaxCacheInstanceVariable}
      
      result syntaxCacheInstanceVariable

    end
    
    add_specs_or_croak(scope_getter: syntaxScopeGetter, scope_setter: syntaxScopeSetter)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    self

  end

  # Add Syntax Methods
  # ##################

  # add is semantically merge
  
  def normalise_and_validate_method_map
    @normalise_and_validate_method_map ||= { key_normalise_method: :nVal,
      value_normalise_method: :vVal,
      key_validate_method: :nVal,
      value_validate_method: :vVal,
    }
  end
  
  def make_syntax_add_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_add'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder

    self.key_normalise_method = 'key_norm_thd' # TESTING
    self.value_validate_method = 'val_val_mth'
    
    add_specs_or_croak(add_multiple_or_croak: make_syntax_add_plural_or_croak,
                       add_multiple_rescue: syntaxBuilder.new_method_rescue(:add, find_plural_name_or_croak),
                       add_single_or_croak:
                       syntaxBuilder.new_method_caller_callee(caller: find_singular_or_croak_method_name_or_croak(:add),
                                                              callee: find_plural_or_croak_method_name_or_croak(:add),
                                                              caller_sig: [:x, :y],
                                                              callee_args: '{x => y}',
                                                              ),
                       add_singular_rescue: syntaxBuilder.new_method_rescue(:add, find_singular_name_or_croak),

                       add_merge_aliases:
                       syntaxBuilder.new_aliases(find_plural_or_croak_method_name_or_croak(:add) => find_plural_method_name_or_croak(:merge),
                                                 )
                                                 
                       )

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    self

  end

  def make_syntax_add_plural_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_add_plu'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder

    cacheName = find_name_or_croak
    cachePluralName = find_plural_name_or_croak

    cacheInstanceVariable = cache_instance_variable
    cacheLocalVariable = cache_local_variable
    
    syntaxAddPLUOrCroak = syntaxBuilder.new_method(parent: self) do

      syntaxCacheInstanceVariable = instance_variable cacheInstanceVariable
      
      croak_name :add, cachePluralName

      set_eye :a, cachePluralName

      signature :args_and_block, :add

      contracts addArgs: :hash

      assign_local_variable cacheLocalVariable, name_builder_method_getter(cacheName)

      iterator :each, :addValues, :nVal, :vVal do

        snippet "
        #{cacheLocalVariable}[nVal] = case
        when (r = #{cacheInstanceVariable}.has_key?(nVal)) then
          Kernel.block_given? ? addBlok.call(nVal, r, vVal) : potrubi_bootstrap_duplicate_exception(nVal, eye, 'nVal seen twice')
        else
          vVal
         end
        "
                 
      end
      
      logger_call who_only: {cacheInstanceVariable =>  syntaxCacheInstanceVariable}
      
      set_result_self

    end  
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxAddPLUOrCroak

  end

  # Delete Syntax Methods
  # ##################

  def make_syntax_delete_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_delete'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder

    self.key_normalise_method = 'key_norm_thd' # TESTING
    self.value_validate_method = 'val_val_mth'
    
    add_specs_or_croak(
                          delete_multiple_or_croak: make_syntax_delete_plural_or_croak,
                          delete_multiple_rescue: syntaxBuilder.new_method_rescue(:delete, find_plural_name_or_croak),
                          
                          delete_single_or_croak:
                          syntaxBuilder.new_method_caller_callee(caller: find_singular_or_croak_method_name_or_croak(:delete),
                                                                 callee: find_plural_or_croak_method_name_or_croak(:delete),
                                                                 caller_sig: [:x, :y],
                                                                 callee_args: '{x => y}',
                                                                 ),
                          delete_singular_rescue: syntaxBuilder.new_method_rescue(:delete, find_singular_name_or_croak),


                          
                          )

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    self

  end

  def make_syntax_delete_plural_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_delete_plu'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder

    cacheName = find_name_or_croak
    cachePluralName = find_plural_name_or_croak

    cacheInstanceVariable = cache_instance_variable
    cacheLocalVariable = cache_local_variable
    
    syntaxDeletePLUOrCroak = syntaxBuilder.new_method(parent: self) do

      syntaxCacheInstanceVariable = instance_variable cacheInstanceVariable
      
      croak_name :delete, cachePluralName

      set_eye :d, cachePluralName

      signature :values_and_block, :del

      assign_local_variable cacheLocalVariable, name_builder_method_getter(cacheName)

      snippet "
        deleteResult = delValues.flatten.compact.each_with_object({}) {|k,h| #{cacheLocalVariable}.has_key?(k) && (h[k] = #{cacheLocalVariable}[k]) }
        "
       
      logger_call who_only: {'deleteResult' =>  :deleteResult}
      
      result :deleteResult

    end  
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxDeletePLUOrCroak

  end

  
  # Each Syntax Methods
  # ###################

  def make_syntax_each_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_each'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder

    add_specs_or_croak(each: make_syntax_each_singular_or_croak)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    self

  end

  def make_syntax_each_singular_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_each_snl'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder

    cacheName = find_name_or_croak
    cacheSingularName = find_singular_name_or_croak

    cacheInstanceVariable = cache_instance_variable
    cacheLocalVariable = cache_local_variable
    
    syntaxEachSNLOrCroak = syntaxBuilder.new_method(parent: self) do

      name :each, cacheSingularName

      set_eye :e, cacheSingularName

      signature :args_and_block, :each

      assign_local_variable cacheLocalVariable, name_builder_method_getter(cacheName)
 
      snippet "
      eachResult = case
      when Kernel.block_given? then
         #{cacheLocalVariable}.each {|v| yield v }
         self
      else
        #{cacheLocalVariable}.to_enum(:each)
      end
        "
      
      logger_call who_only: {'eachResult' => :eachResult}
      
      result :eachResult

    end  
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxEachSNLOrCroak

  end

  # Select / Reject Syntax Methods
  # ##############################

  def make_syntax_select_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_select'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder

    add_specs_or_croak(select: make_syntax_select_plural_or_croak,
                       reject: make_syntax_reject_plural_or_croak)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    self

  end

  def make_syntax_select_plural_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_select_snl'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder

    cacheName = find_name_or_croak
    cachePluralName = find_plural_name_or_croak

    cacheLocalVariable = cache_local_variable
    
    syntaxSelectPLUOrCroak = syntaxBuilder.new_method(parent: self) do

      name :select, cachePluralName

      set_eye :sel, cachePluralName

      signature :args_and_block, :sel

      assign_local_variable cacheLocalVariable, name_builder_method_getter(cacheName)
 
      snippet "
      selectResult = case
      when Kernel.block_given? then #{cacheLocalVariable}.select {|v| yield v }
      else
        #{cacheLocalVariable}.to_enum(:each)
      end
        "
      
      logger_call who_only: {'selectResult' => :selectResult}
      
      result :selectResult

    end  
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxSelectPLUOrCroak

  end

  def make_syntax_reject_plural_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_reject_snl'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder

    cacheName = find_name_or_croak
    cachePluralName = find_plural_name_or_croak
    cacheLocalVariable = cache_local_variable
    
    syntaxRejectPLUOrCroak = syntaxBuilder.new_method(parent: self) do

      name :reject, cachePluralName

      set_eye :rej, cachePluralName

      signature :args_and_block, :rej

      assign_local_variable cacheLocalVariable, name_builder_method_getter(cacheName)
 
      snippet "
      rejectResult = case
      when Kernel.block_given? then #{cacheLocalVariable}.reject {|v| yield v }
      else
        #{cacheLocalVariable}.to_enum(:each)
      end
        "
      
      logger_call who_only: {'rejectResult' => :rejectResult}
      
      result :rejectResult

    end  
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxRejectPLUOrCroak

  end
  
  # Size Syntax Methods
  # ###################

  def make_syntax_size_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_size'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder

    add_specs_or_croak(size: make_syntax_size_plural_or_croak)

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    self

  end

  def make_syntax_size_plural_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLC2d::m_syn_size_snl'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxBuilder = syntax_builder

    cacheName = find_name_or_croak
    cachePluralName = find_plural_name_or_croak
    cacheInstanceVariable = cache_instance_variable
    
    syntaxSizeSNLOrCroak = syntaxBuilder.new_method(parent: self) do

      syntaxCacheInstanceVariable = instance_variable cacheInstanceVariable
      
      name :size, cachePluralName

      set_eye :e, cachePluralName

      snippet "
      sizeResult = defined?(#{syntaxCacheInstanceVariable}) ? #{syntaxCacheInstanceVariable}.size : 0
        "
      
      logger_call who_only: {'sizeResult' => :sizeResult}
      
      result :sizeResult

    end  
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    syntaxSizeSNLOrCroak

  end  
  
  # Assign Statement Methods for Normalise and Validate
  # ###################################################
  
  methodTexts = { key_normalise_method: :nVal,
    value_normalise_method: :vVal,
    key_validate_method: :nVal,
    value_validate_method: :vVal,
  }.map do | mthName, argNameDef |
    "def add_statement_#{mthName}(mthInst=self, varName=nil);
       callName = #{mthName}; # any method defined?
       callName ? begin
                    argName = varName || '#{argNameDef}';
                    mthInst.add_statement_assign_local_variable(argName,  mthInst.new_statement_method_call(callName, argName));
                  end
                : self;
     end;
    "
  end

  methodText  = methodTexts.flatten.compact.join("\n")

  module_eval(methodText)
  
  # Syntax Builder Methods
  # ######################
  
  def syntax_builder
    @syntax_builder ||= self.class.syntax_builder
  end

  # Support Methods
  # ###############

  def validate_or_croak(prcsArgs=nil, &prcsBlok)
    eye = :'DSLC2d::val'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(prcsArgs: prcsArgs, prcsBlok: prcsBlok))

    potrubi_bootstrap_mustbe_symbol_or_croak(name, eye)
    potrubi_bootstrap_mustbe_symbol_or_croak(scope, eye)
    potrubi_bootstrap_mustbe_not_nil_or_croak(key, eye)
    potrubi_bootstrap_mustbe_not_nil_or_croak(value, eye)
    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(prcsArgs: prcsArgs, prcsBlok: prcsBlok))

    self

  end
  
end

module Potrubi
  class DSL
    class Cache2D < Potrubi::DSL::Super
    end
  end
end

Potrubi::DSL::Cache2D.__send__(:include, instanceMethods)  # Instance Methods
Potrubi::DSL::Cache2D.extend(classMethods)  # Class Methods

__END__
