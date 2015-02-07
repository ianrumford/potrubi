
# potrubi contract dsl

# syntax method: builder

# to ease the creation of new methods using text manipulation

require_relative '../../bootstrap'

requireList = %w(super ./mixin/new_snippets)
requireList.each {|r| require_relative "#{r}"}
###require "potrubi/klass/syntax/braket"

classMethods = Module.new do

  include Potrubi::Bootstrap
  include Potrubi::Klass::Syntax::Mixin::NewSnippets
  include Potrubi::Klass::Syntax::Mixin::NewMethods
  include Potrubi::Klass::Syntax::Mixin::NewAliases
  include Potrubi::Klass::Syntax::Mixin::NameGeneration
end

instanceMethods = Module.new do

  include Potrubi::Klass::Syntax::Mixin::NewSnippets
  include Potrubi::Klass::Syntax::Mixin::NewMethods
  include Potrubi::Klass::Syntax::Mixin::NewAliases
  include Potrubi::Klass::Syntax::Mixin::SynelManagement
  
end

module Potrubi
  class Klass
    module Syntax
      class Builder
      end
    end
  end
end

Potrubi::Klass::Syntax::Builder.__send__(:include, instanceMethods)  # Instance Methods
Potrubi::Klass::Syntax::Builder.extend(classMethods)  # Class Methods

__END__

