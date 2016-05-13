#!/bin/sh
sidekiqctl stop tmp/pids/sidekiq.pid && \
rm log/sidekiq.log
