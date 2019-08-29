FROM node:10.16.3-alpine

ENV NODE_ENV=production
WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install

COPY app.js ./

CMD ["node", "app.js"]
