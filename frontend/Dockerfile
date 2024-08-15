FROM node:18.12.0-slim

RUN mkdir -p /frontend

WORKDIR /frontend

COPY . /frontend

RUN yarn

CMD ["yarn", "dev"]
