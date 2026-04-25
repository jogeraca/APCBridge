FROM python:3.12-alpine

WORKDIR /app

COPY apcbridge/rootfs/app/requirements.txt .
RUN apk add --no-cache --virtual .build-deps gcc musl-dev python3-dev libffi-dev openssl-dev \
 && pip install --no-cache-dir -r requirements.txt \
 && apk del .build-deps

COPY apcbridge/rootfs/app/ ./

CMD ["python3", "main.py"]
