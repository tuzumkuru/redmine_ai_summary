module RedmineAiSummary
  module Hooks
    class IssueShowHook < Redmine::Hook::ViewListener
      def view_issues_show_description_bottom(context = {})
        return unless context[:project].module_enabled?(:ai_summary)
        context[:controller].send(:render_to_string, {
          partial: 'ai_summaries/summary',
          locals: context
        })
      end
    end
  end
end