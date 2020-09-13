FROM sirrkitt/dovecot-build-xapian as fts-xapian
FROM alpine:3.12
LABEL maintainer="Jacob Lemus Peschel <jacob@tlacuache.us>"

COPY --from=fts-xapian /home/builder/packages/usr/x86_64/dovecot.apk /root/

RUN	echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories &&\
	echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories &&\
	apk update --no-cache && \
	apk add -U --no-cache dovecot dovecot-submissiond dovecot-ldap dovecot-lmtpd dovecot-pigeonhole-plugin dovecot-pigeonhole-plugin-ldap rspamd-client@edge && \
	apk add --allow-untrusted /root/dovecot.apk && \
	rm -r /etc/dovecot /etc/ssl/dovecot

RUN	addgroup -S vmail && \
	adduser -S -s /usr/sbin/nologin -G vmail -D -H vmail && \
	mkdir -p /config /data /ssl /socket /data/mail /data/sieve && \
	chown -R vmail:vmail /data && \
	chown -R root:root /ssl /config /socket

VOLUME ["/config", "/data", "/ssl", "/socket"]

CMD [ "/usr/sbin/dovecot", "-F", "-c", "/config/dovecot.conf" ]

EXPOSE 143
EXPOSE 587
EXPOSE 993
EXPOSE 4190
