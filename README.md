# Welcome!

Linguado's a language learning terminal program, similar to [duolingo](https://duolingo.com/). It allows users to practice foreign languages by:
* Translating sentences;
* Transcribing what they hear;
* Choosing one or multiple options to fill blank spaces;

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

Courses' filenames should end in _course.rb in order to be recognized.


# Instalation

	$ bundle install

Non-Ruby Dependencies that need to be installed (for the text-to-speech to work):

* libttspico-utils
* sox

For example, on debian systems you can install them like this:

	$ sudo apt-get install libttspico-utils sox

# Running

	$ bundle exec linguado
