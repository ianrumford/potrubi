
# Core Mixin

require_relative 'bootstrap'

requireList = %w(dynamic text-snippets exception contract konstant pathandnames)
requireList.each {|r| require_relative "mixin/#{r}"}

mixinContent = Module.new do

  # Include the mixins becuase of class method usage
  
  includeList = [Potrubi::Bootstrap,
                 Potrubi::Mixin::Dynamic,
                 Potrubi::Mixin::Exception,
                 Potrubi::Mixin::Contract,
                 Potrubi::Mixin::Konstant,
                 Potrubi::Mixin::PathAndNames,
                ]
  includeList.each {|n| include n}

end

module Potrubi
  module Core
  end
end

Potrubi::Core.__send__(:include, mixinContent)  # Instance Methods
Potrubi::Core.extend(mixinContent)              # Module Methods

__END__

