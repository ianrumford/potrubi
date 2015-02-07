
# potrubi klass

# syntax braket

defined?($DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET) ||
  begin
    $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET ||= nil
  end

#require "potrubi/core"
#require 'potrubi/mixin/dynamic-recipes'

requireList = %w(../../bootstrap ../../mixin/dynamic-recipes)
requireList.each {|r| require_relative "#{r}"}


klassMethods = Module.new do

  include Potrubi::Bootstrap
  ###include Potrubi::Mixin::DynamicRecipes
  
  # Class Methods
  # #############
  
  def new_method
    new(:pos_text => "\n")
    #new
  end

  def new_snippet
    new(:pos_text => "\n")
    ###new
  end
  
  def new_statement
    #puts("BRAKET NEW STATEMENT")
    #self.new(nil, nil)
    new
  end
  
end

instanceMethods = Module.new do

  include Potrubi::Bootstrap
  
  attr_accessor :pre_text, :pos_text

  def inspect
    @to_inspect ||= potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('KlsSynBkt'))
  end
  
  def initialize(initArgs=nil)
    initArgs && potrubi_bootstrap_mustbe_hash_or_croak(initArgs, :'braket i').each {|k,v| self.__send__("#{k}=", v)}
  end

  def zzzto_ary
    self
  end

  def west_midl_east
    [
    defined?(@west) ? @west : nil,
    defined?(@midl) ? @midl : nil,
    defined?(@east) ? @east : nil
    ]
  end
  alias_method :to_a, :west_midl_east
  ###alias_method :to_ary, :west_midl_east

  def zzzflatten
    to_a.inject([]) {|s,a| a ? s.concat(a.flatten) : s}
  end

  def empty?
    to_a.inject(true) {|s,a| a ? (s && a.empty?) : s}
  end

  def clear
    to_a.each {|a| a && a.clear }
  end

  

  
  def zzzflatten
    result = []
    defined&&(@west) && result.concat(@west.flatten)
    defined&&(@midl) && result.concat(@midl.flatten)
    defined&&(@east) && result.concat(@east.flatten)
    result
  end

    
  def zzzempty?
    p = defined?(@west) ? @west.empty? : true
    q = defined?(@midl) ? @midl.empty? : true
    r = defined?(@east) ? @east.empty? : true
    (p && q && r) ? true : false
  end
  
  def zzzclear
    defined?(@west) && @west.clear 
    defined?(@midl) && @midl.clear
    defined?(@east) && @east.clear
    self
  end
  alias_method :reset, :clear
  
  def to_s
    eye = :'bkt to_s'
    preText = pre_text 
    posText = pos_text

    fullText = [ 
                defined?(@west) && west_text(preText, posText), 
                defined?(@midl) && midl_text(preText, posText), 
                defined?(@east) && east_text(preText, posText), 
               ].flatten.compact.join

    $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET && potrubi_bootstrap_logger_ca(eye, "self >#{self.object_id}< fulText >#{fullText.class}< >\n#{fullText}\n< ")
    
    fullText
    
  end

  
  def to_s_with_edits(editList=nil)
    eye = :to_s_w_edt
    fulText = to_s
    edtText = case editList
              when NilClass then fulText
              when Hash, Array then  Potrubi::Core.dynamic_apply_edits(editList, fulText)
              else
                potrubi_bootstrap_surprise_exception(editList, eye, "editList >#{editList.whoami_debug}< is what?")
              end
    $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET && potrubi_bootstrap_logger_ca(eye, "self >#{self.object_id} edtText >\n#{edtText}\n<")
    edtText
  end
  


  textMethodText =
    'def METHOD_NAME_text(preText=nil, posText=nil)
      METHOD_NAMEText = defined?(@METHOD_NAME) ? (@METHOD_NAME.map {|i| [preText, i.to_s, posText]}.flatten.compact.join) : nil
      $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET && potrubi_bootstrap_logger_ca(:METHOD_NAME_text, "self >#{self.object_id}< METHOD_NAMEText >#{METHOD_NAMEText.class}< >#{METHOD_NAMEText}<")
      METHOD_NAMEText
    end'


  baseMethodText =
    'def push_METHOD_NAME(*args)
       (@METHOD_NAME ||= []).push(*ARGS_SPEC)
       self
     end
     alias_method :tail_METHOD_NAME, :push_METHOD_NAME
     def unshift_METHOD_NAME(*args)
       (@METHOD_NAME ||= []).unshift(*ARGS_SPEC)
       self
     end
     alias_method :cons_METHOD_NAME, :unshift_METHOD_NAME
     def pop_METHOD_NAME
       r = defined?(@METHOD_NAME) ? @METHOD_NAME.pop : nil
       $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET && potrubi_bootstrap_logger_ca(:pop_METHOD_NAME, "self >#{self.object_id}< r >#{r}<")
       r
     end
     def shift_METHOD_NAME
       r = defined?(@METHOD_NAME) ? @METHOD_NAME.shift : nil
       $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET && potrubi_bootstrap_logger_ca(:shift_METHOD_NAME, "self >#{self.object_id}< r >#{r}<")
       r
     end'

  defTextList = [textMethodText, baseMethodText]
  #puts("TEXT TEST TEXT >#{defTextList}<")

  braketMethods = {
    :east => defTextList,
    :west => defTextList,
    :midl => defTextList,
  }

  Potrubi::Mixin::Dynamic.dynamic_define_methods(self, braketMethods) do |k, v|
    edits = {
     ARGS_SPEC: 'args.flatten(1)',
     METHOD_NAME: k,
    }
    case v
    when Hash then v.merge({edit: [edits, v[:edit]]})
    else
      {edit: edits, spec: v || defTextList}
    end
  end

  aliasMethods = {
    :push     => :push_midl,
    :pop      => :pop_midl,
    :shift    => :shift_midl,
    :unshift  => :unshift_midl,
    :cons     => :cons_midl,
    :tail     => :tail_midl,

    :cons_head => :cons_west,
    :push_tail => :tail_east,

  }

  ###$DEBUG_POTRUBI_BOOTSTRAP = true
  #Potrubi::Core.dynamic_define_methods_aliases(self, aliasMethods)
  Potrubi::Mixin::DynamicRecipes.recipe_aliases(self, aliasMethods)


