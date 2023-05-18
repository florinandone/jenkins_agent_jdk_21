# build with  
# podman build --file Dockerfile --tag oraclelinux-8-5-java-11-openjdk
FROM oraclelinux:8.5

#RUN yum -y update
RUN yum -y install java-11-openjdk 
RUN yum -y install java-11-openjdk-devel

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk


RUN yum -y install sudo
RUN yum -y install rsync


# The below is copied from 
# https://github.com/keeganwitt/docker-gradle/blob/master/jdk11/Dockerfile
CMD ["gradle"]

ENV GRADLE_HOME /opt/gradle

RUN set -o errexit -o nounset \
    && echo "Adding gradle user and group" \
    && groupadd --system --gid 1000 gradle \
    && useradd --system --gid gradle --uid 1000 --shell /bin/bash --create-home gradle \
    && mkdir /home/gradle/.gradle \
    && chown --recursive gradle:gradle /home/gradle \
    \
    && echo "Symlinking root Gradle cache to gradle Gradle cache" \
    && ln --symbolic /home/gradle/.gradle /root/.gradle

VOLUME /home/gradle/.gradle

WORKDIR /home/gradle

RUN set -o errexit -o nounset \
    &&  yum -y  install \
        which \
        unzip \
        wget \
        \
        git \
        git-lfs \
#    &&  yum clean all \
    \
    && echo "Testing VCSes" \
    && which git \
    && which git-lfs 

ENV GRADLE_VERSION 6.8.3
ARG GRADLE_DOWNLOAD_SHA256=7faa7198769f872826c8ef4f1450f839ec27f0b4d5d1e51bade63667cbccd205
RUN set -o errexit -o nounset \
    && echo "Downloading Gradle" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    \
    && echo "Checking download hash" \
    && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
    \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
    \
    && echo "Testing Gradle installation" \
