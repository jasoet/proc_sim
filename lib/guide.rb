require 'process'
require "jqueue"
require 'support/string_extend'

class Guide
  include Jasoet
  class Config
    @@actions = ['daftar', 'tambah', 'fcfs', 'sjfp', 'keluar']

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
      when 'fcfs'
        fcfs
      when 'sjfp'
        sjfp
      when 'keluar'
        return :quit
      else
        puts "\nPerintah tidak Dikenali.\n"
    end
  end

  def sjfp

    output_action_header "Preemptive Shortest Job First"
    total = Process.total_burst_time
    procs = Process.sort(:arrival)


    Thread.new {
#      begin
      sleep(0.5)
      puts ""
      puts "-"*53
      print "|"+"Detik".ljust(5)
      print "|"+"Tereksekusi".ljust(12)
      print "|"+"Proses Datang".ljust(13)
      print "|"+"Antrian".ljust(18) + "|\n"
      puts "|"+ "-"*51+"|"
      antrian  = []
      proc_cur = nil
      (total).times do |i|

        #mengambil seluruh proses yang datang pada detik tertentu
        proc_arrv     = procs.select { |v|
          v.arrival.to_i == i
        }


        #proses yg datang dimasukkan dalam antrian
        unless proc_arrv.empty?
          proc_arrv.each { |v|
            antrian << v
          }
        end

        antrian.sort! do |r1, r2|
          r1.burst_remaining.to_i <=> r2.burst_remaining.to_i
        end


        proc_arrv_pid = proc_arrv.collect { |v|
          v.pid
        }

        antrian_pid   = antrian.collect { |v|
          v.pid+"=>"+v.burst_remaining.to_s
        }

        proc_cur      = antrian.first
        unless proc_cur.nil?
          proc_cur.burst_remaining -= 1
        end

        print "|"+(i+1).to_s.rjust(5)
        print "|"+"#{proc_cur.nil? ? '-' : proc_cur.pid}".ljust(12)
        print "|"+"#{proc_arrv_pid.inspect unless proc_arrv_pid.empty?}".ljust(13)
        print "|"+"#{antrian_pid.inspect unless antrian.empty?}".ljust(18) + "|\n"
        sleep(0.1)


        if proc_cur.nil?

        elsif (proc_cur.burst_remaining.to_i == 0)
          antrian.delete(proc_cur)

          antrian.sort! do |r1, r2|
            r1.burst_remaining.to_i <=> r2.burst_remaining.to_i
          end
          proc_cur      = antrian.first
        end
#      end
#
#        puts "-"*53
#        output_action_header "rangkuman"
#        output_process_table_executed(procs)
#
#        puts "Rata-rata Waktu Tunggu :  " + Process.average_wait_time(procs).to_s
#      rescue => e
#        puts e.message
#        print e.backtrace.join("\n")
      end
      puts "Tekan ENTER untuk melanjutkan"
    }

  end

  def fcfs


    output_action_header "First Come First Serve"

    total    = Process.total_burst_time
    procs    = Process.sort(:arrival)


    Thread.new {
      begin
        sleep(0.5)
        puts ""
        puts "-"*53
        print "|"+"Detik".ljust(5)
        print "|"+"Tereksekusi".ljust(12)
        print "|"+"Proses Datang".ljust(13)
        print "|"+"Antrian".ljust(18) + "|\n"
        puts "|"+ "-"*51+"|"
        antrian  = []
        proc_cur = nil
        (total+1).times do |i|

          #mengambil seluruh proses yang datang pada detik tertentu
          proc_arrv     = procs.select { |v|
            v.arrival.to_i == i
          }


          #proses yg datang dimasukkan dalam antrian
          unless proc_arrv.empty?
            proc_arrv.each { |v|
              antrian << v
            }
          end

          proc_arrv_pid = proc_arrv.collect { |v|
            v.pid
          }

          antrian_pid   = antrian.collect { |v|
            v.pid
          }

          unless proc_cur.nil?
            proc_cur.burst_remaining -= 1
          end

          print "|"+i.to_s.rjust(5)
          print "|"+"#{proc_cur.nil? ? '-' : proc_cur.pid}".ljust(12)
          print "|"+"#{proc_arrv_pid.inspect unless proc_arrv_pid.empty?}".ljust(13)
          print "|"+"#{antrian_pid.inspect unless antrian.empty?}".ljust(18) + "|\n"
          sleep(0.1)


          if proc_cur.nil?
            proc_cur         = antrian.shift

            puts "Detik ke #{i} =>  #{proc_cur.pid.to_s} Dimulai".center(53)

            unless proc_cur.nil?
              proc_updated     = procs.select { |v|
                v.pid == proc_cur.pid
              }

              proc_updated.each { |v|
                v.executed = i
              }
            end
          elsif (proc_cur.burst_remaining.to_i == 0)

            ended            = proc_cur.pid.to_s

            proc_cur         = antrian.shift

            if proc_cur.nil?
              puts "Detik ke #{i} => #{ended} Berakhir.".center(53)
            else
              puts "Detik ke #{i} => #{ended} Berakhir, #{proc_cur.pid.to_s} Dimulai".center(53)
            end


            unless proc_cur.nil?
              proc_updated     = procs.select { |v|
                v.pid == proc_cur.pid
              }

              proc_updated.each { |v|
                v.executed = i
              }
            end
          end
        end

        puts "-"*53
        output_action_header "rangkuman"
        output_process_table_executed(procs)

        puts "Rata-rata Waktu Tunggu :  " + Process.average_wait_time(procs).to_s
      rescue => e
        puts e.message
        print e.backtrace.join("\n")
      end
      puts "Tekan ENTER untuk melanjutkan"
    }

  end

  def list(args=[])
    sort_order = args.shift
    parameters = ['proses', 'burst', 'prioritas', 'kedatangan']
    sort_order = "proses" unless parameters.include?(sort_order)

    output_action_header("Daftar Processs")

    procs      = []
    case sort_order
      when 'proses'
        procs = Process.sort(:pid)
      when 'burst'
        procs = Process.sort(:burst)
      when 'prioritas'
        procs = Process.sort(:priority)
      when 'kedatangan'
        procs = Process.sort(:arrival)
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
    puts "-"*46
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

  def output_process_table_executed(procs = [])
    puts "-"*76
    print "|"+"Proses".ljust(6)
    print "|"+"Burst Time".ljust(10)
    print "|"+"Prioritas".ljust(9)
    print "|"+"Waktu Kedatangan".ljust(16)
    print "|"+"Waktu Dieksekusi".ljust(16)
    print "|"+"Waktu Tunggu".ljust(12) + "|\n"
    puts "-"*76
    procs.each do |pro|
      line  = "|" << pro.pid.rjust(6)
      line << "|" + pro.burst.to_s.rjust(10)
      line << "|" + pro.priority.to_s.rjust(9)
      line << "|" + pro.arrival.to_s.rjust(16)
      line << "|" +pro.executed.to_s.rjust(16)
      line << "|" +(pro.executed.to_i - pro.arrival.to_i).to_s.rjust(12)+"|"
      puts line
    end
    puts "Data Kosong" if procs.empty?
    puts "-" * 76
  end

end
