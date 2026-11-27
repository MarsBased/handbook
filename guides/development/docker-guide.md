# The MarsBased Docker guide for development

At MarsBased we use Docker to work on the development of applications. Using Docker for development has several benefits:

- Makes setting up the environment for a project a breeze. This dramatically reduces the time to onboard new software engineers to a project.
- The environment in which the application runs can be identical to the production environment. This allows to quickly detect bugs depending on the OS or system packages.
- Removes the need to have development dependencies (Ruby, Node, PostgreSQL, Redis) installed locally. Only Docker is needed to work on applications.
- Avoids problems with having multiple versions of dependencies installed. Moreover, prevents them from accumulating when versions are updated.

The approach that we follow to configure the Docker environment is heavily inspired by this [magnificent blog post from our evil colleagues](https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development).

The key point of this way working is that **the Docker image is kept as minimal as possible and dependencies are installed on volumes**.

By working this way, the image hardly ever needs to be re-built and we work very closely to how we would do it if we were working with local dependencies. For example: Instead of installing Ruby gems in the image, we mount a volume on the container to store the installed gems and run `bundle install` on the container.

If gems were installed in the image then when there is a change in the used gems (like adding a new gem or updating one), the image needs to be rebuilt, thus needing to install **all gems** again (which can take a long time). By, instead, having gems installed on a volume, when there is a change in a gem, we can just run `bundle install` again (like we would do locally) and it will just install that new gem or updated version.

It is useful to think of it as if the Docker image is just the bare-bones OS and you do the rest the same way you would do it locally (`bundle install`, `npm install`, etc.). More specifically, the image only contains the programming language and system packages (like ImageMagick).

There are 2 options to set up the development environment with Docker:

- **Services only:** External services (database, Redis, Elasticsearch, etc.) are run with Docker but the application runs locally.
- **Services + Application:** Apart from services, the application is also run in a container.

Running everything with Docker has the advantage of not needing to have any dependency installed locally, apart from Docker. The disadvantage is that it runs slower because the application can't use the full memory + CPU potential from the computer.

