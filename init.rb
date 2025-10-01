Redmine::Plugin.register :redmine_ai_summary do
  name 'Redmine AI Summary Plugin'
  author 'Tolga Uzun'
  description 'A plugin for generating AI summaries on issues.'
  version '0.1.0'
  url 'https://github.com/tuzumkuru/redmine_ai_summary'
  author_url 'https://github.com/tuzumkuru'
  requires_redmine :version_or_higher => '5.0.0'

  # Plugin settings
  settings default: {
    'auto_generate' => false,
    'api_endpoint' => 'https://api.openai.com/v1',
    'api_key' => '',
    'model' => 'gpt-4o-mini',
    'system_prompt' => 'You are a Redmine Issue Summary Agent. Your task is to provide a concise, objective summary of a Redmine issue.
The issue data provided will include:
- subject: The title of the issue.
- description: The initial detailed explanation.
- changes: A chronological list of updates, including code changes and their commit messages.
- notes: All comments and discussions related to the issue.

Your summary should:
- Be a short paragraph, optionally using bullet points for key details.
- Focus on the current status, main problem, key decisions, and any unresolved aspects.
- Avoid repeating information explicitly stated in the subject.
- Be written in simple, clear language understandable to a broad audience.
- Maintain the original language of the issue; do not translate.
- Highlight critical information from the description, recent changes, and notes.',
    'max_completion_tokens' => 1000
  }, partial: 'settings/ai_summary_settings'

  project_module :ai_summary do
    permission :generate_issue_summary, { ai_summaries: [:create] }, public: false
  end

  # Load patches and hooks
  require_dependency File.expand_path('lib/redmine_ai_summary/hooks', __dir__)
  require_dependency File.expand_path('lib/redmine_ai_summary/summary_generator', __dir__)
  require_dependency File.expand_path('lib/redmine_ai_summary/patches/issue_patch', __dir__)
  require_dependency File.expand_path('lib/redmine_ai_summary/patches/journal_patch', __dir__)

end