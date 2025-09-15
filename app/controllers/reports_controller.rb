class ReportsController < ApplicationController
  before_action :require_login
  before_action :set_reportable

  def new
    @report = @reportable.reports.new
  end

  def create
    @report = @reportable.reports.new(report_params)
    @report.user = current_user

    if @report.save
      render turbo_stream: turbo_stream.replace("report_form_#{@reportable.class.name}_#{@reportable.id}",
                                                partial: "reports/success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def set_reportable
    if params[:article_id]
      @reportable = Article.friendly.find(params[:article_id])
    elsif params[:comment_id]
      @reportable = Comment.find(params[:comment_id])
    end
  end

  def report_params
    params.require(:report).permit(:reason)
  end
end
