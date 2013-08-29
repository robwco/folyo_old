class DesignerProject

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :name
  field :direct_upload_url

  has_mongoid_attached_file :artwork, :styles => { large: '1200', medium: '800x600#',  small: '400x300#' }
  belongs_to :designer, inverse_of: :projects

  after_update :transfer_and_cleanup, if: :direct_upload_url_changed?

  DIRECT_UPLOAD_URL_FORMAT = %r{\Ahttps:\/\/s3\.amazonaws\.com\/folyo-#{Rails.env}\/(?<path>uploads\/.+\/(?<filename>.+))\z}.freeze

  validates :direct_upload_url, format: { with: DIRECT_UPLOAD_URL_FORMAT }

  def direct_upload_url=(escaped_url)
    write_attribute(:direct_upload_url, (CGI.unescape(escaped_url) rescue nil))
  end

  protected

  def transfer_and_cleanup
    self.artwork = URI.parse(URI.escape(direct_upload_url))
    save

    s3 = AWS::S3.new
    direct_upload_url_data = DIRECT_UPLOAD_URL_FORMAT.match(direct_upload_url)
    s3.buckets[Rails.configuration.aws[:bucket]].objects[direct_upload_url_data[:path]].delete
  end
  handle_asynchronously :transfer_and_cleanup

end