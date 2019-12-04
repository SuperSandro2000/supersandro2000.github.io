FROM ruby:2 as builder

# fix some weird locale issue. See https://github.com/jekyll/jekyll/issues/4268#issuecomment-167406574
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

COPY Gemfile Gemfile.lock /build/

WORKDIR /build

RUN gem install bundler:">2" \
  && bundle config --global frozen 1 \
  && bundle install

COPY . /build/

CMD [ "bundle", "exec", "jekyll", "serve" ]
