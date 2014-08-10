module AudioBookCreator
  class Binder
    attr_accessor :base_dir
    attr_accessor :force
    attr_accessor :verbose

    attr_accessor :author
    attr_accessor :title
    attr_accessor :channels
    # split on this hour mark
    attr_accessor :max_hours
    attr_accessor :bit_rate
    attr_accessor :sample_rate

    def initialize(options = {})
      options.each { |n, v| public_send("#{n}=", v) }
      @author    ||= "Vicki"
      @channels  ||= 1
      @bit_rate  ||= 32
      @max_hours ||= 7
      @sample_rate ||= 22_050
    end

    def create(chapters)
      raise "No Chapters" if chapters.empty?

      if force || !File.exist?(filename)
        puts "creating #{filename}" if verbose
        Runner.new.run!("abbinder",
                        verbose: verbose,
                        params:  {
                          "-a" => author,
                          "-t" => "\"#{title || base_dir}\"",
                          "-b" => bit_rate,
                          "-c" => channels,
                          "-r" => sample_rate,
                          "-g" => "Audiobook",
                          "-l" => max_hours,
                          "-o" => filename,
                          # "-v" => verbose,
                          # "-A" => nil, #    add audiobook to iTunes
                          # -C file.png cover image
                          nil  => chapters.map { |ch| [ctitle(ch), cfilename(ch)] },
                        })
      end
    end

    private

    def filename
      "#{base_dir}.m4b"
    end

    def ctitle(chapter)
      "@\"#{chapter.title}\"@"
    end

    def cfilename(chapter)
      "#{base_dir}/#{chapter.filename}.m4a"
    end
  end
end
