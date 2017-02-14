development:
	make dockerfile environment=development
	docker-compose build
	docker-compose up -d

test:
	make dockerfile environment=development
	docker-compose build
	docker-compose up -d
	docker-compose exec app rspec
	docker-compose down

production:
	make dockerfile environment=production
	docker build -t tily/mongo-s3-backup .
	docker push tily/mongo-s3-backup

dockerfile:
	docker run --rm -i -v $(PWD)/Dockerfile.erb:/Dockerfile.erb:ro \
		ruby:alpine erb -U -T 1 environment=${environment} \
		/Dockerfile.erb > Dockerfile
