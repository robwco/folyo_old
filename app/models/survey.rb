class Survey

  include Mongoid::Document
  include Mongoid::Timestamps

  field      :name,        type: String
  field      :submitted_at, type: DateTime
  belongs_to :user

  index({ name: 1, user_id: 1 })

  after_create do
    user.track_user_event('Survey Started', name: self.name)
  end

  def submit
    user.track_user_event('Survey Submitted', name: self.name)
    self.submitted_at = DateTime.now
    save!
    on_submit
  end

  def on_submit
  end

  def to_param
    self.name
  end

  # enable support for dynamic attributes
  def method_missing(name, *args)
    if name =~ /(.*)=/
      if args.length == 1
        self[$1] = args[0]
      else
        super
      end
    else
      self[name]
    end
  end

end
