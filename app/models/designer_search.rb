class DesignerSearch

  include Mongoid::Document
  include Mongoid::Timestamps

  ## Relations ##
  belongs_to              :user
  has_and_belongs_to_many :rejected_designers, class_name: 'Designer'
  has_and_belongs_to_many :accepted_designers, class_name: 'Designer'

  ## Fields ##
  field :public_only,       type: Boolean, default: true
  field :skills,            type: Array
  field :location,          type: String
  field :price_range,       type: Symbol
  field :count,             type: Integer
  field :unprocessed_count, type: Integer

  ## Callbacks ##
  before_save :update_counters

  # Returns all designers matching the search criteria.
  # If with_processed is not true, designers already accepted or rejected are not returned.
  def apply(with_processed = true)
    designers = Designer.accepted
    designers = self.public_only ? Designer.public_only : Designer.public_private
    if skills && skills.length > 0
      designers = designers.all_in(skills: self.skills)
    end
    if location
      # TODO
    end
    if price_range
      # TODO
    end
    with_processed ? designers : unprocessed_designers(designers)
  end

  # Returns a random unprocessed designer.
  def sample
    designers = self.apply(false)
    designers.skip(rand(designers.count)).first
  end

  # Returns next unprocessed designer.
  def next(designer)
    self.apply(false).random_order(:asc).where(:randomization_key.gt => designer.randomization_key).limit(1).first
  end

  # Returns previous unprocessed designer.
  def previous(designer)
    self.apply(false).random_order(:desc).where(:randomization_key.lt => designer.randomization_key).limit(1).first
  end

  # Marks a designer as rejected.
  def reject!(designer)
    self.rejected_designers << designer unless rejected_designers.include?(designer)
    self.accepted_designers.delete(designer)
    save!
  end

  # Marks a designer as accepted.
  def accept!(designer)
    self.accepted_designers << designer unless accepted_designers.include?(designer)
    self.rejected_designers.delete(designer)
    save!
  end

  protected

  def update_counters
    self.count = apply.count
    self.unprocessed_count = apply(false).count
  end

  def unprocessed_designers(designer_scope)
    processed_designer_ids = self.rejected_designers.map(&:id).zip(self.accepted_designers.map(&:id)).flatten
    designer_scope.not_in(:_id => processed_designer_ids)
  end

end