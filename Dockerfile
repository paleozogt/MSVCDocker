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
RUN apt-get install -y zip p7zip-full cabextract winbind dos2unix

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

# bring over the snapshots
ARG MSVC
ADD build/msvc$MSVC/snapshots snapshots
USER root
RUN chown -R wine:wine snapshots
USER wine

# import the snapshot files
RUN cd .wine/drive_c && \
    unzip $HOME/snapshots/CMP/files.zip

# import registry snapshot
RUN wine reg import $HOME/snapshots/SNAPSHOT-02/HKLM.reg

# vcwine
USER root
ADD dockertools/vcwine /usr/local/bin/vcwine
ADD dockertools/diffenv /usr/local/bin/diffenv
RUN diffenv /home/wine/snapshots/SNAPSHOT-02/env.txt /home/wine/snapshots/SNAPSHOT-02/vcvars64.txt /etc/vcvars
USER wine

# 64-bit linking has trouble finding cvtres, so help it out
RUN find .wine -iname x86_amd64 | xargs -Ifile cp "file/../cvtres.exe" "file"

# make a tools dir
RUN mkdir -p .wine/drive_c/tools/bin
ENV WINEPATH C:\\tools\\bin

# install cmake
ARG CMAKE_SERIES_VER=3.12
ARG CMAKE_VERS=$CMAKE_SERIES_VER.1
RUN wget https://cmake.org/files/v$CMAKE_SERIES_VER/cmake-$CMAKE_VERS-win64-x64.zip -O cmake.zip && \
    unzip $HOME/cmake.zip && \
    mv cmake-*/* .wine/drive_c/tools && \
    rm -rf cmake*

# install jom
RUN wget http://download.qt.io/official_releases/jom/jom.zip -O jom.zip && \
    unzip -d jom $HOME/jom.zip && \
    mv jom/jom.exe .wine/drive_c/tools/bin && \
    rm -rf jom*

# install which (for easy path debugging)
RUN wget http://downloads.sourceforge.net/gnuwin32/which-2.20-bin.zip -O which.zip && \
    cd ".wine/drive_c/tools" && \
    unzip $HOME/which.zip && \
    rm $HOME/which.zip

# test the tools
RUN vcwine cmake --version
RUN vcwine jom /VERSION
RUN vcwine which --version

# clean up
RUN rm -rf $HOME/snapshots

# reboot for luck
RUN winetricks win10
RUN wineboot -r

# make sure we can compile
ADD test test
USER root
RUN chown -R wine:wine test
USER wine
RUN cd test && \
    vcwine cl helloworld.cpp && \
    vcwine helloworld.exe && \
    cd .. && rm -rf test

ENV WINEDEBUG=-all

ENTRYPOINT [ "/usr/local/bin/vcwine" ]
