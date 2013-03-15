class DesignerPost

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :designer, inverse_of: :posts

  field :comment,           type: String
  field :duration,          type: String
  field :availability_date, type: String
  field :location,          type: String
  field :relocate,          type: String
  field :minimum_budget,    type: String
  field :job_type,          type: String
  field :coding,            type: String
  field :weekly_hours,      type: String
  field :status,            type: Symbol

  ## validations ##
  validates_presence_of :relocate, :minimum_budget, :availability_date

  ## callbacks ##
  before_save :sanitize_attributes

  ## scopes ##
  scope :ordered, order_by(created_at: :desc)

  protected

  def sanitize_attributes
    %w(comment).each do |attribute|
      self.send(:"#{attribute}=", Sanitize.clean(self.send(attribute.to_sym), Sanitize::Config::BASIC))
    end
  end

end