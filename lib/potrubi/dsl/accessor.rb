
# potrubi contract dsl

# to ease the creation of contracts, accessors, etc in class bodies

# Uses conventions for names etc dedined by (in) contract mixin

requireList = %w(contract ../mixin/util)
requireList.each {|r| require_relative "#{r}"}
require "potrubi/klass/syntax/braket"

instanceMethods = Module.new do

  def to_s
    potrubi_bootstrap_logger_fmt(potrubi_bootstrap_logger_instance_telltale('DSLAcc'),  potrubi_bootstrap_logger_fmt(n: name))
  end
  
  def type_handlers
    puts "ACCESSOR TYPE_HANDLERS"
    @type_handlers ||=
      begin
        {
        accessor: :accessor,
      }.each_with_object({}) {|(k,v), h| h[k] = "make_contract_description_#{v}_or_croak".to_sym }
      end
  end

  def express_or_croak
    make_contract_description_accessor_or_croak
  end
  
  # Accessor Handlers
  # #################

  def make_contract_description_accessor_or_croak(descArgs=nil, &descBlok)
    eye = :'DSLAcc::m_ctx_desc_acc'

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_me(eye, potrubi_bootstrap_logger_fmt_who(descArgs: descArgs, descBlok: descBlok))

    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ms(eye, potrubi_bootstrap_logger_fmt_who(default: default))
    
    descContract = case
                   when (descDefault = default) then
                     descDefaultText = case descDefault
                                       when NilClass then 'nil'
                                       when String then "'#{descDefault}'" # need quotes
                                       when Symbol then ":#{descDefault}" # need to supply colon
                                       when Proc then descDefault.call
                                       else
                                         descDefault.to_s
                                       end
                     {name => {edit: {ACCESSOR_DEFAULT: descDefaultText}, spec: spec}}
                     
                   else
                     {name => type}
                   end

    
    $DEBUG_POTRUBI_BOOTSTRAP && potrubi_bootstrap_logger_ca(eye, potrubi_bootstrap_logger_fmt_who(descContract: descContract, descArgs: descArgs, descBlok: descBlok))

    descContract

  end

end

module Potrubi
  class DSL
    class Accessor < Potrubi::DSL::Contract
    end
  end
end

Potrubi::DSL::Accessor.__send__(:include, instanceMethods)  # Instance Methods

__END__
