require_dependency "subscribem/application_controller"

module Subscribem
  class Account::SessionsController < Subscribem::ApplicationController
    #skip_before_action :verify_authenticity_token

    def new
      @user = User.new
    end

    def create
      puts "in create"
      if env["warden"].authenticate(scope: :user)
        flash[:notice] = "You are now signed in."
        redirect_to root_path
        puts "in true"
      else
        @user = User.new
        flash[:error] = "Invalid email or password."
        render action: "new"
        puts "in false"
      end
    end

  end
end
