require 'process'
require 'support/string_extend'

class Guide
  include Jasoet
  class Config
    @@actions = ['daftar', 'tambah', 'fcfs', 'sjfp' 'keluar']

    def self.actions;
      @@actions;
    end
  end

  def initialize(path=nil)
    Process.filepath = path
    if Process.file_usable?
      puts "Menemukan fIle data."
    elsif Process.create_file
      puts "Membuat file Data."
    else
      puts "Keluar.\n\n"
      exit!
    end
  end

  def launch!
    introduction
    result = nil
    until result == :quit
      action, args = get_action
      result = do_action(action, args)
    end
    conclusion
  end

  def get_action
    action = nil
    until Guide::Config.actions.include?(action)
      puts "Perintah: " + Guide::Config.actions.join(", ")
      print "> "
      user_response = gets.chomp
      args          = user_response.downcase.strip.split(' ')
      action        = args.shift
    end
    return action, args
  end

  def do_action(action, args=[])
    case action
      when 'daftar'
        list(args)
      when 'tambah'
        add
      when 'keluar'
        return :quit
      else
        puts "\nPerintah tidak Dikenali.\n"
    end
  end

  def list(args=[])
    sort_order = args.shift
    parameters = ['proses', 'burst', 'prioritas', 'kedatangan']
    sort_order = "proses" unless parameters.include?(sort_order)

    output_action_header("Daftar Processs")

    procs      = Process.saved_process
    procs.sort! do |r1, r2|
      case sort_order
        when 'proses'
          r1.pid.downcase <=> r2.pid.downcase
        when 'burst'
          r1.burst.to_i <=> r2.burst.to_i
        when 'prioritas'
          r1.priority.to_i <=> r2.priority.to_i
        when 'kedatangan'
          r1.arrival.to_i <=> r2.arrival.to_i
      end
    end
    output_process_table(procs)
    puts "Urutkan Menggunakan : 'daftar kedatangan'"
    puts "Parameter yang dapat digunakan ["+ parameters.join("/")+"]"
  end


  def add
    output_action_header("Tambah Process")
    proc     = Process.build_using_questions
    procs    = Process.saved_process
    proc.pid = "P"+(procs.length + 1).to_s
    if proc.save
      puts "\nPenyimpanan Berhasil\n\n"
    else
      puts "\nPenyimpanan Berhasil\n\n"
    end
  end

  def introduction
    puts "\n\n<<< Selamat datang pada Program Simulasi Penjadwalan Proses >>>\n\n"
  end

  def conclusion
    puts "\n<<< Program Selesai >>>\n\n\n"
  end

  private

  def output_action_header(text)
    puts "\n#{text.upcase.center(46)}\n\n"
  end

  def output_process_table(procs = [])
    print "|"+"Proses".ljust(6)
    print "|"+"Burst Time".ljust(10)
    print "|"+"Prioritas".ljust(9)
    print "|"+"Waktu Kedatangan".ljust(16) + "|\n"
    puts "-"*46
    procs.each do |pro|
      line  = "|" << pro.pid.rjust(6)
      line << "|" + pro.burst.to_s.rjust(10)
      line << "|" + pro.priority.to_s.rjust(9)
      line << "|" +pro.arrival.to_s.rjust(16)+"|"
      puts line
    end
    puts "Data Kosong" if procs.empty?
    puts "-" * 46
  end

end
