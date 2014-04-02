require "helper"

class BrowserRepl::MessagerTest < Test::Unit::TestCase

  include BrowserRepl

  context "Messager" do

    setup do
      @socket = Object.new
      @messager = Messager.new(@socket)
    end

    context "#in" do

      setup do
        @message = { :value => "blah", :timestamp => 1396406728702 }.to_json
        @result = @messager.in(@message)
      end

      should "convert from String to Hash" do
        assert_not_nil @result
        assert_equal Hash, @result.class
        assert_equal "blah", @result[:value]
      end

      should "convert timestamp from js time to ruby" do
        timestamp = @result[:timestamp]
        assert_not_nil timestamp
        assert_equal Time, timestamp.class
        assert_equal 2014, timestamp.year
        assert_equal 4, timestamp.month
        assert_equal 22, timestamp.hour
      end
      
    end

    context "#new_timestamp" do

      should "be js int time format" do
        result = @messager.new_timestamp
        assert_not_nil result
        assert_equal Fixnum, result.class
        assert result.to_s.size > Time.new.to_i.to_s.size
        assert_equal (result / 1000).to_s.size, Time.new.to_i.to_s.size
      end

    end

    context "#out" do

      setup do
        @message = { :statement => "something" }
      end

      should "not overwrite timestamp" do
        @socket.expects(:send).once
        ts = Time.now.to_i / 1000
        @message[:timestamp] = ts
        @messager.out(@message)
        assert_equal ts, @message[:timestamp]
      end

      should "generate new timestamp" do
        @socket.expects(:send).once
        @messager.out(@message)
        assert_not_nil @message[:timestamp]
        assert_equal Fixnum, @message[:timestamp].class
      end

      should "return nil if fails" do
        messager = Messager.new(nil)
        result = messager.out(@message)
        assert_nil result
      end

      should "return json string if success" do
        @socket.expects(:send).once
        result = @messager.out(@message)
        assert_not_nil result
        assert_equal String, result.class
      end

    end

  end

end
