
# Potrubi Bootstrap Mixin

requireList = %w(logger bootstrap_common)
requireList.each {|r| require_relative "mixin/#{r}"}

mixinContent = Module.new do

  # Include the mixins becuase of class method usage
  
  includeList = [Potrubi::Mixin::Logger,
                 Potrubi::Mixin::BootstrapCommon,
                ]
  includeList.each {|n| include n}

end

module Potrubi
  module Bootstrap
  end
end

Potrubi::Bootstrap.__send__(:include, mixinContent)  # Instance Methods
Potrubi::Bootstrap.extend(mixinContent)              # Class Methods

__END__

