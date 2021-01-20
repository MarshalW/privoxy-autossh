#!/bin/sh

autossh -M 0 -o "ServerAliveInterval 10" -o "ServerAliveCountMax 3" -o "StrictHostKeyChecking no" -4 -D 0.0.0.0:1337 -C  -N   sjhk