require 'test_helper'
require 'linguado'
require 'fakes/fake_lesson'
require 'fakes/fake_prompt'
require 'fakes/fake_runner'
require 'fakes/fake_recorder'

include Linguado

describe Course do
  let(:prompt) { FakePrompt.new }
  let(:runner) { FakeRunner.new }
  let(:recorder) { FakeRecorder.new }
  let(:questions_one) { [:x, :y, :z] }
  let(:questions_two) { [:a, :b, :c] }
  let(:lesson_name) { "Test" }
  let(:hung_up_lesson_name) { "German::Introduction::LessonOne" }
  let(:introduction_lesson_one) { get_fake_lesson [], hung_up_lesson_name }
  let(:present_lesson_one) { get_fake_lesson questions_one }
  let(:present_lesson_two) { get_fake_lesson questions_two }
  let(:course_name) { 'German' }
  let(:questions_asked) { 10 }
  let(:correct_answers) { 8 }
  subject { Course.new prompt, runner, recorder, name: course_name }

  describe :initialize do
    let(:course_name) { nil }

    it "when no name supplied should use class name" do
      subject.name.must_equal 'Course'
    end
  end

  describe :topic do
    it "should create record in topics" do
      subject.topic 'Introduction'

      subject.topics.count.must_equal 1
      subject.topics.all? { |t| t[:name] == 'Introduction' }
    end
  end

  describe :work do
    let(:title) { 'Select a lesson' }

    before do
      subject.topic "Introduction"
      subject.topic "Verbs"
      subject.topic "Culture", depends_upon: hung_up_lesson_name

      subject.topic "Hello", in: "Introduction"
      subject.topic "Goodbye", in: "Introduction"

      subject.topic "Present", in: "Verbs"
      subject.topic "Future", in: "Verbs"

      subject.topic "Places", in: "Culture"

      subject.topic "Lesson One", in: "Introduction", lesson: introduction_lesson_one
      subject.topic "Lesson One", in: "Present", lesson: present_lesson_one
      subject.topic "Lesson Two", in: "Present", lesson: present_lesson_two

      subject.topic "Lesson One", in: "Places", lesson: get_fake_lesson
      subject.topic "Lesson Two", in: "Places", lesson: get_fake_lesson

      recorder.already_passed_lessons[{course: nil, lesson:nil}] = true
    end

    it "should start by showing top level items" do
      setup_exit

      subject.work

      assert_selection ['Introduction', 'Verbs', 'Culture']
    end

    it "should hide items that have dependencies without completed lessons" do
      setup_exit
      recorder.already_passed_lessons[{course: course_name, lesson: hung_up_lesson_name}] = false

      subject.work

      assert_selection ['Introduction', 'Verbs']
    end

    describe "when Verbs selected" do
      before do
        prompt.setup_answer title, 'Verbs'
      end

      it "should show sub-topics list for selection" do
        setup_exit

        subject.work

        assert_selection ['Present', 'Future'], 1
      end

      it "should show previous menu when going back" do
        setup_exit

        subject.work

        assert_selection ['Introduction', 'Verbs', 'Culture'], 2
      end

      describe "when selecting Present" do
        before do
          prompt.setup_answer title, "Present"
        end

        it "should show next menu when going further" do
          setup_exit

          subject.work

          assert_selection ['Lesson One', 'Lesson Two'], 2
          assert_selection ['Present', 'Future'], 3
          assert_selection ['Introduction', 'Verbs', 'Culture'], 4
        end

        describe "when selecting lesson" do
          before do
            prompt.setup_answer title, "Lesson Two"
          end

          it "should call runner.ask" do
            setup_exit 

            subject.work

            runner.asked.first.must_equal questions_two
          end

          it "should record lesson exercise" do
            setup_exit
            runner.questions_asked = questions_asked
            runner.correct_answers = correct_answers

            subject.work

            recorder.lesson_exercises_recorded.count { |le| le[:course] == course_name and le[:lesson] == lesson_name and le[:questions] == questions_asked and le[:correct_answers] == correct_answers }.must_equal 1
          end
        end
      end
    end
  end

  def setup_exit n = 100
    n.times { prompt.setup_answer title, 'Go Back' }
  end

  def assert_selection choices, drops = 0
    prompt.selections.drop(drops).first.must_equal({ title: title, choices: choices + ['Go Back'], options: nil})
  end

  def get_fake_lesson q = [], name = nil
    FakeLesson.new q, name: name || lesson_name 
  end
end
