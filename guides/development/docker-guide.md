# The MarsBased Docker guide for development

At MarsBased we use Docker to work on the development of applications. Using Docker for development has several benefits:
* Makes setting up the environment for a project a breeze. This dramatically reduces the time to on-board new developers to a project.
* The environment in which the application runs can be identical to the production environment. This allows to quickly detect bugs dependant on the OS or system packages.
* Removes the need to have development dependencies (Ruby, Node, PostgreSQL, Redis) installed locally. Only Docker is needed to work on applications.
* Avoids problems with having multiple versions of dependencies installed. Moreover, stops them for accumulating when versions are updated. 

The approach that we follow to configure the Docker environment is heavily inspired by this [magnificent blog post from our evil colleges](https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development).

The key point of this way working is that **the Docker image is kept as minimal as possible and dependencies are installed on volumes**. 

By working this way, the image hardly ever needs to be re-built and we work very closely to how we would do it if we were working with local dependencies. For example: Instead of installing Ruby gems in the image, we mount a volume on the container to store the installed gems and run `bundle install` on the container. 

If gems were installed in the image then when there is a change in the used gems (like adding a new gem or updating one), the image needs to be rebuilt, thus needing to install **all gems** again (which can take a long time). By, instead, having gems installed on a volume, when there is a change in a gem, we can just run `bundle install` again (like we would do locally) and it will just install that new gem or updated version.

It is useful to think of it as if the Docker image is just the bare-bones OS and you do the rest the same way you would do it locally (`bundle install`, `npm install`, etc.). More specifically, the image only contains the programming language and system packages (like ImageMagick or FFmpeg).

## Rails Docker for development setup

In order to Dockerize a Rails application for development, we create a `.devcontainer` directory in the application root, which contains the `Dockerfile`, `docker-compose.yml` and other support files. Separating it into its own directory avoids mixing it with the production Docker setup which usually resides in the root.

When copying the files from this repo you need to replace several values for the appropriate in your application. These values are: `<application-name>`, `<postgres-version>`, `<redis-version>`, `<ruby-version>`, `<major-node-version>` and `<bundler-version>`.

