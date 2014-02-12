class DesignerProject

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Mongoid::EmbeddedFindable

  field :name
  field :description
  field :url
  field :skills, type: Array, default: []

  slug           :name, history: true, scope: :designer_id
  embedded_in    :designer, inverse_of: :projects
  embeds_many    :artworks, class_name: 'DesignerProjectArtwork', inverse_of: :project

  before_validation  :process_skills, :set_designer_completeness

  validates_length_of :description, maximum: 150, tokenizer: lambda { |str| str.scan(/./) }

  def self.find(id)
    find_through(Designer, :projects, id)
  end

  def artwork
    self.artworks.first rescue nil
  end

  def can_show?
    !!artwork.try(:processed?)
  end

  protected

  def process_skills
    self.skills.reject!(&:blank?) if self.skills_changed?
    self.skills.map!(&:to_sym)
  end

  def set_designer_completeness
    designer.set_completeness
  end

end