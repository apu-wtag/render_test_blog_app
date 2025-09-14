class TopicsController < ApplicationController
  def show
    @topic = Topic.friendly.find(params[:id])
    @articles = @topic.articles.includes(:user).order(created_at: :desc)
  end
end
