FROM ruby:3.3-bullseye as base

RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev nodejs && rm -rf /var/lib/apt/lists/*

RUN echo "alias migrate='bin/rails db:migrate'" >> ~/.bashrc && \
    echo "alias rspec='bundle exec rspec'"  >> ~/.bashrc && \
    echo "alias rubocop='bundle exec rubocop'"  >> ~/.bashrc && \
    echo "alias console='bin/rails console'" >> ~/.bashrc

WORKDIR /backend

RUN gem install bundler

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

ARG DEFAULT_PORT 3000

EXPOSE ${DEFAULT_PORT}

CMD [ "bundle","exec", "puma", "config.ru"] # CMD ["rails","server"]
