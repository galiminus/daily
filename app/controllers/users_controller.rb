class UsersController < ApplicationController
  def new
  end

  def create
    if user = authenticate_with_google
      cookies.signed[:user_id] = { value: user.id, expires: 1.year.from_now }
      redirect_to root_url
    else
      redirect_to root_url, alert: 'authentication_failed'
    end
  end

  def logout
    cookies.signed[:user_id] = nil

    redirect_to root_url
  end

  def edit
    user = User.find params[:id]
    authorize user
  end

  def update
    user = User.find params[:id]
    user.assign_attributes params.require(:user).permit(:monthly_budget, :currency)
    authorize user

    if user.save
      redirect_to root_url
    else
      redirect_to root_url, flash: { error: "An unexpected error occured."}
    end
  end

  def destroy
    user = User.find params[:id]
    authorize user
    user.destroy

    redirect_to root_url
  end

  private

  def authenticate_with_google
    if id_token = flash[:google_sign_in_token]
      identity = GoogleSignIn::Identity.new(id_token)
      User.find_or_create_by(google_id: identity.user_id) do |user|
        user.name = identity.name
      end
    elsif error = flash[:google_sign_in_error]
      logger.error "Google authentication error: #{error}"
      nil
    end
  end
end
