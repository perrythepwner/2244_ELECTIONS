FROM gcr.io/paradigmxyz/ctf/base:latest

ENV HTTP_PORT=1337

RUN true \
    && curl -L https://foundry.paradigm.xyz | bash \
    && bash -c "source /root/.bashrc && foundryup" \
    && chmod 755 -R /root \
    && true

COPY ./config/98-start-gunicorn /startup

# install sass 
WORKDIR /opt
RUN curl -L https://github.com/sass/dart-sass/releases/download/1.57.1/dart-sass-1.57.1-linux-x64.tar.gz -o dart-sass-1.57.1-linux-x64.tar.gz \
    && tar -xvf dart-sass-1.57.1-linux-x64.tar.gz \
    && rm dart-sass-1.57.1-linux-x64.tar.gz

# Setup app
RUN mkdir -p /app

# Switch working environment
WORKDIR /app

COPY challenge .

RUN python3 -m pip install -r /app/requirements.txt 

ENV PYTHONPATH /usr/lib/python

EXPOSE 1337

COPY ./challenge/contracts /tmp/contracts

RUN true \
    && /opt/dart-sass/sass /app/static/css/main.scss /app/static/css/main.css \
    && cd /tmp \
    && /root/.foundry/bin/forge build --optimizer-runs 1 --via-ir --out /home/ctf/compiled \
    && rm -rf /tmp/contracts \
    && true
