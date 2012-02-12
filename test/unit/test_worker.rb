# encoding: UTF-8

require 'helper/require_unit'
require 'siba-destination-ftp/init'

describe Siba::Destination::Ftp::Worker do
  before do                    
    @cls = Siba::Destination::Ftp::Worker
    @obj = @cls.new "host", nil, nil, nil
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

  it "should call check_connection" do
    @obj.check_connection
  end

  it "should call user_host_and_dir" do
    host = "myhost"
    user = "myuser"
    dir = "mydir"
    @obj = @cls.new host, nil, nil, nil
    str = @obj.user_host_and_dir
    str.must_include host
    str.wont_include "dir"

    @obj = @cls.new host, user, nil, nil
    @obj.user_host_and_dir.must_include user

    @obj = @cls.new host, user, nil, dir
    @obj.user_host_and_dir.must_include dir
  end

  it "should call connect_and_put_file" do
    @obj.connect_and_put_file "file"
  end

  it "should call connect" do
    @obj.connect
  end

  it "should call get_files_list" do
    @obj.get_files_list "prefix"
  end

  it "should call connect_and_get_file" do
    @obj.connect_and_get_file "file_name", "path_to_dest_file"
  end

  it "should call connect_and_delete_file" do
    @obj.connect_and_delete_file "file_name"
  end
end
