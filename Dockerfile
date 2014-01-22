# DOCKER-VERSION 0.7.1
FROM swcc/chef-solo
MAINTAINER Paul B. "paul+swcc@bonaud.fr"

ADD . /chef
RUN cd /chef && /opt/chef/embedded/bin/berks install --path /chef/cookbooks
RUN chef-solo -c /chef/solo.rb -j /chef/solo.json
