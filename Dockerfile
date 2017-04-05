FROM ubuntu:14.04.5

RUN apt-get update && apt-get -y upgrade && apt-get -y install \
    curl \
    software-properties-common \
    libssl-dev \
    git

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -

RUN apt-get install -y \
		nodejs

RUN npm install -g coffee-script && npm install -g stylus && npm install -g bower

WORKDIR /deploy

CMD bash