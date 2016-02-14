require 'rubygems'
require 'bundler'
Bundler.require(:default)
require "require_all"
require "goofy"
require "goofy/controller"
require_all './config/initializers'
require_all './app'
require_relative "routes"
