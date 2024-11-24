Redmine::Plugin.register :redmine_ai_summary do
  name 'Redmine Ai Summary plugin'
  author 'Tolga Uzun'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/tuzumkuru/redmine_ai_summary'
  author_url 'https://github.com/tuzumkuru'
  requires_redmine '5.0'

  settings default: {
    'auto_generate' => false,
    'api_address' => '',
    'api_key' => ''
  }, partial: 'settings/ai_summary_settings'
  
  # Add a permission for updating summaries
  project_module :ai_summary do
    permission :update_summaries, { :ai_summary => :update }
  end
end