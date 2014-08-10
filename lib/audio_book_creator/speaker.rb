require 'open3'
module AudioBookCreator
  class Speaker
    MAP = {
      "-v" => :voice,
      "-r" => :rate,
#      #--file-format=m4af,m4bf
#      "--data-format" => :format, # or aac / aac@8000
#      "--channels" => :channels, # doesn't seem to do anything. voices are 1 anyway
#      "--bitrate" => :bitrate,  # doesn't do anything
#      "--quality" => :quality,  # 0..127 - doesn't seem to do anything
    }
    # -f file

    attr_accessor :base_dir
    attr_accessor :force
    attr_accessor :command

    # currently like the following voices:
    # Vicki             # 10
    # Serena            #  8 UK
    # Allison           #  ? (ok)
    # Moira             #  7 Irish
    # Fiona             #  5 Scottish
    # Kate              #  4 UK
    # Susan             #  2
    # Zosia             # 0 Poland
    # Angelica          # 0 Mexican?
    # Paulina           # 0 Mexican
    attr_accessor :voice
    attr_accessor :rate
    attr_accessor :format
#    attr_accessor :force

    def initialize(options = {})
      options.each { |n, v| self.send("#{n}=", v) }
      @command ||= "say"
      @voice   ||= "Vicki"
      @rate    ||= "320"
#      @format  ||= 
    end

    def say(chapter)
      raise "Empty chapter" if chapter.empty?

      sound_filename = "#{base_dir}/#{chapter.filename}.m4a"
      text_filename = "#{base_dir}/#{chapter.filename}.txt"
      File.write(text_filename, chapter.to_s) if force || !File.exist?(text_filename)

      if force || !File.exist?(sound_filename)
        cmd = build_command("-f" => text_filename, "-o" => sound_filename)
        puts ">> #{cmd}"
        o, e, s = run(cmd, chapter)

        puts s == 0 ? "success" : "issue (return code #{s})"
        puts o, e
      end
    end

    private

    def build_command(extra)
      [command, MAP.map { |n, v| "#{n} #{send(v)}" }, extra.map { |n, v| "#{n} #{v}" }].join " "
    end

    # basically AwesomeSpawn
    def run(command, input)
#      options = { :stdin_data => input}
      options = {}
      output, error, status = Open3.capture3(command, options)
      status &&= status.exitstatus
      [ output, error, status ]
    end
  end
end
