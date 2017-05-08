class FakeFile
  attr_accessor :exists
  attr_accessor :deletes
  attr_accessor :exists_return

  def initialize
    @exists = []
    @exists_return = {}
    @deletes = []
  end

  def exists? filename
    @exists.push filename

    @exists_return[filename]
  end

  def delete filename
    @deletes.push filename
  end
end
