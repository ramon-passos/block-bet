server:
	docker compose up server

build:
	docker compose exec server bash -c "truffle build"

migrate:
	docker compose exec server bash -c "truffle migrate --reset"

console:
	docker compose exec server bash -c "truffle console"

