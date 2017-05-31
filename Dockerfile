FROM ruby:2.3-alpine

RUN apk add --update alpine-sdk

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/

RUN bundle install

RUN curl -L https://github.com/rancher/rancher-compose/releases/download/v0.9.2/rancher-compose-linux-amd64-v0.9.2.tar.gz -o rc.tar.gz
RUN tar zxvf rc.tar.gz --strip-components 2
RUN rm -rf rc.tar.gz
RUN mv rancher-compose /usr/bin/rancher-compose && chmod +x /usr/bin/rancher-compose

COPY . /app

EXPOSE 4567

CMD ["ruby", "/app/app.rb"]
