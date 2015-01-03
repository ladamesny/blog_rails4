class SessionsController < ApplicationController

  def create
    #authenticate returns a User object if the authentication succeeds; otherwise, it returns nil
    if user = User.authenticate(params[:email], params[:password])
      #if the assignment above takes place, you want to store a reference to the authenticated user so you can keep the user logged in
      #We store user id instead of user object incase the user object goes stale if we change the model at a later point in time.
      session[:user_id] = user.id
      #With a reference to the logged-in user safely stored in session, we can redirect to the root path, corresponding to the articles controller.
      redirect_to root_path, notice: "Logged in successfully"
    else
      #If the assignment doesn't take place and the User.authenticate method returns nil, you know the provided login and password are invalide
      #and you return to the login page with an alert message using flash.now. RESTfully speaking, the login page is where you enter the new
      #session information, so it's basically the new action.
      flash.now[:alert] = "Invalid login/password combination"
      render :action => 'new'
    end
  end

  def destroy
    #here we clear the session by using the reset_session method that comes iwth Rails, which does exactly as it says.
    #After we clear the session, we redirect back to the login_path, which is our login screen.
    reset_session
    redirect_to root_path, :notice => "You successfully logged out"
  end
end
