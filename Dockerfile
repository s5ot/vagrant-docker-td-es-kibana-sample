FROM base

MAINTAINER s5ot "https://github.com/s5ot"

# Install packages for building ruby
RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN apt-get clean

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN ./root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile

# Install Bundler for each version of ruby
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN bash -l -c 'rbenv install 2.0.0-p353; rbenv global 2.0.0-p353; rbenv exec gem install apache-loggen; rbenv rehash'

RUN echo "deb http://packages.treasure-data.com/precise/ precise contrib" > /etc/apt/sources.list.d/treasure-data.list
RUN apt-get update
RUN apt-get install -y --force-yes td-agent
RUN /etc/init.d/td-agent stop
RUN cat /dev/null > /var/log/td-agent/td-agent.log

RUN /usr/lib/fluent/ruby/bin/fluent-gem install fluent-plugin-elasticsearch

ADD daemon.rb /usr/local/bin/daemon.rb
RUN chmod +x /usr/local/bin/daemon.rb

ADD run.sh /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

CMD ["/usr/local/bin/run"]
