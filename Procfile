web: jemalloc.sh bin/puma -C config/puma.rb
worker: jemalloc.sh bundle exec sidekiq -q default -q mailers -c ${SIDEKIQ_CONCURRENCY:-5}
release: bundle exec rake db:migrate
