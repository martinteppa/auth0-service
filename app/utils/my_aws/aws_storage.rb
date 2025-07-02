require 'aws-sdk'

module MyAws
  class AwsStorage

    def initialize
      @client = aws_s3_client
    end

    def upload_file(file, s3_key:)
      client.put_object(
        bucket: BUCKET,
        key: s3_key,
        body: file
      )
    end

    def delete_file(s3_key:)
      client.delete_object(
        bucket: BUCKET,
        key: s3_key
      )
    end

    def download_file(s3_key:)
      tmpfile = Tempfile.new(File.basename(s3_key))
      client.get_object(bucket: BUCKET, key: s3_key) do |chunk|
        tmpfile.write(chunk)
      end
      tmpfile.rewind
      tmpfile
    end

    private

    def aws_s3_client
      Aws::S3::Client.new(
        region: REGION,
        access_key_id: ACCESS_KEY_ID,
        secret_access_key: SECRET_ACCESS_KEY
      )
    end

    attr_reader :client
  end
end
