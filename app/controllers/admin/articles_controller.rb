class Admin::ArticlesController < Admin::BaseController
  before_action :set_article, only: [:destroy, :resolve_reports, :dismiss_reports]
  def destroy
    @article.reports.pending.update_all(status: :resolved)
    @article.discard
    redirect_to admin_moderation_path, notice: "Article was deleted and reports were resolved."
  end
  def resolve_reports
    @article.reports.pending.update_all(status: :resolved)
    redirect_to admin_moderation_path, notice: "Reports for article were resolved."
  end
  def dismiss_reports
    @article.reports.pending.update_all(status: :dismissed)
    redirect_to admin_moderation_path, notice: "Reports for article were dismissed."
  end

  private
  def set_article
    @article = Article.kept.friendly.find(params[:id])
  end
end
