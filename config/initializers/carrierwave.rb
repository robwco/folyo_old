CarrierWave.configure do |config|

  aws_settings = YAML.load(ERB.new(File.read("#{Rails.root}/config/aws.yml")).result)[Rails.env].symbolize_keys!

  config.cache_dir = "#{Rails.root}/tmp/"
  config.storage = :fog
  config.permissions = 0666
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => aws_settings[:access_key_id],
    :aws_secret_access_key  => aws_settings[:secret_access_key],
  }
  config.fog_directory = aws_settings[:bucket]
end