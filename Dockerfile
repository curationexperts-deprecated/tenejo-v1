FROM ruby:2.6.3-stretch

RUN apt-get update -qq
# Add https support to apt to download yarn & node
RUN apt install -y apt-transport-https

# Add basic dev tools
RUN apt install -y curl build-essential wget git

# Add node and yarn repos and install them along
# along with other rails deps
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq

# Install system dependencies
RUN apt-get update -qq && apt install -y --no-install-recommends postgresql-client build-essential libpq-dev nodejs yarn imagemagick libreoffice ffmpeg unzip clamav clamav-freshclam clamav-daemon openjdk-8-jre-headless

# Chrome 74
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update && apt-get -y install google-chrome-stable

# Chromedriver
RUN wget -q https://chromedriver.storage.googleapis.com/74.0.3729.6/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip -d /usr/local/bin
RUN rm -f chromedriver_linux64.zip

# Update AV
RUN freshclam
RUN /etc/init.d/clamav-daemon start &

# Install fits
RUN mkdir /fits
WORKDIR /fits
ADD https://github.com/harvard-lts/fits/releases/download/1.4.0/fits-1.4.0.zip /fits/
RUN unzip fits-1.4.0.zip -d /fits
ENV PATH "/fits:$PATH"

# Install Ruby Gems

ENV APP_HOME /tenejo
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ENV BUNDLE_PATH /box
ENV GEM_PATH /box
ENV GEM_HOME /box

RUN gem install bundler:2.0.2

RUN ls -la

COPY Gemfile* $APP_HOME/
RUN bundle _2.0.2_ install

RUN bundle show bundler

RUN bundle show --paths

# Add tenejo
COPY . $APP_HOME
CMD ["sh", "/tenejo/docker/start-app.sh"]
