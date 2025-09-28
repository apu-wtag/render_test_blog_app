class Admin::CommentsController < Admin::BaseController
  before_action :set_comment, only: [ :destroy, :resolve_reports, :dismiss_reports ]
  def destroy
    @comment.reports.pending.update_all(status: :resolved)
    @comment.discard
    redirect_to admin_moderation_path(scope: "comments"), notice: "Comment was successfully deleted and reports were resolved."
  end
  def resolve_reports
    @comment.reports.pending.update_all(status: :resolved)
    redirect_to admin_moderation_path(scope: "comments"), notice: "Reports for comment were resolved."
  end
  def dismiss_reports
    @comment.reports.pending.update_all(status: :dismissed)
    redirect_to admin_moderation_path(scope: "comments"), notice: "Reports for comment were dismissed."
  end
  private
  def set_comment
    @comment = Comment.kept.find(params[:id])
  end
end
