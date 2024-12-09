class AiSummariesController < ApplicationController
  before_action :find_issue, only: [:create]
  before_action :check_create_permission, only: [:create]

  def create
    summary_content = generate_summary

    # Return an error if summary generation fails
    if summary_content.is_a?(String) && summary_content.start_with?("Error:")
      flash[:error] = summary_content
      Rails.logger.error "Failed to generate summary: #{summary_content}"
      redirect_to issue_path(@issue) and return
    end

    @summary = IssueSummary.find_or_initialize_by(issue_id: @issue.id)

    # Update the summary content
    @summary.summary = summary_content
    @summary.created_by = User.current.id

    if @summary.save
      Rails.logger.info "Summary saved/updated for issue ##{@issue.id} by User #{User.current.id}"
      flash[:notice] = t('redmine_ai_summary.flash.summary_created')

      respond_to do |format|
        format.js   # Render create.js.erb for AJAX requests
        format.html { redirect_to issue_path(@issue) }  # Redirect for non-AJAX requests
      end
    else
      Rails.logger.error "Failed to save/update summary for issue ##{@issue.id}: #{@summary.errors.full_messages.join(', ')}"
      flash[:error] = t('redmine_ai_summary.flash.summary_creation_failed')

      respond_to do |format|
        format.js { render json: { error: @summary.errors.full_messages }, status: :unprocessable_entity }
        format.html { redirect_to issue_path(@issue) }
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
    client = initialize_openai_client

    system_prompt = Setting.plugin_redmine_ai_summary['system_prompt']

    # Create a JSON structure with the issue data for the user prompt
    issue_data = {
      subject: @issue.subject,
      description: @issue.description,
      changes: @issue.changesets.map do |changeset|
        {
          id: changeset.id,
          comments: changeset.comments,
          committed_on: changeset.committed_on
        }
      end,
      notes: @issue.journals.map do |journal|
        {
          id: journal.id,
          notes: journal.notes,
          created_on: journal.created_on
        }
      end
    }

    # Convert the issue data to a JSON string for the user prompt
    user_prompt = issue_data.to_json

    begin
      response = client.chat(
        parameters: {
          model: Setting.plugin_redmine_ai_summary['model'],
          messages: [
            { role: "system", content: system_prompt },
            { role: "user", content: user_prompt }
          ],
          max_tokens: 1000
        }
      )
      
      response.dig("choices", 0, "message", "content") || "This is a generated summary for issue ##{@issue.id}"

    rescue Faraday::UnauthorizedError => e
      Rails.logger.error "Unauthorized access: #{e.message}"
      "Error: Failed to generate summary: Invalid API key or API address."
    rescue StandardError => e
      Rails.logger.error "Error generating summary: #{e.message}"
      "Error: An error occurred while generating the summary."
    end
  end

  def initialize_openai_client
    options = {
      access_token: Setting.plugin_redmine_ai_summary['api_key'],
      log_errors: true
    }

    api_address = Setting.plugin_redmine_ai_summary['api_address']
    options[:uri_base] = api_address if api_address.present?

    api_version = Setting.plugin_redmine_ai_summary['api_version']
    options[:api_version] = api_version if api_version.present?

    OpenAI::Client.new(options)
  end
end