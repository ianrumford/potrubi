
# potrubi mixin logger

require "logger"

module Potrubi
  module Mixin
    module Logger

      def logger
        Logger.logger
      end

      def self.logger(logrArgs=nil)
        @logger ||= new_logger(logrArgs)
      end
      
      def self.new_logger(logrArgs=nil)
        
        logrArgs && (logrArgs.is_a?(Hash) || raise(ArgumentError,"logrArgs >#{logrArgs}< not hash",caller))
        ###log = Log4r.new(STDOUT)

        logrArgsDef = {device: STDOUT, level: ::Logger::DEBUG, datetime_format: "%H:%M:%S"}
        
        logrArgsUse = logrArgs ? logrArgsDef.merge(logrArgs) : logrArgsDef

        logr = ::Logger.new(logrArgsUse[:device])

        logrArgsUse.delete(:device)

        logrArgsUse.each {|k,v| logr.__send__("#{k}=", v) }
        
        logr
        
      end
      
      def logger_enabled?(logrLevel=nil)
        case logrLevel
        when Fixnum
          (@logger_level ||= nil) && @logger_level.is_a?(Fixnum) && (logrLevel <= @logger_level) && logrLevel
        else
          nil
        end
      end
      
      def logger_fmt(*logrArgs)
        logrArgs.flatten.compact.join(' ')
      end
      alias_method :logger_format_telltales, :logger_fmt
      alias_method :potrubi_bootstrap_logger_format_telltales, :logger_fmt
      
      def logger_message(logEye, *logArgs, &msgBlok)
        $DEBUG && logger.debug(logEye) { logger_format_telltales(*logArgs) }
      end
      
      def logger_message_beg(logEye, *logArgs, &msgBlok)
        logger_message(logEye, :BEG, *logArgs, &msgBlok)
      end

      def logger_message_fin(logEye, *logArgs, &msgBlok)
        logger_message(logEye, :FIN, *logArgs, &msgBlok)
      end
      
      def logger_method_entry(logEye, *a)
        logger_message(logEye, '==>', *a)
      end

      def logger_method_exit(logEye, *a)
        logger_message(logEye, '<==', *a)
      end

      def logger_method_call(logEye, *a)
        logger_message(logEye, '<=>', *a)
      end        
      alias_method :logger_me, :logger_method_entry
      alias_method :logger_mx, :logger_method_exit
      alias_method :logger_ca, :logger_method_call
      
      alias_method :logger_ms, :logger_message
      alias_method :logger_en?, :logger_enabled?

      alias_method :logger_beg, :logger_message_beg
      alias_method :logger_fin, :logger_message_fin
      
      def logger_fmt0(logrArgs)
        logrArgs.is_a?(Hash) || raise(ArgumentError,"logrArgs >#{logrArgs}< not hash",caller)
        logrArgs.inject([]) {|s, (k,v)| s << "#{k} >#{v.class}< >#{v.inspect}<"}
      end

      def logger_fmt00(logrArgs)
        logrArgs.is_a?(Hash) || raise(ArgumentError,"logrArgs >#{logrArgs}< not hash",caller)
        logrArgs.inject([]) {|s, (k,v)| s << "#{k} >#{v.class}<"}
      end

      def logger_fmt000(logrArgs)
        logrArgs.is_a?(Hash) || raise(ArgumentError,"logrArgs >#{logrArgs}< not hash",caller)
        logrArgs.inject([]) {|s, (k,v)| s << "#{k} >#{v.inspect}<"}
      end

      def logger_fmt0000(logrArgs)
        logrArgs.is_a?(Hash) || raise(ArgumentError,"logrArgs >#{logrArgs}< not hash",caller)
        logrArgs.inject([]) {|s, (k,v)| s << "#{k} >#{v.class}< >#{v.size rescue :nosize}<"}
      end

      def logger_fmt1(logrArgs)
        logrArgs.is_a?(Hash) || raise(ArgumentError,"logrArgs >#{logrArgs}< not hash",caller)
        logrArgs.inject([]) {|s, (k,v)| s << "#{k} >#{v.whoami?}< >#{v.inspect}<"}
      end

      def logger_fmt2(logrArgs)
        logrArgs.is_a?(Hash) || raise(ArgumentError,"logrArgs >#{logrArgs}< not hash",caller)
        logrArgs.inject([]) {|s, (k,v)| s << "#{k} >#{v.whoami?}<"}
      end

      alias_method :logger_fmt_kls, :logger_fmt0
      alias_method :logger_fmt_kls_only, :logger_fmt00
      alias_method :logger_fmt_who, :logger_fmt1
      alias_method :logger_fmt_who_only, :logger_fmt2

      def logger_info(*a, &b)
        logger_generic(:info, *a, &b)
      end
      def logger_debug(*a, &b)
        logger_generic(:debug, *a, &b)
      end
      def logger_warn(*a, &b)
        logger_generic(:warn, *a, &b)
      end
      def logger_error(*a, &b)
        logger_generic(:error, *a, &b)
      end
      def logger_fatal(*a, &b)
        logger_generic(:fatal, *a, &b)
      end
      def logger_unknown(*a, &b)
        logger_generic(:unknown, *a, &b)
      end

      def logger_generic(logType, logEye, *logArgs, &logBlok)
        $DEBUG && begin
                    logTypeCheck = [logType] - [:warn, :debug, :info, :error, :fatal, :unknown]

                    logTypeCheck.empty? || raise_exception(ArgumentError, "log type >#{logType}< unknown")

                    logger.__send__(logType, *logEye) { logger_fmt(*logArgs) }
                  end
        

      end

      def logger_instance_telltale(tellTale=nil)
        case tellTale
        when NilClass then
          @logger_instance_telltale ||= "I(%x)" % (object_id.abs*2)
        else
          @logger_instance_telltale = "#{tellTale}(%x)" % (object_id.abs*2)
        end
      end
  
    end
  end
end


__END__
