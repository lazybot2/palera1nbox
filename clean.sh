#!/bin/bash
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo apt-get clean -y
sudo rm -rf ./.git
sudo rm -rf ./doc
sudo rm -f ./*.md
sudo rm -rf ./Source
sudo rm -rf ./udev-media-automount-master
sudo rm -rf /var/tmp/*
sudo rm -rf /var/lib/apt/lists/*