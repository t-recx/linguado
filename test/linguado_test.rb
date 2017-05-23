require 'test_helper'
require 'linguado'

describe Linguado do
  it "has a version number" do
    ::Linguado::VERSION.wont_be_nil
  end

  describe :aplication do
    it "will create instance of Application" do
      Linguado.application.wont_be_nil
      Linguado.application.must_be_instance_of Linguado::Application 
      Linguado.application.object_id.must_equal Linguado.application.object_id
    end
  end
end
