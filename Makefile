development:
	docker run --rm -i -v $(PWD)/Dockerfile.erb:/Dockerfile.erb:ro \
		ruby:alpine erb -U -T 1 environment=development \
		/Dockerfile.erb > Dockerfile
	docker-compose build
	docker-compose up -d
