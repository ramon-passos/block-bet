# block-bet

## Business Model Canvas: [BMC Link](https://www.canva.com/design/DAGBaQGA1xA/xKYAZAaZ9XhfqMiSRokO1Q/edit?utm_content=DAGBaQGA1xA&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

## Como rodar o projeto:

Primeiramente é necessário subir o servidor ganache:

```
docker compose up server
```

Para subir o console truffle:

```
docker compose exec server bash
```

Dentro do bash do container:
```
    truffle build
    truffle migrate --reset
    npm run truffle-console
```


