module RedmineAiSummary
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          has_many :issue_summaries
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineAiSummary::Patches::IssuePatch)
  Issue.send(:include, RedmineAiSummary::Patches::IssuePatch)
end