FROM alpine:3.11

RUN apk --update add --no-cache rsync openssh-client py3-pip
RUN rm -rf /var/cache/apk/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
