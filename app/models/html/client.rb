class Html::Client < ::Client

  def text_format
    :html
  end

  def to_markdown!
    self._type = 'Client'
    self.company_description = ReverseMarkdown.parse(self.company_description)
    save!
  end

end