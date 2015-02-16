# Set up gems listed in the Gemfile.
# See: http://gembundler.com/bundler_setup.html
#      http://stackoverflow.com/questions/7243486/why-do-you-need-require-bundler-setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require gems we care about
require 'rubygems'
require 'grocer'
require 'uri'
require 'pathname'
require 'net/http'
require 'pg'
require 'active_record'
require 'logger'
require 'dotenv'
require 'sinatra'
require "sinatra/reloader" if development?
require 'erb'
require 'aws-sdk'
require 'byebug'
# Some helper constants for path-centric logic
APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))

APP_NAME = APP_ROOT.basename.to_s

# Set up the controllers and helpers
Dir[APP_ROOT.join('app', 'controllers', '*.rb')].each { |file| require file }
Dir[APP_ROOT.join('app', 'helpers', '*.rb')].each { |file| require file }

# Set up the database and models
require APP_ROOT.join('config', 'database')

Dotenv.load

AWS.config(
  access_key_id: ENV['ACCESS_KEY_ID'],
  secret_access_key: ENV['SECRET_ACCESS_KEY']
  )

$s3 = AWS::S3.new

cert_path = ENV['APN_CERTIFICATE']

PUSHCLIENT = Grocer.pusher(
  certificate: cert_path,            # required
  passphrase:  "",                       # optional
  gateway:     "gateway.sandbox.push.apple.com", # optional; See note below.
  port:        2195,                     # optional
  retries:     3                         # optional
)