# Diagnostics
# ###########

  def raw_debug(levelText=nil)
    eye = :'braket r_dbg'

    #$DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET &&
      begin
        levelString = case levelText
                      when NilClass then 'BRAKET'
                      when String, Symbol then "#{levelText}"
                      else
                        unsupported_exception(levelText, eye)
                      end

        braketAddress = "%x" % (object_id.abs*2)
        
        puts "#{levelString} #{braketAddress} ==>"
        
        defined?(@west) && raw_content_debug(levelString, "west", @west)
        defined?(@midl) && raw_content_debug(levelString, "midl", @midl)
        defined?(@east) && raw_content_debug(levelString, "east", @east)
        
        puts "#{levelString} #{braketAddress} <=="
      end
    
    self
  end

  def raw_content_debug(levelString, contentName, contentData)
    eye = :'braket r_cnt_dbg'
    
    braketAddress = "%x" % (object_id.abs*2)
    
    case contentData
    when NilClass then puts "#{levelString} #{braketAddress} #{contentName.to_s.upcase} IS EMPTY"
    when Array then
      selfClass = self.class
      contentData.each_with_index do | cV, cN |
        case
        when cV.is_a?(selfClass) then cV.raw_debug("#{levelString} #{braketAddress}")
        else
          puts "#{levelString} #{braketAddress} #{contentName.to_s.upcase} cN #{"%2d" % cN} cV >#{cV.class}< >#{cV}<"
        end
      end
    else
      potrubi_bootstrap_surprise_exception(contentData, eye)
    end
    
    self
    
  end

end

module Potrubi
  class Klass
    module Syntax
      class Braket
      end
    end
  end
end

Potrubi::Klass::Syntax::Braket.__send__(:include, instanceMethods)  # Instance Methods
Potrubi::Klass::Syntax::Braket.extend(klassMethods)  # Class Methods


__END__

#Potrubi::Core.assign_class_constant_or_croak(klassContent, __FILE__)
Potrubi::Core.assign_class_constant_or_croak(klassContent, :Potrubi, :Klass, :Syntax, :Braket)

__END__


