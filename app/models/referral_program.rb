class ReferralProgram

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,              type: String
  field :token,             type: String
  field :message,           type: String
  field :discount,          type: Integer

  validates_length_of     :message, maximum: 200, tokenizer: lambda { |str| str.scan(/./) }
  validates_uniqueness_of :token
  validates_inclusion_of  :discount, in: 1..100, allow_nil: true, message: 'must be between 1 and 100'

  index code: 1

end
