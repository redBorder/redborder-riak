#!/usr/bin/env ruby

CDOMAIN=File.open("/etc/redborder/cdomain").first.chomp
SSL_CERT_FILE = "SSL_CERT_FILE=#{ENV['SSL_CERT_FILE'].nil? ? '/etc/nginx/ssl/s3.crt' : ENV['SSL_CERT_FILE']}"


#buckets=["redborder", "rbookshelf"]
buckets=["redborder"]

buckets.each do |b|
  # Check if bucket is created
  bucket_found=`#{SSL_CERT_FILE} s3cmd ls 2>/dev/null| grep -q "s3://#{b}$"; [ $? -eq 0 ] && echo -n 1`
  # Create new bucket if not created yet
  out=`#{SSL_CERT_FILE} s3cmd -c /root/.s3cfg mb s3://#{b}`.strip if bucket_found!="1"

  # If bucket created successfully...
  if out=="Bucket 's3://#{b}/' created" or bucket_found=="1"
    # Create an account for the user
    `curl -H 'Content-Type: application/json' -X POST http://s3.#{CDOMAIN}:8088/riak-cs/user --data '{"email":"#{b}@#{CDOMAIN}", "name":"#{b}"}'`
    # Grant privileges
    `#{SSL_CERT_FILE} s3cmd --config /root/.s3cfg --acl-grant=all:#{b}@#{CDOMAIN} setacl s3://#{b}`

    printf "INFO: #{b} bucket created successfully\n"
  else
    printf "ERROR: #{out}\n"
    ret=1
  end

end
