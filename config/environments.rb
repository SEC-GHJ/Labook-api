# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'logger'
require 'sequel'
require_relative '../app/lib/secure_db'
require_relative '../app/lib/auth_token'

module Labook
  # Configuration for the API
  class Api < Roda
    plugin :environments

    # load config secrets into local environment variables (ENV)
    Figaro.application = Figaro::Application.new(
      environment: environment, # rubocop:disable Style/HashSyntax
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load

    # Make the environment variables accessible to other classes
    def self.config = Figaro.env

    # Retrieve db secret
    SecureDB.setup(ENV.delete('DB_KEY'))
    # Retrieve db secret
    AuthToken.setup(ENV.delete('MSG_KEY'))

    # Logger setup
    LOGGER = Logger.new($stderr)
    def self.logger = LOGGER

    # Connect and make the database accessible to other classes
    db_url = ENV.delete('DATABASE_URL')
    DB = Sequel.connect("#{db_url}?encoding=utf8")
    def self.DB = DB # rubocop:disable Naming/MethodName

    configure :development, :test do
      require 'pry'
      # logger.level = Logger::ERROR
      logger.level = Logger::INFO
    end
  end
end
