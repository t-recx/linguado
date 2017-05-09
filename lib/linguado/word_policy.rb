require 'text'

class WordPolicy
  include Text

  attr_accessor :condition
  attr_accessor :levenshtein_distance_allowed
  attr_accessor :exceptions

  def initialize condition: lambda { |word| true }, levenshtein_distance_allowed: 0, exceptions: []
    @condition = condition
    @levenshtein_distance_allowed = levenshtein_distance_allowed
    @exceptions = exceptions
  end

  def passes? word, original_word
    word = word.downcase
    original_word = original_word.downcase

    return true if word == original_word

    return true unless condition.call original_word

    return false if exceptions.include? word

    return true if typo? word, original_word

    return false
  end

  def typo? word, original_word
    word = word.downcase
    original_word = original_word.downcase

    return false if word == original_word

    return true if Levenshtein.distance(word, original_word) <= levenshtein_distance_allowed

    return false
  end
end
