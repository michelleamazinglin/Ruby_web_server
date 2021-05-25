require "sinatra/base"


class MyApp < Sinatra::Base 
    get '/' do
        "Hello from Sinatra App (Concurrent Server)!" 
    end
end