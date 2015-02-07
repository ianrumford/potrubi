
# Potrubi Test Logger Mixin

require 'minitest/autorun'
require 'minitest/spec'


require 'potrubi/mixin/logger'

class TestClass1

  include Potrubi::Mixin::Logger

end

describe TestClass1 do

  before do
    @mixConstant = Potrubi::Mixin::Logger
    @t = TestClass1.new
    @validClassMethods = [:logger,
                          :new_logger,
                         ]

    @validInstanceMethods = [:logger_fmt,
                             :logger_message,
                             :logger_method_entry,
                             :logger_method_exit,
                             :logger_method_call,
                             :logger_instance_telltale,
                            ]

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

  describe 'format messages' do

    it 'formats telltales ok' do
      tellTales = {
        'x' => :x,
        '1' => 1,
        'a b c' => %w(a b c),
        'Hello Mum' => [:Hello, :Mum],
        'Ruby is the Biz!' => [:Ruby, [:is, :the], 'Biz!'],
      }
      tellTales.each do | wantText, tellTale |
        @t.logger_format_telltales(tellTale).must_equal wantText
      end

    end

    it 'formats the instance telltales ok' do

      basetellTale = "(%x)" % (@t.object_id.abs*2)
      
      instanceTellTales = [
                           [nil, "I#{basetellTale}"],
                           ['ABC', "ABC#{basetellTale}"],
                           [nil, "ABC#{basetellTale}"],
                           [:xyz, "xyz#{basetellTale}"],
                           [nil, "xyz#{basetellTale}"],
                          ]
      
      

      instanceTellTales.each do | (prefix, instanceTellTale) |
        @t.logger_instance_telltale(prefix).must_equal instanceTellTale
      end
      
 
    end
    

  end
  

end


__END__


class TestLogger < MiniTest::Unit::TestCase
  def setup
    @logger = Potrubi:
    @meme = Meme.new
  end

  def test_that_kitty_can_eat
    assert_equal "OHAI!", @meme.i_can_has_cheezburger?
  end

  def test_that_it_will_not_blend
    refute_match /^no/i, @meme.will_it_blend?
  end

  def test_that_will_be_skipped
    skip "test this later"
  end
end

__END__