Services only is our default: the application runs natively, with the runtimes that [mise](/guides/development/meta-tools-guide.md#mise-versions-environment-and-tasks) installs per project. Use services + application when the project cannot run natively. This usually happens in old projects whose dependencies can no longer be installed on a current machine, for example gems that only work with OpenSSL 1.1.

## Services only development setup

In order to Dockerize the services for the development application, we create a `.dockerdev` directory in the application root, which contains the `compose.yml` and other support files. Separating it into its own directory avoids mixing it with the production Docker setup which usually resides in the root.

When copying the files from this repo you need to replace several values for the appropriate in your application. These values are: `<application-name>`, `<postgres-version>`, `<redis-version>`.

The `.dockerdev` directory contains the following files:

- `compose.yml`: Contains only external services. Its `name` key sets the Docker Compose project name; without it, Docker Compose takes the name from the directory, and every project would be called `dockerdev`.
- `.psqlrc`: This file is copied to running containers to improve the development experience when working on a Postgres session.
- `volumes` directory: This directory needs to be gitignored and its purpose is to store the contents of the postgres volume. This makes it easier to manipulate it, back it up if you are migrating to a new laptop, share it with a colleague, etc.

Apart from the files in `.dockerdev` we have a few more moving pieces:

- `mise.toml`: [All development operations](#working-with-docker) with Docker are mise tasks, as described in the [meta tools guide](/guides/development/meta-tools-guide.md#docker-local-services).
- We need to add `.dockerdev/volumes/*` to the `.gitignore`.

### Working with Docker

The example `mise.toml` wraps every `docker compose` call, so nobody has to remember the `-f .dockerdev/compose.yml` flag:

- `mise run db:up`: start the services in the background and wait until they are up.
- `mise run db:down`: stop and remove the containers. The data in `.dockerdev/volumes` stays.
- `mise run dev:db`: the services in the foreground, for the `db` task of [dekit](/guides/development/meta-tools-guide.md#dekit-development-processes).

### Initial setup

When setting up an application for the first time, you just need to run `mise run setup`. The project's `setup` task calls `db:up`, which starts the services.

## Rails Docker for development setup

In order to Dockerize a Rails application for development, we create a `.dockerdev` directory in the application root, which contains the `Dockerfile`, `compose.yml` and other support files. Separating it into its own directory avoids mixing it with the production Docker setup which usually resides in the root.

When copying the files from this repo you need to replace several values for the appropriate in your application. These values are: `<application-name>`, `<postgres-version>`, `<redis-version>`, `<ruby-version>` and `<bundler-version>`.

The `.dockerdev` directory contains the following files:

- `compose.yml`: [Docker compose configuration](#docker-compose-configuration).
- `Dockerfile`: [Dockerfile used to build the image for development](#dockerfile).
- `.pryrc`: This file is copied to running containers to improve the development experience when working on Pry.
- `.psqlrc`: This file is copied to running containers to improve the development experience when working on a Postgres session.
- `volumes` directory: This directory needs to be gitignored and its purpose is to store the contents of the postgres volume. This makes it easier to manipulate it, back it up if you are migrating to a new laptop, share it with a colleague, etc.

Apart from the files in `.dockerdev` we have a few more moving pieces:

- `mise.toml`: [All development operations](#working-with-docker) with Docker are mise tasks, as described in the [meta tools guide](/guides/development/meta-tools-guide.md#docker-local-services).
- `dekit.yaml`: the [development processes](/guides/development/meta-tools-guide.md#dekit-development-processes), one task per container.
- We need to add `.dockerdev/volumes/*` to the `.gitignore`.
- [Capybara needs to be configured](#capybara-configuration) to use the selenium container.

### Working with Docker

The example `mise.toml` wraps every `docker compose` call, so nobody has to remember the `-f .dockerdev/compose.yml` flag. Rails runs in a container, so mise installs no runtimes here; it only holds the tasks.

### Application setup

When setting up an application for the first time, you just need to run `mise run setup`.

This will perform several things:

- Build Docker images.
- Install dependencies.
- Prepare the database.

From that point on, to install new gems or node modules you will need to do it from a container. You can open a container with bash by running `mise run docker:run bash` and inside just run `bundle install` or `yarn install` as usual.

### Running the application

`mise run dev` opens dekit with one task per process, each in its own container:

- `rails`: the Rails server, started automatically. Breakpoints are interactive in its task.
- `jobs`: Sidekiq, only needed if you wish to run background jobs like sending e-mails. Select it and press `s`.

PostgreSQL, Redis and Selenium start with them, through `depends_on` in `compose.yml`.

### Rails commands

In order to execute a Rails command you can use `mise run docker:run [command]`. This will run the command inside a container. For example to run database migrations: `mise run docker:run bin/rails db:migrate`.

### Other commands

- Stop and remove every container: `mise run docker:down`.
- Open a bash session: `mise run docker:run bash`.
- Run the test suite: `mise run docker:run bundle exec rspec`.

### Capybara configuration (Ruby on Rails only)

To get reliable test runs, we run system tests against a container that runs a pinned version of Chromium (`selenium` service in `compose.yml`). This also avoids the need to have Chrome installed locally to run the test suite.

To configure Capybara to use the container add the following to `spec_helper.rb`:

```ruby
require 'socket'

LOCAL_PORT = 8200
LOCAL_IP = if ENV['SELENIUM_URL']
             Socket.ip_address_list.find(&:ipv4_private?)&.ip_address
           else
             'localhost'
           end

Capybara.register_driver :selenium_remote do |app|
    Capybara::Selenium::Driver.new(app,
                                   browser: :remote,
                                   options: Selenium::WebDriver::Chrome::Options.new,
                                   url: ENV['SELENIUM_URL'])
end

Capybara.javascript_driver = :selenium_remote

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test

    Capybara.app_host = "http://#{LOCAL_IP}:#{LOCAL_PORT}"
    Capybara.server_host = LOCAL_IP
    Capybara.server_port = LOCAL_PORT
    Capybara.always_include_port = true
  end
end

# When using Webmock
require 'webmock/rspec'
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: [/selenium/, LOCAL_IP]
)
```

### Dockerfile

The Dockerfile used for development is pretty minimal. Below there is a description of each of its blocks for a Ruby on Rails
application. For a NodeJS or Python application the Dockerfile will vary.

```docker
FROM ruby:<ruby-version>-alpine
```

We start from the ruby image which contains the full OS, basic system packages and, of course, Ruby itself.

```docker
RUN apk --update add less bash git curl wget build-base && \
    apk add postgresql-client && \
    apk add nodejs yarn && \
    apk add vim imagemagick && \
    rm -rf /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

```

This does various things:

- Install basic build tools, often needed to install other packages.
- Install a client to access the PostgreSQL database from a bash session if needed.
- Install NodeJS and Yarn.
- Install an editor (vim) and ImageMagick which is used in the majority of applications.
- Clean packages, temporary files and logs.

**NOTE:** All these operations are done in the same command to avoid caching unnecessary layers. This way the whole operation gets cached as a single layer.

```docker
ENV LANG=C.UTF-8
ENV GEM_HOME=/bundle
ENV PATH /app/bin:$GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH
```

This does various things:

- Make contents of the `bin` directory of the application available to use as commands. This way when we run `rails` or `rake`, for example, inside the container, it uses the versions in `bin`.
- Tell bundler to install gems in the `/bundle` directory. This goes hand in hand with the `bundle` volume that is mounted on the containers. By keeping the gems in a known location and a volume, we persist them across containers and container restarts.

```docker
RUN gem update --system && \
    gem install bundler:$BUNDLER_VERSION
```

Install a pinned version of bundler. This is recommended to avoid the `Gemfile.lock` changing every time the image is re-built. Since the `Gemfile.lock` specifies the Bundler version used, if the image is recreated and a newer version happens to be installed, the `Gemfile.lock` will change once we install gems again.

```docker
RUN mkdir -p /app

WORKDIR /app
```

Create the directory where the app volume will be mounted and tell it to work from this directory.

### Docker compose configuration

The Docker compose setup contains services for both the application and infrastructure.

All the application services inherit from a common `app` and/or `backend` configuration, whose more interesting aspects are:

- All the infrastructure/running related environment variables are specified in this configuration. Application specific variables should be defined using another mechanism (like `dotenv`).
- It uses volumes for various things:
  - `../:/app:cached`: This makes the whole application available as a volume, so that changes to the codebase are propagated to the container.
  - `rails_cache`: Keeping the cache in a volume persists it across containers restarts, improving the performance of the application during development.
  - `bundle`: The image is configured to install gems in the `/bundle` directory of the container, therefore we need to make this directory available.
  - `./.psqlrc:/root/.psqlrc:ro` and `./.pryrc:/root/.pryrc:ro`: This is a simple way of copying files to the container without needing to embed them in the image.

The rest of services defined are pretty much self-explanatory.
