# Dockerfile for icinga2 with icingaweb2
# https://github.com/fastjack/icinga2

FROM debian:stretch

LABEL maintainer="martin@maciaszek.net"

ENV APACHE2_HTTP=REDIRECT \
    ICINGA2_FEATURE_GRAPHITE=false \
    ICINGA2_FEATURE_GRAPHITE_HOST=graphite \
    ICINGA2_FEATURE_GRAPHITE_PORT=2003 \
    ICINGA2_FEATURE_GRAPHITE_URL=http://graphite \
    ICINGA2_USER_FULLNAME="Icinga2" \
    ICINGA2_FEATURE_DIRECTOR="true" \
    ICINGA2_FEATURE_DIRECTOR_KICKSTART="true" \
    ICINGA2_FEATURE_DIRECTOR_USER="icinga2-director"

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
      apache2 \
      ca-cacert \
      ca-certificates \
      curl \
      dnsutils \
      file \
      gnupg \
      libdbd-mysql-perl \
      libdigest-hmac-perl \
      libnet-snmp-perl \
      locales \
      lsb-release \
      mailutils \
      mariadb-client \
      netbase \
      openssh-client \
      openssl \
      php-curl \
      php-gmp \
      php-ldap \
      php-mysql \
      php-soap \
      procps \
      pwgen \
      snmp \
      ssmtp \
      sudo \
      supervisor \
      unzip \
      wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN export DEBIAN_FRONTEND=noninteractive \
 && curl -s https://packages.icinga.com/icinga.key \
 | apt-key add - \
 && echo "deb http://packages.icinga.org/debian icinga-$(lsb_release -cs) main" > /etc/apt/sources.list.d/icinga2.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      icinga2 \
      icinga2-ido-mysql \
      icingacli \
      icingaweb2 \
      icingaweb2-module-doc \
      icingaweb2-module-monitoring \
      monitoring-plugins \
      nagios-nrpe-plugin \
      nagios-plugins-contrib \
      nagios-snmp-plugins \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ARG GITREF_DIRECTOR=master
ARG GITREF_MODGRAPHITE=master
ARG GITREF_MODAWS=master
ARG GITREF_BUSINESSPROCESS=master
ARG GITREF_GRAFANA=master
ARG GITREF_CUBE=master
ARG GITREF_IPL=v0.2.1
ARG GITREF_REACT=v0.5.1
ARG GITREF_X509=master
ARG GITREF_INCUBATOR=v0.2.0
ARG GITREF_VSPHERE=master

RUN mkdir -p /usr/local/share/icingaweb2/modules/ \
# Icinga Director
 && mkdir -p /usr/local/share/icingaweb2/modules/director/ \
 && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-director/archive/${GITREF_DIRECTOR}.tar.gz" \
 | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/director --exclude=.gitignore -f - \
# Icingaweb2 Graphite
 && mkdir -p /usr/local/share/icingaweb2/modules/graphite \
 && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-graphite/archive/${GITREF_MODGRAPHITE}.tar.gz" \
 | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/graphite -f - icingaweb2-module-graphite-${GITREF_MODGRAPHITE}/ \
# Icingaweb2 AWS
 && mkdir -p /usr/local/share/icingaweb2/modules/aws \
 && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-aws/archive/${GITREF_MODAWS}.tar.gz" \
 | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/aws -f - icingaweb2-module-aws-${GITREF_MODAWS}/ \
 && wget -q --no-cookies "https://github.com/aws/aws-sdk-php/releases/download/2.8.30/aws.zip" \
 && unzip -d /usr/local/share/icingaweb2/modules/aws/library/vendor/aws aws.zip \
 && rm aws.zip \
# Icinga PHP Library (IPL)
 && mkdir -p /usr/local/share/icingaweb2/modules/ipl \
 && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-ipl/archive/${GITREF_IPL}.tar.gz" \
 | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/ipl --exclude=.gitignore -f - \
# Business Process
 && mkdir -p /usr/local/share/icingaweb2/modules/businessprocess \
 && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-businessprocess/archive/${GITREF_BUSINESSPROCESS}.tar.gz" \
 | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/businessprocess --exclude=.gitignore -f - \
# React bundle
 && mkdir -p /usr/local/share/icingaweb2/modules/react \
 && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-reactbundle/archive/${GITREF_REACT}.tar.gz" \
 | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/react --exclude=.gitignore -f - \
# X509
 && mkdir -p /usr/local/share/icingaweb2/modules/x509 \
 && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-x509/archive/${GITREF_X509}.tar.gz" \
 | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/x509 --exclude=.gitignore -f - \
# Grafana
 && mkdir -p /usr/local/share/icingaweb2/modules/grafana \
 && wget -q --no-cookies -O - "https://github.com/Mikesch-mp/icingaweb2-module-grafana/archive/${GITREF_GRAFANA}.tar.gz" \
 | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/grafana --exclude=.gitignore -f - \
# Cube
 && mkdir -p /usr/local/share/icingaweb2/modules/cube \
 && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-cube/archive/${GITREF_CUBE}.tar.gz" \
 | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/cube --exclude=.gitignore -f - \
# Incubator (VSphere dependency)
 && mkdir -p /usr/local/share/icingaweb2/modules/incubator \
 && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-incubator/archive/${GITREF_INCUBATOR}.tar.gz" \
 | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/incubator --exclude=.gitignore -f - \
# VSphere
 && mkdir -p /usr/local/share/icingaweb2/modules/vspheredb \
 && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-vspheredb/archive/${GITREF_VSPHERE}.tar.gz" \
 | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/vspheredb --exclude=.gitignore -f - \
 && true

ADD content/ /

# Final fixes
RUN true \
 && sed -i 's/vars\.os.*/vars.os = "Docker"/' /etc/icinga2/conf.d/hosts.conf \
 && mv /etc/icingaweb2/ /etc/icingaweb2.dist \
 && mkdir /etc/icingaweb2 \
 && mv /etc/icinga2/ /etc/icinga2.dist \
 && mkdir /etc/icinga2 \
 && usermod -aG icingaweb2 www-data \
 && usermod -aG nagios www-data \
 && rm -rf \
     /var/lib/mysql/* \
 && chmod u+s,g+s \
     /bin/ping \
     /bin/ping6 \
     /usr/lib/nagios/plugins/check_icmp

EXPOSE 80 443 5665

# Initialize and run Supervisor
ENTRYPOINT ["/opt/run"]
