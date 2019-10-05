FROM ruby:2 as builder

ENV JEKYLL_ENV=production
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

RUN bundle exec jekyll build

#---------------#

FROM httpd:alpine

RUN printf "\
<Directory \"/usr/local/apache2/htdocs\">\n\
    AllowOverride FileInfo=Header\n\
</Directory>\n\
" >>/usr/local/apache2/conf/httpd.conf

COPY --from=builder /build/_site/ /usr/local/apache2/htdocs/
