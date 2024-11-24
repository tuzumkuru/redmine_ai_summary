class AiSummariesController < ApplicationController
    before_action :find_issue, only: [:create, :update]
  
    def create
      summary_content = generate_ai_summary(@issue)
  
      @summary = IssueSummary.new(
        issue_id: @issue.id,
        summary: summary_content,
        created_by: User.current.id
      )
  
      if @summary.save
        flash[:notice] = 'Summary created successfully.'
      else
        flash[:error] = 'Failed to create summary.'
      end
      redirect_to issue_path(@issue)
    end
  
    def update
      # Logic for updating an existing summary, if needed
    end
  
    private
  
    def find_issue
      @issue = Issue.find(params[:issue_id])
    end
  
    def generate_ai_summary(issue)
      # Placeholder logic; replace with actual AI service integration
      "This is an AI-generated summary for issue ##{issue.id}"
    end
  end