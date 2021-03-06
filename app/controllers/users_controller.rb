class UsersController < ApplicationController

	before_filter :login_required, :except => [:new, :create]


  # render new.rhtml
  def new
		@path = [link_to_signup]
		@subnavigation = []
		@user = User.new
		@user_detail = UserDetail.new
  end




	# creates a new user

  def create
		@path = [link_to_signup]
		@subnavigation = []

    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session

    @user = User.new(params[:user])
	
		# for the user details
		@user_detail = UserDetail.new(params[:user_detail])
		
		@user.user_detail = @user_detail
		
		# what will be the login name be
		if params[:last_name_check] == "1"
			@user.login = @user_detail.last_name
		else
			@user.login = @user_detail.first_name + " " + @user_detail.last_name
		end


		valid1 = @user.valid?
		valid2 = @user_detail.valid?

		if valid1 && valid2
			@user.save!
	
			@user_detail.save!
		
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end



	# for the activation of an user

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end



	# The Users profile

	
	def index
		
		@user = current_user
		
		
		@path = [link_to_user(@user)]
		@subnavigation = [active_link_to_user(@user), link_to_edit_user_user_detail(@user), link_to_user_user_detail(@user), link_to_messages]

		@message_count = current_user.mailbox[:inbox].unread_mail.size

		@ideas = Ideas.new("created_at", "DESC", {:user_id => current_user}, 0, 5).ideas
		@projects = Project.paginate_by_user_id current_user.id, :page => 1, :order => "created_at DESC", :per_page => 5
		@innovations = Innovation.paginate_by_user_id current_user.id, :page => 1, :order => "created_at DESC", :per_page => 5	

	end





	def edit
		@user = current_user.login		
		@user_detail = UserDetail.find_by_user_id(params[:id])	

		@path = [link_to_user(@user), link_to_user_user_detail(@user)]
		@subnavigation = [link_to_user(@user), active_link_to_user_user_detail(@user), link_to_user_user_detail(@user), link_to_messages]
	end




	def update
    @user_detail = UserDetail.find_by_user_id(params[:id])

		
		respond_to do |format|
      if @user_detail.update_attributes(params[:user_detail])
        flash[:notice] = 'Profil wurde erfolgreich verändert'
        format.html { redirect_to(users_path(@user_detail)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @idea.errors, :status => :unprocessable_entity }
      end
    end

  end

	
	def show
		redirect_to users_path
	end


end
