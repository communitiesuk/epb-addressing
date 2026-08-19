# epb-addressing

Application for address matching addresses to a UPRN
using data from the NGD database

## Prerequisites

* [Ruby](https://www.ruby-lang.org/en/)
* [PostgreSQL](https://www.postgresql.org/)
* Bundler (run `gem install bundler`)

## Installing
`bundle install`

## Creating a local database

Ensure you have Postgres installed. If you are working on a Mac, [this page](https://www.postgresql.org/download/macosx/) help you install it.

You will need to have a user with the role name postgres, which has the `Create DB` and `Superuser` permissions to create databases.

Once you have set this up, run the command to set up and seed your local database

`make setup-db`

## Running tests
`make test`

## Code Formatting
To run Rubocop on its own, run:

`make format`

## Environmental variables

#### `APP_ENV`

Set the [Sintra environment](https://sinatrarb.com/intro.html#environments).
Should be one of "production", "development" or "test".

Sinatra will fallback to `RACK_ENV` or "development" if unset.

#### `RAILS_ENV`

[sintra-activerecord](https://github.com/sinatra-activerecord/sinatra-activerecord)
uses `APP_ENV` as the active record environment, but will fallback to `RAILS_ENV` if it is not supplied.

This should be one of "production", "development" or "test".  It will default to
"development" if neither `APP_ENV` or `RAILS_ENV` is set.

#### `RACK_ENV`

Used by rackup to choose the [default middleware stack](https://github.com/rack/rackup/blob/f3fa1d6ada90e9e7aa1f712488ddde87ea2a2075/lib/rackup/server.rb#L273).
Should be one of "development" (default) or "deployment". If set to any other value no middleware stack is loaded.

#### `STAGE`

The EPB environment. Can be one of "test", "development", "integration", "staging" or "production".

- Unless "development" or "test", enables Sentry and sets its environment value

#### `DATABASE_URL`

Postgres connection string for connecting to the database

#### `DOCKER_POSTGRES_PASSWORD`

The password for the database.  Only used during test.

#### `JWT_ISSUER`

Issuer for the JWT encoded auth token.

#### `JWT_SECRET`

Secret for the JWT encoded auth token.
