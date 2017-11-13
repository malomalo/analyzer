require 'bigdecimal'

class Analyzer
  class Rss

    KB_TO_BYTE = 1024          # 2**10   = 1024
    MB_TO_BYTE = 1_048_576     # 1024**2 = 1_048_576
    GB_TO_BYTE = 1_073_741_824 # 1024**3 = 1_073_741_824
    CONVERSION = { "kb" => KB_TO_BYTE, "mb" => MB_TO_BYTE, "gb" => GB_TO_BYTE }
  
    def initialize(pid = Process.pid)
      @pid          = pid
      @status_file  = "/proc/#{@pid}/status"
      @linux        = File.exists?(@status_file)
    end
  
    def bytes
      @linux ? (linux_status_memory || ps_memory) : ps_memory
    end
  
    def inspect
      "#<#{self.class}:0x%08x @bytes=#{bytes}>" % (object_id * 2)
    end
  
    # linux stores memory info in a file "/proc/#{@pid}/status"
    # If it's available it uses less resources than shelling out to ps
    def linux_status_memory
      line = File.new(@status_file).each_line.detect { |l| l.start_with?('VmRSS'.freeze) }
      if line
        line = line.split(nil)
        if line.length == 3
          CONVERSION[line[1].downcase!] * line[2].to_i
        end
      end
    rescue Errno::EACCES, Errno::ENOENT
      0
    end
  
    # Pull memory from `ps` command, takes more resources and can freeze
    # in low memory situations
    def ps_memory
      KB_TO_BYTE * BigDecimal.new(`ps -o rss= -p #{@pid}`)
    end
  
  end
end