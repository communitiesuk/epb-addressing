.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: format
format:
	@bundle exec rubocop --autocorrect

.PHONY: test
test:
	@STAGE=test bundle exec rspec

.PHONY: setup-db
setup-db:
	@echo ">>>>> Creating DB"
	@bundle exec rake db:create RACK_ENV=development
	@bundle exec rake db:create RACK_ENV=test
	@echo ">>>>> Migrating DB"
	@bundle exec rake db:migrate RACK_ENV=development
	@bundle exec rake db:migrate RACK_ENV=test

.PHONY: drop-db
drop-db:
	@echo ">>>>> Dropping db"
	@bundle exec rake db:drop RACK_ENV=development
	@bundle exec rake db:drop RACK_ENV=test

.PHONY: run
run:
	@STAGE=development bundle exec rackup -p 9191