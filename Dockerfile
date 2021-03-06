FROM alpine:3.11

RUN apk --update add --no-cache bash rsync openssh-client py3-pip gnupg
RUN rm -rf /var/cache/apk/*

COPY secrets /secrets
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
