#!/bin/bash

# Install pnpm

## install via script
curl -fsSL https://get.pnpm.io/install.sh | sh -

## install the rust analyzer
pnpm runtime set node 24 -g

## install necesary deps to helix
pnpm add -g intelephense

