#!/bin/bash
bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0
