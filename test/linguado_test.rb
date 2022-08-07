require 'test_helper'
require 'linguado'

describe Linguado do
  it "has a version number" do
    _(::Linguado::VERSION).wont_be_nil
  end

  describe :aplication do
    it "will create instance of Application" do
      _(Linguado.application).wont_be_nil
      _(Linguado.application).must_be_instance_of Linguado::Application 
      _(Linguado.application.object_id).must_equal Linguado.application.object_id
    end
  end
end
