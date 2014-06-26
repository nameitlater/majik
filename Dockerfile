FROM ubuntu
RUN apt-get update --fix-missing 
RUN apt-get install openssl=1.0.1f-1ubuntu2
RUN apt-get install -y curl
RUN curl -O http://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
RUN apt-get install -y unzip
RUN unzip dartsdk-linux-x64-release.zip
RUN mv dart-sdk /usr/lib/
RUN rm dartsdk-linux-x64-release.zip
RUN ln -s /usr/lib/dart-sdk/bin/dart /usr/bin/dart
RUN apt-get install -y haproxy

