FROM ruby:2-alpine as builder

ENV JEKYLL_ENV=production
# fix some weird locale issue. See https://github.com/jekyll/jekyll/issues/4268#issuecomment-167406574
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apk add --no-cache \
    g++ \
    libxslt-dev \
    make \
    musl-dev \
    npm \
    sed \
  && gem install bundler:">2"

WORKDIR /build
COPY [ "package.json", "package-lock.json", "/build/" ]
RUN npm install

COPY [ "Gemfile", "Gemfile.lock", "/build/" ]
RUN bundle config --global frozen 1 \
  && bundle config build.nokogiri --use-system-libraries \
  && bundle install \
# monkey patch github-pages gem to allow any plugin to be loaded
  && sed -i 's/^.*"plugins_dir" =>.*$/      "plugins_dir" => "_plugins",/gm' $GEM_HOME/gems/github-pages-*/lib/github-pages/configuration.rb \
  && sed -i 's/^.*"safe" =>.*$/      "safe" => false,/gm' $GEM_HOME/gems/github-pages-*/lib/github-pages/configuration.rb

COPY [ ".", "/build/" ]

ARG JEKYLL_GITHUB_TOKEN
RUN bundle exec jekyll build

#---------------#

FROM nginx:mainline

COPY --from=builder [ "/build/_site/", "/usr/share/nginx/html/" ]
COPY [ "default.conf", "/etc/nginx/conf.d/default.conf" ]
