FROM ruby:alpine as builder

ENV JEKYLL_ENV=production
# fix some weird locale issue. See https://github.com/jekyll/jekyll/issues/4268#issuecomment-167406574
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apk add --no-cache g++ make musl-dev \
  && gem install bundler:">2"

COPY Gemfile Gemfile.lock /build/

WORKDIR /build
RUN bundle config --global frozen 1 \
  && bundle install

COPY . /build/

ARG JEKYLL_GITHUB_TOKEN
RUN bundle exec jekyll build

#---------------#

FROM nginx:mainline

COPY --from=builder [ "/build/_site/", "/usr/share/nginx/html/" ]
COPY [ "default.conf", "/etc/nginx/conf.d/default.conf" ]
