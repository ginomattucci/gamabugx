CarrierWave.configure do |config|
  config.cache_dir = Rails.root.join('tmp', 'uploads')

  if Rails.env.production?
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Rails.application.secrets.aws_access_key,
      aws_secret_access_key: Rails.application.secrets.aws_secret_key,
      region: Rails.application.secrets.aws_region
    }
    config.fog_directory = Rails.application.secrets.aws_bucket
    config.fog_public = true
    config.fog_attributes = {
      'Cache-Control' => "max-age=#{365.days.to_i}"
    }
    config.storage = :fog
    config.enable_processing = true
  else
    config.storage = :file
    config.enable_processing = !Rails.env.test?
  end
end
