class UsersController < ApplicationController
  before_action :require_user, only: [:show]

  def new
    @user = User.new
  end

  def new_with_invite_token
    invite = Invite.find_by(token: params[:token])

    if invite
      @user = User.new(email: invite.friend_email)
      @invite_token = invite.token
      render :new
    else
      redirect_to expired_token_path
    end
  end

  def create
    @user = User.new(user_params)
    charge = StripeWrapper::Charge.create(amount: 999, card: params[:stripeToken])
    
    if @user.save && charge.successful?
      check_for_invite
      AppMailer.delay.welcome_email(@user)
      session[:user_id] = @user.id
      flash[:notice] = "You are now registered!"
      redirect_to home_path
    else
      flash[:danger] = "Please fix the problems below."
      flash[:danger] = charge.error_message
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:fullname, :email, :password, :invite_token)
  end

  def check_for_invite
    if invite = Invite.find_by(token: params[:invite_token])
      @user.follow_and_be_followed_by(invite.user)
      invite.generate_token
    end
  end
end


