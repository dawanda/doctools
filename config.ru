$: << File.expand_path(File.dirname(__FILE__) + '/lib')

require 'doctools/web_app'

run Doctools::WebApp
