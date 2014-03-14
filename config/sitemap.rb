SitemapGenerator::Sitemap.default_host = "http://www.folyo.me"
SitemapGenerator::Sitemap.sitemaps_host = "http://s3.amazonaws.com/folyo-production"
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new
SitemapGenerator::Sitemap.create do

  # signup
  add apply_path
  add new_user_with_role_path(initial_role: 'client')

  # footer
  add about_path
  add press_path
  add partners_path

  # guides
  add guides_path

  # designers
  add designers_path
  Designer.accepted.public_only.each do |designer|
    add designer_path(designer)
  end

end