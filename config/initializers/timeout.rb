# timeout must be lower than one in unicorn.rb
# https://www.elcurator.net/articles/0f84053c-sizing-your-rails-application-with-unicorn-on-heroku
Rack::Timeout.timeout = 20
