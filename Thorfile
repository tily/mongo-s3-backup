Bundler.require
require "logger"

class Default < Thor
  desc "backup", "backup mongo databases"
  option :list, :aliases => %w(l), :type => :boolean
  option :delete, :aliases => %w(d), :type => :string
  option :once, :type => :boolean
  option :now, :type => :string
  def backup
    if options[:list]
      backups.each {|b| puts b }
    elsif options[:delete]
      s3_object(options[:delete]).delete
    elsif options[:once]
      do_backup
    else
      trigger = Chrono::Trigger.new(ENV["BACKUP_SCHEDULE"]) { do_backup }
      trigger.run
    end
  end

  desc "restore", "restore mongo databases"
  def restore(backup)
    Dir.mktmpdir do |dir|
      File.write("#{dir}/dump.gz", s3_object(backup).get.body.read)
      system "cat #{dir}/dump.gz | mongorestore -vv --drop --archive --gzip -h #{ENV["MONGO_HOST"]}"
    end
  end

  no_commands do
    def do_backup
      logger.info("starting backup process")
      create_backup
      rotate_backups
      logger.info("backup process is done, and the current backups are: #{backups.join(", ")}")
    end

    def create_backup
      Dir.mktmpdir do |dir|
        logger.info("dumping databases")
        system "mongodump -h #{ENV["MONGO_HOST"]} --gzip --archive > #{dir}/dump.gz"
        logger.info("uploading the dump to s3")
        s3_object = s3_object(now.strftime("%Y%m%d.gz"))
        s3_object.upload_file(File.new("#{dir}/dump.gz"))
      end
    end

    def rotate_backups
      backups = []
      s3_objects.each do |object|
        backups << object
      end
      backups.sort_by! {|object| object.key }
      if backups.size > ENV["BACKUP_NUM"].to_i
        logger.info("doing backup rotation (backup number is #{ENV["BACKUP_NUM"]})")
        until backups.size == ENV["BACKUP_NUM"].to_i
          object = backups.shift
          logger.info("deleting #{object.key}")
          object.delete
        end
      end
    end

    def now
      @now ||= options[:now] ? Time.parse(options[:now]) : Time.now
    end

    def backups
      s3_objects.map do |object|
        object.key.gsub(/^#{ENV["S3_PREFIX"]}\//) { "" }
      end
    end

    def s3_objects
      s3_bucket.objects(prefix: "#{ENV["S3_PREFIX"]}")
    end

    def s3_object(path)
      s3_bucket.object([ENV["S3_PREFIX"], path].join("/"))
    end

    def s3
      @s3 ||= Aws::S3::Resource.new
    end

    def s3_bucket
      @s3_bucket ||= s3.bucket(ENV["S3_BUCKET"])
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
