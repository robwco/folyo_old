web:     bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker:  bundle exec sidekiq -C config/sidekiq.yml
logs:    tail -f log/development.log