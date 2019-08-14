FROM ubuntu:18.04 AS build

RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y unzip
RUN apt-get install -y ssh

# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest#install
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install kubectl via Azure CLI
RUN az aks install-cli

# https://kubeless.io/docs/quick-start/
WORKDIR /kubeless-cli 
ARG KUBELESS_CLI_VERSION=v1.0.4
RUN curl -OL https://github.com/kubeless/kubeless/releases/download/$KUBELESS_CLI_VERSION/kubeless_linux-amd64.zip
RUN unzip kubeless_linux-amd64.zip
RUN mv bundles/kubeless_linux-amd64/kubeless /usr/local/bin/
RUN rm kubeless_linux-amd64.zip

# https://helm.sh/docs/using_helm/#from-script
WORKDIR /helm-cli
RUN curl -LO https://git.io/get_helm.sh
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh
RUN rm get_helm.sh

# https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions-enterprise-linux-fedora-and-snap-packages
WORKDIR /nodejs
RUN curl -o nodesource_setup.sh -sL https://deb.nodesource.com/setup_12.x
RUN bash nodesource_setup.sh
RUN apt-get -y install nodejs
RUN rm nodesource_setup.sh

# https://docs.mongodb.com/manual/tutorial/install-mongodb-enterprise-on-debian/#using-tgz-tarballs
ARG MONGO_CLI_ROOT=/mongo-cli
ARG MONGO_CLI_DOWNLOAD_URL=https://downloads.mongodb.org/linux/mongodb-shell-linux-x86_64-debian81-4.0.11.tgz
ARG MONGO_CLI_EXTRACTED_PATH=mongodb-linux-x86_64-debian81-4.0.11/bin
WORKDIR $MONGO_CLI_ROOT
RUN apt-get install -y libgssapi-krb5-2 libkrb5-dbg libldap-2.4-2 libpcap0.8 libsasl2-2 snmp openssl
RUN wget -O mongo-cli.tgz $MONGO_CLI_DOWNLOAD_URL
RUN tar zxvf mongo-cli.tgz
ENV PATH=$PATH:$MONGO_CLI_ROOT/$MONGO_CLI_EXTRACTED_PATH
RUN rm mongo-cli.tgz

# https://dotnet.microsoft.com/download/linux-package-manager/ubuntu18-04/sdk-2.2.401
WORKDIR /dotnet
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get install -y apt-transport-https
RUN apt-get update
RUN apt-get install -y dotnet-sdk-2.2
RUN rm packages-microsoft-prod.deb

# redis-cli
RUN apt-get install -y redis-server

WORKDIR /app

CMD bash