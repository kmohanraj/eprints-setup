# Run as
#     docker run kbai/eprints -p 4444:4444
# Set up host:
#     echo '127.0.0.1 eprints-3.4.local eprints-3.4' >> /etc/hosts
# Open in browser:
#     http://eprints-3.4.local:4444
#
# http://files.eprints.org/1101/1/eprints-3.4-preview-1.tgz
# EPrints 3.4 has the same prerequisites as 3.3.
# We advise installing eprints into /opt, and running apache as the eprints user

# As the root user download both eprints-3.4-preview-1.tgz and eprints_publication_flavour-3.4-preview-1.tgz and put them into /root/
# Then also as root install the files:

# cd /opt
# tar xzf ~/eprints-3.4-preview-1.tgz
# cd /opt/eprints3
# tar xzf ~/eprints_publication_flavour-3.4-preview-1.tgz
# chown -R eprints:eprints /opt/eprints3

# # change to the eprints user
# su - eprints
# cd /opt/eprints3

# # to create a minimal repository
# bin/epadmin create zero

# # or to create a publications repository
# bin/epadmin create publication
FROM ubuntu:16.04
WORKDIR /opt/eprints3

# ENV EPRINTS_TARBALL_URL="http://files.eprints.org/1101/1/eprints-3.4-preview-1.tgz"
ENV EPRINTS_TARBALL="eprints-3.4-preview-1.tgz"
ENV EPRINTS_TARBALL_PUBL="eprints_publication_flavour-3.4-preview-1.tgz"
ENV DEBIAN_FRONTEND=noninteractive
ENV MYSQL_PASSWORD="root"

ADD eprints-3.4-preview-1.tgz /opt
ADD eprints_publication_flavour-3.4-preview-1.tgz /opt/eprints3

# Dependencies taken from the Debian source package control file:
RUN echo "mysql-server mysql-server/root_password password $MYSQL_PASSWORD" | debconf-set-selections \
    && echo "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD" | debconf-set-selections \ 
    && apt-get update -y && apt-get install -y \
    perl \
    libncurses5 \
    libselinux1 \
    libsepol1 \
    apache2 \
    libapache2-mod-perl2 \
    libxml-libxml-perl \
    libunicode-string-perl \
    libterm-readkey-perl \
    libmime-lite-perl \
    libmime-types-perl \
    libxml-libxslt-perl \
    libdigest-sha-perl \
    libdbd-mysql-perl \
    libxml-parser-perl \
    libxml2-dev \
    libxml-twig-perl \
    libarchive-any-perl \
    libjson-perl \
    lynx \
    wget \
    ghostscript \
    xpdf \
    antiword \
    elinks \
    pdftk \
    texlive-base \
    texlive-base-bin \
    psutils \
    imagemagick \
    adduser \
    mysql-server \
    mysql-client \
    unzip \
    libsearch-xapian-perl

# Dependencies taken from the Debian source package control file:
RUN apt-get update -y && apt-get install -y sudo expect

ADD install.expect install.expect

RUN service mysql start && \
    useradd eprints && \
    chown -R eprints:eprints /opt/eprints3 && \
    cd /opt/eprints3 && \
    sudo -u eprints expect install.expect && \
    chmod -R g+w . && \
    chgrp -R www-data . && \
     sudo -u eprints ./bin/import_subjects foobar

RUN echo 'Include /opt/eprints3/cfg/apache.conf' > /etc/apache2/sites-enabled/000-default.conf && \
    echo 'ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-enabled/000-default.conf && \
    echo 'CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-enabled/000-default.conf && \
    echo 'Listen 4444' >> /etc/apache2/ports.conf && \
    a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    service apache2 start

EXPOSE 80

ADD docker-cmd.sh .
CMD bash ./docker-cmd.sh
