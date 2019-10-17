module UsersHelper

 def logged_in?
    current_user
  end

# Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end

# Stores the URL to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

end
