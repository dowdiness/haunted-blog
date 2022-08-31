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
    @blog = current_user.blogs.new(blog_params)

    if !current_user.premium? && coerce_boolean(params[:blog][:random_eyecatch])
      redirect_to blogs_url, alert: 'You cannot use random_eyecatch.'
    elsif @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if !current_user.premium? && coerce_boolean(params[:blog][:random_eyecatch])
      redirect_to blog_url(@blog), alert: 'You cannot use random_eyecatch.'
    elsif @blog.update(blog_params)
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

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end

  def coerce_boolean(value)
    value.nil? || value == '' ? nil : !Set[false, 'false', 0, '0'].include?(value)
  end
end
