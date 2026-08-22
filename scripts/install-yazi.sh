#!/bin/bash

# Install yazi

## install recommended deps
sudo dnf install ffmpeg jq poppler fd rg fzf zoxide wl-clipboard

## add repo
sudo dnf copr enable lihaohong/yazi
sudo dnf install yazi

