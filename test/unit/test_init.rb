# encoding: UTF-8

require 'helper/require_unit'
require 'siba-destination-ftp/init'

# Unit test example
# 'rake' command runs unit tests
# 'guard' command will run unit tests automatically
describe Siba::Destination::Ftp do
  before do                    
    @cls = Siba::Destination::Ftp::Init
    @yml_path = File.expand_path('../yml', __FILE__)
  end

  it "siba should load plugin" do 
    options_hash = load_options "valid" 
    plugin = @cls.new options_hash
    plugin.must_be_instance_of Siba::Destination::Ftp::Init
    plugin.worker.must_be_instance_of Siba::Destination::Ftp::Worker

    plugin.worker.host.wont_be_nil
    plugin.worker.host.must_equal options_hash["host"]
    plugin.worker.user.wont_be_nil
    plugin.worker.user.must_equal options_hash["user"]
    plugin.worker.password.wont_be_nil
    plugin.worker.password.must_equal options_hash["password"]
    plugin.worker.directory.wont_be_nil
    plugin.worker.directory.must_equal options_hash["directory"]
    plugin.worker.passive.must_equal false
  end

  it "siba should load plugin with just host" do 
    @cls.new({"host" => "myhost"})
  end

  it "init should set passive mode" do 
    plugin = @cls.new({"host" => "myhost", "passive" => true})
    plugin.worker.passive.must_equal true
  end

  it "siba should get user and password from environment variables" do 
    begin
      env_user_prev = ENV[Siba::Destination::Ftp::Init::DEFAULT_FTP_USER_ENV_NAME]
      env_password_prev = ENV[Siba::Destination::Ftp::Init::DEFAULT_FTP_PASSWORD_ENV_NAME]
      user = "def user"
      password = "def password"
      ENV[Siba::Destination::Ftp::Init::DEFAULT_FTP_USER_ENV_NAME] = user
      ENV[Siba::Destination::Ftp::Init::DEFAULT_FTP_PASSWORD_ENV_NAME] = password
      plugin = @cls.new({"host" => "myhost"})
      plugin.worker.user.must_equal user
      plugin.worker.password.must_equal password
    ensure
      ENV[Siba::Destination::Ftp::Init::DEFAULT_FTP_USER_ENV_NAME] = env_user_prev
      ENV[Siba::Destination::Ftp::Init::DEFAULT_FTP_PASSWORD_ENV_NAME] = env_password_prev
    end
  end

  it "load should fail if no host" do 
    ->{@cls.new({})}.must_raise Siba::CheckError
  end

  it "should call backup" do
    @cls.new({"host"=>"testhost"}).backup "path_to_backup"
  end

  it "should call get_backups_list" do
    @cls.new({"host"=>"testhost"}).get_backups_list "backup_name"
  end

  it "should call restore" do
    @cls.new({"host"=>"testhost"}).restore "backup_name", "/dir"
  end
end
