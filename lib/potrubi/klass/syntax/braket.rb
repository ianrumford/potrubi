
# potrubi klass

# syntax braket

defined?($DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET) ||
  begin
    $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET ||= nil
  end

require "potrubi/core"
require 'potrubi/mixin/dynamic-recipes'

klassContent = Class.new do

  include Potrubi::Core
  ###include Potrubi::Mixin::DynamicRecipes
  
  # Class Methods
  # #############
  
  def self.new_method
    new(:pos_text => "\n")
  end

  def self.new_stanza
    new(:pos_text => "\n")
  end
  
  def self.new_statement
    #self.new(nil, nil)
    new
  end
  
  attr_accessor :pre_text, :pos_text

  def initialize(initArgs=nil)
    initArgs && mustbe_hash_or_croak(initArgs, :'braket i').each {|k,v| self.__send__("#{k}=", v)}
  end
  
  def to_s
    eye = :'bkt to_s'
    preText = pre_text 
    posText = pos_text

    fullText = [ 
                defined?(@head) && head_text(preText, posText), 
                defined?(@midl) && midl_text(preText, posText), 
                defined?(@tail) && tail_text(preText, posText), 
               ].flatten.compact.join

    $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET && logger_ca(eye, "self >#{self.object_id}< fulText >#{fullText.class}< >\n#{fullText}\n< ")
    
    fullText
    
  end

  
  def to_s_with_edits(editList=nil)
    eye = :to_s_w_edt
    fulText = to_s
    edtText = case editList
              when NilClass then fulText
              when Hash, Array then  Potrubi::Core.dynamic_apply_edits(editList, fullText)
              else
                surprise_exception(editList, eye, "editList >#{editList.whoami_debug}< is what?")
              end
    $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET && logger_ca(eye, "self >#{self.object_id} edtText >\n#{edtText}\n<")
    edtText
  end
  


  textMethodText =
    'def METHOD_NAME_text(preText=nil, posText=nil)
      METHOD_NAMEText = defined?(@METHOD_NAME) ? (@METHOD_NAME.map {|i| [preText, i.to_s, posText]}.flatten.compact.join) : nil
      $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET && logger_ca(:METHOD_NAME_text, "self >#{self.object_id}< METHOD_NAMEText >#{METHOD_NAMEText.class}< >#{METHOD_NAMEText}<")
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
       $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET && logger_ca(:pop_METHOD_NAME, "self >#{self.object_id}< r >#{r}<")
       r
     end
     def shift_METHOD_NAME
       r = defined?(@METHOD_NAME) ? @METHOD_NAME.shift : nil
       $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET && logger_ca(:shift_METHOD_NAME, "self >#{self.object_id}< r >#{r}<")
       r
     end'

  defTextList = [textMethodText, baseMethodText]
  ###puts("TEXT TEST TEXT >#{defTextList}<")

  braketMethods = {
    :tail => defTextList,
    :head => defTextList,
    :midl => defTextList,
  }

  Potrubi::Core.dynamic_define_methods(self, braketMethods) do |k, v|
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
  }

  #Potrubi::Core.dynamic_define_methods_aliases(self, aliasMethods)
  Potrubi::Mixin::DynamicRecipes.recipe_aliases(self, aliasMethods)


# Diagnostics
# ###########

  def raw_debug(levelText=nil)
    eye = :'braket r_dbg'

    $DEBUG_POTRUBI_KLASS_SYNTAX_BRAKET &&
      begin
        levelString = case levelText
                      when NilClass then 'BRAKET'
                      when String, Symbol then "#{levelText}"
                      else
                        unsupported_exception(levelText, eye)
                      end

        braketAddress = "%x" % (object_id.abs*2)
        
        puts "#{levelString} #{braketAddress} ==>"
        
        defined?(@head) && raw_content_debug(levelString, "head", @head)
        defined?(@midl) && raw_content_debug(levelString, "midl", @midl)
        defined?(@tail) && raw_content_debug(levelString, "tail", @tail)
        
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
      surprise_exception(contentData, eye)
    end
    
    self
    
  end

end

#Potrubi::Core.assign_class_constant_or_croak(klassContent, __FILE__)
Potrubi::Core.assign_class_constant_or_croak(klassContent, :Potrubi, :Klass, :Syntax, :Braket)

__END__


