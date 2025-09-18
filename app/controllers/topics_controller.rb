class TopicsController < ApplicationController
  def show
    @topic = Topic.friendly.find(params[:id])
    @pagy, @articles = pagy(@topic.articles.kept.includes(:user).order(created_at: :desc), items: 10)
  end
end
