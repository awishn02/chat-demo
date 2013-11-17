class ChatController < ApplicationController
  include Tubesock::Hijack
  def index
    @messages = Message.all
  end
  
  def setUser
    session[:username] = params[:username]
    render :nothing => true
  end
  
  def chat
   uri = URI.parse(ENV["REDISTOGO_URL"]) 
    hijack do |tubesock|
      redis_thread = Thread.new do
        Redis.new(:host => uri.host, :port => uri.port, :password => uri.password).subscribe "chat" do |on|
          on.message do |channel, message|
            data = message.split(",")
            puts message
            tubesock.send_data "#{data[1]}: #{data[0]}"
          end
        end
      end
      tubesock.onopen do
        tubesock.send_data "Hello, friend"
      end

      tubesock.onmessage do |data|
        #@message = Message.new(:username => session[:username], :message => data)
        #if @message.save
        Redis.new(:host => uri.host, :port => uri.port, :password => uri.password).publish "chat", "#{data},#{session[:username]}"
        #end
      end

      tubesock.onclose do
        redis_thread.kill
      end
    end
  end
end
