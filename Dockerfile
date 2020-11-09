FROM debian:stable-slim

LABEL author="Michael Wharmby <mtwharmby>"

RUN apt-get -q update
RUN apt-get -yq install bind9-dyndb-ldap tini
RUN apt-get -q clean

ADD ./container /container

EXPOSE 53/tcp
EXPOSE 53/udp

# Using tini to act to provide a basic init (see zombie process)
ENTRYPOINT [ "/container/init.sh" ]
CMD [ "/container/startup.sh" ]