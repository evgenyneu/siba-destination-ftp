# encoding: UTF-8

module Siba::Destination
  module Ftp                 
    class Worker
      include Siba::LoggerPlug
      include Siba::FilePlug

      attr_accessor :host, :user, :password, :directory

      def initialize(host, user, password, directory)
        @host = host
        @user = user
        @password = password
        @directory = directory
      end
    end
  end
end
