#!/bin/bash
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo apt-get clean -y
sudo rm -rf /var/tmp/*
sudo rm -rf /var/lib/apt/lists/*