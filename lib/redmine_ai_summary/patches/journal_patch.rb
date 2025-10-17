module RedmineAiSummary
  module Patches
    module JournalPatch
      def self.included(base)
        base.class_eval do
          after_create :generate_summary_after_note

          private

          def generate_summary_after_note
            return unless self.journalized_type == 'Issue' && self.notes.present?
            return unless Setting.plugin_redmine_ai_summary['auto_generate'] == '1'

            issue = self.journalized
            return unless issue.is_a?(Issue)

            # Only run if the AI Summary module is enabled on the project
            return unless issue.project&.module_enabled?(:ai_summary)

            summary = IssueSummary.find_or_initialize_by(issue_id: issue.id)

            # Optional setting: require that a manual summary exists before auto-generating
            if Setting.plugin_redmine_ai_summary['auto_requires_existing_summary'] == '1'
              return unless summary.persisted?
            end

            summary.update(status: 'generating')
            GenerateSummaryJob.perform_later(issue.id, self.user_id)
          end
        end
      end
    end
  end
end

unless Journal.included_modules.include?(RedmineAiSummary::Patches::JournalPatch)
  Journal.send(:include, RedmineAiSummary::Patches::JournalPatch)
end
