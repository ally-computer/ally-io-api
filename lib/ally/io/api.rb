require 'ally/io'
require 'ally/io/api/version'
require 'sinatra/base'
require 'sinatra/streaming'
require 'pp'
require 'httparty'

module Ally
  module Io
    class Api
      include Ally::Io

    
      def say(text)
        super # do not delete
        port = ENV['PORT'] || 7455
        HTTParty.post("http://localhost:#{port}/say", :query => { msg: text })
      end

      def listen
        app = HttpServer
        app.run!
      end
    
    end
  end
end

class HttpServer < Sinatra::Base

  attr_accessor :io

  helpers Sinatra::Streaming

  port = ENV['PORT'] || 7455
  set :port, port
  set :server, %w[thin mongrel webrick]

  before do
    content_type :txt
  end

  connections = []

  get '/listen' do
    stream(:keep_open) do |out|
      # store connection for later on
      connections << out

      # remove connection when closed properly
      out.callback { connections.delete(out) }

      # remove connection when closed due to an error
      out.errback do
        logger.warn 'we just lost a connection!'
        connections.delete(out)
      end
    end
  end

  post '/say' do
    connections.each do |out|
      out << "#{params[:msg]}\n"
    end
  end

  post '/inquiry' do
    io = DLA::IO::Api.new
    if params[:msg]
      raw_text = params[:msg].chomp
      inquiry = DLA::Inquiry.new(raw_text)
      io.input(inquiry)
    else
      io.say('Sorry no message parameter in inquiry')
    end
  end

  post '/install' do
    require 'treat'
    Treat::Core::Installer.install 'english'
    "done."
  end
end
