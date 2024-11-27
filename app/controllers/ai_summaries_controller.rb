class AiSummariesController < ApplicationController
  before_action :find_issue, only: [:create, :index]
  before_action :check_view_permission, only: [:index]
  before_action :check_create_permission, only: [:create]

  def index
    @latest_summary = @issue.issue_summaries.last
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @latest_summary }
    end
  end

  def create
    summary_content = generate_summary

    @summary = IssueSummary.new(
      issue_id: @issue.id,
      summary: summary_content,
      created_by: User.current.id
    )
    
    if @summary.save
      flash[:notice] = t('redmine_ai_summary.flash.summary_created')
    else
      flash[:error] = t('redmine_ai_summary.flash.summary_creation_failed')
    end
    
    redirect_to issue_ai_summaries_path(@issue)
  end

  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
  end

  def check_view_permission
    unless User.current.allowed_to?(:view_summaries, @issue.project)
      render plain: "You do not have permission to view summaries.", status: :forbidden
    end
  end

  def check_create_permission
    unless User.current.allowed_to?(:create_summaries, @issue.project)
      render plain: "You do not have permission to create summaries.", status: :forbidden
    end
  end

  def generate_summary
    # Placeholder for actual AI service integration
    "This is a generated summary for issue ##{@issue.id}"
  end
end