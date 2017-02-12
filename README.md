# mongo-s3-backup

Script to backup mongo databases to s3 bucket everyday.

## Usage

Set environment variables:

```
AWS_ACCESS_KEY_ID=<YOUR ACCESS KEY ID>
AWS_SECRET_ACCESS_KEY=<YOUR SECRET ACCESS KEY>
AWS_REGION=ap-northeast-1
S3_BUCKET=your-backup-bucket
S3_PREFIX=backups
MONGO_HOST=localhost
BACKUP_NUM=7
BACKUP_SCHEDULE='0 6 * * *'
```

Backup periodically according to BACKUP_SCHEDULE:

```
$ bundle exec thor backup
```

Do backup just once:

```
$ bundle exec thor backup --once
```

List backups:

```
$ bundle exec thor backup -l
```

Restore from backup:

```
$ bundle exec thor restore 20170210.gz
```

Delete backup:

```
$ bundle exec thor backup -d 20170210.gz
```

## How to develop

You can setup and login to development environment as follows:

```
$ make development
$ docker-compose exec app bash
```

## Links

* [Makefile の書き方 \(C 言語\) — WTOPIA v1\.0 documentation](http://www.ie.u-ryukyu.ac.jp/~e085739/c.makefile.tuts.html)
* [Install MongoDB Community Edition on Ubuntu — MongoDB Manual 3\.4](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/)
* [mongorestore — MongoDB Manual 3\.4](https://docs.mongodb.com/manual/reference/program/mongorestore/#examples)
* [12\.04 \- lsb\_release command not found \- Ask Ubuntu](http://askubuntu.com/questions/146226/lsb-release-command-not-found)
