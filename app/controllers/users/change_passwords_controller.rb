class Users::ChangePasswordsController < ApplicationController

  def update
    user = current_user

    unless user.valid_password?(params[:user][:old_password])
      return render json: { error: "Old password is incorrect." }, status: :unauthorized
    end

    if params[:user][:new_password] != params[:user][:password_confirmation]
      return render json: { error: "New password and confirmation do not match." }, status: :unprocessable_entity
    end

    if user.update(password: params[:user][:new_password], password_confirmation: params[:user][:password_confirmation])
      render json: { notice: "Password changed successfully." }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
