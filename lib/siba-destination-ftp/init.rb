# encoding: UTF-8

require 'siba-destination-ftp/worker'

module Siba::Destination
  module Ftp                 
    class Init                 
      include Siba::LoggerPlug
      attr_accessor :worker

      DEFAULT_FTP_HOST_ENV_NAME = "SIBA_FTP_HOST"
      DEFAULT_FTP_USER_ENV_NAME = "SIBA_FTP_USER"
      DEFAULT_FTP_PASSWORD_ENV_NAME = "SIBA_FTP_PASSWORD"

      def initialize(options)
        host = Siba::SibaCheck.options_string options, "host"
        user = Siba::SibaCheck.options_string options, "user", true, ENV[DEFAULT_FTP_USER_ENV_NAME]
        password = Siba::SibaCheck.options_string options, "password", true, ENV[DEFAULT_FTP_PASSWORD_ENV_NAME]
        directory = Siba::SibaCheck.options_string options, "directory", true, "/"
        @worker = Siba::Destination::Ftp::Worker.new host, user, password, directory
      end                      

      # Put backup file (path_to_backup_file) to destination
      # No return value is expected
      def backup(path_to_backup_file) 
        logger.info "Uploading backup to FTP: #{worker.user_host_and_dir}"
        @worker.connect_and_put_file path_to_backup_file
      end

      # Shows the list of files stored currently at destination
      # with file names starting with 'backup_name'
      #
      # Returns an array of two-element arrays:
      # [backup_file_name, modification_time]
      def get_backups_list(backup_name)
        logger.info "Getting the list of backups from FTP: #{worker.user_host_and_dir}"
        @worker.get_files_list backup_name
      end

      # Restoring: put backup file into dir
      def restore(backup_name, dir)
        logger.info "Downloading backup from FTP: #{worker.user_host_and_dir}"
        @worker.connect_and_get_file backup_name, File.join(dir, backup_name)
      end
    end
  end
end
