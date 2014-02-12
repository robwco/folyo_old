Paperclip::Attachment.default_options.merge!(
  url:                  ':s3_domain_url',
  path:                 ':class/:attachment/:id/:style/:filename',
  storage:              :s3,
  s3_credentials:       Rails.configuration.aws,
  s3_permissions:       'public-read',
  s3_host_alias: Proc.new do |asset|
    if Rails.env.production?
      "assets#{asset.size.to_i % 4}.folyo.me"
    elsif Rails.env.staging?
      "assets#{asset.size.to_i % 4}.staging.folyo.me"
    else
      "folyo-#{Rails.env}.s3.amazonaws.com"
    end

  end
)