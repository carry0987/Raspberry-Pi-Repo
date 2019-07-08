#!/usr/bin/env bash

set -e

sudo apt-get clean
sudo rm -rvf /var/lib/apt/lists/*
sudo apt-get clean
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get clean

exit 0
