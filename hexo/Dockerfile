FROM alpine:latest

RUN apk --update --no-progress add yarn git openssh

WORKDIR /Hexo

RUN yarn global add hexo-cli \
    && hexo init . \
    && yarn install
        
VOLUME ["/Hexo/public", "/Hexo/source", "/Hexo/themes"]

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["hexo", "generate", "--watch"]
