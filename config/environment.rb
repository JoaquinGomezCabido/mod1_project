require "bundler/setup"
require 'rake'
require "sinatra/activerecord"
require 'ostruct'
require 'active_record'
require 'date'
require 'json'
require 'open-uri'
require 'pry'
require "tty-prompt"
require 'launchy'
require_relative '../app/models/user.rb'
require_relative '../app/models/playlist.rb'
require_relative '../app/models/playlistsong.rb'
require_relative '../app/models/song.rb'
require_relative '../app/lib/api_request.rb'

Bundler.require

ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'db/activemusicrecord.db'
)
