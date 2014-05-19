module Pushr
  module Daemon
    module ApnsSupport
      class InterruptibleSleep
        def sleep(seconds)
          @_sleep_check, @_sleep_interrupt = IO.pipe
          IO.select([@_sleep_check], nil, nil, seconds)
          @_sleep_check.close rescue IOError
          @_sleep_interrupt.close rescue IOError
        end

        def interrupt
          if @_sleep_interrupt
            @_sleep_interrupt.close rescue IOError
          end
        end
      end
    end
  end
end
