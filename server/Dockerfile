FROM node:18.16.0-slim

RUN mkdir -p /app
WORKDIR /app

COPY . /app

RUN npm install -g truffle
RUN npm install -g ganache-cli

CMD ["npm", "run", "start-dev"]
