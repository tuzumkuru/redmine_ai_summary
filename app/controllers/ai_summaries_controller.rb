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
      Rails.logger.info "Summary created for issue ##{@issue.id} by User #{User.current.id}"
      flash[:notice] = t('redmine_ai_summary.flash.summary_created')
    else
      Rails.logger.error "Failed to create summary for issue ##{@issue.id}: #{@summary.errors.full_messages.join(', ')}"
      flash[:error] = t('redmine_ai_summary.flash.summary_creation_failed')
    end
    
    redirect_to issue_ai_summaries_path(@issue)
  end

  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
  end

  def check_view_permission
    unless User.current.allowed_to?(:view_issues, @issue.project)
      render json: { error: "You do not have permission to view summaries." }, status: :forbidden
    end
  end

  def check_create_permission
    unless User.current.allowed_to?(:generate_issue_summary, @issue.project)
      render json: { error: "You do not have permission to create summaries." }, status: :forbidden
    end
  end

  def generate_summary
    # Placeholder for actual AI service integration
    # You would implement the logic here to call your AI service and generate the summary based on the issue context
    "This is a generated summary for issue ##{@issue.id}"
  end
end