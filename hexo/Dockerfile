FROM node:alpine

RUN \
    apk --update --no-progress add git openssh

WORKDIR /Hexo

RUN \
    npm install hexo-cli -g \
    && hexo init . \
    && npm install
        
VOLUME ["/Hexo/public", "/Hexo/source", "/Hexo/themes"]

COPY entrypoint.sh /Hexo/entrypoint.sh

ENTRYPOINT ["/Hexo/entrypoint.sh"]

CMD ["hexo", "generate", "--watch"]
