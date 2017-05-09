class FakePastel
  def underline sentence
    "_#{sentence}_"
  end

  def no_style sentence
    return sentence
  end

  alias_method :red, :no_style
  alias_method :green, :no_style
end
