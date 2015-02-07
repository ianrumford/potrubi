
# potrubi contract dsl

# syntax methods: method

# to ease the creation of new methods using text manipulation

#require_relative '../../bootstrap'

#requireList = %w(base )
#requireList.each {|r| require_relative "#{r}"}
###require "potrubi/klass/syntax/braket"


instanceMethods = Module.new do

  #include Potrubi::Klass::Syntax::Mixin::Base

   # Naming Methods
  # ##############

  def name_builder_instance_variable(*names)
    name_creator('', '@', name_creator('_', *names))
  end
  
  def name_builder_method_getter(*names)
    name_builder_method(*names)
  end
  
  def name_builder_method_setter(*names)
    name_creator('', name_builder_method(*names), '=')
  end

  def name_builder_method_or_croak(*names)
    name_creator('_', name_builder_method(*names), :or, :croak)
  end
  
  def name_builder_method(*names)
    name_creator('_', *names)
  end

  def name_creator(sepChar, *names, &joinBlok)
    r = names.flatten.compact
    case
    when Kernel.block_given? then r.map {|a| joinBlok.call(a) }.flatten.compact.join
    else
      #p = r.map {|a| [a, sepChar]}.flatten
      #p.pop # last sepchar
      #p.join('')
      r.join(sepChar)
    end
  end

  def name_builder_eye_getter(*eyes)
    name_builder_eye(:g, *eyes)
  end

  def name_builder_eye_setter(*eyes)
    name_builder_eye(:s, *eyes)
  end
  
  def name_builder_eye(*eyes)
    name_builder_method(*eyes).to_sym
  end
  
end



module Potrubi
  class Klass
    module Syntax
      module Mixin
        module NameGeneration
        end
      end
    end
  end
end

Potrubi::Klass::Syntax::Mixin::NameGeneration.__send__(:include, instanceMethods)  # Instance Methods


__END__

