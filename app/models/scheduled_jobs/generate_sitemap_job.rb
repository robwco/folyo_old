module ScheduledJobs

  class GenerateSitemapJob < Jobbr::Job

    include Jobbr::Scheduled

    description 'Generate sitemap and upload it to S3'

    heroku_run :daily, priority: 0

    def perform(run)
      run.logger.debug "Generating sitemap"
      SitemapGenerator::Interpreter.run
      if Rails.env.production?
        run.logger.debug "Pinging search engines"
        SitemapGenerator::Sitemap.ping_search_engines
      end
    end

  end

end