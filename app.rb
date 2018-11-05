require 'sinatra'
require 'sinatra/activerecord'
require './models'


set :database, "sqlite3:second.sqlite3"
set :sessions, true


def current_blog
	@blog = Blog.find(params[:id])

end	
def current_user
   if(session[:user_id])
       @currentuser = User.find(session[:user_id])
   end
end	

get "/" do 
    @users = User.all
    @blogs =Blog.all  
	erb :index
end	
get "/userb" do
    @blogs =Blog.all
    @user = User.find(session[:user_id])
	erb :userb
end	
get "/new" do
	

	erb :new
end

post "/create_blog" do
	if !session[:user_id]
		redirect "/"
	end	
	title = params[:title]
	content = params[:content]
	user = User.find(session[:user_id])
    Blog.create(title: title, content: content, user_id:user.id)

	redirect "/userb"
end	

get '/blogs/:id'  do


	current_blog
    erb :show

end
get "/blogs/:id/edit" do
    current_blog
	erb :edit
end


post "/update/:id"  do
   current_blog 
    if !session[:user_id]
     	redirect "/"
     end
  if session[:user_id] != @blog.user_id
            redirect"/"
     end       
  if @blog.update(title: params[:title],content: params[:content])
       redirect "/"
  else
  	erb "/blogs/<%= @blog.id %>/edit"
  end

end

post "/destroy/:id" do
	 current_blog
     if !session[:user_id]
     	redirect "/"
     end
    if session[:user_id] != @blog.user_id
            redirect"/" 	
    
    else
	 if @blog.destroy
	 	redirect "/"
	 end
  end 
end	



	post "/signup"  do

		username= params[:username]
		password= params[:password]
		user =User.new(username: username,password: password)
		if user.save
			redirect "/hello"
		else
		  erb :index 

		
		end  	


	end	

get "/hello" do
	

	erb :hello
end
post "/login" do
		user = User.where(username: params[:username]).first


		if user.password == params[:password]
			session[:user_id] = user.id
			# redirect "/hello"
			redirect "/users/#{user.id}"
		else
		  erb :index	


    end	
end

get "/users/:id" do
	current_user
	erb :user
end	

post "/users/logout" do

   session[:user_id] =nil
   redirect "/"


end
post "/logout" do

   session[:user_id] =nil
   redirect "/"


end

post '/destroy/:id' do
  current_blog
  @blog.destroy
  redirect '/'
end

post "/destroy/user/:id" do
  session[:user_id] =nil
  @user = User.find(params[:id])
  @user.blogs.each do |b|
  	b.destroy
  end
 
  @user.destroy

  redirect "/"
end
get "/all_user" do

   @user= User.all

   if !session[:user_id]
       redirect "/"
   end

   erb :all_user

end