
# potrubi mixin util

# various useful methods

# Notes *ONLY* need bootstrap

require_relative '../bootstrap'

mixinContent = Module.new do

  def potrubi_util_merge_arrays_or_croak(*arrays)
    r = arrays.compact.inject({}) {|s, a| s.concat(potrubi_bootstrap_mustbe_array_or_croak(a)) }
    r.empty? ? nil : r
  end
  alias_method :potrubi_util_merge_arrays, :potrubi_util_merge_arrays_or_croak
  alias_method :potrubi_util_reduce_arrays, :potrubi_util_merge_arrays_or_croak
  
  def potrubi_util_merge_hashes_or_croak(*hashes, &mergeBlok)
    r = hashes.flatten.compact.inject({}) {|s, h| s.merge(potrubi_bootstrap_mustbe_hash_or_croak(h), &mergeBlok)}
    r.empty? ? nil : r
  end
  alias_method :potrubi_util_merge_hashes, :potrubi_util_merge_hashes_or_croak
  alias_method :potrubi_util_reduce_hashes_or_croak, :potrubi_util_merge_hashes_or_croak
  alias_method :potrubi_util_reduce_hashes, :potrubi_util_merge_hashes_or_croak

  def potrubi_util_merge_hashes_concatenate_array_values_or_croak(*hashes)
    potrubi_util_merge_hashes_or_croak(*hashes) do | k, oldV, newV |
      case
      when oldV.is_a?(Array) && newV.is_a?(Array) then [].concat(oldV).concat(newV)
      else
        newV
      end
    end
  end
  
  #  Apply a proc to the hash values and return a new hash with new values
  
  def potrubi_util_apply_proc_to_hash_or_croak(srceHash, &srceBlok)
    potrubi_bootstrap_mustbe_proc_or_croak(srceBlok)
    potrubi_bootstrap_mustbe_hash_or_croak(srceHash).each_with_object({}) {|(k,v),h| h[k] = srceBlok.call(k, v) }
  end
  alias_method :potrubi_util_map_hash_value, :potrubi_util_apply_proc_to_hash_or_croak
  alias_method :potrubi_util_map_hash_v, :potrubi_util_apply_proc_to_hash_or_croak

  def potrubi_util_map_hash_key_and_value_or_croak(srceHash, &srceBlok)
    potrubi_bootstrap_mustbe_proc_or_croak(srceBlok)
    potrubi_bootstrap_mustbe_hash_or_croak(srceHash).each_with_object({}) {|(k,v),h| r = potrubi_bootstrap_mustbe_array_or_croak(srceBlok.call(k, v)); h[r[0]] = r[1] }
  end
  alias_method :potrubi_util_map_hash_kv, :potrubi_util_map_hash_key_and_value_or_croak

  # find hash keys recursively
  def potrubi_util_find_hash_keys_or_croak(srceHash, *srceKeys, &srceBlok)
    potrubi_bootstrap_mustbe_hash_or_croak(srceHash)

    # puts "potrubi_util_find_hash_keys_or_croak srceHash #{srceHash}"
    # puts "potrubi_util_find_hash_keys_or_croak srceKeys #{srceKeys}"
    
    r = srceKeys.flatten.compact.reduce(srceHash) do | s, k |
      # puts "potrubi_util_find_hash_keys_or_croak k #{k} s #{s}"
      ###(s.is_a?(Hash) && s.has_key?(k)) ? s[k] : break
      (s.is_a?(Hash) && s.has_key?(k)) ? s[k] : potrubi_bootstrap_mustbe_key_or_croak(s, k, 'potrubi_util_find_hash_keys_or_croak')
    end
    # any blok? - call even if nil (i.e key was found and value was nil)
    srceBlok ? srceBlok.call(r) : r
  end

  def potrubi_util_find_hash_keys(srceHash, *srceKeys, &srceBlok)
    potrubi_util_find_hash_keys_or_croak(srceHash, *srceKeys, &srceBlok) rescue nil
  end
  
  def potrubi_util_array_to_hash(aVal, &procBlok)
    aVal.is_a?(Array) || aVal.is_a?(Enumerator) || potrubi_bootstrap_mustbe_array_or_croak(aVal)
    case
    when Kernel.block_given? then aVal.each_with_object({}) {|a, h| r = potrubi_bootstrap_mustbe_array_or_croak(procBlok.call(a)); h[r[0]] = r[1] }  # k&v from proc
    else
      aVal.each_with_object({}) {|a, h| h[a] = nil }  # values to nil
    end
  end

  def potrubi_util_setter_or_croak(setTarget, *hashes, &mergeBlok)
    potrubi_util_merge_hashes_or_croak(*hashes, &mergeBlok).each {|k, v| setTarget.__send__("#{k}=", v) }
    setTarget
  end
  alias_method :potrubi_util_set_attributes_or_croak, :potrubi_util_setter_or_croak

end

module Potrubi
  module Mixin
    module Util
    end
  end
end

Potrubi::Mixin::Util.__send__(:include, mixinContent)  # Instance Methods

__END__

