class Client < Sinatra::Base
  get '/' do
    haml :index
  end
end