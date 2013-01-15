
require_relative '../core'

mixinContent = Module.new do
  
  attr_accessor :name, :type, :parent

  def initialize(initArgs=nil, &initBlok)
    eye = :i_std
    
    initArgs && mustbe_hash_or_croak(initArgs, eye).each {|k, v| __send__("#{k}=", v) }
    
    Kernel.block_given? && instance_eval(&initBlok)

  end
  
end

Potrubi::Core.assign_module_constant_or_croak(mixinContent, :Potrubi, :Mixin, :Initialize)
#Potrubi::Core.assign_module_constant_or_croak(mixinContent, __FILE__)

__END__

