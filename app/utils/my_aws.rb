module MyAws
  ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID'].freeze
  SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY'].freeze
  REGION = 'sa-east-1'.freeze
  BUCKET = ENV['AWS_S3_BUCKET'].freeze
end
