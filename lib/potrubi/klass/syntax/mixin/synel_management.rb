
# potrubi contract dsl

# syntax methods: method

# to ease the creation of new methods using text manipulation

#require_relative '../../bootstrap'

#requireList = %w(base )
#requireList.each {|r| require_relative "#{r}"}
###require "potrubi/klass/syntax/braket"


instanceMethods = Module.new do

  # Synel Management
  # ################

  # Synels are any onject that inherits Syntax:Super

  def synel_klass
    @synel_klass ||= Potrubi::Klass::Syntax::Super
  end

  # the container is a braket because of the six edges
  def synel_container_klass
    @synel_container_klass ||= Potrubi::Klass::Syntax::Braket
  end

  def new_synel_container
    synel_container_klass.new_snippet
  end
  
  def synels
    @synels ||= new_synel_container
  end

  def mustbe_synel_or_croak(synelValue)
    synelValue.is_a?(synel_klass) ? synelValue : potrubi_bootstrap_surprise_exception(synelValue, :mustbe_syn, "synelValue not a synel")
  end

  def mustbe_synel_container_or_croak(synelContainer)
    synelContainer.is_a?(synel_container_klass) ? synelContainer : potrubi_bootstrap_surprise_exception(synelContainer, :mustbe_syn, "synelContainer not a synel_container")
  end
  
  def synels=(newSynContainer)
    @synels = mustbe_synel_container_or_croak(newSynContainer)
  end

  def xxxxsynels=(*newSyns)
    synels.clear
    add_synels_or_croak(*newSyns)
  end
  
  def zzzsynels=(*newSyns)
    newSynsNrm = newSyns.flatten.compact.map {|s| mustbe_synel_or_croak(s) }
    @synels = newSynsNrm
  end
  
  def add_synels_or_croak(*newSynels)
    eye = :'PotKlsSynMixSnlMan::a_synels'
    eyeTale = 'ADD SYNELS'

        puts("#{eye} X0")
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, eyeTale, potrubi_bootstrap_logger_fmt_who_only(newSynels: newSynels))

    newSyns = newSynels.flatten.compact
    #STOPHEREADDSYNELSPOSTFLATTEN
    puts("#{eye} X1")
    #newSyns = newSynels
    
    sizSyn = newSyns.size
    newSyns.each_with_index do | newSyn, ndxSyn|
      newSyn.is_a?(Potrubi::Klass::Syntax::Method) && potrubi_bootstrap_surprise_exception(ndxSyn, eye, "SYNEL IS A METHOD")
      $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, 'TEST', ">#{ndxSyn}< of >#{sizSyn}<", potrubi_bootstrap_logger_fmt_who(newSyn: newSyn), "SYN >#{newSyn.syntax}<")
      #$DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, eyeTale, ">#{ndxSyn}< of >#{sizSyn}<", potrubi_bootstrap_logger_fmt_who(newSyn: newSyn), "SYN >#{newSyn.inspect}<")
      mustbe_synel_or_croak(newSyn)
    end

    #STOPHEREADDSYNELSX1
    puts("#{eye} X2")
    
    newSynelsNrm = newSyns.map {|s| mustbe_synel_or_croak(s) }

    #STOPHEREADDSYNELSX2

        puts("#{eye} X3")
    synels.push_midl(newSynelsNrm)

    
    #STOPHEREADDSYNELSX3
        puts("#{eye} X4")
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_mx(eye, eyeTale, potrubi_bootstrap_logger_fmt_who_only(newSyns: newSynelsNrm))

    puts("#{eye} #{eyeTale} EXITSING CHECK ANY TO_Ses")
    
    self
    #SYOPHEREADDSTMSEXIT
  end

  # Passthru to Delegate
  # ####################

  # Delegate must handle
  
  callPassthruMap = {

    push: nil,
    pop: nil,
    shift: nil,
    unshift: nil,
    cons: nil,
    tail: nil,

    push_west: nil,
    pop_west: nil,
    shift_west: nil,
    unshift_west: nil,
    cons_west: nil,
    tail_west: nil,

    push_midl: nil,
    pop_midl: nil,
    shift_midl: nil,
    unshift_midl: nil,
    cons_midl: nil,
    tail_midl: nil,

    push_east: nil,
    pop_east: nil,
    shift_east: nil,
    unshift_east: nil,
    cons_east: nil,
    tail_east: nil,
    
  }

  callPassthruTexts = callPassthruMap.map do |srcMth, tgtMth|
    tgtMthNrm =  tgtMth || srcMth
     "def #{srcMth}_synels(*a, &b); synels.#{tgtMthNrm}(*a, &b); end;"
  end
  
  callPassthruText = callPassthruTexts.flatten.compact.join("\n")
  puts("SYNELS PASSTHRU MAP >\n#{callPassthruText}")
  module_eval(callPassthruText)
  
  
end



module Potrubi
  class Klass
    module Syntax
      module Mixin
        module SynelManagement
        end
      end
    end
  end
end

Potrubi::Klass::Syntax::Mixin::SynelManagement.__send__(:include, instanceMethods)  # Instance Methods


__END__

