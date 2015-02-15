module AudioBookCreator
  class SpeakerDef

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

    attr_accessor :channels
    # split on this hour mark
    attr_accessor :max_hours
    attr_accessor :bit_rate
    attr_accessor :sample_rate
    attr_accessor :regen_audio

    def initialize(options = {})
      options.each { |n, v| public_send("#{n}=", v) }

      # for speaking the chapter
      @voice    ||= "Vicki"
      @rate     ||= 280

      # for binding the book
      @channels  ||= 1
      @bit_rate  ||= 32
      @max_hours ||= 7
      @sample_rate ||= 22_050
    end    
  end
end
