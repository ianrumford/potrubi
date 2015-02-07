
# bootstrap common methods

# This turns on or off logging from boostrap / core methods
# Normally off (nil/false)

defined?($DEBUG_POTRUBI_BOOTSTRAP) || ($DEBUG_POTRUBI_BOOTSTRAP = nil)

#$DEBUG_POTRUBI_BOOTSTRAP = true
#$DEBUG = true # TESTING

require_relative('logger')

module Potrubi
  module Mixin
    module BootstrapCommon

      bootstrapLoggerMethods = {
        logger: :logger_message,
        logger_instance_telltale: :logger_instance_telltale,
        logger_me: :logger_me,
        logger_mx: :logger_mx,
        logger_ms: :logger_ms,
        logger_ca: :logger_ca,
        logger_beg: :logger_beg,
        logger_fin: :logger_fin,
        logger_fmt: :logger_fmt,
        logger_fmt_kls: :logger_fmt00,
        logger_fmt_kls_size: :logger_fmt0000,
        logger_fmt_who: :logger_fmt0,
        logger_fmt_who_only: :logger_fmt000,
      }

      bootstrapLoggerText = bootstrapLoggerMethods.map do | bootMethod, loggerMethod |
        text = <<-"ENDOFHERE"
          def potrubi_bootstrap_#{bootMethod}(*a, &b)
            $DEBUG_POTRUBI_BOOTSTRAP && #{loggerMethod}(*a, &b)
          end;
          ENDOFHERE
          text
      end.compact.flatten.join("\n")

      self.module_eval(bootstrapLoggerText)
      
      def potrubi_bootstrap_raise_exception(exception, value, *tellTales)
        #tellTale = potrubi_bootstrap_logger_format_telltales(*tellTales)
        tellTale = tellTales.flatten.compact.join(' ')
        raise(exception,"Potrubi Bootstrap Exception value >#{value.class}< >#{value}< #{tellTale}",caller)
      end

      def potrubi_bootstrap_surprise_exception(value, *tellTales)
        potrubi_bootstrap_raise_exception(ArgumentError, value, "value was a surprise", *tellTales)
      end
      
      def potrubi_bootstrap_unsupported_exception(value, *tellTales)
        potrubi_bootstrap_raise_exception(ArgumentError, value, "value not supported", *tellTales)
      end

      def potrubi_bootstrap_missing_exception(value, *tellTales)
        potrubi_bootstrap_raise_exception(ArgumentError, value, "value missing", *tellTales)
      end

      def potrubi_bootstrap_duplicate_exception(value, *tellTales)
        potrubi_bootstrap_raise_exception(ArgumentError, value, "duplicate value", *tellTales)
      end
      
      def potrubi_bootstrap_mustbe_hash_or_croak(testValue, *tellTales)
        testValue.is_a?(Hash) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "value not hash", tellTales)
      end
      
      def potrubi_bootstrap_mustbe_array_or_croak(testValue, *tellTales)
        testValue.is_a?(Array) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "value not array", tellTales)
      end

      def potrubi_bootstrap_mustbe_module_or_croak(testValue, *tellTales)
        testValue.is_a?(Module) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "value not module", tellTales)
      end

      def potrubi_bootstrap_mustbe_class_or_croak(testValue, *tellTales)
        testValue.is_a?(Class) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "value not class", tellTales)
      end

      def potrubi_bootstrap_mustbe_proc_or_croak(testValue, *tellTales)
        testValue.is_a?(Proc) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "value not proc", tellTales)
      end
      
      def potrubi_bootstrap_mustbe_string_or_croak(testValue, *tellTales)
        testValue.is_a?(String) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "value not string", tellTales)
      end

      def potrubi_bootstrap_mustbe_symbol_or_croak(testValue, *tellTales)
        testValue.is_a?(Symbol) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "value not symbol", tellTales)
      end
      
      def potrubi_bootstrap_mustbe_fixnum_or_croak(testValue, *tellTales)
        testValue.is_a?(Fixnum) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "value not fixnum", tellTales)
      end
      
      def potrubi_bootstrap_mustbe_float_or_croak(testValue, *tellTales)
        testValue.is_a?(Float) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "value not float", tellTales)
      end
      
      def potrubi_bootstrap_mustbe_file_or_croak(testValue, *tellTales)
        File.file?(testValue.to_s) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "value not file", tellTales)
      end
      
      def potrubi_bootstrap_mustbe_directory_or_croak(testValue, *tellTales)
        File.directory?(testValue.to_s) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "value not directory", tellTales)
      end
      
      def potrubi_bootstrap_mustbe_key_or_croak(testValue, keyName, *tellTales)
        (testValue.respond_to?(:has_key?) && testValue.has_key?(keyName)) ? testValue[keyName] : potrubi_bootstrap_raise_exception(ArgumentError, keyName, "testValue >#{testValue}< keyName not found", tellTales)
      end

      def potrubi_bootstrap_mustbe_not_nil_or_croak(testValue, *tellTales)
        testValue || potrubi_bootstrap_raise_exception(ArgumentError, testValue, "testValue >#{testValue}< failed not nil ", tellTales)
      end

      def potrubi_bootstrap_mustbe_not_empty_or_croak(testValue, *tellTales)
        (testValue.respond_to?(:empty?) && (! testValue.empty?)) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "testValue >#{testValue}< failed not empty", tellTales)
      end

      def potrubi_bootstrap_mustbe_empty_or_croak(testValue, *tellTales)
        (testValue.respond_to?(:empty?) && testValue.empty?) ? testValue : potrubi_bootstrap_raise_exception(ArgumentError, testValue, "testValue >#{testValue}< failed empty", tellTales)
      end
      
      def bootstrap_find_module_constant(*a)
        bootstrap_find_module_constant_or_croak(*a) rescue nil
      end
      
      def bootstrap_find_module_constant_or_croak(*modNames)
        #potrubi_bootstrap_mustbe_module_or_croak(modNames.flatten.compact.inject(Object) {|s,m| (s && s.const_defined?(m, false)) ? s.const_get(m) : nil})
        potrubi_bootstrap_mustbe_module_or_croak(modNames.flatten.compact.join('::').split('::').inject(Object) {|s,m| (s && s.const_defined?(m, false)) ? s.const_get(m) : nil}) 
      end
      
      def bootstrap_find_class_constant(*a)
        bootstrap_find_class_constant_or_croak(*a) rescue nil
      end
      
      def bootstrap_find_class_constant_or_croak(*a)
        potrubi_bootstrap_mustbe_class_or_croak(bootstrap_find_module_constant_or_croak(*a))
      end
      
    end
  end
end

__END__

Potrubi::Mixin::BootstrapCommon.instance_methods.each {|m| puts("Potrubi::Mixin::BootstrapCommon Inst Mth >#{m}<")}

__END__
