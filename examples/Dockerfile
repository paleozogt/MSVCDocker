ARG MSVC
FROM msvc:$MSVC

RUN apt-get update && apt-get install -y \
    curl \
 && rm -rf /var/lib/apt/lists/*

# java jdk in wine
ADD get_oracle_jdk.sh get_oracle_jdk.sh
RUN ./get_oracle_jdk.sh && \
    vcwine jdk-8u202-windows-x64.exe /s && \
    rm -f get_oracle_jdk.sh *.exe
ENV WINEPATH="C:\\Program Files\\Java\\jdk1.8.0_202\\bin;$WINEPATH"
RUN vcwine java -version
RUN vcwine javac -version

# python in wine
RUN wget https://www.python.org/ftp/python/2.7.12/python-2.7.12.amd64.msi && \
    vcwine msiexec /i python-2.7.12.amd64.msi /passive /norestart ADDLOCAL=ALL && \
    rm *.msi
ENV WINEPATH="C:\\Python27\\;C:\\Python27\\Scripts;$WINEPATH"
RUN vcwine python -m ensurepip && \
    vcwine python -m pip install --upgrade pip && \
    vcwine pip install virtualenv
RUN vcwine python --version
RUN vcwine pip --version

# tcl in wine
RUN wget https://downloads.activestate.com/ActiveTcl/releases/8.6.8.0/ActiveTcl-8.6.8.0-MSWin32-x64.exe && \
    WINEDEBUG= vcwine ActiveTcl-8.6.8.0-MSWin32-x64.exe /exenoui /exenoupdates /quiet /norestart && \
    rm *.exe
ENV WINEPATH="C:\\ActiveTcl\\bin;$WINEPATH"
RUN echo 'puts $tcl_version' > test.tcl && \
    vcwine tclsh test.tcl && \
    rm *.tcl
