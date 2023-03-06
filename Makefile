include .env

PWD = $(shell pwd)
.PHONY: certbot clone migrate 

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
	

clone:
	# Clonning SSO modules
	git clone git@github.com:kallabs/sso-api.git sso/api
	git clone git@github.com:kallabs/sso-web.git sso/web

	# Clonning Microblog modules
	git clone git@github.com:kallabs/microblog-api.git microblog/api

migra/apply:
	docker compose exec microblog-api alembic upgrade head 

migra/new:
	docker compose exec microblog-api alembic revision --autogenerate -m '$(msg)'

.PHONY: migra/idp
migra/idp:
	migrate -path ./sso/api/src/migrations -database "mysql://${MARIADB_SSO_USER}:${MARIADB_SSO_PASSWORD}@tcp(localhost:3307)/sso?parseTime=true" up

.PHOPY: migra/idp/new
migra/idp/new:
	migrate create -ext sql -dir $(PWD)/src/migrations -seq $(new)

test/target:
	echo '$(msg)'