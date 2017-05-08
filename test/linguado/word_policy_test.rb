require 'test_helper'
require 'linguado'
include Linguado

describe WordPolicy do
  subject { WordPolicy.new }

  describe :passes? do
    it "should return true if word = original_word" do
      subject.passes?('abc', 'abc').must_equal true
    end

    it "should ignore casing on the words" do
      subject.passes?('AbC', 'aBc').must_equal true
    end

    it "should return true policy condition does not apply to word" do
      subject.condition = lambda { |word| false }

      subject.passes?('aaa', 'bbb').must_equal true
    end

    it "should allow for specified deviation" do
      subject.levenshtein_distance_allowed = 2

      subject.passes?('katze', 'kazte').must_equal true
    end

    it "should not allow for specified deviation if word in exceptions list" do
      subject.levenshtein_distance_allowed = 300
      subject.exceptions.push 'eine'
      subject.condition = lambda { |word| word.downcase == 'ein' }

      subject.passes?('eine', 'ein').must_equal false
    end

    it "should return false if words are different" do
      subject.passes?('abc', 'xyz').must_equal false
    end
  end

  describe :typo? do
    it "should return false if words are equal" do
      subject.typo?('abc', 'AbC').must_equal false
    end

    it "should return false if words are different" do
      subject.typo?('katze', 'hund').must_equal false
    end

    it "should return true if words are similar" do
      subject.levenshtein_distance_allowed = 2

      subject.typo?('hund', 'hudn').must_equal true
    end
  end
end
