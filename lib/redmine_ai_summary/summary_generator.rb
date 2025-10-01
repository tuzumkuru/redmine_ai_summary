module RedmineAiSummary
  class SummaryGenerator
    def self.generate(issue)
      client = initialize_openai_client

      issue_data = {
        subject: issue.subject,
        description: issue.description,
        changes: issue.changesets.map do |changeset|
          {
            id: changeset.id,
            comments: changeset.comments,
            committed_on: changeset.committed_on
          }
        end,
        notes: issue.journals.map do |journal|
          {
            id: journal.id,
            notes: journal.notes,
            created_on: journal.created_on
          }
        end
      }

      user_prompt = issue_data.to_json

      begin
        response = client.chat(
          parameters: {
            model: Setting.plugin_redmine_ai_summary['model'],
            messages: [
              { role: "system", content: Setting.plugin_redmine_ai_summary['system_prompt'] },
              { role: "user", content: user_prompt }
            ],
            max_completion_tokens: Setting.plugin_redmine_ai_summary['max_completion_tokens'].to_i,
          }
        )
        
        summary_content = response.dig("choices", 0, "message", "content") || "This is a generated summary for issue ##{issue.id}"

        summary = IssueSummary.find_or_initialize_by(issue_id: issue.id)
        summary.summary = summary_content

        if summary.new_record?
          summary.created_by = User.current.id
        else
          summary.updated_at = Time.now
          summary.updated_by = User.current.id
        end

        if summary.save
          summary
        else
          Rails.logger.error "Failed to save summary for issue ##{issue.id}: #{summary.errors.full_messages.join(', ')}"
          nil
        end
      rescue Faraday::UnauthorizedError => e
        Rails.logger.error "Unauthorized access: #{e.message}"
        nil
      rescue StandardError => e
        Rails.logger.error "Error generating summary: #{e.message}"
        nil
      end
    end

    private

    def self.initialize_openai_client
      options = {
        access_token: Setting.plugin_redmine_ai_summary['api_key'],
        log_errors: true
      }

      api_endpoint = Setting.plugin_redmine_ai_summary['api_endpoint']
      options[:uri_base] = api_endpoint if api_endpoint.present?

      OpenAI::Client.new(options)
    end
  end
end
