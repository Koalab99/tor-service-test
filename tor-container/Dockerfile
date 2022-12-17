FROM debian:bullseye-slim

RUN apt-get update -y && apt-get install -y ca-certificates

COPY files /

RUN apt-get update -y && apt-get install -y tor deb.torproject.org-keyring

CMD ["/entrypoint.sh"]
