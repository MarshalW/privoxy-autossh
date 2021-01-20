FROM alpine

RUN set -eux && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN \
    apk --no-cache add \
        tini \
        autossh
    
COPY ./autossh/run.sh /
RUN chmod +x /run.sh

RUN mkdir /root/.ssh
COPY ./config/config /root/.ssh/
COPY ./config/id_rsa* /root/.ssh/
RUN chmod 600 /root/.ssh/config

ENTRYPOINT [ "tini","--"] 
CMD ["/run.sh"]