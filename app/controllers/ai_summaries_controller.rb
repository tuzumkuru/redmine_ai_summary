class AiSummariesController < ApplicationController
  before_action :find_issue, only: [:create]
  before_action :check_create_permission, only: [:create]

  def create
    summary_content = generate_summary

    if summary_content.is_a?(String) && summary_content.start_with?("Error:")
      handle_error(summary_content)
      return
    end

    @summary = IssueSummary.find_or_initialize_by(issue_id: @issue.id)
    @summary.summary = summary_content

    if @summary.new_record?
      @summary.created_by = User.current.id
    else
      @summary.updated_at = Time.now
      @summary.updated_by = User.current.id
    end

    if @summary.save
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

  def generate_summary
    client = initialize_openai_client

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
            { role: "system", content: Setting.plugin_redmine_ai_summary['system_prompt'] },
            { role: "user", content: user_prompt }
          ],
          max_tokens: Setting.plugin_redmine_ai_summary['max_tokens'].to_i,
        }
      )
      
      response.dig("choices", 0, "message", "content") || "This is a generated summary for issue ##{@issue.id}"

    rescue Faraday::UnauthorizedError => e
      Rails.logger.error "Unauthorized access: #{e.message}"
      "Error: Invalid API key or API address: #{e.message}"
    rescue StandardError => e
      Rails.logger.error "Error generating summary: #{e.message}"
      "Error: An error occurred while generating the summary: #{e.message}"
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