web: bin/puma -C config/puma.rb
worker: bundle exec sidekiq -q default -q mailers -c ${SIDEKIQ_CONCURRENCY:-5}
release: bundle exec rake db:migrate
