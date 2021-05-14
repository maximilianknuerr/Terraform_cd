#!/bin/bash
set -e # this is important!

sudo apt-get update
sudo apt-get install -y build-essential ruby ruby-dev redis
sudo gem install --no-document sinatra json redis
mkdir -p /home/ubuntu
mv /tmp/packer/app.rb /home/ubuntu/