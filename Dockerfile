FROM ubuntu:xenial
USER root
WORKDIR /root

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    software-properties-common \
    wget \
 && rm -rf /var/lib/apt/lists/*

# setup wine repo
RUN dpkg --add-architecture i386 && \
    wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \
    apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ && \
    rm *.key

# install wine
RUN apt-get update && apt-get install -y --install-recommends \
    winehq-stable \
 && rm -rf /var/lib/apt/lists/*

# install winetricks
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/local/bin/winetricks && \
    chmod +x /usr/local/bin/winetricks

# tools used by wine
RUN apt-get update && apt-get install -y \
    cabextract \
    dos2unix \
    p7zip-full \
    winbind \
    zip \
 && rm -rf /var/lib/apt/lists/*

# virtual display (because its windows of course)
RUN apt-get update && apt-get install -y \
    xvfb \
 && rm -rf /var/lib/apt/lists/*

# setup wine
ENV WINEARCH win64
ENV WINEPREFIX=/opt/windows
RUN winetricks win10
RUN wget https://dl.winehq.org/wine/wine-mono/4.7.3/wine-mono-4.7.3.msi && \
    wine msiexec /i wine-mono-4.7.3.msi && \
    rm *.msi
RUN wineboot -r
RUN wine cmd.exe /c echo '%ProgramFiles%'

# bring over the snapshots
ARG MSVC
ADD build/msvc$MSVC/snapshots snapshots

# import the snapshot files
RUN cd $WINEPREFIX/drive_c && \
    unzip -n $HOME/snapshots/CMP/files.zip

# import registry snapshot
RUN wine reg import $HOME/snapshots/SNAPSHOT-02/HKLM.reg

# import environment snapshot
ADD dockertools/diffenv /usr/local/bin/diffenv
RUN diffenv $HOME/snapshots/SNAPSHOT-01/env.txt $HOME/snapshots/SNAPSHOT-02/vcvars32.txt /etc/vcvars32
RUN diffenv $HOME/snapshots/SNAPSHOT-01/env.txt $HOME/snapshots/SNAPSHOT-02/vcvars64.txt /etc/vcvars64

# 64-bit linking has trouble finding cvtres, so help it out
RUN find $WINEPREFIX -iname x86_amd64 | xargs -Ifile cp "file/../cvtres.exe" "file"

# workaround bugs in wine's cmd that prevents msvc setup bat files from working
ADD dockertools/hackvcvars hackvcvars
RUN find $WINEPREFIX/drive_c -iname v[cs]\*.bat | xargs -Ifile $HOME/hackvcvars "file" && \
    find $WINEPREFIX/drive_c -iname win\*.bat | xargs -Ifile $HOME/hackvcvars "file" && \
    rm hackvcvars

# vcwine
ENV MSVCARCH=64
ADD dockertools/vcwine /usr/local/bin/vcwine

# make a tools dir
RUN mkdir -p $WINEPREFIX/drive_c/tools/bin
ENV WINEPATH C:\\tools\\bin

# install cmake
ARG CMAKE_SERIES_VER=3.12
ARG CMAKE_VERS=$CMAKE_SERIES_VER.1
RUN wget https://cmake.org/files/v$CMAKE_SERIES_VER/cmake-$CMAKE_VERS-win64-x64.zip -O cmake.zip && \
    unzip $HOME/cmake.zip && \
    mv cmake-*/* $WINEPREFIX/drive_c/tools && \
    rm -rf cmake*
RUN vcwine cmake --version

# install jom
RUN wget http://download.qt.io/official_releases/jom/jom.zip -O jom.zip && \
    unzip -d jom $HOME/jom.zip && \
    mv jom/jom.exe $WINEPREFIX/drive_c/tools/bin && \
    rm -rf jom*
RUN vcwine jom /VERSION

# install which (for easy path debugging)
RUN wget http://downloads.sourceforge.net/gnuwin32/which-2.20-bin.zip -O which.zip && \
    cd "$WINEPREFIX/drive_c/tools" && \
    unzip $HOME/which.zip && \
    rm $HOME/which.zip
RUN vcwine which --version

# clean up
RUN rm -rf $HOME/snapshots

# reboot for luck
RUN winetricks win10
RUN wineboot -r

# make sure we can compile
ADD test test
RUN cd test && \
    vcwine cl helloworld.cpp && \
    vcwine helloworld.exe && \
    cd .. && rm -rf test

# turn off wine's verbose logging
ENV WINEDEBUG=-all

ENTRYPOINT [ "/usr/local/bin/vcwine" ]
