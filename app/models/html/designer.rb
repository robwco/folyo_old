class Html::Designer < ::Designer

  trackable :email, :full_name, :role, :created_at

  def text_format
    :html
  end

  def to_markdown!
    self._type = 'Designer'
    self.skip_validation = true
    self.long_bio = ReverseMarkdown.parse(self.long_bio)
    save!
  end

end