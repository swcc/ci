#!/bin/sh

if [ ! -f /home/git/.profile ]; then
  echo 'echo You are now logged in as the git user that runs GitLab, to get sudo privileges please exit to become the vagrant user' | su git -c 'cat >> /home/git/.profile'
fi

cat /home/vagrant/.bashrc | grep --quiet 'sudo su - git' || echo 'sudo su - git' >> /home/vagrant/.bashrc
