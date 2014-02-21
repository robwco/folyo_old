module ScheduledJobs

  class GenerateSitemapJo < Jobbr::ScheduledJob

    description 'Generate sitemap and upload it to S3'

    heroku_run :daily, priority: 0

    def perform
      SitemapGenerator::Interpreter.run
      SitemapGenerator::Sitemap.ping_search_engines
    end

  end

end