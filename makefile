default: test

MAKE_ENV ?= .env

install:
	    @bundle install

update:
	    @bundle update

console:
	    @env $$(cat $(MAKE_ENV)) irb -I lib -r ./test/helper.rb

secret:
	    @ruby -r securerandom -e 'puts SecureRandom.hex(64)'

seed:
	    @env $$(cat $(MAKE_ENV)) ruby db/seeds.rb

server:
	    @env $$(cat $(MAKE_ENV)) puma -C config/puma.rb

smtp:
	    @mt 2525

test:
	    @env $$(cat $(MAKE_ENV)) rake

migrate:
	    source $(MAKE_ENV) && sequel -m db/migrations $$DATABASE_URL
