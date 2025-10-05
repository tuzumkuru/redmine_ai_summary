module RedmineAiSummary
  module Patches
    module PluginsControllerPatch
      extend ActiveSupport::Concern

      included do
        # Use a conditional lambda for better readability and to keep the method focused.
        prepend_before_action :normalize_redmine_ai_summary_settings,
                              only: %i[configure plugin],
                              if: -> { params[:id] == 'redmine_ai_summary' }
      end

      private

      def normalize_redmine_ai_summary_settings
        settings = params[:settings]

        # This guard protects against GET requests or malformed params by ensuring
        # `settings` is a hash-like object that contains an `api_key`.
        return unless settings.respond_to?(:key?) && (settings.key?('api_key') || settings.key?(:api_key))

        submitted = settings['api_key'] || settings[:api_key]
        sentinel = RedmineAiSummary::Constants::API_KEY_SENTINEL

        # If the submitted value is the placeholder, replace it with the actual saved key.
        if submitted == sentinel
          settings['api_key'] = Setting.plugin_redmine_ai_summary['api_key']
        end
      end
    end
  end
end

# Only include when the controller is loaded to avoid NameError
if defined?(SettingsController) && !SettingsController.included_modules.include?(RedmineAiSummary::Patches::PluginsControllerPatch)
  SettingsController.send(:include, RedmineAiSummary::Patches::PluginsControllerPatch)
end