The `.devcontainer` directory contains the following files:
* `docker-compose.yml`: [Docker compose configuration](#docker-compose-configuration).
* `Dockerfile`: [Dockerfile used to build the image for development](#dockerfile).
* `Aptfile`: All required system dependencies (like ImageMagick or FFmpeg) need to be listed in this file. When the file is changed, the image needs to be rebuilt.
* `.pryrc`: This file is copied to running containers to improve the development experience when working on Pry.
* `.psqlrc`: This file is copied to running containers to improve the development experience when working on a Postgres session.
* `com.user.docker-host-alias.plist`: This file is used to create an alias from the 127.17.0.1 to localhost, in order to [make Minio accessible from both the host and containers](#make-minio-accessible-everywhere)
* `.env`: This file is read by Docker compose when it runs, and we use it to define a single environment variable with the name of the Docker compose project. By default, Docker compose takes the name from the directory, so without this environment variable the project would be called `devcontainer`.
* `volumes` directory: This directory needs to be gitignored and its purpose is to store the contents of the postgres and minio volumes. This makes it easier to manipulate them, back them up if you are migrating to a new laptop, share them with a college, etc.
* `scripts` directory: This directory contains some utilities to aid in the setup of the environment.

Apart from the files in `.devontainer` we have a few more moving pieces:
* `bin/dockerdev`: [All development operations](#working-with-docker) with Docker are done through this script.
* We need to add `.devcontainer/volumes/*` to the `.gitignore`.
* In the Webpacker config (`webpacker.yml`), the `host` of the `dev_server` needs to be set to `webpacker`.
* [Capybara needs to be configured](#capybara-configuration) to use the selenium container.

### Working with Docker

The `bin/dockerdev` script contains all the necessary commands to start, stop and manage the application.

#### Application setup

When setting up an application for the first time, you just need to run `bin/dockerdev setup`.

This will perform several things:
* Build Docker images.
* Create the Minio bucket.
* Install dependencies.
* Prepare the database.

From that point on, to install new gems or node modules you will need to do it from a container. You can open a container with bash by running `bin/dockerdev bash` and inside just run `bundle install` or `yarn install` as usual.

#### Running the application

In order to have the application fully functional you need to run several processes:

* Rails server: `bin/dockerdev server`
* Webpack: `bin/dockerdev webpacker`
* Background jobs: `bin/dockerdev jobs` (only needed if you wish to run background jobs like sending e-mails)

### Rails commands

In order to execute rails command you can use `bin/dockerdev [command]`. This will run the command inside a container.

### Other commands

* Start all required services to run the application: `bin/dockerdev start`. This command is useful for team members working only on the front-end of the application, because they can just run this command and forget.
* Stop and remove containers: `bin/dockerdev stop`
* Open a bash session: `bin/dockerdev bash`
* Run the test suite: `bin/dockerdev test`

### Capybara configuration

In order to get reliable test runs, we run system tests against a container that runs a pinned version of Chromium (`selenium` service in `docker-compose.yml`). This also avoids the need to have Chrome installed locally to run the test suite.

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
                                   desired_capabilities: :chrome,
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

The Dockerfile used for development is pretty minimal. Below there is a description of each of its blocks

```docker
FROM ruby:<ruby-version>
```

We start from the ruby image which contains the full OS, basic system packages and, of course, Ruby itself.

```docker
# Add NodeJS to sources list
RUN curl -sL https://deb.nodesource.com/setup_<major-node-version>.x | bash -

# Add Yarn to the sources list
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

```

We add a couple of sources to APT to be able to install Node and Yarn from their official sources.

```docker
# Install dependencies
COPY ./Aptfile /tmp/Aptfile
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    nodejs \
    yarn \
    $(cat /tmp/Aptfile | xargs) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

```

This does various things:
* Upgrade the OS distribution.
* Install basic build tools, often needed to install other packages.
* Install NodeJS and Yarn.
* Install all the packages listed in `Aptfile`.
* Clean packages, temporary files and logs.

**NOTE:** All these operations are done in the same command to avoid caching unnecessary layers. This way the whole operation gets cached as a single layer.

```docker
# Configure bundler and PATH
ENV LANG=C.UTF-8 \
  GEM_HOME=/bundle \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
  BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH /workspace/bin:$BUNDLE_BIN:$PATH
```

This does various things:
* Make contents of the `bin` directory of the application available to use as commands. This way when we run `rails` or `rake`, for example, inside the container, it uses the versions in `bin`.
* Tell bundler to install gems in the `/bundle` directory. This goes hand in hand with the `bundle` volume that is mounted on the containers. By keeping the gems in a known location and a volume, we persist them across containers and container restarts.

```docker
# Upgrade RubyGems and install required Bundler version
RUN gem update --system && \
    gem install bundler:<bundler-version>
```

Install a pinned version of bundler. This is recommended to avoid the `Gemfile.lock` changing every time the image is re-built. Since the `Gemfile.lock` specifies the Bundler version used, if the image is recreated and a newer version happens to be installed, the `Gemfile.lock` will change once we install gems again.

```docker
# Create a directory for the app code
RUN mkdir -p /workspace

WORKDIR /workspace
```

Create the directory where the app volume will be mounted and tell it to work from this directory.
 
### Docker compose configuration

The Docker compose setup contains services for both the application and infrastructure.

All the application services inherit from a common `app` configuration, whose more interesting aspects are:
* All the infrastructure/running related environment variables are specified in this configuration. Application specific variables should be defined using another mechanism (like `dotenv`).
* It uses volumes for various things:
   * `../:/workspace:cached`: This makes the whole application available as a volume, so that changes to the codebase are propagated to the container.
   * `rails_cache`: Keeping the cache in a volume persists it across containers restarts, improving the performance of the application during development.
   * `bundle`: The image is configured to install gems in the `/bundle` directory of the container, therefore we need to make this directory available.
   * `./.psqlrc:/root/.psqlrc:ro` and `./.pryrc:/root/.pryrc:ro`: This is a simple way of copying files to the container without needing to embed them in the image.
   
The rest of services defined are pretty much self-explanatory.  

### Make Minio accessible everywhere

When working with MacOS we need to run `sudo bin/dockerdev setup-localhost-alias` the first time we are setting up the project. 

This sets up an alias of 172.17.0.1 to localhost in order to be able to interact with Minio.

#### Why?

Minio needs to be accessible both from the browser and from the containers. We need it from the browser in order to access files from pages (like images) and we need it from the container in order to upload files.

However, there is no way to access Minio from both places using the same URL:
* From the host we can access by using `localhost`: http://localhost:9000
* From the container we can access by using the name of the container: http://minio:9000

In order to overcome this limitation we make use of the fact that from the container the IP `127.17.0.1` can be used to access the host. By setting up an alias on the host from this IP to localhost we can use the URL http://127.17.0.1:9000 from both the host and the container:
* From the host it just maps to localhost, so it's the same as before.
* From the container it maps to the host, and from there it accesses Minio through the exposed port.
