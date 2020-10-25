FROM debian:stable-slim

LABEL author="Michael Wharmby <mtwharmby>"

RUN apt-get -q update
RUN apt-get -yq install bind9-dyndb-ldap
RUN apt-get -q clean

ADD ./container /container

EXPOSE 53

ENTRYPOINT [ "/container/startup.sh" ]