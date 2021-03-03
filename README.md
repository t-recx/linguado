# Welcome!

Linguado's a language learning terminal program, similar to [duolingo](https://duolingo.com/). It allows users to practice foreign languages by:
* Translating sentences;
* Transcribing what they hear;
* Choosing one or multiple options to provide an answer to a question;

# Lessons and courses

Linguado requires lessons and courses to be present on the ~/.linguado directory in order to work.

Lessons are just ruby code, and they inherit from the Lesson class:

```ruby
require 'linguado'

include Linguado

class BasicsI < Lesson
  def initialize
    super course: 'German', language: 'de-DE', name: 'Basics I' 
    
    ask_to write: 'hallo'
    ask_to choose: '? katze', answer: 'die', wrong: ['das', 'der']
    ask_to translate: 'ich bin fröhlich', answers: ['I am happy', 'I am cheerful']
    ask_to select: 'hallo', answers: ['hi', 'hello'], wrong: ['goodbye']
  end
end
```

Same thing happens with courses, which inherit from the Course class:

```ruby
require 'linguado'
require '~/.linguado/basics_i.rb'
require '~/.linguado/basics_ii.rb'
require '~/.linguado/greetings.rb'
require '~/.linguado/phrases.rb'

include Linguado

class German < Course
  def initialize
    super name: 'German'

    topic 'Basics I', lesson: BasicsI.new

    topic 'Greetings', lesson: Greetings.new, depends_upon: 'Basics I'

    topic 'Basics II', lesson: BasicsII.new, depends_upon: 'Greetings'
    topic 'Phrases', lesson: Phrases.new, depends_upon: 'Greetings'
  end
end
```

Courses' filenames should end in **_course.rb** in order to be recognized.


## Word policies

If you'd like to give your users some leeway on the ortography of words, allowing them to make typos if they don't differ too much from the correct answer, you can use the WordPolicy class. Word policies accept the following parameters:

|Parameter|Type|Description|
|-|-|-|
|levenshtein_distance_allowed|integer|[Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance) tolerated between the correct word and the word the user wrote|
|exceptions|array|List of words that can't be written any other way (useful for short words that you want to make sure the user gets right)|
|condition|lambda|A lambda accepting a string for a word and returning a boolean. Use it to define conditions for the word policy to apply if you need more control|


Every lesson can have multiple word policies and they're declared on the constructor:

```ruby
class BasicsI < Lesson
  def initialize
    # we'll allow a deviation of 2 characters for most words:
    general_word_policy = WordPolicy.new levenshtein_distance_allowed: 0

    # the word 'ein' can have a typo, like 'eni' for instance
    # but not be mistaken with 'einen' or 'eine':
    ein_word_policy = WordPolicy.new condition: lambda { |word| word == 'ein' },
      exceptions: ['einen', 'eine'], 
      levenshtein_distance_allowed: 2

    super course: 'German', 
      language: 'de-DE', 
      name: 'Basics I', 
      word_policies: [general_word_policy, ein_word_policy]

    ask_to write: 'es ist ein hund'
  end
end
```

# Installation

	$ bundle install

Non-Ruby Dependencies that need to be installed (for the text-to-speech to work):

* libttspico-utils
* sox

For example, on debian systems you can install them like this:

	$ sudo apt-get install libttspico-utils sox

# Running

	$ bundle exec linguado
