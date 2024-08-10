FROM node:18.12.0-slim

RUN mkdir -p /frontend

WORKDIR /frontend

COPY . /frontend

RUN yarn

EXPOSE 3000
EXPOSE 8080
EXPOSE 24678

CMD ["yarn", "dev"]
