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
