server-up:
	docker compose up server

compile:
	docker compose exec server bash -c "truffle compile"

migrate:
	docker compose exec server bash -c "truffle migrate --reset"

console:
	docker compose exec server bash -c "truffle console"

develop:
	docker compose exec server bash -c "truffle develop"

test:
	docker compose exec server bash -c "truffle test"
