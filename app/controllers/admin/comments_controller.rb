class Admin::CommentsController < Admin::BaseController
  before_action :set_comment, only: [:destroy, :resolve_reports, :dismiss_reports]
  def index
    @comments = Comment.joins(:reports)
                       .where(reports: { status: :pending })
                       .distinct
                       .includes(:user, :article)
                       .order("articles.created_at DESC")
  end
  def destroy
    @comment.reports.pending.update_all(status: :resolved)
    @comment.destroy
    redirect_to admin_comments_path, notice: "Comment was successfully deleted and reports were resolved."
  end
  def resolve_reports
    @comment.reports.pending.update_all(status: :resolved)
    redirect_to admin_comments_path, notice: "Reports for comment were resolved."
  end
  def dismiss_reports
    @comment.reports.pending.update_all(status: :dismissed)
    redirect_to admin_comments_path, notice: "Reports for comment were dismissed."
  end
  private
  def set_comment
    @comment = Comment.find(params[:id])
  end

end
