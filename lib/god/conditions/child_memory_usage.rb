module God
  module Conditions

    # Condition Symbol :child_memory_usage
    # Type: Poll
    #
    # Trigger when the resident memory of a process is above a specified limit.
    #
    # Paramaters
    #   Required
    #     +pid_file+ is the pid file of the process in question. Automatically
    #                populated for Watches.
    #     +above+ is the amount of resident memory (in kilobytes) above which
    #             the condition should trigger. You can also use the sugar
    #             methods #kilobytes, #megabytes, and #gigabytes to clarify
    #             this amount (see examples).
    #
    # Examples
    #
    # Trigger if the process is using more than 100 megabytes of resident
    # memory (from a Watch):
    #
    #   on.condition(:child_memory_usage) do |c|
    #     c.above = 100.megabytes
    #   end
    #
    # Non-Watch Tasks must specify a PID file:
    #
    #   on.condition(:child_memory_usage) do |c|
    #     c.above = 100.megabytes
    #     c.pid_file = "/var/run/mongrel.3000.pid"
    #   end
    class ChildMemoryUsage < MemoryUsage

      def test
        child_process = System::PortableChildPoller.new(self.pid)
        @timeline.push(child_process.memory)

        history = "[" + @timeline.map { |x| "#{x > self.above ? '*' : ''}#{x}kb" }.join(", ") + "]"

        if @timeline.select { |x| x > self.above }.size >= self.times.first
          self.info = "memory out of bounds #{history}"
          return true
        else
          self.info = "memory within bounds #{history}"
          return false
        end
      end

    end

  end
end
