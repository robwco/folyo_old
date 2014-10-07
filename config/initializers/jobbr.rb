require 'ohm'
require 'ohm/contrib'
require 'jobbr/logger'
require 'jobbr/ohm'
require 'jobbr/ohm_pagination'

if redis_url = ENV['REDIS_URL']
  Ohm.redis = Redic.new(redis_url)
end