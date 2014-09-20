require 'sinatra'
require 'data_mapper'

if ENV['RACK_ENV'] != "production"
  require 'sqlite3'
  require 'dotenv'
  Dotenv.load '.env'
  DataMapper.setup(:default, "sqlite:todo.db")
end

if ENV['RACK_ENV'] == "production"
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

# Todo model
class Todo
  include DataMapper::Resource

  property :id,           Serial
  property :title,        Text
  property :description,  Text
  property :created_at,   DateTime
  # property :due_by,       DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

def show_params(params)
  puts "\n"
  p params
  puts "\n"
end

# Root endpoint calls all todos in database and sends response to primary list page.
get "/" do
  @todos = Todo.all
  erb :todo_list
end

# Need a get method to call an erb file containing the code for the second form.
get "/todos/new" do
  show_params(params)
  @todo = Todo.new
   # We're going to create a new todo and call the erb method to bring up the new_todo form.
  erb :new_todo
end

post "/todos" do
  show_params(params)
  todo_attributes = params["todo"]
  todo_attributes["created_at"] = DateTime.now
  @todo = Todo.create(todo_attributes)
  if @todo.save
    redirect "/"
  else
    erb :new_todo
  end
end

