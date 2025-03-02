# frozen_string_literal: true

require 'set'

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show]
  before_action :set_my_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params(premium: current_user.premium?))
    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params(premium: current_user.premium?))
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
    raise ActiveRecord::RecordNotFound if @blog.secret? && !@blog.owned_by?(current_user)
  end

  def set_my_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def blog_params(premium: false)
    permit_keys = %i[title content secret]
    permit_keys.push(:random_eyecatch) if premium
    params.require(:blog).permit(*permit_keys)
  end
end
