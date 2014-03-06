FROM stackbrew/ubuntu:saucy
VERSION 0.1
MAINTAINER Patrick Aljord <patcito@gmail.com>

## add mongodb ppa
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
RUN apt-get update

## install everything
RUN apt-get install -y --force-yes build-essential libssl-dev libreadline6  libreadline6-dev zlib1g zlib1g-dev bison openssl git make libyaml-dev ca-certificates zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev python-software-properties libsqlite3-dev curl mongodb-10gen libxml2-dev libxslt-dev
RUN apt-get clean

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN ./root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

# Install multiple versions of ruby
ENV CONFIGURE_OPTS --disable-install-doc
ADD ./versions.txt /root/versions.txt
RUN xargs -L 1 rbenv install < /root/versions.txt

# Install Bundler for each version of ruby
RUN rbenv global 2.1.1
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN bash -l -c 'for v in $(cat /root/versions.txt); do rbenv global $v; gem install bundler; done'
## configure gem
RUN touch ~/.gemrc
RUN echo 'gem: --no-document' >> ~/.gemrc
## install rails and bundler
#RUN rbenv global 2.1.1; ruby -v ;bundle exec gem install --no-rdoc --no-ri rails
## install nodejs (or rubytracer if you prefer)
RUN apt-get install -y --force-yes software-properties-common
RUN add-apt-repository ppa:chris-lea/node.js
RUN add-apt-repository ppa:chris-lea/redis-server
RUN apt-get update
RUN apt-get install -y --force-yes nodejs redis-server
## set up init rails script
##ENTRYPOINT if [ -f /railsapp/init_rails_app.sh ]; then echo "already exists"; else echo 'cd /railsapp && mkdir -p /railsapp/bundle && bund
le install --path /railsapp/bundle && find /railsapp/config/mongoid.yml -type f -exec sed -i "s/localhost/$DB_PORT_27017_TCP_ADDR/g" {} \; &
& rails s' >> /railsapp/init_rails_app.sh; fi; /bin/bash /railsapp/init_rails_app.sh;
## RUN  echo 'cd /railsapp && mkdir -p /railsapp/bundle && bundle install --path /railsapp/bundle && find /railsapp/config/mongoid.yml -type
 f -exec sed -i "s/localhost/$DB_PORT_27017_TCP_ADDR/g" {} \; && rails s' >> /init_rails_app.sh 
## RUN cat /init_rails_app.sh
## expose rails server port
##EXPOSE 3000
RUN rbenv exec gem install rails
RUN echo 'Runs: docker run -i -t -link mongo:db -v /path/to/rails/app:/railsapp 52139e950e2a'
##ENTRYPOINT ["/bin/bash" ,"/railsapp/init_rails_app.sh"]
