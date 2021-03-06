class UserDetailsController < ApplicationController

	before_filter :login_required, :except => [:show]


	# to show a profile of an user
	# just use this link: user_user_detail_path(:user_id => id)

  def show
		@user = User.find_by_id(params[:user_id]) || current_user
    @user_detail = @user.user_detail

		@path = [link_to_user(@user), link_to_user_user_detail(@user)]
		@subnavigation = [link_to_user(@user), link_to_edit_user_user_detail(@user), active_link_to_user_user_detail(@user), link_to_messages]

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_detail }
    end
  end


 


  def edit
    @user = current_user
    @user_detail = @user.user_detail

		@path = [link_to_user(@user), link_to_edit_user_user_detail(@user)]
		@subnavigation = [link_to_user(@user), active_link_to_edit_user_user_detail(@user), link_to_user_user_detail(@user), link_to_messages]
  end



 


  def update
    @user = current_user
    @user_detail = current_user.user_detail

		@path = [link_to_user(@user), link_to_edit_user_user_detail(@user)]
		@subnavigation = [link_to_user(@user), active_link_to_edit_user_user_detail(@user), link_to_user_user_detail(@user), link_to_messages]

    respond_to do |format|
      if @user_detail.update_attributes(params[:user_detail])
        flash[:notice] = 'Ihr Profil wurde erfolgreich geändert'
        format.html { redirect_to(@user_detail) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_detail.errors, :status => :unprocessable_entity }
      end
    end
  end


end
