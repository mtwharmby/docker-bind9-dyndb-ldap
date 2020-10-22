FROM debian:stable

RUN apt-get -q update
RUN apt-get -yq install bind9-dyndb-ldap

EXPOSE 53

CMD ["bash"]