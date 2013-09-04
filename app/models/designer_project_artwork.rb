class DesignerProjectArtwork

  DIRECT_UPLOAD_URL_FORMAT = %r{\Ahttps:\/\/s3\.amazonaws\.com\/folyo-#{Rails.env}\/(?<path>uploads\/.+\/(?<filename>.+))\z}.freeze

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :direct_upload_url, type: String
  field :status,            type: Symbol, default: :initialized

  has_mongoid_attached_file :asset,   styles: { large: '1200', medium: '800x600#',  small: '400x300#' }
  belongs_to                :project, class_name: 'DesignerProject', inverse_of: :artworks

  validates :direct_upload_url, format: { with: DIRECT_UPLOAD_URL_FORMAT }, allow_blank: true

  after_create :transfer_and_cleanup

  scope :processed, where(status: :processed)

  def direct_upload_url=(escaped_url)
    write_attribute(:direct_upload_url, (CGI.unescape(escaped_url) rescue nil))
  end

  protected

  def transfer_and_cleanup
    begin
      self.status = :processing
      self.asset = URI.parse(URI.escape(direct_upload_url))
      save

      s3 = AWS::S3.new
      direct_upload_url_data = DIRECT_UPLOAD_URL_FORMAT.match(direct_upload_url)
      s3.buckets[Rails.configuration.aws[:bucket]].objects[direct_upload_url_data[:path]].delete
      self.status = :processed
      save
    rescue e
      self.status = :failed
      save
      raise e
    end
  end
  handle_asynchronously :transfer_and_cleanup

end