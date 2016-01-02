FROM node:0.12.9

ADD dist /dist
WORKDIR /dist

RUN npm install

ENV NODE_ENV production
ENV PORT 80
ENV SECURE_PORT 443

EXPOSE 80
EXPOSE 443

CMD ["node", "server/app.js"]
