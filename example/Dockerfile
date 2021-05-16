FROM node:16.1.0-alpine3.12

ENV NODE_ENV=production
RUN mkdir -p /app
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY app.js ./
CMD node app.js
