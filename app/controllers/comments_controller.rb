class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_article, only: [ :create, :edit, :update, :destroy ]
  before_action :set_comment, only: [ :edit, :update, :destroy ]

  def create
    @comment = @article.comments.build(comment_params)
    @comment.user = current_user
    authorize @comment
    if @comment.save
      respond_to do |format|
        format.turbo_stream
      end
    else
        redirect_to @article, alert: "Comment cant be created"
    end
  end
  def edit
    authorize @comment
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to article_path(@article, anchor: view_context.dom_id(@comment)) }
    end
  end
  def update
    authorize @comment
    if @comment.update(comment_params)
      respond_to do |format|
        format.turbo_stream
      end
    else
      redirect_to @article, alert: "Comment cant be updated"
    end
  end
  def destroy
    authorize @comment
    @comment.discard
    respond_to do |format|
      format.turbo_stream
    end
  end
  private
  def set_article
    # binding.irb
    @article = Article.kept.friendly.find(params[:article_id])
    # if action_name == "show" && request.path != article_path(@article)
    #   redirect_to @article, status: :moved_permanently
    # end
  end
  def set_comment
    @comment = Comment.kept.find_by(id: params[:id])
    redirect_to @article, alert: "Comment not found" unless @comment
  end
  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end
end
