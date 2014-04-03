module WebRepl

  # The main REPL object
  class REPL

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

    # Start the Websocket connection (blocking)
    # @param [Hash] options
    # @option options [Boolean] :background Do not wait for input, just run in the bg
    def start(options = {})
      EM::WebSocket.run(@config) do |ws|
        @socket = ws
        @messager = Messager.new(@socket)
        configure_event_handling(:background => options[:background])
      end
    end

    private

    # Configure the Websocket event handling
    # @param [Hash] options
    # @option options [Boolean] :background Do not wait for input, just run in the bg
    def configure_event_handling(options = {})
      @socket.onopen do |handshake|
        puts "b-r: Connection open"
        @active = true
        gets unless !!options[:background]
      end

      @socket.onclose do 
        puts "b-r: Connection closed"
        @active = false
      end

      @socket.onmessage do |raw_message|
        @messager.in(raw_message) do |message|
          output = if !message[:value].nil?
            message[:value]
          elsif !message[:error].nil?
            message[:error].red
          end
          puts(output)
        end
        gets unless !!options[:background]
      end

    end

  end
end
