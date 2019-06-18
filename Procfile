web: RUBYOPT=--jit jemalloc.sh bin/puma -C config/puma.rb
worker: RUBYOPT=--jit jemalloc.sh bundle exec sidekiq -q default -q mailers -c ${SIDEKIQ_CONCURRENCY:-5}
release: RUBYOPT=--jit bundle exec rake db:migrate
