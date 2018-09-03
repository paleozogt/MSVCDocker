FROM ubuntu:xenial
USER root
WORKDIR /root

# install basics
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
    winehq-stable=4.0~xenial \
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
ENV WINEPREFIX=/opt/win
RUN winetricks win10
RUN wineboot -r
RUN wine cmd.exe /c echo '%ProgramFiles%'

# vc redist 2010
RUN wget https://download.microsoft.com/download/5/B/C/5BC5DBB3-652D-4DCE-B14A-475AB85EEF6E/vcredist_x86.exe && \
    xvfb-run wine vcredist_x86.exe /Q /norestart && \
    rm *.exe
RUN wget https://download.microsoft.com/download/3/2/2/3224B87F-CFA0-4E70-BDA3-3DE650EFEBA5/vcredist_x64.exe && \
    xvfb-run wine vcredist_x64.exe /Q /norestart && \
    rm *.exe

# vc redist 2013
RUN wget https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe && \
    xvfb-run wine vcredist_x86.exe /Q /norestart && \
    rm *.exe
RUN wget https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe && \
    xvfb-run wine vcredist_x64.exe /Q /norestart && \
    rm *.exe
RUN wineboot -r

# install dotnet
# winetricks' dotnet installers don't work well on 64-bit, 
# so we employ a well-known workaround: https://www.reddit.com/r/wine_gaming/comments/8r6low/guide_how_to_install_net_45_on_64bit_prefixes/
RUN winetricks winxp
RUN wget 'https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe' && \
    wine64 dotNetFx40_Full_x86_x64.exe /q && wineserver -k && \
    rm *.exe
RUN winetricks win7
ENV WINEDLLOVERRIDES=mscoree=n
RUN wget 'https://download.microsoft.com/download/9/E/6/9E63300C-0941-4B45-A0EC-0008F96DD480/NDP471-KB4033342-x86-x64-AllOS-ENU.exe' && \
    wine64 NDP471-KB4033342-x86-x64-AllOS-ENU.exe /q && wineserver -k && \
    rm *.exe
RUN winetricks win10

# bring over the snapshots
ARG MSVC
ADD build/msvc$MSVC/snapshots snapshots

# import the snapshot files
RUN cd $WINEPREFIX/drive_c && \
    unzip -n $HOME/snapshots/CMP/files.zip

# import registry snapshot
RUN wine reg import $HOME/snapshots/SNAPSHOT-02/HKLM.reg

# import environment snapshot
ADD dockertools/diffenv diffenv
ADD dockertools/make-vcclang-vars make-vcclang-vars
RUN mkdir /etc/vcwine /etc/vcclang
RUN ./diffenv $HOME/snapshots/SNAPSHOT-01/env.txt $HOME/snapshots/SNAPSHOT-02/vcvars32.txt /etc/vcwine/vcvars32 && \
    ./make-vcclang-vars /etc/vcwine/vcvars32 /etc/vcclang/vcvars32
RUN ./diffenv $HOME/snapshots/SNAPSHOT-01/env.txt $HOME/snapshots/SNAPSHOT-02/vcvars64.txt /etc/vcwine/vcvars64 && \
    ./make-vcclang-vars /etc/vcwine/vcvars64 /etc/vcclang/vcvars64
RUN rm diffenv make-vcclang-vars

# 64-bit linking has trouble finding cvtres, so help it out
RUN find $WINEPREFIX -iname x86_amd64 | xargs -Ifile cp "file/../cvtres.exe" "file"

# workaround bugs in wine's cmd that prevents msvc setup bat files from working
ADD dockertools/hackvcvars hackvcvars
RUN find $WINEPREFIX/drive_c -iname v[cs]\*.bat | xargs -Ifile $HOME/hackvcvars "file" && \
    find $WINEPREFIX/drive_c -iname win\*.bat | xargs -Ifile $HOME/hackvcvars "file" && \
    rm hackvcvars

