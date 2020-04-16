FROM buildpack-deps:jessie-curl
LABEL maintainer "Scott Reu (https://keybase.io/gatsbysghost)"

RUN \
	# Install dependencies
	apt-get update && apt-get install -y \
		fuse \
		libappindicator1 \
        libgconf-2-4 \
        psmisc \
        lsof \
        libasound2 \
        libnss3 \
        libxss1 \
        libxtst6 \
        libgtk-3-0 \
        git \
		--no-install-recommends \
	# Get and verify Keybase.io's code signing key
	&& curl https://keybase.io/docs/server_security/code_signing_key.asc | \
		gpg --import \
	&& gpg --fingerprint 222B85B0F90BE2D24CFEB93F47484E50656D16C7 \
	# Get, verify and install client package
	&& curl -O https://prerelease.keybase.io/keybase_amd64.deb.sig \
	&& curl -O https://prerelease.keybase.io/keybase_amd64.deb \
	&& gpg --verify keybase_amd64.deb.sig keybase_amd64.deb \
	&& dpkg -i keybase_amd64.deb \
	&& apt-get install -f \
	# Create group, user
	&& groupadd -g 1000 keybase \
	&& useradd --create-home -g keybase -u 1000 keybase \
	# Cleanup
	&& rm -r /var/lib/apt/lists/* \
	&& rm keybase_amd64.deb*

RUN \
  apt-get update && apt-get install -y --no-install-recommends --no-install-suggests curl bzip2 build-essential libssl-dev libreadline-dev zlib1g-dev && \
  rm -rf /var/lib/apt/lists/* && \
  curl -L https://github.com/sstephenson/ruby-build/archive/v20200401.tar.gz | tar -zxvf - -C /tmp/ && \
  cd /tmp/ruby-build-* && ./install.sh && cd / && \
  ruby-build -v 2.6.1 /usr/local && rm -rfv /tmp/ruby-build-* && \
  gem install bundler


RUN sed -i '/^Environment=.*/a Environment=KEYBASE_ALLOW_ROOT=1' /usr/lib/systemd/user/keybase.service

USER keybase
WORKDIR /home/keybase

CMD ["bash"]

RUN env KEYBASE_ALLOW_ROOT=1 run_keybase -g
