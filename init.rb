Redmine::Plugin.register :redmine_ai_summary do
  name 'Redmine AI Summary Plugin'
  author 'Tolga Uzun'
  description 'A plugin for generating AI summaries on issues.'
  version '0.0.1'
  url 'https://github.com/tuzumkuru/redmine_ai_summary'
  author_url 'https://github.com/tuzumkuru'
  requires_redmine '5.0'

  # Plugin settings
  settings default: {
    'auto_generate' => false,
    'api_address' => '',
    'api_key' => ''
  }, partial: 'settings/ai_summary_settings'

  # Define project module and permissions
  project_module :ai_summary do |ai_summary|
    ai_summary.permission :create_summaries, { ai_summaries: [:create] }
  end

  # Load patches and hooks
  require_dependency File.expand_path('lib/redmine_ai_summary/patches/issue_patch', __dir__)
  require_dependency File.expand_path('lib/redmine_ai_summary/hooks', __dir__)

end