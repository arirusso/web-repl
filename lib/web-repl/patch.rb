# Patch EventMachine::WebSocket so that we can initialize EM on demand.  This is useful when 
# having multiple EMs working.  It won't error out by calling EM.run repeatedly.
#
module EventMachine
  module WebSocket
    def self.start(options = {}, &block)
      EM.epoll
      if EM.reactor_running?
        hamdle_start(options, &block)
      else
        EM.run { handle_start(options, &block) }
      end
    end

    def self.run(options = {}, &block)
      if EM.reactor_running?
        hamdle_run(options, &block)
      else
        EM.run { handle_run(options, &block) }
      end      
    end

    private

    def self.handle_run(options = {}, &block)
      host, port = options.values_at(:host, :port)
      EM.start_server(host, port, Connection, options) do |c|
        yield c
      end
    end

    def self.handle_start(options = {}, &block)
      trap("TERM") { stop }
      trap("INT")  { stop }
      run(options, &block)
    end

  end
end
