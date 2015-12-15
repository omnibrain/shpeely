FROM node:0.12.9

ADD dist /dist
WORKDIR /dist

ENV NODE_ENV production
ENV PORT 80

EXPOSE 80

CMD ["node", "server/app.js"]
