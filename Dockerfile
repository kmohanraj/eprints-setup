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
WORKDIR /opt/eprints

# ENV EPRINTS_TARBALL_URL="http://files.eprints.org/1101/1/eprints-3.4-preview-1.tgz"
ENV EPRINTS_TARBALL="eprints-3.4-preview-1.tgz"
ENV EPRINTS_TARBALL_PUBL="eprints_publication_flavour-3.4-preview-1.tgz"
ENV DEBIAN_FRONTEND noninteractive

ADD eprints-3.4-preview-1.tgz /opt
ADD eprints_publication_flavour-3.4-preview-1.tgz /opt/eprints3

# Dependencies taken from the Debian source package control file:
RUN apt-get update -y && apt-get install -y \
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
RUN apt-get update -y && apt-get install -y sudo

# wtf must input to epadmin be read from terminal??
ENV COLUMNS 0
ENV LINES 0

RUN useradd eprints && \
    chown -R eprints:eprints /opt/eprints3 && \
    cd /opt/eprints3 && \
    sudo -u eprints sh -c "COLUMNS=80 ROWS=25 echo 'test-repo'| bin/epadmin create zero"

CMD service apache2 start

