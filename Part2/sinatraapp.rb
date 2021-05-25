require 'sinatra/base'

# class MyApp < Sinatra::Base; end
# MyApp.get '/' do 
#     "Hello World from myapp using Sinatra"
# end

class MyApp < Sinatra::Base;
    get '/' do 
        "Hello World from myapp using Sinatra"
    end
end