## Metacoin

### Como rodar o projeto e acessar o truffle console

Primeiramente, é necesssário o container com servidor ganache:

```
docker compose up metacoin
```


Depois é necessário entrar no bash do container:
```
docker compose exec metacoin bash
```

Dentro do container:

```
npm run truffle-console
migrate --reset
const metacoin = await MetaCoin.deployed();
```