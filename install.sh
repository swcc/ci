#!/usr/bin/env bash

# No password prompt
export DEBIAN_FRONTEND=noninteractive

# Apt update
apt-get update -y > /dev/null
apt-get upgrade -y > /dev/null
apt-get install sudo -y > /dev/null

# Install tools
apt-get install -y git curl

# Backports Redis server && git for Debian squeeze
echo "deb http://backports.debian.org/debian-backports squeeze-backports main" >> /etc/apt/sources.list
apt-get update
apt-get -t squeeze-backports install redis-server
apt-get -t squeeze-backports install git

######################
###                ###
### MySQL Install  ###
###                ###
######################

# Install the database packages
apt-get install -y mysql-server mysql-client libmysqlclient-dev

# Sett root password to root
mysqladmin -u root password mysql

############
# MySQL users
############

# Create DB and user for GitLab
mysql -u root --password=mysql < /vagrant/config/gitlab/create_database.sql

## SonarQube
mysql -u root --password=mysql < /vagrant/config/sonarqube/create_database.sql


#######################
###                 ###
### Sonar Install   ###
###                 ###
#######################

echo "deb http://downloads.sourceforge.net/project/sonar-pkg/deb binary/" >> /etc/apt/sources.list
apt-get update -y
apt-get install -y --force-yes sonar

export SONAR_HOME=/opt/sonar

cp /vagrant/config/sonarqube/sonar.properties $SONAR_HOME/conf
cp /vagrant/config/sonarqube/wrapper.conf $SONAR_HOME/conf
cp /vagrant/config/sonarqube/sonar /etc/init.d/

ln -s $SONAR_HOME/bin/linux-x86-64/sonar.sh /usr/bin/sonar
chmod 755 /etc/init.d/sonar
update-rc.d sonar defaults

#######################
###                 ###
### Jenkins Install ###
###                 ###
#######################

############
# 1. Jenkins
############
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
echo "deb http://pkg.jenkins-ci.org/debian binary/" >> /etc/apt/sources.list
apt-get update -y
apt-get install -y jenkins

############
# 1. Plugins
############
/etc/init.d/jenkins start
pushd /usr/lib/jenkins
wget -q http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
jenkins_plugins_to_install=(git gitlab-hook ruby-runtime)
for i in ${jenkins_plugins_to_install[@]}; do
    java -jar jenkins-cli.jar -s http://127.0.0.1:8080/ install-plugin $i -deploy
done
popd

######################
###                ###
### GitLab Install ###
###                ###
######################

############
# 1. Python
############

# Install required Packages
apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl git-core openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate

# If it's Python 3 you might need to install Python 2 separately
apt-get install -y python2.7

# Make sure you can access Python via python2
# If you get a "command not found" error create a link to the python binary
command -v python2 >/dev/null || sudo ln -s /usr/bin/python /usr/bin/python2

# For reStructuredText markup language support install required package:
apt-get install -y python-docutils

############
# 2. Ruby
############

apt-get remove -y ruby1.8

# Install ruby2
mkdir /tmp/ruby && cd /tmp/ruby
curl --progress ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p247.tar.gz | tar xz
cd ruby-2.0.0-p247
./configure --disable-install-rdoc
make
make install

#Install the Bundler Gem
gem install bundler --no-ri --no-rdoc


############
# 3. System users
############
adduser --disabled-login --gecos 'GitLab' git

############
# 4. GitLab shell
############

# Go to home directory
cd /home/git

# Clone gitlab shell
sudo -u git -H git clone https://github.com/gitlabhq/gitlab-shell.git

cd gitlab-shell

# switch to right version
sudo -u git -H git checkout v1.7.9

sudo -u git -H cp /vagrant/config/gitlab/gitlab-shell-config.yml config.yml

# Do setup
sudo -u git -H ./bin/install

############
# 5. GitLab Install
############

# We'll install GitLab into home directory of the user "git"
cd /home/git

# Clone GitLab repository
sudo -u git -H git clone https://github.com/gitlabhq/gitlabhq.git gitlab

# Go to gitlab dir
cd /home/git/gitlab

# Checkout to stable release
sudo -u git -H git checkout 6-3-stable

cd /home/git/gitlab

# Copy the vm GitLab config
sudo -u git -H cp /vagrant/config/gitlab/gitlab.yml config/gitlab.yml

# Make sure GitLab can write to the log/ and tmp/ directories
sudo chown -R git log/
sudo chown -R git tmp/
sudo chmod -R u+rwX  log/
sudo chmod -R u+rwX  tmp/

# Create directory for satellites
sudo -u git -H mkdir /home/git/gitlab-satellites

# Create directories for sockets/pids and make sure GitLab can write to them
sudo -u git -H mkdir tmp/pids/
sudo -u git -H mkdir tmp/sockets/
sudo chmod -R u+rwX  tmp/pids/
sudo chmod -R u+rwX  tmp/sockets/

# Create public/uploads directory otherwise backup will fail
sudo -u git -H mkdir public/uploads
sudo chmod -R u+rwX  public/uploads

# Copy the example Unicorn config
sudo -u git -H cp /vagrant/config/gitlab/unicorn.rb config/unicorn.rb

# Copy the example Rack attack config
sudo -u git -H cp /vagrant/config/gitlab/rack_attack.rb config/initializers/rack_attack.rb

# Enable rack attack middleware
# Find and uncomment the line 'config.middleware.use Rack::Attack'
sudo -u git -H cp /vagrant/config/gitlab/application.rb config/application.rb

# Configure Git global settings for git user, useful when editing via web
# Edit user.email according to what is set in gitlab.yml
sudo -u git -H git config --global user.name "GitLab"
sudo -u git -H git config --global user.email "gitlab@localhost"
sudo -u git -H git config --global core.autocrlf input


############
# 6. DB config 
############

sudo -u git cp /vagrant/config/gitlab/database.yml config/database.yml
sudo -u git -H chmod o-rwx config/database.yml

############
# 7. Install Gems
############

cd /home/git/gitlab

# Seems to lack this lib for now...
apt-get install -y libpq-dev

# For MySQL (note, the option says "without ... postgres")
sudo -u git -H bundle install --deployment --without development test postgres aws

############
# 7. Install DB & Init script
############

# Init DB
# sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production
# NEED TO TYPE YES,
# Call the three tasks called by gitlab:setup
sudo -u git -H bundle exec rake db:setup db:seed_fu RAILS_ENV=production

# Install Init Script
sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
sudo chmod +x /etc/init.d/gitlab

# Make GitLab start on boot:
sudo update-rc.d gitlab defaults 21

# Setup logrotate
sudo cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab

###############
# 8. Web server
###############

apt-get install -y nginx

sudo cp /vagrant/config/nginx/gitlab /etc/nginx/sites-available/gitlab
sudo ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab

sudo usermod -a -G git www-data
sudo chmod g+rx /home/git/

############
# 9. Start !!
############

sudo /etc/init.d/nginx restart
sudo /etc/init.d/gitlab restart
