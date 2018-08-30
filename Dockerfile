#VESION               0.0.1
FROM     drecom/centos-base:latest

# proxy
ENV https_proxy ""
ENV http_proxy ""

MAINTAINER Developer 

# PostgreSQL install
RUN yum -y install postgresql-devel

# rbenv install
RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv \
&&  git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
&&  git clone https://github.com/jf/rbenv-gemset.git /usr/local/rbenv/plugins/rbenv-gemset \
&&  /usr/local/rbenv/plugins/ruby-build/install.sh
ENV PATH /usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
&&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /etc/profile.d/rbenv.sh \
&&  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc \
&&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /root/.bashrc \
&&  echo 'eval "$(rbenv init -)"' >> /root/.bashrc

ENV CONFIGURE_OPTS --disable-install-doc
ENV PATH /usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH

# ruby install
RUN rbenv install 2.3.1
RUN rbenv global 2.3.1
RUN gem update --system
RUN gem install bundler --force

# java
RUN yum install -y wget tar java-1.8.0-openjdk java-1.8.0-openjdk-devel

# dynamodb
RUN wget http://dynamodb-local.s3-website-us-west-2.amazonaws.com/dynamodb_local_latest.tar.gz
ENV DYNAMODB_PATH /usr/local/dynamodb
RUN mkdir -p $DYNAMODB_PATH
RUN tar zxf dynamodb_local_latest.tar.gz -C $DYNAMODB_PATH
WORKDIR /usr/local/dynamodb
CMD ["java", "-Djava.library.path=/usr/local/dynamodb/", "-jar", "/usr/local/dynamodb/DynamoDBLocal.jar", "-port", "8000", "&"]

# projects setting
WORKDIR /
COPY . /

# npm install
# proxyがある場合
# RUN npm set https-proxy 
# RUN npm set proxy 

RUN npm install

# gem install
RUN bundle install

