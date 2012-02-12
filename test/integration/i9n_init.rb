# encoding: UTF-8

require 'helper/require_integration'
require 'siba-destination-ftp/init'

# Integration test example
# 'rake test:i9n' command runs integration tests
describe Siba::Destination::Ftp::Init do
  before do
    @test_dir = "siba_ftp_test/subdir"
    @cls = Siba::Destination::Ftp::Init

    host_env = @cls::DEFAULT_FTP_HOST_ENV_NAME
    user_env = @cls::DEFAULT_FTP_USER_ENV_NAME
    password_env = @cls::DEFAULT_FTP_PASSWORD_ENV_NAME

    @host = ENV[host_env]
    @user = ENV[user_env]
    @password = ENV[password_env]

    msg = "environment variable needs to be set in order to run integration tests"
    flunk "#{host_env} #{msg}" unless @host
    flunk "#{user_env} #{msg}" unless @user
    flunk "#{password_env} #{msg}" unless @password
  end

  it "should backup and restore" do
    ftp = @cls.new({"host" => @host, "directory"=>@test_dir})
    src_backup = prepare_test_file "ftp_test"

    # backup
    ftp.backup src_backup
    file_name = File.basename src_backup

    # get list
    list = ftp.get_backups_list file_name
    list.size.must_equal 1
    item = list[0]
    item[0].must_equal file_name
    item[1].must_be_instance_of Time

    # restore
    dest_backup_dir = mkdir_in_tmp_dir "restored_backup_dir"
    dest_backup = File.join dest_backup_dir, file_name
    ftp.restore file_name, dest_backup_dir

    dest_backup.wont_equal src_backup
    FileUtils.compare_file(src_backup, dest_backup).must_equal true

    # remove test file
    ftp.worker.connect_and_delete_file file_name
  end
  
end
