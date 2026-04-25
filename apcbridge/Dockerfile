ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8
WORKDIR /app

RUN apk add --no-cache jq curl

COPY rootfs/app/requirements.txt /app/requirements.txt
RUN apk add --no-cache --virtual .build-deps gcc musl-dev python3-dev libffi-dev openssl-dev \
 && pip3 install --no-cache-dir --break-system-packages -r /app/requirements.txt \
 && apk del .build-deps

COPY rootfs/app/ /app/
COPY run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT []
CMD ["/run.sh"]
