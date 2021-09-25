FROM ruby:3.0.2-bullseye

ENTRYPOINT ["/bin/sh", "-c", "while :; do sleep 10; done"]
