#!/bin/bash
# $1 is link to git repo
# $2 is tag name

git ls-remote $1 rev-list -n 1 $2 | awk '{print $1}'
