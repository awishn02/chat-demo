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
    hijack do |tubesock|
      redis_thread = Thread.new do
        REDIS.new.subscribe "chat" do |on|
          on.message do |channel, message|
            tubesock.send_data message
          end
        end
      end
      tubesock.onopen do
        tubesock.send_data "Hello, friend"
      end

      tubesock.onmessage do |data|
        #@message = Message.new(:username => session[:username], :message => data)
        #if @message.save
        REDIS.new.publish "chat", data
        #end
      end

      tubesock.onclose do
        redis_thread.kill
      end
    end
  end
end
