
# Potrubi Test Bootstrap Common Mixin

require 'minitest/autorun'
require 'minitest/spec'

require 'potrubi/mixin/logger'
require 'potrubi/mixin/bootstrap_common'

class TestClass1

  
  include Potrubi::Mixin::Logger
  include Potrubi::Mixin::BootstrapCommon

end

describe TestClass1 do

  before do
    @mixConstant = Potrubi::Mixin::BootstrapCommon
    @t = TestClass1.new
    @validClassMethods = [#:logger,
                          #:new_logger,
                         ]

    @validLoggerInstanceMethods = [
                                   :logger,
                                   :logger_instance_telltale,
                                   :logger_me,
                                   :logger_mx,
                                   :logger_ms,
                                   :logger_ca,
                                   :logger_beg,
                                   :logger_fin,
                                   :logger_fmt,
                                   :logger_fmt_kls,
                                   :logger_fmt_kls_size,
                                   :logger_fmt_who,
                                   :logger_fmt_who_only,
                                   
                                  ].map {|m| "potrubi_bootstrap_#{m}" }


    @validContractInstanceMethods = [:hash,
                                     :array,
                                     :fixnum,
                                     :string,
                                     :symbol,
                                     :float,
                                     :class,
                                     :module,
                                     :proc,
                                     :key,
                                     :file,
                                     :directory,
                                     :not_nil,
                                     :not_empty,
                                     :empty
                                    ].map {|m| "potrubi_bootstrap_mustbe_#{m}_or_croak"}

    @validExceptionInstanceMethods = [:raise,
                                      :surprise,
                                      :duplicate,
                                      :missing,
                                     ].map {|m| "potrubi_bootstrap_#{m}_exception" }

    @validInstanceMethods = [@validContractInstanceMethods,
                             @validLoggerInstanceMethods,
                             @validExceptionInstanceMethods,
                            ].flatten

    @validContractTests = {
      hash: {},
      array: [],
      string: 'Hi There',
      symbol: :'A symbol',
      fixnum: 1,
      float: 2.3,

      class: Class.new,
      module: Module.new,

      file: __FILE__,
      directory: File.dirname(__FILE__),
      
      #empty: [],
      #not_empty: %w(this is not empty),
      #not_nil: 'definitely is not nil',
      ###proc: ->(p) {true}, # can't test proc for some reason - confuses Minitest?
    }

    @invalidContractTests = {
      hash: {},
      array: [],
      string: 'Hi There',
      symbol: :'A symbol',
      fixnum: 1,
      float: 2.3,

      #class: Class.new,
      module: Module.new,

      #file: __FILE__,
      #directory: File.dirname(__FILE__),
      
 
      ###proc: ->(p) {true}, # can't test proc for some reason - confuses Minitest?
    }

    @validContractSpecialTests = {
      empty: [],
      not_empty: %w(this is not empty),
      not_nil: 'definitely is not nil',
    }
  end

  describe 'mixin reponds to only module methods' do

    it 'has valid module methods' do
      @validClassMethods.each { | methodName | @mixConstant.must_respond_to methodName }
    end

    it 'mixin doesnt repond to instance methods' do
      @validInstanceMethods.each { | methodName | @mixConstant.wont_respond_to methodName }
    end

    
  end

  describe 'class reponds to instance methods' do
    
    it 'has valid instance methods' do
      @validInstanceMethods.each { | methodName | @t.must_respond_to methodName }
    end

  end

  describe 'does contracts' do

    it 'valid one value contracts' do

      validContracts = @validContractTests


      validContracts.each do | contractName, contractTest |
        contractMethod = "potrubi_bootstrap_mustbe_#{contractName}_or_croak"
        puts("VALID contractName >#{contractName}< contractMethod >#{contractMethod}< contractTest >#{contractTest.class}<")
        @t.__send__(contractMethod, contractTest).must_equal(contractTest)
      end
      

    end

    it 'valid one value speical contracts' do

      validContracts = @validContractSpecialTests

      validContracts.each do | contractName, contractTest |
        contractMethod = "potrubi_bootstrap_mustbe_#{contractName}_or_croak"
        puts("VALID SPEICAL contractName >#{contractName}< contractMethod >#{contractMethod}< contractTest >#{contractTest.class}<")
        @t.__send__(contractMethod, contractTest).must_equal(contractTest)
      end
      

    end
    
    it 'invalid one value contracts' do

      validContracts =  @validContractTests
      invalidContracts = @invalidContractTests

      ##invalidContracts = invalidContractsNom.select {|k,v| k != contractName}

      invalidContracts.each do | invalidContractName, invalidContractTest |

        validContractsSel = validContracts.select {|k,v| k != invalidContractName}
        
        ###validContracts.has_key?(invalidContractName) || next # invliad only a subset
        
        validContractsSel.each do | contractName, contractTest |
          contractMethod = "potrubi_bootstrap_mustbe_#{contractName}_or_croak"
          
          puts("INVALID contractName >#{contractName}< contractMethod >#{contractMethod}< invalidContractTest >#{invalidContractTest.class}< invalidContractName >#{invalidContractName}<")
          ##@t.__send__(contractMethod, contractTest).must_equal(contractTest)
          proc do
            @t.__send__(contractMethod, invalidContractTest)
          end.must_raise ArgumentError
          
        end
        
        
      end
      

    end
    
    
  end
  
end


__END__

