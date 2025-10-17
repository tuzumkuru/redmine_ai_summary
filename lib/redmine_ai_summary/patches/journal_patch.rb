module RedmineAiSummary
  module Patches
    module JournalPatch
      def self.included(base)
        base.class_eval do
        end
      end
    end
  end
end

unless Journal.included_modules.include?(RedmineAiSummary::Patches::JournalPatch)
  Journal.send(:include, RedmineAiSummary::Patches::JournalPatch)
end
