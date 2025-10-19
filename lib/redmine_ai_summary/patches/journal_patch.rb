module RedmineAiSummary
  module Patches
    module JournalPatch
      def self.included(base)
        base.class_eval do
          after_create :generate_summary_after_note

          private

          def generate_summary_after_note
            # Act on any journal that belongs to an Issue, regardless of whether a note is present
            return unless journalized_type == 'Issue'
            # Respect the plugin setting that enables/disables auto‑generation on notes
            return unless Setting.plugin_redmine_ai_summary['auto_generate'] == '1'

            issue = journalized
            return unless issue.is_a?(Issue)

            # Ensure the AI Summary module is enabled for the project
            return unless issue.project&.module_enabled?(:ai_summary)

            summary = IssueSummary.find_or_initialize_by(issue_id: issue.id)

            # Optional flag: generate only if a manual summary already exists
            if Setting.plugin_redmine_ai_summary['auto_requires_existing_summary'] == '1'
              return unless summary.persisted?
            end

            summary.update(status: 'generating')
            GenerateSummaryJob.perform_later(issue.id, user_id)
          end
        end
      end
    end
  end
end

unless Journal.included_modules.include?(RedmineAiSummary::Patches::JournalPatch)
  Journal.send(:include, RedmineAiSummary::Patches::JournalPatch)
end