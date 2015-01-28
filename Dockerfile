
#################################################################
# This docker image build file creates an image crafted for RoR 
# development. It packs nginx, passenger, rvm with ruby on rails 
# and nodejs. As dev env uses tmux, zsh, oh-my-zsh, powerline and 
# vim with pathogen and a lot of plugins.
# Is is based on ubuntu:saucy
#
#                    ##        .
#              ## ## ##       ==
#           ## ## ## ##      ===
#       /""""""""""""""""\___/ ===
#  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
#       \______ o          __/
#         \    \        __/
#          \____\______/
#
# Credentials
# User: dev
# Pass: dev
#
# Component:    ubuntu-dev
# Author:       batou99 <lorenzo.lopez@intec.es>
#################################################################

#####
# Building: sudo docker build -t batou99/ubuntu-dev .

FROM dockerfile/supervisor
MAINTAINER Lorenzo Lopez <lorenzo.lopez@intec.es>

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Add node repository to sources.list and update apt
RUN add-apt-repository -y ppa:chris-lea/node.js && apt-get update

# Install Git 2.x.
# This isn't available in the main repo so we get it from a PPA.
# Source: http://unix.stackexchange.com/a/170831 
RUN sudo add-apt-repository ppa:git-core/ppa -y

# Setup all needed dependencies
RUN apt-get update
RUN apt-get -y install curl libcurl4-gnutls-dev git libxslt-dev libxml2-dev libpq-dev libffi-dev vim-nox git software-properties-common python-software-properties zsh tmux ctags sudo openssh-server net-tools inetutils-ping xdg-utils ack-grep libnotify-bin mysql-client libmysqlclient-dev ruby-dev git nodejs

# Install locale
RUN locale-gen es_ES.UTF-8

# Install yeoman
RUN npm -g install yo

RUN mkdir -p /var/log/nginx/
# Install rvm, ruby, rails, rubygems, nginx
ENV RUBY_VERSION 2.2.0

# User settings
RUN useradd -d /home/dev -m dev 
RUN echo "dev:dev" | chpasswd

# Add "dev" to "sudoers"
RUN echo "dev        ALL=(ALL:ALL) ALL" >> /etc/sudoers

USER dev
WORKDIR /home/dev
ENV HOME /home/dev
ENV PATH $PATH:/home/dev
ENV TERM screen-256color

# All rvm commands need to be run as bash -l or they won't work.
# Add GPG key for RVM.
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
# Install RVM.
RUN \curl -sSL https://get.rvm.io | bash -s stable
RUN echo 'source /usr/local/rvm/scripts/rvm' >> ~/bash.bashrc
USER root
RUN /bin/bash -l -c 'rvm requirements'
USER dev
RUN /bin/bash -l -c 'rvm install 2.2.0'
RUN /bin/bash -l -c 'rvm use $RUBY_VERSION --default'
RUN /bin/bash -l -c 'rvm rubygems current'
RUN /bin/bash -l -c 'gem install bundler --no-ri --no-rdoc'

USER root
RUN chsh -s /bin/zsh dev

USER dev

# Clone oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh/
RUN git clone https://github.com/Batou99/dotfiles ~/.vim
RUN cd ~/.vim/ && ./install.sh

# Just to make things safer. 
ENV RAILS_ENV development

# You'll need to override the default nginx.conf with you're own. 
# I've provided a sample in the github project.
#ADD local/path/to/nginx.conf /opt/nginx/conf/nginx.conf

# You'll obviously want to expose some ports.
EXPOSE 22

EXPOSE 80

EXPOSE 443
