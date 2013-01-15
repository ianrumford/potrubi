
# potrubi mixin util

# various useful methods

require_relative '../core'

#requireList = %w(bootstrap)
#requireList.each {|r| require_relative "#{r}"}

mixinContent = Module.new do
  
  #=begin
  def potrubi_util_merge_hashes_or_croak(*hashes)
    r = hashes.flatten.compact.inject({}) {|s, h| s.merge(potrubi_bootstrap_mustbe_hash_or_croak(h))}
    r.empty? ? nil : r
  end
  alias_method :potrubi_util_merge_hashes, :potrubi_util_merge_hashes_or_croak
  #=end

  #  Apply a proc to the hash values and return a new hash with new values
  
  #=begin
  def potrubi_util_apply_proc_to_hash_or_croak(srceHash, &srceBlok)
    mustbe_proc_or_croak(srceBlok)
    mustbe_hash_or_croak(srceHash).each_with_object({}) {|(k,v),h| h[k] = srceBlok.call(k, v) }
  end
  alias_method :potrubi_util_map_hash_value, :potrubi_util_apply_proc_to_hash_or_croak
  alias_method :potrubi_util_map_hash_v, :potrubi_util_apply_proc_to_hash_or_croak
  #=end
  #=begin
  def potrubi_util_map_hash_key_and_value_or_croak(srceHash, &srceBlok)
    mustbe_proc_or_croak(srceBlok)
    mustbe_hash_or_croak(srceHash).each_with_object({}) {|(k,v),h| r = mustbe_array_or_croak(srceBlok.call(k, v)); h[r[0]] = r[1] }
  end
  alias_method :potrubi_util_map_hash_kv, :potrubi_util_map_hash_key_and_value_or_croak
  #=end

  #=begin
  def potrubi_util_array_to_hash(aVal, &procBlok)
    mustbe_array_or_croak(aVal)
    case
    when Kernel.block_given? then aVal.each_with_object({}) {|a, h| r = mustbe_array_or_croak(procBlok.call(a)); h[r[0]] = r[1] }  # k&v from proc
    else
      aVal.each_with_object({}) {|a, h| h[a] = nil }  # values to nil
    end
  end
  #=end
end

Potrubi::Core.assign_module_constant_or_croak(mixinContent, :Potrubi, :Mixin, :Util)

__END__
