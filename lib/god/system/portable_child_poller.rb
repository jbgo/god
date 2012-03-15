module God
  module System
    class PortableChildPoller
      def initialize(pid)
        @pid = pid
      end
      # Memory usage in kilobytes (resident set size)
      def memory
        child_pids.empty? ? 0 : ps_int('rss') / 1.kilobytes
      end

      # Percentage memory usage
      def percent_memory
        child_pids.empty? ? 0.0 : ps_float('%mem')
      end

      # Percentage CPU usage
      def percent_cpu
        child_pids.empty? ? 0.0 : ps_float('%cpu')
      end

      private

      def child_pids
        @child_pids ||= `ps -Ao pid,ppid | grep #@pid | awk '{print $1}' | grep -v #@pid`.strip.split("\n").join(' ')
      end

      def ps_int(keyword)
        sum_ps_output(`ps -o #{keyword}= -p #{child_pids}`, :to_i)
      end

      def ps_float(keyword)
        sum_ps_output(`ps -o #{keyword}= -p #{child_pids}`, :to_f)
      end

      def sum_ps_output(stdout, type=:to_i)
        stdout.strip.split("\n").map(&type).inject(0, &:+)
      end
    end
  end
end
