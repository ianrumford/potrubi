
# potrubi contract methods

require_relative '../bootstrap'
require_relative "dynamic"

#requireList = %w(dynamic)
#requireList.each {|r| require_relative "#{r}"}

#$DEBUG = true
#$DEBUG_POTRUBI_BOOTSTRAP = true

mixinContent = Module.new do

  # mustbe contracts
  
  mustbeDefaultSpec = [:package_mustbe]
  mustbeLimited1OneArgSpec = [:method_mustbe_one_arg, :alias_is_value_value_is]
  mustbeLimited2OneArgSpec = [mustbeLimited1OneArgSpec, :method_mustbe_key, :method_mustbe_one_arg_or_nil, :method_mustbe_collections].flatten
  mustbeLimited1TwoArgSpec = [:method_mustbe_two_arg, :alias_is_value_value_is]
  
  mustbeMethods = {
    :hash         => [:package_mustbe, :method_mustbe_hash_with_proc, :method_mustbe_one_arg_or_nil_with_proc].flatten,
    #=begin
    :array        => [:package_mustbe, :method_mustbe_array_with_proc, :method_mustbe_one_arg_or_nil_with_proc, :method_mustbe_subset].flatten,
    :string	=> nil,
    :symbol	=> nil,
    :fixnum	=> nil,
    :range	=> nil,
    :proc	=> nil,
    :class	=> nil,
    :module	=> nil,
    :time	=> nil,
    :enumerator   => nil,
    :regexp       => nil,
    :struct       => nil,
    :empty        => [{:name => :'is_value_empty?', :spec => ->(c) {(c.respond_to?(:empty?) && c.empty?) ? c : nil }}, mustbeLimited1OneArgSpec].flatten,
    :not_empty    => [{:name => :'is_value_not_empty?', :spec => ->(c) {(c.respond_to?(:empty?) && (! c.empty?)) ? c : nil }}, mustbeLimited1OneArgSpec].flatten,
    :not_nil      => [{:name => :'is_value_not_nil?', :spec => ->(c) { c }}, mustbeLimited1OneArgSpec].flatten,
    :file         => [{:name => :'is_value_file?', :spec => ->(f) {(f.is_a?(String) && File.file?(f)) ? f : nil}}, mustbeLimited2OneArgSpec].flatten,
    :directory    => [{:name => :'is_value_directory?', :spec => ->(d) {(f.is_a?(String) && File.directory?(d)) ? d : nil}}, mustbeLimited2OneArgSpec].flatten,
    :file_or_directory => [{:name => :'is_value_file_or_directory?', :spec => ->(e) {(e.is_a?(String) && (File.file?(e) || File.directory?(e))) ? e : nil}}, mustbeLimited2OneArgSpec].flatten,
    :key         => [{:name => :'is_value_key?', :spec => ->(h,k) {(h.respond_to?(:has_key?) && h.has_key?(k)) ? h[k] : nil}}, mustbeLimited1TwoArgSpec].flatten,
    :not_key     => [{:name => :'is_value_not_key?', :spec => ->(h,k) {is_value_key?(h,k) ? nil : k}}, mustbeLimited1TwoArgSpec].flatten,
    :any         => [{:name => :'is_value_any?', :spec => ->(v) {v} }].flatten,
    :same_class  => [{:name => :'is_value_same_class?', :spec => ->(p,q) {((r = p.class) == q.class) ? r : nil}}, mustbeLimited1TwoArgSpec].flatten,
    :instance_of => [{:name => :'is_value_instance_of?', :spec => ->(p,q) {p.instance_of?(q) ? p : nil}}, mustbeLimited1TwoArgSpec].flatten,
    #=end
  }

  mustbeSpecs = mustbeMethods.each_with_object({}) { | (mustbeName, mustbeSpec), h | h[mustbeName] = mustbeSpec || mustbeDefaultSpec }

  Potrubi::Mixin::Dynamic::dynamic_define_methods(self, mustbeSpecs) do |k, v|
    edits = {
      ###:MUSTBE_TEST => k.to_s.capitalize,
      IS_VALUE_TEST: "testValue.is_a?(#{k.to_s.capitalize})",
      MUSTBE_NAME: k,
      ###MUSTBE_SPEC: v,
    }
    case v
    when Hash then v.merge({:edit => [edits, v[:edit]]})
    else
      {:edit => edits, :spec => v}
    end
  end
  

  # Compare Contracts
  
  compareMethods = {
    :eq => '==',
    :equal => '==',
    :lt => '<',
    :le => '<=',
    :less_or_equal => '<=',
    # :less_than_or_equal => '<=',
    # :lessthan_or_equal => '<=',
    :gt => '>',
    :ge => '>=',
    :greater_or_equal => '>=',
    # :greater_than_or_equal => '>=',
    # :greaterthan_or_equal => '>=',
    :identical => '===',
    :ne => '!=',
    :not_equal => '!=',
    # :lessequal => '<=',
  }

  Potrubi::Mixin::Dynamic::dynamic_define_methods(self, compareMethods) do | mN, mO |
    # puts "<=> #{eye} mN >#{mN.class}< >#{mN}< mO >#{mO.class}< >#{mO}< textValue >#{textValue.class}< >\n#{textValue}\n<"
    {edit: {MUSTBE_NAME: mN, MUSTBE_SPEC: mO}, spec: :method_mustbe_compare}
  end

end

module Potrubi
  module Mixin
    module Contract
    end
  end
end

Potrubi::Mixin::Contract.__send__(:include, mixinContent)  # Instance Methods

__END__
