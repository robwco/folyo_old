class Survey

  include Mongoid::Document
  include Mongoid::Timestamps

  field      :name
  belongs_to :user

  index({ name: 1, user_id: 1 })

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
