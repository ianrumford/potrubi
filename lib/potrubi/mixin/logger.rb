
# Common Mixins

# logger methods 

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
      
      #=begin
      def logger_enabled?(logrLevel=nil)
        case logrLevel
        when Fixnum
          (@logger_level ||= nil) && @logger_level.is_a?(Fixnum) && (logrLevel <= @logger_level) && logrLevel
        else
          nil
        end
      end
      #=end
      
      #=begin
      def logger_fmt(*logrArgs)
        logrArgs.flatten.compact.join(' ')
      end
      alias_method :logger_format_telltales, :logger_fmt
      alias_method :potrubi_bootstrap_logger_format_telltales, :logger_fmt
      #=end
      
      #=begin
      def logger_message(logEye, *logArgs, &msgBlok)
        $DEBUG && logger.debug(logEye) { logger_format_telltales(*logArgs) }
      end
      #=end

      #=begin
      def logger_message_beg(logEye, *logArgs, &msgBlok)
        logger_message(logEye, :BEG, *logArgs, &msgBlok)
      end
      #=end
      #=begin
      def logger_message_fin(logEye, *logArgs, &msgBlok)
        logger_message(logEye, :FIN, *logArgs, &msgBlok)
      end
      #=end
      
      #=begin
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
      #=end
      
      alias_method :logger_ms, :logger_message
      alias_method :logger_en?, :logger_enabled?

      alias_method :logger_beg, :logger_message_beg
      alias_method :logger_fin, :logger_message_fin
      
      #=begin
      def logger_fmt0(logrArgs)
        logrArgs.is_a?(Hash) || raise(ArgumentError,"logrArgs >#{logrArgs}< not hash",caller)
        logrArgs.inject([]) {|s, (k,v)| s << "#{k} >#{v.class}< >#{v}<"}
      end
      #=end
      #=begin
      def logger_fmt00(logrArgs)
        logrArgs.is_a?(Hash) || raise(ArgumentError,"logrArgs >#{logrArgs}< not hash",caller)
        logrArgs.inject([]) {|s, (k,v)| s << "#{k} >#{v.class}<"}
      end
      #=end
      #=begin
      def logger_fmt1(logrArgs)
        logrArgs.is_a?(Hash) || raise(ArgumentError,"logrArgs >#{logrArgs}< not hash",caller)
        logrArgs.inject([]) {|s, (k,v)| s << "#{k} >#{v.whoami?}< >#{v}<"}
      end
      #=end
      #=begin
      def logger_fmt2(logrArgs)
        logrArgs.is_a?(Hash) || raise(ArgumentError,"logrArgs >#{logrArgs}< not hash",caller)
        logrArgs.inject([]) {|s, (k,v)| s << "#{k} >#{v.whoami?}<"}
      end
      #=end

      alias_method :logger_fmt_kls, :logger_fmt0
      alias_method :logger_fmt_kls_only, :logger_fmt00
      alias_method :logger_fmt_who, :logger_fmt1
      alias_method :logger_fmt_who_only, :logger_fmt2

=begin
      alias_method :potrubi_bootstrap_logger, :logger_message
      alias_method :potrubi_bootstrap_logger_me, :logger_me
      alias_method :potrubi_bootstrap_logger_mx, :logger_mx
      alias_method :potrubi_bootstrap_logger_ms, :logger_ms
      alias_method :potrubi_bootstrap_logger_ca, :logger_ca
      alias_method :potrubi_bootstrap_logger_fmt_class, :logger_fmt0
      alias_method :potrubi_bootstrap_logger_fmt_who, :logger_fmt0
      alias_method :potrubi_bootstrap_logger_fmt_who_only, :logger_fmt00
=end
      
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

                    #logger.__send__(logType, *logArgs, &logBlok)
                    logger.__send__(logType, *logEye) { logger_fmt(*logArgs) }
                  end
        

      end
    end
  end
end


__END__

IGR::Mixin::Logger.instance_methods.each {|m| puts("Lgr Inst Mth >#{m}<")}

