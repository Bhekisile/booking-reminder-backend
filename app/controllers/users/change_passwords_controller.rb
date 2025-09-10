class Users::ChangePasswordsController < ApplicationController

  def update
    user = current_user
    permitted = change_password_params

    unless user.valid_password?(permitted[:old_password])
      return render json: { error: "Old password is incorrect." }, status: :unauthorized
    end

    if user.update(password: permitted[:new_password], password_confirmation: permitted[:password_confirmation])
      render json: { notice: "Password changed successfully." }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def change_password_params
    params.require(:user).permit(:old_password, :new_password, :password_confirmation)
  end
end
