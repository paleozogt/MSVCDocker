ARG MSVC
FROM msvc:$MSVC

RUN apt-get update
RUN apt-get install -y curl

# java jdk
ADD get_oracle_jdk.sh get_oracle_jdk.sh
RUN ./get_oracle_jdk.sh && \
    vcwine jdk-8u181-windows-x64.exe /s && \
    rm -f get_oracle_jdk.sh *.exe
ENV WINEPATH="C:\\Program Files\\Java\\jdk1.8.0_181\\bin;$WINEPATH"
RUN vcwine java -version
RUN vcwine javac -version
