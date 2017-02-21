#!/usr/bin/env ruby

require 'json'
require 'netaddr'
require "getopt/std"

def usage
  printf("rb_user_s3 [-h] [-a] [-q] [-u <username>] [-e <email>]\n")
  printf("  -h  -> print this help\n")
  printf("  -u username\n")
  printf("  -e email -> assign this email to the created user\n")
  printf("  -q -> show only json output\n")
  exit 1
end

opt = Getopt::Std.getopts("he:u:aq")

usage if opt["h"]

riak_cs_ip = NetAddr::CIDR.create(`grep listener /etc/riak-cs/riak-cs.conf | grep -v "^#" | awk '{print $3;}' | cut -d ":" -f 1`.strip).ip

S3FILE="/etc/redborder/s3user.json"
CDOMAIN=File.open("/etc/redborder/cdomain").first.chomp

username = "redborder" if opt["u"].nil?
email    = "admin@#{CDOMAIN}" if opt["e"].nil?

#chef if we can create admin users:
anonymous_user_creation = `grep anonymous_user_creation /etc/riak-cs/riak-cs.conf | grep anonymous_user_creation | grep -v "^#" | grep "= on"`

if anonymous_user_creation==""
  printf "ERROR: the riak-cs doesn't allow create user with anonymous user\n"
  ret=1
else
  riak_cs_ip="127.0.0.1" if (riak_cs_ip.nil? or riak_cs_ip=="" or riak_cs_ip=="0.0.0.0")
  # New admin user creation
  printf "Creating username #{username} (#{email}) into riak-cs server (#{riak_cs_ip}):\n"
  out  = `curl -H 'Content-Type: application/json' -X POST http://#{riak_cs_ip}:8088/riak-cs/user --data '{"email":"#{email}", "name":"#{username}"}'`# 2>/dev/null`
  begin
    data = JSON.parse(out);
    f = File.new(S3FILE, "w")
    f.write(out)
    f.close
  rescue
    if out.include?("The specified email address has already been registered")
      e = "INFO: the username #{username} (#{email}) already exists into riak-cs\n"
      printf e
    else
      e = "ERROR: #{out}\n"
      printf e
      raise e
      ret=1
    end
  end
end
