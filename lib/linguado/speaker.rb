require 'open3'

module Linguado
  class Speaker
    def initialize open3 = nil, file = nil
      @open3 = open3 || Open3
      @file = file || File
    end

    def speak sentence, language = "en-US"
      filename = "linguado.wav"

      return unless execute "pico2wave", "--wave=" + filename, "-l=" + language, sentence

      return unless execute "play", filename

      @file.delete filename if @file.exists? filename
    end

    def execute *cmd
      _, _, _, wt = @open3.popen3(*cmd)

      wt.value.success?
    end
  end 
end
