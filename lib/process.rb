module Jasoet
  class Process
    attr_accessor :pid, :arrival, :burst, :priority, :burst_remaining, :active

    @@filepath = nil

    def self.filepath=(path=nil)
      @@filepath = File.join(APP_ROOT, path)
    end


    def self.file_exists?
      if @@filepath && File.exists?(@@filepath)
        return true
      else
        return false
      end
    end

    def self.file_usable?
      return false unless @@filepath
      return false unless File.exists?(@@filepath)
      return false unless File.readable?(@@filepath)
      return false unless File.writable?(@@filepath)
      return true
    end

    def self.create_file
      File.open(@@filepath, 'w') unless file_exists?
      return file_usable?
    end

    def self.saved_process
      processes = []
      if file_usable?
        file = File.new(@@filepath, 'r')
        file.each_line do |line|
          processes << Process.new.import_line(line.chomp)
        end
        file.close
      end
      return processes
    end

    def self.build_using_questions
      args              = {}
      args[:arrival]    = input_prompt("Waktu kedatangan (ms) ", 0, 25)
      args[:burst]      = input_prompt("Burst Time (ms)", 1, 35)
      args[:priority]   = input_prompt("Prioritas (ms)", 1, 35)
      return self.new(args)
    end

    def initialize(args={})
      @pid             = args[:pid] || ""
      @arrival         = args[:arrival] || ""
      @burst           = args[:burst] || ""
      @burst_remaining = @burst
      @active          = true
      @priority        = args[:priority] || ""
    end

    def import_line(line)
      line_array = line.split(",")
      @pid, @arrival, @burst, @priority = line_array
      return self
    end

    def save
      return false unless Process.file_usable?
      File.open(@@filepath, 'a') do |file|
        file.puts "#{[@pid, @arrival, @burst, @priority].join(",")}\n"
      end
      return true
    end

    def self.input_prompt(str, min, max)
      condition  = true
      while condition do
        print "#{str} (#{min}-#{max})".ljust(35)+" : "
        var = gets.to_i
        if var < min || var > max
          puts "Data yang diperbolehkan antara #{min} sampai #{max}"
        else
          condition = false
        end
      end
      var        ||= 0
      return var
    end
  end
end