PWD = $(shell pwd)
.PHONY: certbot

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
	