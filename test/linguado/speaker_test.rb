require 'test_helper'
require 'linguado'
require 'fakes/fake_open3'
require 'fakes/fake_file'
include Linguado

describe Speaker do
  let(:open3) { FakeOpen3.new }
  let(:file) { FakeFile.new }
  let(:filename) { "linguado.wav" }

  subject { Speaker.new open3, file }

  describe :speak do
    it "should call open3 with correct parameters" do
      subject.speak "Hallo, wie geht's?", "de-DE"

      open3.calls[0].must_equal ["pico2wave", "--wave=#{filename}", "-l=de-DE", "Hallo, wie geht's?"]
    end

    it "should call play if first call successful" do
      open3.default_wait_thread.value.success = true

      subject.speak "hi"

      open3.calls.last.must_equal ["play", filename]
    end

    it "should not call play if first call unsuccessful" do
      open3.default_wait_thread.value.success = false

      subject.speak "hi"

      open3.calls.count.must_equal 1
    end

    it "should check if filename exists" do
      subject.speak "hi"

      file.exists.must_equal [filename]
    end

    it "should delete file if exists" do
      file.exists_return[filename] = true

      subject.speak "hi"

      file.deletes.must_equal [filename]
    end

    it "should do nothing if execution of play not over" do 
      file.exists_return[filename] = true
      open3.wait_threads[["play", filename]] = FakeWaitThread.new(false)

      subject.speak "hi"

      file.deletes.must_be_empty
    end

    it "should do nothing if file does not exist" do
      file.exists_return[filename] = false

      subject.speak "hi"

      file.deletes.must_be_empty
    end
  end
end
