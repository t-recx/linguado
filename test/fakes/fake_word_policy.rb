class FakeWordPolicy
  attr_accessor :passes
  attr_accessor :typos
  attr_accessor :passes_return
  attr_accessor :typos_return
  attr_accessor :default_typos_return
  attr_accessor :default_passes_return

  def initialize
    @passes = []
    @passes_return = {}
    @default_passes_return = true
    @typos = []
    @typos_return = {}
    @default_typos_return = false
  end

  def passes? word, original_word
    @passes.push({ word: word, original_word: original_word })

    return @passes_return[[word, original_word]] || @default_passes_return
  end

  def typo? word, original_word
    @typos.push({ word: word, original_word: original_word })

    return @typos_return[[word, original_word]] || @default_typos_return
  end
end
