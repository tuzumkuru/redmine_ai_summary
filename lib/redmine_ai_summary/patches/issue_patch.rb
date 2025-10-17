module RedmineAiSummary
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          has_one :issue_summary, dependent: :destroy
          after_save :generate_summary_after_update
        end
      end

      def generate_summary_after_update
        return unless Setting.plugin_redmine_ai_summary['generate_on_update'].to_s == '1'
        return unless self.project&.module_enabled?(:ai_summary)

        summary = IssueSummary.find_or_initialize_by(issue_id: self.id)
        return if summary.persisted? && summary.up_to_date?

        summary.update(status: 'generating')
        GenerateSummaryJob.perform_later(self.id, User.current.id)
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineAiSummary::Patches::IssuePatch)
  Issue.send(:include, RedmineAiSummary::Patches::IssuePatch)
end