# fix inconsistent casing in filenames
RUN find $WINEPREFIX -name Include -execdir mv Include include \; || \
    find $WINEPREFIX -name Lib -execdir mv Lib lib \; || \
    find $WINEPREFIX -name \*.Lib -execdir rename 'y/A-Z/a-z/' {} \;

# vcwine
ENV MSVCARCH=64
ADD dockertools/vcwine /usr/local/bin/vcwine
ADD dockertools/clang-cl /usr/local/bin/clang-cl
ADD dockertools/lld-link /usr/local/bin/lld-link

# make a tools dir
RUN mkdir -p $WINEPREFIX/drive_c/tools/bin
ENV WINEPATH C:\\tools\\bin

# install clang on host (for clang-cl)
ENV CLANG_HOME=/opt/bin
ENV CC=clang-cl
ENV CXX=clang-cl
RUN wget https://releases.llvm.org/7.0.0/clang+llvm-7.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz && \
    tar xvf *.tar.xz && \
    cp -r clang*/* /opt && \
    rm -rf clang*
RUN clang-cl --version
RUN lld-link --version

# install make on host
RUN apt-get update && apt-get install -y \
    make \
 && rm -rf /var/lib/apt/lists/*

# install cmake on host
ARG CMAKE_SERIES_VER=3.12
ARG CMAKE_VERS=$CMAKE_SERIES_VER.1
RUN wget https://cmake.org/files/v$CMAKE_SERIES_VER/cmake-$CMAKE_VERS-Linux-x86_64.sh -O cmake.sh && \
    sh $HOME/cmake.sh --prefix=/usr/local --skip-license && \
    rm -rf $HOME/cmake*
RUN cmake --version

# install cmake in wine
RUN wget https://cmake.org/files/v$CMAKE_SERIES_VER/cmake-$CMAKE_VERS-win64-x64.zip -O cmake.zip && \
    unzip $HOME/cmake.zip && \
    mv cmake-*/* $WINEPREFIX/drive_c/tools && \
    rm -rf cmake*
RUN vcwine cmake --version

# install jom in wine
RUN wget http://download.qt.io/official_releases/jom/jom.zip -O jom.zip && \
    unzip -d jom $HOME/jom.zip && \
    mv jom/jom.exe $WINEPREFIX/drive_c/tools/bin && \
    rm -rf jom*
RUN vcwine jom /VERSION

# install which in wine (for easy path debugging)
RUN wget http://downloads.sourceforge.net/gnuwin32/which-2.20-bin.zip -O which.zip && \
    cd "$WINEPREFIX/drive_c/tools" && \
    unzip $HOME/which.zip && \
    rm $HOME/which.zip
RUN vcwine which --version

# clean up
RUN rm -rf $HOME/snapshots

# reboot for luck
RUN wineboot -r

# get _MSC_VER for use with clang-cl
ADD dockertools/msc_ver.cpp msc_ver.cpp
RUN vcwine cl msc_ver.cpp && \
    echo -n "MSC_VER=`vcwine msc_ver.exe`" >> /etc/vcclang/vcvars32  && \
    echo -n "MSC_VER=`vcwine msc_ver.exe`" >> /etc/vcclang/vcvars64  && \
    rm *.cpp

# make sure we can compile with MSVC
ADD test test
RUN cd test && \
    vcwine cl helloworld.cpp && \
    vcwine helloworld.exe && \
    cd .. && rm -rf test

# make sure we can compile with clang-cl
ADD test test
RUN cd test && \
    clang-cl helloworld.cpp && \
    vcwine helloworld.exe && \
    cd .. && rm -rf test

# turn off wine's verbose logging
ENV WINEDEBUG=-all

ADD dockertools/vcentrypoint /usr/local/bin/vcentrypoint
ENTRYPOINT [ "/usr/local/bin/vcentrypoint" ]
