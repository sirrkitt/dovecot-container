FROM sirrkitt/dovecot-build-xapian as fts-xapian
FROM alpine:3.11
LABEL maintainer="Jacob Lemus Peschel <jacob@tlacuache.us>"

RUN	echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories &&\
	echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories &&\
	apk update --no-cache && \
	apk add -U --no-cache dovecot dovecot-submissiond dovecot-ldap dovecot-lmtpd dovecot-pigeonhole-plugin dovecot-pigeonhole-plugin-ldap rspamd-client@edge && \
	rm -r /etc/dovecot /etc/ssl/dovecot

RUN	addgroup -S vmail && \
	adduser -S -s /usr/sbin/nologin -G vmail -D -H vmail && \
	mkdir -p /config /mail /ssl /socket && \
	chown -R vmail:vmail /mail && \
	chown -R root:root /ssl /config /socket
COPY --from=fts-xapian /usr/lib/dovecot/lib21_fts_xapian_plugin.a /usr/lib/dovecot/lib21_fts_xapian_plugin.a
COPY --from=fts-xapian /usr/lib/dovecot/lib21_fts_xapian_plugin.la /usr/lib/dovecot/lib21_fts_xapian_plugin.la
COPY --from=fts-xapian /usr/lib/dovecot/lib21_fts_xapian_plugin.so /usr/lib/dovecot/lib21_fts_xapian_plugin.so

VOLUME ["/config", "/mail", "/ssl", "/socket"]

CMD [ "/usr/sbin/dovecot", "-F", "-c", "/config/dovecot.conf" ]

EXPOSE 143
EXPOSE 587
EXPOSE 993
