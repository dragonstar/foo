class ThingsController < ApplicationController
  def index
    #@things = current_account.things
    @things = Thing.scoped_to(current_account)
  end
end
