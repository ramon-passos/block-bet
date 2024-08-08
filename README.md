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

Carregue o contrato em uma constante:
```
    const BlockBet = artifacts.require('BlockBet');
```

Crie uma nova instância do contrato:
```
    let instance = await BlockBet.new();
```

Para criar uma aposta, você deve chamar a função `createBet` na instância:
```
    instance.createBet(1, 1, 'teste de aposta nada a ver')
```

E possivel passar um endereco de um apostador no momento de criar a bet:
```
    let accounts = await web3.eth.getAccounts();
    instance.createBet(1, 1, 'teste de aposta nada a ver', {from: accounts[0]})
```

Para ver as apostas criadas, chame a função `getBets`:
```
    instance.getBets()
```

Para desafiar uma aposta, chame a função `challengeBet`:
```
instance.challengeBet('uuid', 2, {from: accounts[1]})
```

Para votar no vencedor de uma aposta, chame a função `voteWinner`:
```
instance.voteWinner('uuid', 1, {from: accounts[0]})
```
Para finalizar uma aposta, chame a função `finalizeBet`:
```
instance.finalizeBet('uuid')
```