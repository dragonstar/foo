require_dependency "subscribem/application_controller"

module Subscribem
  class Account::AccountsController < ApplicationController

    def update
      if current_account.update_attributes(account_params)
        flash[:success] = "Account updated successfully."
        redirect_to root_path
      end
    end

    private
    def account_params
      params.require(:account).permit(:name)
    end

  end
end