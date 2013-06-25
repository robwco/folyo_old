class Html::Designer < ::Designer

  def text_format
    :html
  end

  def to_markdown!
    self._type = 'Designer'
    self.long_bio = ReverseMarkdown.parse(self.long_bio)
    save!
  end

end