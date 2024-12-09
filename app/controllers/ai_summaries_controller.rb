class AiSummariesController < ApplicationController
  before_action :find_issue, only: [:create]
  before_action :check_create_permission, only: [:create]

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
    respond_to do |format|
      format.js   # Render create.js.erb for the AJAX response
      format.html { redirect_to issue_path(@issue) }  # Redirect for non-AJAX requests
    end
  else
    Rails.logger.error "Failed to create summary for issue ##{@issue.id}: #{@summary.errors.full_messages.join(', ')}"
    flash[:error] = t('redmine_ai_summary.flash.summary_creation_failed')
    respond_to do |format|
      format.js   # Render create.js.erb for AJAX errors
      format.html { redirect_to issue_path(@issue) }  # Redirect for non-AJAX requests
    end
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

  def generate_summary
    # Placeholder for actual AI service integration
    "This is a generated summary for issue ##{@issue.id}"
  end
end