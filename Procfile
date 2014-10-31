web:     bundle exec unicorn -p $PORT -c ./config/unicorn.rb  > /dev/null 2>&1
worker:  bundle exec sidekiq -C config/sidekiq.yml
guard:    bundle exec guard
logs:    tail -f log/development.log
