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

            RedmineAiSummary::SummaryGenerator.generate(self.journalized)
          end
        end
      end
    end
  end
end

unless Journal.included_modules.include?(RedmineAiSummary::Patches::JournalPatch)
  Journal.send(:include, RedmineAiSummary::Patches::JournalPatch)
end
