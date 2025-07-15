class Api::V1::PayfastController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  def itn
    user_id = params[:custom_str1]
    user = User.find_by(id: user_id)

    if params[:payment_status] == 'COMPLETE'
      user.update(subscribed: true)
      Rails.logger.info "PayFast: Subscription marked complete for User##{user.id}"
    else
      Rails.logger.warn "PayFast: Incomplete payment for User##{user_id}"
    end

    head :ok
  end
end
