# Patch EventMachine::WebSocket so that we can initialize EM on demand
module EventMachine
  module WebSocket
    def self.start(options, &blk)
      EM.epoll
      #EM.run {
        trap("TERM") { stop }
        trap("INT")  { stop }

        run(options, &blk)
      #}
    end

    def self.run(options)
      host, port = options.values_at(:host, :port)
      EM.start_server(host, port, Connection, options) do |c|
        yield c
      end
    end
  end
end

module BrowserRepl

  class REPL

    attr_reader :messager

    def initialize(config)
      @config = config
      @socket = nil
      @messager = nil
      start
    end

    private

    def get_input
      line = Readline.readline('> ', true)
      return nil if line.nil?
      if line =~ /^\s*$/ or Readline::HISTORY.to_a[-2] == line
        Readline::HISTORY.pop
      end      
      statement = line.strip
      if statement == "exit"
        exit
      else
        @messager.out({ :statement => statement })
      end
    end

    def start
      EM::WebSocket.run(@config) do |ws|
        @socket = ws
        @messager = Messager.new(@socket)
        configure
      end
    end

    def configure
      @socket.onopen do |handshake|
        puts "b-r: Connection open"
        @active = true
        get_input
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
        get_input
      end

    end

  end
end
