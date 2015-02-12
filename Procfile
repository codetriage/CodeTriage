web: bin/puma -C config/puma.rb
worker: bin/rake resque:work VVERBOSE=1 QUEUE=*