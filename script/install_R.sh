#!/bin/bash

set -e

R_VERSION=${1:-${R_VERSION:-"latest"}}
PURGE_BUILDDEPS=${PURGE_BUILDDEPS:-"true"}

# shellcheck source=/dev/null
source /etc/os-release

apt-get update
apt-get -y install locales

## Configure default locale
LANG=${LANG:-"en_US.UTF-8"}
/usr/sbin/locale-gen --lang "${LANG}"
/usr/sbin/update-locale --reset LANG="${LANG}"

export DEBIAN_FRONTEND=noninteractive

READLINE_VERSION=8
if [ "${UBUNTU_CODENAME}" == "bionic" ]; then
    READLINE_VERSION=7
fi

apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    file \
    fonts-texgyre \
    g++ \
    gfortran \
    gsfonts \
    libblas-dev \
    libbz2-* \
    libcurl4 \
    "libicu[0-9][0-9]" \
    liblapack-dev \
    libpcre2* \
    libjpeg-turbo* \
    libpangocairo-* \
    libpng16* \
    "libreadline${READLINE_VERSION}" \
    libtiff* \
    liblzma* \
    libxt6 \
    make \
    tzdata \
    unzip \
    zip \
    zlib1g

BUILDDEPS="curl \
    default-jdk \
    devscripts \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libicu-dev \
    libpcre2-dev \
    libpng-dev \
    libreadline-dev \
    libtiff5-dev \
    liblzma-dev \
    libx11-dev \
    libxt-dev \
    perl \
    rsync \
    subversion \
    tcl-dev \
    tk-dev \
    texinfo \
    texlive-extra-utils \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    texlive-latex-extra \
    x11proto-core-dev \
    xauth \
    xfonts-base \
    xvfb \
    wget \
    zlib1g-dev"

# shellcheck disable=SC2086
apt-get install -y --no-install-recommends ${BUILDDEPS}

cd /install/pkgs/R
# install R
tar xzf "R-4.1.3.tar.gz"
cd R-*/

R_PAPERSIZE=letter \
    R_BATCHSAVE="--no-save --no-restore" \
    R_BROWSER=xdg-open \
    PAGER=/usr/bin/pager \
    PERL=/usr/bin/perl \
    R_UNZIPCMD=/usr/bin/unzip \
    R_ZIPCMD=/usr/bin/zip \
    R_PRINTCMD=/usr/bin/lpr \
    LIBnn=lib \
    AWK=/usr/bin/awk \
    CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
    CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
    ./configure --enable-R-shlib \
    --enable-memory-profiling \
    --with-readline \
    --with-blas \
    --with-lapack \
    --with-tcltk \
    --with-recommended-packages

make
make install
make clean

## Clean up from R source install
cd ..
rm -rf /tmp/*
rm -rf R-*/
rm -rf "R-4.1.3.tar.gz"

## Copy the checkbashisms script to local before remove devscripts package.
## https://github.com/rocker-org/rocker-versioned2/issues/510
cp /usr/bin/checkbashisms /usr/local/bin/checkbashisms

# shellcheck disable=SC2086
if [ "${PURGE_BUILDDEPS}" != "false" ]; then
    apt-get remove --purge -y ${BUILDDEPS}
fi

apt-get autoremove -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/*

# Check the R info
echo -e "Check the R info...\n"

R -q -e "sessionInfo()"

echo -e "\nInstall R from source, done!"
