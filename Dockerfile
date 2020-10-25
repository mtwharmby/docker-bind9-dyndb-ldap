FROM debian:stable
#FROM debian:stable-slim

ADD ./container /container

RUN apt-get -q update
RUN apt-get -yq install bind9-dyndb-ldap

EXPOSE 53

CMD [ "/container/startup.sh" ]