Bundler.require("default", "development")

RSpec.describe "mongo-s3-backup" do
  def s3
    @s3 ||= Aws::S3::Resource.new(region: "dummy", endpoint: ENV["S3_ENDPOINT"])
  end

  def cleanup_s3_bucket
    s3.bucket(ENV["S3_BUCKET"]).objects.each do |object|
      puts object.key
      object.delete
    end
  end

  before do
    ENV["BACKUP_SCHEDULE"] = "* 6 * * *"
    ENV["AWS_ACCESS_KEY_ID"] = "accesskeyid"
    ENV["AWS_SECRET_ACCESS_KEY"] = "secretaccesskey"
    ENV["MONGO_HOST"] = "mongo"
    ENV["S3_ENDPOINT"] = "http://s3:3000"
    ENV["S3_BUCKET"] = "fake"
    ENV["S3_PREFIX"] = "backup"
    ENV["BACKUP_NUM"] = "3"

    cleanup_s3_bucket
  end

  after do
    cleanup_s3_bucket
  end

  context "Backup" do
    context "Once" do
      it "backups" do
        system "bundle exec thor backup --once"
        expect(`bundle exec thor backup -l`.chomp).to eq(Time.now.strftime("%Y%m%d.gz"))
      end

      it "rotates backups" do
        1.upto(ENV["BACKUP_NUM"].to_i + 1) do |i|
          now = Time.now + (i-1) * 60 * 60 * 24
          system "bundle exec thor backup --once --now #{now.strftime("%Y%m%d")}"
          expect(`bundle exec thor backup -l`.split("\n").size).to be <= ENV["BACKUP_NUM"].to_i
        end
      end
    end

    context "List" do
      it "shows empty string when there are no backups" do
        expect(`bundle exec thor backup --list`).to eq("")
      end

      it "shows one backup when there are only one backup" do
        system "bundle exec thor backup --once"
        expect(`bundle exec thor backup -l`.chomp).to eq(Time.now.strftime("%Y%m%d.gz"))
      end

      it "shows multiple backups when there are multiple backups" do
        system "bundle exec thor backup --once"
        system "bundle exec thor backup --once --now #{(Time.now + 60 * 60 * 24).strftime("%Y%m%d")}"
        expect(`bundle exec thor backup -l`.chomp.split("\n")).to eq([
          Time.now.strftime("%Y%m%d.gz"),
          (Time.now + 60 * 60 * 24).strftime("%Y%m%d.gz"),
        ])
      end
    end

    context "Delete" do
      it "removes backup" do
        system "bundle exec thor backup --once"
        expect(`bundle exec thor backup -l`.chomp).to eq(Time.now.strftime("%Y%m%d.gz"))
        system "bundle exec thor backup -d #{Time.now.strftime("%Y%m%d.gz")}"
        expect(`bundle exec thor backup --list`).to eq("")
      end
    end

    context "Restore" do
      it "restores from backup" do
        client = Mongo::Client.new("mongodb://#{ENV["MONGO_HOST"]}/test")
        collection = client["collection"]

        collection.insert_one({"hello" => "world"})

        system "bundle exec thor backup --once"

        collection.delete_one({"hello" => "world"})
        expect(collection.find().to_a.size).to eq(0)

        system "bundle exec thor restore #{Time.now.strftime("%Y%m%d.gz")}"
        expect(collection.find().to_a.size).to eq(1)
        expect(collection.find().first["hello"]).to eq("world")
      end
    end
  end
end
