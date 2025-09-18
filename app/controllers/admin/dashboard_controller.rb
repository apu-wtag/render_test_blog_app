class Admin::DashboardController < Admin::BaseController
  # before_action :require_admin
  def index
    # Overview Cards Data
    @total_users = User.count
    @total_articles = Article.count
    @total_comments = Comment.count
    @total_claps = Clap.count
    # Chartkick Data (grouped by the week they were created)
    @users_per_week = User.group_by_week(:created_at).count
    @articles_per_week = Article.group_by_week(:created_at).count
    # Moderation Queue (10 most recent pending reports)
    # @pending_reports = Report.pending.includes(:user, reportable: [:user]).order(created_at: :desc).limit(10)
    @pending_reports = Report.pending
                             .where("(reportable_type = 'Article' AND reportable_id IN (?)) OR (reportable_type = 'Comment' AND reportable_id IN (?))",
                               Article.kept.select(:id),
                               Comment.kept.select(:id)
                             )
                             .includes(:user)
                             .order(created_at: :desc)
                             .limit(10)

    # Spotlight Section
    @most_clapped_articles = Article.order(claps_count: :desc).limit(3)
    @most_commented_articles = Article.order(comments_count: :desc).limit(3)

  end
end
