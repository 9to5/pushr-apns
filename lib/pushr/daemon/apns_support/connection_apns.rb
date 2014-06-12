module Pushr
  module Daemon
    module ApnsSupport
      class ConnectionError < StandardError; end

      class ConnectionApns
        attr_reader :name, :configuration
        attr_accessor :last_write
        IDLE_PERIOD = 30 * 60
        SELECT_TIMEOUT = 0.2
        ERROR_TUPLE_BYTES = 6
        APN_ERRORS = {
          1 => 'Processing error',
          2 => 'Missing device token',
          3 => 'Missing topic',
          4 => 'Missing payload',
          5 => 'Missing token size',
          6 => 'Missing topic size',
          7 => 'Missing payload size',
          8 => 'Invalid token',
          255 => 'None (unknown error)'
        }

        def initialize(configuration, i = nil)
          @configuration = configuration
          if i
            # Apns push connection
            @name = "#{@configuration.app}: ConnectionApns #{i}"
            @host = "gateway.#{configuration.sandbox ? 'sandbox.' : ''}push.apple.com"
            @port = 2195
          else
            @name = "#{@configuration.app}: FeedbackReceiver"
            @host = "feedback.#{configuration.sandbox ? 'sandbox.' : ''}push.apple.com"
            @port = 2196
          end
          written
        end

        def connect
          @ssl_context = setup_ssl_context
          @tcp_socket, @ssl_socket = connect_socket
        rescue
          Pushr::Daemon.logger.error("#{@name}] Error connection to server, invalid certificate?")
        end

        def close
          @ssl_socket.close if @ssl_socket
          @tcp_socket.close if @tcp_socket
        rescue IOError
        end

        def read(num_bytes)
          @ssl_socket.read(num_bytes)
        end

        def select(timeout)
          IO.select([@ssl_socket], nil, nil, timeout)
        end

        def write(data)
          reconnect_idle if idle_period_exceeded?

          retry_count = 0

          begin
            write_data(data)
          rescue Errno::EPIPE, Errno::ETIMEDOUT, Errno::ECONNRESET, OpenSSL::SSL::SSLError => e
            retry_count += 1

            if retry_count == 1
              Pushr::Daemon.logger.error("[#{@name}] Lost connection to #{@host}:#{@port} (#{e.class.name}), reconnecting...")
            end

            if retry_count <= 3
              reconnect
              sleep 1
              retry
            else
              raise ConnectionError, "#{@name} tried #{retry_count - 1} times to reconnect but failed (#{e.class.name})."
            end
          end
          check_for_error(data)
        end

        def reconnect
          close
          @tcp_socket, @ssl_socket = connect_socket
        end

        def check_for_error(notification)
          # check for true, because check_for_error can be nil
          return if @configuration.skip_check_for_error == true

          if select(SELECT_TIMEOUT)
            error = nil

            if tuple = read(ERROR_TUPLE_BYTES)
              _, code, notification_id = tuple.unpack('ccN')

              description = APN_ERRORS[code.to_i] || 'Unknown error. Possible push bug?'
              error = Pushr::Daemon::DeliveryError.new(code, notification_id, description, 'APNS')
            else
              error = DisconnectionError.new
            end

            begin
              Pushr::Daemon.logger.error("[#{@name}] Error received, reconnecting...")
              reconnect
            ensure
              fail error if error
            end
          end
        end

        protected

        def reconnect_idle
          Pushr::Daemon.logger.info("[#{@name}] Idle period exceeded, reconnecting...")
          reconnect
        end

        def idle_period_exceeded?
          Time.now - last_write > IDLE_PERIOD
        end

        def write_data(data)
          @ssl_socket.write(data.to_message)
          @ssl_socket.flush
          written
        end

        def written
          self.last_write = Time.now
        end

        def setup_ssl_context
          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.key = OpenSSL::PKey::RSA.new(configuration.certificate, configuration.certificate_password)
          ssl_context.cert = OpenSSL::X509::Certificate.new(configuration.certificate)
          ssl_context
        end

        def connect_socket
          tcp_socket = TCPSocket.new(@host, @port)
          tcp_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, 1)
          tcp_socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
          ssl_socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, @ssl_context)
          ssl_socket.sync = true
          ssl_socket.connect
          Pushr::Daemon.logger.info("[#{@name}] Connected to #{@host}:#{@port}")
          [tcp_socket, ssl_socket]
        end
      end
    end
  end
end
