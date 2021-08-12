FROM ruby:2.6.3-stretch

# Add node and yarn repos and install them
# along with other rails deps
RUN apt-get update && apt install -y curl apt-transport-https ca-certificates

# Install node from nodesource
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - 2>/dev/null \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sS https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - 2>/dev/null  \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# Install system dependencies
RUN apt-get update -qq && apt install -y --no-install-recommends postgresql-client build-essential libpq-dev imagemagick libreoffice ffmpeg unzip clamav clamav-freshclam clamav-daemon openjdk-8-jre-headless apt-transport-https build-essential git vim google-chrome-stable

# Chromedriver
RUN curl -sS https://chromedriver.storage.googleapis.com/92.0.4515.43/chromedriver_linux64.zip > chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip -d /usr/local/bin
RUN rm -f chromedriver_linux64.zip


# Install fits
RUN mkdir /fits
WORKDIR /fits
ADD https://github.com/harvard-lts/fits/releases/download/1.4.0/fits-1.4.0.zip /fits/
RUN unzip fits-1.4.0.zip -d /fits
ENV PATH "/fits:$PATH"

# Install Ruby Gems
RUN gem install bundler:2.2.14

COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install

# Update AV
RUN /usr/bin/freshclam

# Add tenejo
RUN mkdir /tenejo
WORKDIR /tenejo
COPY . /tenejo

CMD ["sh", "/tenejo/docker/start-app.sh"]
