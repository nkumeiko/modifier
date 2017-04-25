ROOT = File.expand_path('..', File.dirname(__FILE__))

$:.unshift File.expand_path('lib', ROOT)
require 'rspec'
require 'csv'
require 'yaml'
require 'fileutils'
require 'fakefs/safe'

Dir[File.expand_path('spec/support/*.rb', ROOT)].each { |file| require file }
