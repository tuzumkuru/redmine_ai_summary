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
              old_value, new_value = resolve_detail_values(detail)
              prop_key = detail.prop_key
              if detail.property == 'cf'
                custom_field = CustomField.find_by(id: detail.prop_key)
                prop_key = custom_field.name if custom_field
              end

              {
                property: detail.property,
                prop_key: prop_key,
                old_value: old_value,
                value: new_value
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
          Rails.logger.error "Failed to save summary: #{summary.errors.full_messages.join(', ')}"
          return [false, nil]
        end
      rescue Faraday::UnauthorizedError => e
        Rails.logger.error "Unauthorized access. Please check your API key and endpoint. Original error: #{e.message}"
        return [false, nil]
      rescue StandardError => e
        Rails.logger.error "An unexpected error occurred during summary generation. Original error: #{e.message}"
        return [false, nil]
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

    def self.resolve_detail_values(detail)
      old_value = detail.old_value
      new_value = detail.value

      if detail.property == 'cf'
        custom_field = CustomField.find_by(id: detail.prop_key)
        if custom_field
          old_value = custom_field.value_to_string(detail.old_value)
          new_value = custom_field.value_to_string(detail.value)
        end
        return old_value, new_value
      end

      return old_value, new_value unless detail.property == 'attr'

      case detail.prop_key
      when 'status_id'
        old_value = IssueStatus.find_by(id: detail.old_value)&.name
        new_value = IssueStatus.find_by(id: detail.value)&.name
      when 'priority_id'
        old_value = IssuePriority.find_by(id: detail.old_value)&.name
        new_value = IssuePriority.find_by(id: detail.value)&.name
      when 'tracker_id'
        old_value = Tracker.find_by(id: detail.old_value)&.name
        new_value = Tracker.find_by(id: detail.value)&.name
      when 'assigned_to_id'
        old_value = User.find_by(id: detail.old_value)&.name
        new_value = User.find_by(id: detail.value)&.name
      when 'category_id'
        old_value = IssueCategory.find_by(id: detail.old_value)&.name
        new_value = IssueCategory.find_by(id: detail.value)&.name
      when 'fixed_version_id'
        old_value = Version.find_by(id: detail.old_value)&.name
        new_value = Version.find_by(id: detail.value)&.name
      end

      return old_value, new_value
    end
  end
end
