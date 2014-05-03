module Pushr
  module Daemon
    module ApnsSupport
      class InterruptibleSleep

        def initialize
          @sleep_reader, @wake_writer = IO.pipe
        end

        # wait for the given timeout in seconds, or data was written to the pipe.
        # @return [boolean] true if the sleep was interrupted, or false
        def sleep(timeout)
          read_ports = [@sleep_reader]
          rs, = IO.select(read_ports, nil, nil, timeout) rescue nil

          # consume all data on the readable io's so that our next call will wait for more data
          perform_io(rs, @sleep_reader, :read_nonblock)

          !rs.nil? && rs.any?
        end

        # writing to the pipe will wake the sleeping thread
        def interrupt_sleep
          @wake_writer.write('.')
        end

        def close
          @sleep_reader.close rescue nil
          @wake_writer.close rescue nil
        end

        private

        def perform_io(selected, io, meth)
          if selected && selected.include?(io)
            while true
              begin
                io.__send__(meth, 1)
              rescue Errno::EAGAIN, IO::WaitReadable
                break
              end
            end
          end
        end
      end
    end
  end
end
