class AR::DesignerPost < ActiveRecord::Base

  self.table_name = 'designer_posts'

  validates_presence_of :relocate, :minimum_budget, :availability_date

  ## associations ##
  belongs_to :designer
  belongs_to :status

  ## callbacks ##
  before_save :sanitize_attributes

  ## scopes ##
  scope :ordered, :order => 'created_at DESC'

  # status foreign keys
  class Status_Keys
    PENDING = 1
    REJECTED = 2
    ACCEPTED = 3
    ARCHIVED = 5
  end

  protected

  def sanitize_attributes
    %w(comment).each do |attribute|
      self.send(:"#{attribute}=", Sanitize.clean(self.send(attribute.to_sym), Sanitize::Config::BASIC))
    end
  end

end
