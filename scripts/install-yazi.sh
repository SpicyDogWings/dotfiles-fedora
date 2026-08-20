#!/bin/bash

# Install yazi

## install recommended deps
sudo dnf install ffmpeg jq poppler fd rg fzf zoixde wl-clipboard

## add repo
sudo dnf copr enable lihaohong/yazi
sudo dnf install yazi

