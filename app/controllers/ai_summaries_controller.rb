class AiSummariesController < ApplicationController
  before_action :find_issue, only: [:create, :content]
  before_action :check_create_permission, only: [:create]

  def content
    render partial: 'ai_summaries/summary_content', locals: { issue: @issue }
  end

  def create
    @summary = IssueSummary.find_or_initialize_by(issue_id: @issue.id)
    @summary.status = 'generating'

    if @summary.save
      GenerateSummaryJob.perform_later(@issue.id, User.current.id)
      handle_success
    else
      handle_error(@summary.errors.full_messages)
    end
  end

  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
  end

  def check_create_permission
    unless User.current.allowed_to?(:generate_issue_summary, @issue.project)
      render json: { error: "You do not have permission to create summaries." }, status: :forbidden
    end
  end

  def handle_success
    Rails.logger.info "Summary saved/updated for issue ##{@issue.id} by User #{User.current.id}"
    respond_to do |format|
      format.js   # Render create.js.erb for AJAX requests
      format.html { redirect_to issue_path(@issue) }
    end
  end

  def handle_error(errors)
    @errors = Array.wrap(errors)
    Rails.logger.error "Failed to generate summary for issue ##{@issue.id}: #{@errors.join(', ')}"
    respond_to do |format|
      format.js { render json: { error: @errors }, status: :unprocessable_entity }
      format.html do
        flash[:error] = @errors.join(', ')
        redirect_to issue_path(@issue)
      end
    end
  end
end