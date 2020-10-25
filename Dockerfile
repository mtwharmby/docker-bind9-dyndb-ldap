FROM debian:stable
#FROM debian:stable-slim

RUN apt-get -q update
RUN apt-get -yq install bind9-dyndb-ldap
RUN apt-get -q clean

ADD ./container /container

EXPOSE 53

CMD [ "/container/startup.sh" ]