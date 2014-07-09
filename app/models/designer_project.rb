class DesignerProject

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Mongoid::EmbeddedFindable

  def self.budget_ranges
    ["n/a" ,'Under $1000', '$1000-$1500', '$1500-$2000', '$2000-$3000', '$3000-$4000', '$4000-$5000', '$5000-$6000', '$6000-$7500', '$7500-$10000', '$10000-$15000', '$15000-$20000', '$20000+']
  end

  def self.budget_privacies
    {
      public: "Public (shown on profile page)", 
      private: "Private (used for anonymous stats only)"
    }
  end

  field :name
  field :description
  field :url
  field :skills, type: Array, default: []
  field :budget_range, default: budget_ranges.first
  field :budget_privacy, type: Symbol, default: :designers_only

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

  def budget_is_public?
    self.budget_range && self.budget_range != DesignerProject.budget_ranges.first && self.budget_privacy == :public
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
