FROM ruby:3.0.2-bullseye

ENV OPENSSL_CONF /etc/ssl

RUN apt-get update &&  apt-get install sudo && sudo apt-get install build-essential chrpath libssl-dev libxft-dev && \
 sudo apt-get install libfreetype6 libfreetype6-dev && \
  sudo apt-get install libfontconfig1 libfontconfig1-dev

RUN cd /root && wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
  sudo tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 && mv phantomjs-2.1.1-linux-x86_64 /usr/local/share && \
  sudo ln -sf /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin

ENTRYPOINT ["/bin/sh", "-c", "while :; do sleep 10; done"]
