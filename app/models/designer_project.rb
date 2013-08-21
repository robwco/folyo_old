class DesignerProject

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :name
  field :cover_url, type: String
  field :direct_upload_url

  has_mongoid_attached_file :upload, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  belongs_to :designer, inverse_of: :projects

  before_update :set_upload_attributes, if: :direct_upload_url_changed?
  after_update  :queue_processing,      if: :direct_upload_url_changed?

  DIRECT_UPLOAD_URL_FORMAT = %r{\Ahttps:\/\/s3\.amazonaws\.com\/folyo-#{Rails.env}\/(?<path>uploads\/.+\/(?<filename>.+))\z}.freeze

  validates :direct_upload_url, format: { with: DIRECT_UPLOAD_URL_FORMAT }

  def direct_upload_url=(escaped_url)
    write_attribute(:direct_upload_url, (CGI.unescape(escaped_url) rescue nil))
  end

   # Determines if file requires post-processing (image resizing, etc)
  def post_process_required?
    %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}.match(upload_content_type).present?
  end

  protected

  # Set attachment attributes from the direct upload
  # @note Retry logic handles S3 "eventual consistency" lag.
  def set_upload_attributes
    tries ||= 5
    direct_upload_url_data = DIRECT_UPLOAD_URL_FORMAT.match(direct_upload_url)
    s3 = AWS::S3.new
    direct_upload_head = s3.buckets[Rails.configuration.aws[:bucket]].objects[direct_upload_url_data[:path]].head

    self.upload_file_name     = direct_upload_url_data[:filename]
    self.upload_file_size     = direct_upload_head.content_length
    self.upload_content_type  = direct_upload_head.content_type
    self.upload_updated_at    = direct_upload_head.last_modified
  rescue AWS::S3::Errors::NoSuchKey => e
    tries -= 1
    if tries > 0
      sleep(3)
      retry
    else
      false
    end
  end

  # Queue file processing
  def queue_processing
    self.delay.transfer_and_cleanup
  end

  # Final upload processing step
  def transfer_and_cleanup
    Rails.logger.debug("transfer_and_cleanup")
    direct_upload_url_data = DIRECT_UPLOAD_URL_FORMAT.match(direct_upload_url)
    s3 = AWS::S3.new

    if post_process_required?
      self.upload = URI.parse(URI.escape(direct_upload_url))
    else
      paperclip_file_path = "documents/uploads/#{id}/original/#{direct_upload_url_data[:filename]}"
      s3.buckets[Rails.configuration.aws[:bucket]].objects[paperclip_file_path].copy_from(direct_upload_url_data[:path])
    end

    save

    s3.buckets[Rails.configuration.aws[:bucket]].objects[direct_upload_url_data[:path]].delete
  end

end