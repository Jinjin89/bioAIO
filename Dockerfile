# set system version
FROM ubuntu:jammy
RUN apt-get update

RUN mkdir -p /install/script
RUN mkdir -p /install/pkgs

# set enviroment
ENV R_VERSION="4.1.3"
ENV R_HOME=${R_HOME:-"/usr/local/lib/R"}
ENV TZ="Etc/UTC"

# copy enssential data
ADD pkgs /install/pkgs
ADD script /install/script

# 1) install R-4.1.3 and depends
RUN /install/script/install_R.sh

# 2) install R4.1.3


# 3) install rstudio


# 4) install bio-fix package


# 5) install vnc: GUI


# 6) install browser: for 


# 7) 
