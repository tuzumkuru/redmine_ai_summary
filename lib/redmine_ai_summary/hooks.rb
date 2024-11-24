module RedmineAiSummary
  module Hooks
    class IssueShowHook < Redmine::Hook::ViewListener
      render_on :view_issues_show_description_bottom, partial: 'ai_summaries/summary'
    end
  end
end