class FolyoEvaluation

  include Mongoid::Document
  include Mongoid::Timestamps

  field :evaluation

  belongs_to :user

  def text_format
    :markdown
  end

end