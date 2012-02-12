# encoding: UTF-8

require 'net/ftp'
require 'net/ftp/list'

module Siba::Destination
  module Ftp                 
    class Worker
      include Siba::LoggerPlug
      include Siba::FilePlug

      attr_accessor :host, :user, :password, :directory

      def initialize(host, user, password, directory)
        @host = host
        @host = ENV[Siba::Destination::Ftp::Init::DEFAULT_FTP_HOST_ENV_NAME] if host.nil?

        @user = user
        @password = password
        @directory = directory || "/"

        logger.info "Connecting to FTP server: #{host}"
        check_connection
      end

      def check_connection
        connect do |ftp|
          begin
            test_file ftp
            logger.debug("FTP connection verified")
          rescue
            logger.error "Failed to connect to FTP server: #{host}"
            raise
          end
        end
      end

      def user_host_and_dir
        str = "#{user.nil? ? "" : user + "@"}#{host}"
        str += ", dir: '#{directory}'" unless directory.nil? || directory == "/"
        str
      end

      def get_files_list(prefix)
        connect do |ftp|
          list = []
          ftp.list do |e|
            entry = Net::FTP::List.parse(e)

            # Ignore everything that's not a file (so symlinks, directories and devices etc.)
            next unless entry.file?
            next unless entry.basename =~ /^#{prefix}/

            list << [entry.basename, entry.mtime]
          end
          list
        end
      end

      def connect_and_put_file(path_to_file)
        connect do |ftp|
          put_file ftp, path_to_file
        end
      end

      def put_file(ftp, path_to_file)
        ftp.putbinaryfile path_to_file
      end

      def connect_and_get_file(remote_file_name, path_to_destination_file)
        connect do |ftp|
          get_file ftp, remote_file_name, path_to_destination_file
        end
      end

      def get_file(ftp, remote_file_name, path_to_destination_file)
        ftp.getbinaryfile remote_file_name, path_to_destination_file
      end
      
      def connect_and_delete_file(remote_file_name)
        connect do |ftp|
          delete_file ftp, remote_file_name
        end
      end

      def delete_file(ftp, remote_file_name)
        ftp.delete(remote_file_name)
      end

      def cd(ftp)
        directory.gsub! "\\","/"
        begin
          ftp.chdir(subdir) # try to change to full subdir first
        rescue
          directories = directory.split("/")
          directories.each do |subdir|
            ftp.mkdir(subdir) rescue nil
            ftp.chdir(subdir)
          end
        end
      end

      def test_file(ftp)
        src_file = Siba::TestFiles.prepare_test_file "test_ftp"
        put_file ftp, src_file
        src_to_check = Siba::TestFiles.generate_path "test_ftp_check"
        remote_file_name = File.basename(src_file)
        get_file ftp, remote_file_name, src_to_check
        raise Siba::Error, "Failed to get test file" unless File.file? src_to_check
        raise Siba::Error, "Error getting test files" unless FileUtils.compare_file(src_file, src_to_check)
        delete_file ftp, remote_file_name
      end

      def connect(&block)
        siba_file.run_this do
          ftp = nil
          begin
            ftp = Net::FTP.open(host, user, password)
            cd ftp
            block.call(ftp)
          ensure
            unless ftp.nil?              
              ftp.close rescue nil
            end
          end
        end
      end
    end
  end
end
