class DesignerProject

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  field :name
  field :description
  field :skills, type: Array, default: []

  slug        :name, history: true, scope: :designer_id
  belongs_to  :designer, inverse_of: :projects
  has_many    :artworks, class_name: 'DesignerProjectArtwork', inverse_of: :project

  before_validation  :process_skills

  validates_length_of :description, maximum: 300, tokenizer: lambda { |str| str.scan(/./) }

  def all_artworks_processed?
    self.artworks.where(:status.nin => [:processed, :failed] ).count == 0
  end

  protected

  def process_skills
    self.skills.reject!(&:blank?) if self.skills_changed?
    self.skills.map!(&:to_sym)
  end

end