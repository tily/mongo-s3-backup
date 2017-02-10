docker build -t mongo-s3-backup .
docker run --entrypoint bash --network prgrphstokyo_default --link mongo:mongo -ti --rm --name mongo-s3-backup -v $(pwd):/usr/local/app mongo-s3-backup
