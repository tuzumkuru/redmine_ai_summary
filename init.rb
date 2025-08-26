Redmine::Plugin.register :redmine_ai_summary do
  name 'Redmine AI Summary Plugin'
  author 'Tolga Uzun'
  description 'A plugin for generating AI summaries on issues.'
  version '0.0.1'
  url 'https://github.com/tuzumkuru/redmine_ai_summary'
  author_url 'https://github.com/tuzumkuru'
  requires_redmine :version_or_higher => '5.0.0'

  # Plugin settings
  settings default: {
    'auto_generate' => false,
    'api_address' => 'https://api.openai.com',
    'api_key' => '',
    'api_version' => 'v1',
    'model' => 'gpt-4o-mini',
    'system_prompt' => 'You are a Redmine Issue Summary Agent. Your job is to summarize issues given to you.
Each issue has the following information:
- subject: The title of the issue.
- description: A detailed explanation of the issue.
- changes: A list of updates made to the issue, including what was done and when.
- notes: Comments and messages about the issue.
Please summarize the issue in a short paragraph using simple language that anyone can understand.
Additionally, you are welcome to use bullet points.
Do not repeat info like subject etc.
Also, make sure to summarize in the original language of the issue - do not translate it.',
    'max_tokens' => 1000
  }, partial: 'settings/ai_summary_settings'

  project_module :ai_summary do
    permission :generate_issue_summary, { ai_summaries: [:create] }, public: false
  end

  # Load patches and hooks
  require_dependency File.expand_path('lib/redmine_ai_summary/patches/issue_patch', __dir__)
  require_dependency File.expand_path('lib/redmine_ai_summary/hooks', __dir__)

end