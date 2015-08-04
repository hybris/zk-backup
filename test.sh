#!/bin/bash
set -e
set -x

vagrant up
vagrant ssh -c "sudo bash -c 'mkdir -p /zk-backup/tmp && cd /zk-backup && GOPATH=~/.go ./build.sh'"
vagrant ssh -c "sudo bash -c 'cd /zk-backup/tmp && /zk-backup/test/zk-backup.sh'"