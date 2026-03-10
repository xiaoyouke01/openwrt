#!/bin/bash

# 1. 修改默认 IP
sed -i '/lan)/s/192\.168\.[0-9.]*/192.168.100.252/' package/base-files/files/bin/config_generate
