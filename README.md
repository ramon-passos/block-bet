# block-bet

## Business Model Canvas: [BMC Link](https://www.canva.com/design/DAGBaQGA1xA/xKYAZAaZ9XhfqMiSRokO1Q/edit?utm_content=DAGBaQGA1xA&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

## Como rodar o projeto

Primeiramente é necessário subir o servidor ganache:

```
make server-up
```

Depois, é necessário compilar o contrato:

```
make compile
```

Migrar o contrato para o servidor ganache:

```
make migrate
```

Rodar o console:

```
make console
```

Carregue o contrato em uma constante:
```
const contract = await BlockBet.deployed()
```

Para criar uma aposta, você deve chamar a função `createBet` na instância.
E possivel passar um endereco de um apostador no momento de criar a bet:

```
    let accounts = await web3.eth.getAccounts();
    contract.createBet(1, 'teste de aposta nada a ver', {from: accounts[0], value: 100})
```

Para ver as apostas criadas, chame a função `getBets`:

```
    contract.getBets()
```

Pegue o uuid da aposta e armazene em uma constante:

```
    const uuid = 'uuid da aposta criada'
```

Para desafiar uma aposta, chame a função `challengeBet`:

```
contract.challengeBet(uuid, {from: accounts[1], value: 100})
```

Para votar no vencedor de uma aposta, chame a função `voteWinner`:

```
contract.voteWinner(uuid, 1, {from: accounts[0]})
```

Se os votos forem iguais, automaticamente o contrato finaliza a aposta e distribui o valor para o vencedor.
Do contrário, o contrato fica em estado de auditoria.

Para auditar uma aposta, chame a função `auditBet`:

```
contract.auditBet(uuid, 2, {from: accounts[3]})
```
