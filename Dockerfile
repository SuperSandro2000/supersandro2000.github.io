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

RUN bundle exec jekyll build

#---------------#

FROM httpd:alpine

RUN printf "\
<Directory \"/usr/local/apache2/htdocs\">\n\
    AllowOverride FileInfo=Header AuthConfig=BasicAuth\n\
</Directory>\n\
\n\
LoadModule rewrite_module modules/mod_rewrite.so\n\
LoadModule proxy_module modules/mod_proxy.so\n\
LoadModule proxy_http_module modules/mod_proxy_http.so\n\
LoadModule ssl_module modules/mod_ssl.so\n\
\n\
SSLProxyEngine on\n\
" >>/usr/local/apache2/conf/httpd.conf

COPY --from=builder /build/_site/ /usr/local/apache2/htdocs/
