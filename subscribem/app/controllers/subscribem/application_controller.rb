module Subscribem
  class ApplicationController < ::ApplicationController
    protect_from_forgery with: :null_session

    def authorize_owner
      unless owner?
        flash[:error] = "You are not allowed to do that."
        redirect_to root_path
      end
    end
  end
end
