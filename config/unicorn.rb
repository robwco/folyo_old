worker_processes Integer(ENV.fetch("WEB_CONCURRENCY") { 2 })

# timeout must be lower than Heroku 30secs timeouut
# https://www.elcurator.net/articles/0f84053c-sizing-your-rails-application-with-unicorn-on-heroku
timeout 25

preload_app true

before_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

end