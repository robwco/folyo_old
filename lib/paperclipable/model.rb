module Paperclipable

  module Model

    DIRECT_UPLOAD_URL_FORMAT = %r{\Ahttps:\/\/s3\.amazonaws\.com\/folyo-\w+\/(?<path>uploads\/.+\/(?<filename>.+))\z}.freeze

    extend ActiveSupport::Concern

    included do

      include Mongoid::Paperclip
      include Sidekiq::Delay

      field :direct_upload_url, type: String
      field :status,            type: Symbol,  default: :initialized
      field :geometry,          type: Hash

      field :crop_x
      field :crop_y
      field :crop_w
      field :crop_h

      has_mongoid_attached_file :asset, styles: styles, url: ":s3_alias_url", s3_host_alias: Proc.new { |asset|
        if Rails.env.production?
          "assets#{asset.size.to_i % 4}.folyo.me"
        elsif Rails.env.staging?
          "assets#{asset.size.to_i % 4}.staging.folyo.me"
        else
          "assets#{asset.size.to_i % 4}.folyo.me"
          #"folyo-development.s3.amazonaws.com"
        end
      }

      validates_attachment_content_type :asset, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

      validates :direct_upload_url, format: { with: DIRECT_UPLOAD_URL_FORMAT }, allow_blank: true

      after_create        :transfer_and_cleanup
      after_post_process  :save_image_dimensions

      scope :processed, -> { where(status: :processed) }

    end

    def direct_upload_url=(escaped_url)
      write_attribute(:direct_upload_url, (CGI.unescape(escaped_url) rescue nil))
    end

    def crop_cover(crop_x, crop_y, crop_w, crop_h)
      self.crop_x = crop_x
      self.crop_y = crop_y
      self.crop_w = crop_w
      self.crop_h = crop_h

      save!
      reprocess_asset!
    end

    def cropping?
      !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
    end

    def processed?
      self.status == :processed
    end


    def transfer_and_cleanup
      self.delay.async_transfer_and_cleanup
    end

    def async_transfer_and_cleanup
      self.status = :processing
      self.asset = URI.parse(URI.escape(direct_upload_url))
      save

      s3 = AWS::S3.new
      direct_upload_url_data = DIRECT_UPLOAD_URL_FORMAT.match(direct_upload_url)
      s3.buckets[Rails.configuration.aws[:bucket]].objects[direct_upload_url_data[:path]].delete
      self.status = :processed
      save
    rescue Exception => e
      self.status = :failed
      save
      raise e
    end

    def reprocess_asset!
      self.status = :processing
      save
      self.delay.async_reprocess_asset!
    end

    def async_reprocess_asset!
      asset.reprocess!
      self.status = :processed
      save
    rescue Exception => e
      self.status = :failed
      save
      raise e
    end

    protected

    def save_image_dimensions
      self.geometry ||= {}
      self.class.styles.keys.each do |style|
        begin
          geo = ::Paperclip::Geometry.from_file(asset.queued_for_write[style])
          self.geometry[style] = {width: geo.width, height: geo.height}
        rescue Exception => e
          self.status = :failed
          save
          raise e
        end
      end
    end

  end

end
