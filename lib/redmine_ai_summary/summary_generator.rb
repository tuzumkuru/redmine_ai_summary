module RedmineAiSummary
  class SummaryGenerator
    def self.generate(issue, user)
      client = initialize_openai_client

      issue_data = {
        subject: issue.subject,
        description: issue.description,
        text_formatting: Setting.text_formatting,
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
            user: journal.user.login,
            notes: journal.notes,
            created_on: journal.created_on,
            details: journal.details.map do |detail|
              {
                property: detail.property,
                prop_key: detail.prop_key,
                old_value: detail.old_value,
                value: detail.value
              }
            end
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
            # Provide multiple token limit keys for cross-provider compatibility (avoid Responses-only keys)
            max_tokens: Setting.plugin_redmine_ai_summary['max_completion_tokens'].to_i,
            max_completion_tokens: Setting.plugin_redmine_ai_summary['max_completion_tokens'].to_i,
          }
        )
        
        summary_content = response.dig("choices", 0, "message", "content") || "This is a generated summary for issue ##{issue.id}"

        summary = IssueSummary.find_or_initialize_by(issue_id: issue.id)
        summary.summary = summary_content

        if summary.new_record?
          summary.created_by = user.id
        else
          summary.updated_at = Time.now
          summary.updated_by = user.id
        end

        if summary.save
          return [true, summary]
        else
          error_msg = "Failed to save summary: #{summary.errors.full_messages.join(', ')}"
          Rails.logger.error error_msg
          return [false, error_msg]
        end
      rescue Faraday::UnauthorizedError => e
        error_msg = "Unauthorized access. Please check your API key and endpoint."
        Rails.logger.error "#{error_msg} Original error: #{e.message}"
        return [false, error_msg]
      rescue StandardError => e
        error_msg = "An unexpected error occurred during summary generation."
        Rails.logger.error "#{error_msg} Original error: #{e.message}"
        return [false, error_msg]
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
