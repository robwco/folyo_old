class Html::Client < ::Client

  trackable :email, :full_name, :role, :company_name, :created_at

  def text_format
    :html
  end

  def to_markdown!
    self._type = 'Client'
    self.company_description = ReverseMarkdown.parse(self.company_description)
    save!
  end

end