class PostsController < ApplicationController
  def index
    @posts = Post.scoped_to(current_account)
  end

  def show
    #@post = Post.find(params[:id])
    post = Post.scoped_to(current_account).find(params[:id])
  end
end
