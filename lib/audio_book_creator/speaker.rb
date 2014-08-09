require 'open3'
module AudioBookCreator
  class Speaker
    MAP = {
      ""  => :command,
      "-v" => :voice,
      "-r" => :rate,
#      #--file-format=m4af,m4bf
#      "--data-format" => :format, # or aac / aac@8000
#      "--channels" => :channels, # doesn't seem to do anything. voices are 1 anyway
#      "--bitrate" => :bitrate,  # doesn't do anything
#      "--quality" => :quality,  # 0..127 - doesn't seem to do anything
    }
    # -f file

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
      filename = chapter.filename()

      raise "Empty chapter" if chapter.empty?
      File.write("#{filename}.txt", chapter) if force || !File.exist?("#{filename}.txt")

      if force || !File.exist?("#{filename}.m4a")
        # currently using a text filename
        cmd = build_command("-f #{filename}.txt -o #{filename}.m4a")
        puts ">> #{cmd}"
        o, e, s = run(cmd, chapter)

        puts s == 0 ? "success" : "issue (return code #{s})"
        puts o, e
      end
    end


    private

    def build_command(extra)
      [command, extra, MAP.map { |n, v| "#{n} #{send(v)}" }].join " "
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
