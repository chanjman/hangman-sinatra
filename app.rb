# app/app.rb
require 'sinatra/base'
require 'sprockets'
require 'uglifier'
require 'sass'
require 'coffee-script'
require 'execjs'
require 'v8'
require_relative 'models/game'

class ApplicationController < Sinatra::Base
  # initialize new sprockets environment
  set :environment, Sprockets::Environment.new

  configure do
    enable :sessions
  end

  # append assets paths
  environment.append_path 'assets/stylesheets'
  environment.append_path 'assets/js'
  environment.append_path 'assets/img'

  # compress assets
  environment.js_compressor  = :uglify
  environment.css_compressor = :sass

  # get assets
  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  # routes
  get '/' do
    slim :index
  end

  get '/new-game' do
    slim :new_game
  end

  get '/load' do
    @saved = SaveLoad.new.saved_games
    slim :load_game
  end

  get '/load/:id' do
    load_game_data = SaveLoad.new.savegame_by_id(params[:id])
    @game = Game.new(load_game_data)
    @player = @game.player
    session[:game] = @game

    slim :new
  end

  get '/save' do
    SaveLoad.new.save_game(session[:game].to_save)
    return
  end

  get '/new' do
    session[:name] = params[:name] unless (params[:name].nil? || params[:name].empty?)
    @player = session[:name]
    @game = Game.new(player: @player)
    session[:game] = @game

    slim :new
  end

  post '/guess' do
    letter = params[:guess]
    game = session[:game]
    return game.json_response.to_json if letter.empty?
    game.good_guess(letter)
    game.json_response.to_json
  end

  delete '/delete' do
    SaveLoad.new.delete_game(params[:id])
    @saved = SaveLoad.new.saved_games

    slim :load_table, layout: false
  end

  delete '/delete-all' do
    SaveLoad.new.delete_all
    @saved = SaveLoad.new.saved_games

    slim :load_table, layout: false
  end
end
