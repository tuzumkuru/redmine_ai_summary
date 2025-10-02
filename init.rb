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
    'api_endpoint' => 'https://api.groq.com/openai/v1',
    'api_key' => '',
    'model' => 'openai/gpt-oss-20b',
        'system_prompt' => File.read(File.join(File.dirname(__FILE__), 'config', 'default_prompt.txt')),
    'max_completion_tokens' => 2000
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