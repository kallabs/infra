include .env

PWD = $(shell pwd)
RP_APP_DIR=./reading_plan_infra/reading_plan
RP_SCRAPE_DIR=./reading_plan_infra/scraping
RP_MIGRATIONS_DIR = ${RP_APP_DIR}/migrations
DOT_ENV_PATH = $(abspath .env)

$(info .env file path ${DOT_ENV_PATH})
$(eval export $(shell sed -ne 's/ *#.*$$//; /./ s/=.*$$// p' .env))

.PHONY=rp/run-tg
rp/run-tg:
	cd ${RP_APP_DIR} && env $$(cat ${DOT_ENV_PATH} | sed 's/#.*//g' | xargs ) cargo run --bin telegram

.PHONY=rp/run-web
rp/run-web:
	cd ${RP_APP_DIR} && env $$(cat ${DOT_ENV_PATH} | sed 's/#.*//g' | xargs ) cargo run --bin web

.PHONY=rp/migrate
rp/migrate: 
	sqlx migrate run --source ${RP_MIGRATIONS_DIR} --database-url postgres://$(PG_USER):$(PG_PASSWORD)@localhost:${PG_PORT}/$(PG_RP_DATABASE)

.PHONY=rp/scrape
rp/scrape:
	cd ${RP_SCRAPE_DIR} && env $$(cat ${DOT_ENV_PATH} | sed 's/#.*//g' | xargs ) python3 -m scrapy crawl bibleonline

.PHONY=certbot
certbot:
	docker run -v $(PWD)/letsencrypt:/etc/letsencrypt -it certbot/certbot \
		certonly \
		--preferred-challenges dns \
		--manual \
		--email alexsure.k@gmail.com \
		--agree-tos \
		--no-eff-email \
		-d *.akarpovich.online \
		-d akarpovich.online
	
.PHONY=clone
clone:
	# Clonning IdP modules
	git clone git@github.com:kallabs/idp-api.git idp-api
	git clone git@github.com:kallabs/idp-web.git idp-web

	# Clonning Microblog modules
	# git clone git@github.com:kallabs/microblog-api.git microblog/api

migra/apply:
	docker compose exec microblog-api alembic upgrade head 

migra/new:
	docker compose exec microblog-api alembic revision --autogenerate -m '$(msg)'

.PHONY: idp/migrate
idp/migrate:
	docker run -v ./idp-api/src/migrations:/migrations --network host migrate/migrate -path=/migrations/ -database "postgres://${PG_USER}:${PG_PASSWORD}@localhost:${PG_PORT}/${PG_IDP_DATABASE}?sslmode=disable" up 2

.PHOPY: idp/new_migration
idp/new_migration:
	docker run -v ./idp-api/src/migrations:/migrations --network host migrate/migrate create -ext sql -dir /migrations -seq $(new)


.PHONY: gen-keypair
gen-keypair:
	ssh-keygen -t rsa -P "" -b 2048 -m PEM -f jwtRS256.key
	ssh-keygen -e -m pkcs8 -f kallabs_rsa > kallabs_rsa.pub