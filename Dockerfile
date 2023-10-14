# build with  
# podman build --file Dockerfile --tag oraclelinux-8-5-java-21-openjdk
FROM oraclelinux:9

#RUN yum -y update
RUN yum list available jdk
RUN yum -y install jdk-21-headless 
RUN yum -y install jdk-21-headful
RUN yum -y install net-tools

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk


RUN yum -y install sudo
RUN yum -y install rsync


# The below is copied from 
# https://github.com/keeganwitt/docker-gradle/blob/master/jdk21/Dockerfile
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

ENV GRADLE_VERSION 8.3
ARG GRADLE_DOWNLOAD_SHA256=591855b521fc635b9e04de1d05d5e76ada3f89f5fc76f87978d1b245b4f69225
RUN set -o errexit -o nounset \
    && echo "Downloading Gradle" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    \
    && echo "Checking Gradle download hash" \
    && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
    \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle
