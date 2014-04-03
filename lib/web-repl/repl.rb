module WebRepl

  # The main REPL object
  class REPL

    attr_reader :thread

    # Start a repl connection
    # @param [Hash] config A hash of config options to be passed to EM::WebSocket.run directly
    # @param [Hash] options
    # @option options [IO, nil] :debug A debug logger or nil if debug is not needed (default: nil)
    # @option options [Boolean] :background Do not wait for input, just run in the bg
    # @return [WebRepl::REPL]
    def self.start(config, options = {})
      new(config, options).tap { |repl| repl.start(options) }
    end

    # @param [Hash] config A hash of config options to be passed to EM::WebSocket.run directly
    # @param [Hash] options
    # @option options [IO, nil] :debug A debug logger or nil if debug is not needed (default: nil)
    def initialize(config, options = {})
      @config = config
      @socket = nil
      @messager = nil
      @buffer = []
      @debug = options[:debug]
    end

    # Send a statement to the browser for evaluation
    # @param [Fixnum, String] statement A Javascript statement to be evaluated
    # @return [String, nil] The data that was sent to the browser, or nil if sending could not be completed. 
    def evaluate(statement)
      @messager.out({ :statement => statement }) unless @messager.nil?
    end

    # Prompt the Ruby user for input and send that input to the browser for evaluation (blocking)
    # @return [String, nil] The data that was sent to the browser, or nil if sending could not be completed
    def gets
      line = Readline.readline('> ', true)
      return nil if line.nil?
      if line =~ /^\s*$/ or Readline::HISTORY.to_a[-2] == line
        Readline::HISTORY.pop
      end      
      statement = line.strip
      case statement
      when "exit" then exit
      else
        evaluate(statement)
      end
    end

    # Wait for a response from the browser
    def wait_for_response
      loop until !@buffer.empty?
    end

    # Start the Websocket connection (blocking)
    # @param [Hash] options
    # @option options [Boolean] :background Do not wait for input, just run in the bg
    def start(options = {}, &block)
      @thread = Thread.new do
        EM::WebSocket.run(@config) do |ws|
          if @socket.nil?
            @socket = ws
            @messager = Messager.new(@socket)
            configure_event_handling(:background => options[:background], &block)
          end
        end
      end
      acknowledge_handshake do
        yield if block_given?
        gets unless !!options[:background]
      end
      @thread.join unless !!options[:background]
    end

    # Execute a block when a connection is made
    # @return [TrueClass]
    def acknowledge_handshake(&block)
      Thread.new do
        loop until !@handshake.nil?
        yield
      end
    end

    # Close the REPL
    def close
      @socket.close unless @socket.nil?
      @thread.kill unless @thread.nil?
    end

    private

    def handle_open(handshake, options = {})
      puts "web-repl: Connection open"
      @handshake = handshake
    end

    def handle_close
      puts "web-repl: Connection closed"
      @handshake = nil
    end

    def handle_message_received(raw_message, options = {})
      @messager.in(raw_message) do |message|
        @buffer.clear
        @buffer << message
        keys = { :error => :red, :value => :white }
        text = nil
        keys.each do |k,v| 
          text ||= message[k].to_s.send(v) unless message[k].nil?
        end
        puts(text)
      end
      gets unless !!options[:background]
    end

    # Configure the Websocket event handling
    # @param [Hash] options
    # @option options [Boolean] :background Do not wait for input, just run in the bg
    def configure_event_handling(options = {})
      @socket.onopen { |handshake| handle_open(handshake) }
      @socket.onclose { handle_close }
      @socket.onmessage { |raw_message| handle_message_received(raw_message) }
    end

  end
end
