FROM python:3.8-alpine

RUN mkdir /app

ADD . /app

WORKDIR /app


RUN apk update \
    && apk add --no-cache \
        python3-dev \
        build-base \
    && python3 -m ensurepip \
    && pip3 install --upgrade pip setuptools \
    && rm -r /usr/lib/python*/ensurepip \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && ln -sf pip3 /usr/bin/pip \
    && pip install --no-cache-dir -r requirements.txt

CMD ["python3", "app.py"]

