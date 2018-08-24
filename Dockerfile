FROM ubuntu:xenial

RUN apt-get update
RUN apt-get install -y wget apt-transport-https software-properties-common

# setup wine repo
RUN dpkg --add-architecture i386 && \
    wget -nc https://dl.winehq.org/wine-builds/Release.key && \
    apt-key add Release.key && \
    apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ && \
    rm *.key && \
    apt-get update   

# install wine
RUN apt-get install -y --install-recommends winehq-stable

# install winetricks
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/local/bin/winetricks && \
    chmod +x /usr/local/bin/winetricks

# tools used by wine
RUN apt-get install -y cabextract p7zip-full winbind

# virtual display (because its windows of course)
RUN apt-get install -y xvfb

# wine gets upset if you run it as root
RUN adduser --gecos "" --disabled-password --uid 1000 wine
WORKDIR /home/wine
USER wine

# setup wine
ENV WINEARCH win32
RUN winetricks win7
RUN xvfb-run winetricks --unattended vcrun6
RUN winetricks --unattended corefonts

RUN wget https://dl.winehq.org/wine/wine-mono/4.7.3/wine-mono-4.7.3.msi && \
    wine msiexec /i wine-mono-4.7.3.msi && \
    rm *.msi

RUN winetricks win7
RUN wineboot -r
RUN wine cmd.exe /c echo '%ProgramFiles%'

ENTRYPOINT [ "/usr/bin/wine", "cmd", "/c" ]
