FROM alpine:3.12 AS build-fts-xapian
LABEL maintainer="jacob@tlacuache.us"
WORKDIR /build
#ADD https://github.com/grosjo/fts-xapian/archive/1.3.3.tar.gz /build/fts-xapian.tar.gz

RUN apk update --no-cache && apk add -U --no-cache \
	automake autoconf build-base libtool dovecot-dev xapian-core-dev icu-dev sqlite-dev
#        alpine-sdk build-base git dovecot-dev xapian-core-dev autoconf icu-dev automake libtool sqlite-dev

#RUN     tar -xzvf fts-xapian.tar.gz
#WORKDIR /build/fts-xapian-1.3.3
RUN	wget -qO- https://github.com/grosjo/fts-xapian/archive/1.4.6.tar.gz | tar xzvf - -C /build --strip-components=1 && \
	autoreconf -vi && \
	./configure --with-dovecot=/usr/lib/dovecot && \
	make DESTDIR=/opt prefix=/usr && \
	make DESTDIR=/opt prefix=/usr install


FROM alpine:3.12 AS final
COPY --from=build-fts-xapian /opt/usr /usr
RUN     echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories &&\
        echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories &&\
        apk update --no-cache && \
	apk add -U --no-cache dovecot dovecot-submissiond dovecot-ldap dovecot-lmtpd dovecot-pigeonhole-plugin dovecot-pigeonhole-plugin-ldap rspamd-client@edge xapian-core && \
        rm -r /etc/dovecot /etc/ssl/dovecot

RUN     addgroup -S vmail && \
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
