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
RUN apt-get install -y zip p7zip-full cabextract winbind

# virtual display (because its windows of course)
RUN apt-get install -y xvfb

# wine gets upset if you run it as root
RUN adduser --gecos "" --disabled-password --uid 1000 wine
WORKDIR /home/wine
USER wine

# setup wine
ENV WINEARCH win64
RUN winetricks win10
RUN wget https://dl.winehq.org/wine/wine-mono/4.7.3/wine-mono-4.7.3.msi && \
    wine msiexec /i wine-mono-4.7.3.msi && \
    rm *.msi
RUN wineboot -r
RUN wine cmd.exe /c echo '%ProgramFiles%'

# bring over the snapshot
ARG MSVC
ADD build/msvc$MSVC/snapshots snapshots
USER root
RUN chown -R wine:wine snapshots
USER wine

# import the snapshot files
RUN cd .wine/drive_c && \
    unzip $HOME/snapshots/CMP/files.zip && \
    wine reg import $HOME/snapshots/SNAPSHOT-02/HKLM.reg

# workaround for bug in wine's cmd that breaks msvc setup bat files
# see https://bugs.winehq.org/show_bug.cgi?id=43337
RUN cd .wine/drive_c && \
    find . -iname vc\*.bat | xargs -Ifile cp "file" "file.orig" && \
    find . -iname vc\*.bat | xargs -Ifile sed -i.bak 's/\(.*%ProgramFiles(x86)%.*\)//g' file && \
    find . -iname vc\*.bat | xargs -Ifile sed -i.bak 's/.*if exist .* set/set/g' file && \
    find . -iname vc\*.bat.bak | xargs -Ifile rm "file"

# clean up
RUN rm -rf $HOME/snapshots

# reboot for luck
RUN winetricks win10
RUN wineboot -r

ADD dockertools/winecmd /usr/local/bin/winecmd
ENTRYPOINT [ "/usr/local/bin/winecmd" ]

# make sure we can compile
ADD test test
USER root
RUN chown -R wine:wine test
USER wine
RUN cd test && \
    winecmd cl helloworld.cpp && \
    winecmd helloworld.exe && \
    cd .. && rm -rf test
