FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install -y openssh-server libpam-yubico

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
