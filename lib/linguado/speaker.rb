require 'open3'

module Linguado
  class Speaker
    def initialize open3 = nil, file = nil
      @open3 = open3 || Open3
      @file = file || File
    end

    def speak sentence, lang = "en-US"
      filename = "linguado.wav"

      i, o, e, wt = @open3.popen3 "pico2wave", "--wave=" + filename, "-l=" + lang, sentence

      return unless wt.value.success?

      i, o, e, wt = @open3.popen3 "play", filename

      return unless wt.value.success?

      @file.delete filename if @file.exists? filename
    end
  end 
end
