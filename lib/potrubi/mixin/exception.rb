
require_relative '../bootstrap'

requireList = %w(dynamic)
requireList.each {|r| require_relative "#{r}"}

mixinContent = Module.new do

  errorMap = {
    :ArgumentError => [:ContractError, :SurpriseError, :EmptyError, :NilError, :ValueError, :UnsupportedError, :SupriseError, :DuplicateError, :MissingError, :UnequalError, :SizeError, :FileNotFoundError, :FileNotWriteableError, :RequireError, :ChainError],
    :RuntimeError => [:MethodError, :TraceAbort, :TraceError, :LogicError, :ConnectionError],
  }

  errorTexts = errorMap.map do | mainError, subErrors |
    subErrors.map { | subError | "class #{subError} < #{mainError};end;\n" }
  end
  
  errorText = errorTexts.flatten.compact.join
  
  Object.class_eval(errorText)

  def raise_exception(exceptionTypeNom, *tellTales)
    exceptionTypeNrm = exceptionTypeNom.is_a?(Exception) ? exceptionTypeNom : RuntimeError  # was an exxception type given? Default to Rumtime
    tellTale = (exceptionTypeNrm == exceptionTypeNom) ? logger_format_telltales(*tellTales) : logger_format_telltales(exceptionTypeNom, *tellTales)
    raise(exceptionTypeNrm,tellTale,caller)
  end
  
  def trace_exception(*tellTales)
    raise_exception(RuntimeError, 'TRACE TRACE TRACE', *tellTales)
  end

  exceptionMethods = {
    :unsupported => nil,
    :surprise => nil,
    :duplicate => nil,
    :missing => nil,
    :contract => nil,
    :nomethod => nil,
    :size => nil,
    :empty => nil,
    :connection => nil,
  }

  Potrubi::Mixin::Dynamic::dynamic_define_methods(self, exceptionMethods) do | exceptionMethod, exceptionType |

    excType = exceptionType || exceptionMethod
    edits = {
      METHOD_NAME: "#{exceptionMethod}_exception",
      EXCEPTION_NAME: "#{exceptionMethod}",
      EXCEPTION_TYPE: excType.to_s.split('_').map{|a| a.capitalize }.join.sub(/\Z/,'Error'),
    }

    textException = <<-'ENDOFHERE'
           def METHOD_NAME(value, *args)
             raise_exception(EXCEPTION_TYPE, *args, "value >#{value.class}< >#{value}<")
           end;                            
           ENDOFHERE

           {edit: edits, spec: textException}
           
         end
         
end

module Potrubi
  module Mixin
    module Exception
    end
  end
end

###Potrubi::Mixin::Exception.extend(metaclassMethods)
Potrubi::Mixin::Exception.__send__(:include, mixinContent)  # Instance Methods

__END__




