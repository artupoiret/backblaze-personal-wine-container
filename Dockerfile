FROM jlesage/baseimage-gui:ubuntu-24.04-v4.6.7

ENV WINEPREFIX="/config/wine/"
ENV LANG="en_US.UTF-8"
ENV APP_NAME="Backblaze Personal Backup"
ENV DISPLAY_WIDTH="1280"
ENV DISPLAY_HEIGHT="800"
ENV WINEDEBUG="-all"
ENV DISPLAY=:0

RUN apt update && apt install -y curl wget software-properties-common gnupg2 winbind xvfb

RUN dpkg --add-architecture i386

RUN mkdir -pm755 /etc/apt/keyrings && \
    wget --no-check-certificate -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key - && \
    wget --no-check-certificate -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources

RUN apt update && apt install --install-recommends winehq-devel cabextract p7zip unrar unzip zenity -y

RUN wget --no-check-certificate https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/bin/winetricks
RUN chmod +x /usr/bin/winetricks

RUN DEBIAN_FRONTEND=noninteractive apt install -y locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

EXPOSE 5900

COPY rootfs/ /
RUN chmod +x /startapp.sh
