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
        # If there is an associated summary, mark it as stale on any issue save.
        # However, do **not** overwrite a summary that is already being generated.
        return if issue_summary.nil?
        return if issue_summary.status == 'generating'
        issue_summary.update(status: 'stale')
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineAiSummary::Patches::IssuePatch)
  Issue.send(:include, RedmineAiSummary::Patches::IssuePatch)
end