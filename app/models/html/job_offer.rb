class Html::JobOffer < ::JobOffer

  before_save :sanitize_attributes

  def text_format
    :html
  end

  def to_markdown!
    self._type = 'JobOffer'
    self.project_summary = ReverseMarkdown.parse(self.project_summary)
    save!
  end

   def sanitize_attributes
     %w(project_summary).each do |attribute|
       self.send(:"#{attribute}=", Sanitize.clean(self.send(attribute.to_sym), Sanitize::Config::BASIC))
     end
   end

end