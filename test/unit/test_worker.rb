# encoding: UTF-8

require 'helper/require_unit'
require 'siba-destination-ftp/init'

describe Siba::Destination::Ftp::Worker do
  before do                    
    @cls = Siba::Destination::Ftp::Worker
  end

  it "should init" do 
    host = "host"
    user = "testuser"
    password = "testpassword"
    directory = "testdirectory"

    worker = @cls.new host, user, password, directory
    worker.host.must_equal host
    worker.user.must_equal user
    worker.password.must_equal password
    worker.directory.must_equal directory 
  end
end
