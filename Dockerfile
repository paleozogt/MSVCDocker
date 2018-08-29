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

# workaround bugs in wine's cmd that prevents msvc setup bat files from working
ADD dockertools/hack-vcvars.sh hack-vcvars.sh
USER root
RUN chown wine:wine *.sh
USER wine
RUN find .wine/drive_c -iname vc\*.bat | xargs -Ifile $HOME/hack-vcvars.sh "file" && \
    find .wine/drive_c -iname vs\*.bat | xargs -Ifile $HOME/hack-vcvars.sh "file"

# 64-bit linking has trouble finding cvtres, so help it out
RUN find .wine -iname x86_amd64 | xargs -Ifile cp "file/../cvtres.exe" "file"

# clean up
RUN rm -rf $HOME/snapshots

# reboot for luck
RUN winetricks win10
RUN wineboot -r

ADD dockertools/winecmd /usr/local/bin/winecmd
ENTRYPOINT [ "/usr/local/bin/winecmd" ]

# install cmake
ARG CMAKE_SERIES_VER=3.12
ARG CMAKE_VERS=$CMAKE_SERIES_VER.1
ARG CMAKE_WIN_PATH=C:\\Program\ Files\\CMake\\bin
RUN wget https://cmake.org/files/v$CMAKE_SERIES_VER/cmake-$CMAKE_VERS-win64-x64.zip -O cmake.zip && \
    cd ".wine/drive_c/Program Files" && \
    unzip $HOME/cmake.zip && \
    mv cmake-* CMake && \
    rm $HOME/cmake.zip

# install jom
ARG JOM_VERSION=1.1.2
ARG JOM_WIN_PATH=C:\\jom
RUN wget http://download.qt.io/official_releases/jom/jom.zip -O jom.zip && \
    cd ".wine/drive_c" && \
    mkdir jom && cd jom && \
    unzip $HOME/jom.zip && \
    rm $HOME/jom.zip

# gnuwin32 tools
ARG GNUWIN32_WIN_PATH=C:\\gnuwin32\\bin
RUN cd ".wine/drive_c" && \
    mkdir -p gnuwin32/bin

# install which
RUN wget http://downloads.sourceforge.net/gnuwin32/which-2.20-bin.zip -O which.zip && \
    cd ".wine/drive_c/gnuwin32" && \
    unzip $HOME/which.zip && \
    rm $HOME/which.zip

ENV WINEPATH $CMAKE_WIN_PATH;$JOM_WIN_PATH;$GNUWIN32_WIN_PATH

# test tools
RUN winecmd cmake --version
RUN winecmd jom /VERSION

# make sure we can compile
ADD test test
USER root
RUN chown -R wine:wine test
USER wine
RUN cd test && \
    winecmd cl helloworld.cpp && \
    winecmd helloworld.exe && \
    cd .. && rm -rf test

ENV WINEDEBUG=-all
