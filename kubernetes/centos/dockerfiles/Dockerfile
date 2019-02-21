FROM centos:7

RUN  yum install -y epel-release \
     && yum install -y openssh-clients openssh-server pam_yubico

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
COPY ../../share/entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
