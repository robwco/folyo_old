require "twitter"

class FolyoTwitter

  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "zrf3o2rhs6n413b8uF9lw"
      config.consumer_secret     = "H38TKkRnhJvBsdlVXFbo0Og3sCL8WRU0SBEOXaSq7r4"
      config.access_token        = "372180766-5hTA5bfrWThfDwILskDgRG11xpBI60IxqGXvB1Gi"
      config.access_token_secret = "2nqN51FTCCd9Cnzrz2z2mUfakg2Za0QwfsjmnD9Q"
    end
  end

  def update(status)
    @client.update(status)
  end

end