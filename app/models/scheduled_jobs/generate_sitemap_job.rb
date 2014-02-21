module ScheduledJobs

  class GenerateSitemapJob < Jobbr::ScheduledJob

    description 'Generate sitemap and upload it to S3'

    heroku_run :daily, priority: 0

    def perform
      SitemapGenerator::Interpreter.run
      SitemapGenerator::Sitemap.ping_search_engines if Rails.env.production?
    end

  end

end