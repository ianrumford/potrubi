
require_relative '../bootstrap'

mixinContent = Module.new do
  
  attr_accessor :name, :type, :parent

  def initialize(initArgs=nil, &initBlok)
    eye = :i
    
    initArgs && potrubi_bootstrap_mustbe_hash_or_croak(initArgs, eye).each {|k, v| __send__("#{k}=", v) }
    
    Kernel.block_given? && instance_eval(&initBlok)

  end
  
end

module Potrubi
  module Mixin
    module Initialize
    end
  end
end

Potrubi::Mixin::Initialize.__send__(:include, mixinContent)  # Instance Methods

__END__
