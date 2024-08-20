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

debug:
	docker compose exec server bash -c "truffle debug"

front-end:
	docker compose up front-end --force-recreate

mock-server:
	docker compose exec front-end bash -c "yarn start:mock"
