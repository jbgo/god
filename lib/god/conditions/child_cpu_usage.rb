module God
  module Conditions

    # Condition Symbol :child_cpu_usage
    # Type: Poll
    #
    # Trigger when the percent of CPU use of a child process is above a specified limit.
    # On multi-core systems, this number could conceivably be above 100.
    #
    # Paramaters
    #   Required
    #     +pid_file+ is the pid file of the process in question. Automatically
    #                populated for Watches.
    #     +above+ is the percent CPU above which to trigger the condition. You
    #             may use #percent to clarify this amount (see examples).
    #
    # Examples
    #
    # Trigger if the child process is using more than 25 percent of the cpu (from a Watch):
    #
    #   on.condition(:child_cpu_usage) do |c|
    #     c.above = 25.percent
    #   end
    #
    # Non-Watch Tasks must specify a PID file:
    #
    #   on.condition(:child_cpu_usage) do |c|
    #     c.above = 25.percent
    #     c.pid_file = "/var/run/mongrel.3000.pid"
    #   end
    class ChildCpuUsage < CpuUsage

      def test
        child_process = System::PortableChildPoller.new(self.pid)
        @timeline.push(child_process.percent_cpu)

        history = "[" + @timeline.map { |x| "#{x > self.above ? '*' : ''}#{x}%%" }.join(", ") + "]"

        if @timeline.select { |x| x > self.above }.size >= self.times.first
          self.info = "cpu out of bounds #{history}"
          return true
        else
          self.info = "cpu within bounds #{history}"
          return false
        end
      end

    end

  end
end
