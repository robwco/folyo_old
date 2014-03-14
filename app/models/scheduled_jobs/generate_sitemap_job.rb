module ScheduledJobs

  class GenerateSitemapJob < Jobbr::ScheduledJob

    description 'Generate sitemap and upload it to S3'

    heroku_run :daily, priority: 0

    def perform
      Rails.logger.debug "Generating sitemap"
      SitemapGenerator::Interpreter.run
      if Rails.env.production?
        Rails.logger.debug "Pinging search engines"
        SitemapGenerator::Sitemap.ping_search_engines
      end
    end

  end

end