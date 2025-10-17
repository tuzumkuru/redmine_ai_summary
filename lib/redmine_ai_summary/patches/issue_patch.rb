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
        return if issue_summary.nil?

        if Setting.plugin_redmine_ai_summary['generate_on_update'].to_s == '1'
          issue_summary.update(status: 'generating')
          GenerateSummaryJob.perform_later(self.id, User.current.id)
        else
          issue_summary.update(status: 'stale')
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineAiSummary::Patches::IssuePatch)
  Issue.send(:include, RedmineAiSummary::Patches::IssuePatch)
end