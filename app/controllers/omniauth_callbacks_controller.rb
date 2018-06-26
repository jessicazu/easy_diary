class OmniauthCallbacksController < ApplicationController
  def line
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user
      flash[:notice] = "ログインしました。"
    else
      session["devise.line_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end
