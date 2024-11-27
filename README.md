# Redmine AI Summary Plugin

**Redmine AI Summary Plugin** is a plugin for Redmine that enables users to generate AI-generated summaries for issues. This functionality enhances the project management experience by providing quick insights into issues through automated summaries.

## Features

- **Generate Summaries**: Automatically generate summaries for issues with a single click.
- **User Permissions**: Control access to summary generation through Redmine's permission system.
- **Localizable**: The plugin is fully localizable, allowing for easy translation to different languages.
- **Settings**: Configure plugin options including API address and key for potential AI services.

## Requirements

- Redmine version 5.0 or later
- Ruby on Rails framework compatible with your Redmine installation

## Installation

1. **Clone the Plugin Repository**:
   Navigate to your Redmine `plugins` directory and clone the repository:

   ```bash
   cd /path/to/redmine/plugins
   git clone https://github.com/tuzumkuru/redmine_ai_summary.git
   ```

2. **Migrate the Database**:
   Run the following command to create the necessary database tables:

   ```bash
   cd /path/to/redmine
   bundle exec rake redmine:plugins:migrate RAILS_ENV=production
   ```

3. **Restart Redmine**:
   Restart your Redmine application to load the plugin.

## Usage

### Generating a Summary

- Navigate to any issue within Redmine.
- If you have the necessary permissions, you will see a "Generate Summary" button.
- Click the button to generate a new summary. The latest summary will be saved in the database for future reference.

### Viewing a Summary

- The most recent summary for each issue will be displayed on the issue details page.
- If no summary is available, a default message will indicate that no summary is present.

## Configuration

The plugin provides several configuration options:

- **Auto Generate**: Enables or disables auto-generated summaries.
- **API Address**: Specify the address of the AI service if applicable.
- **API Key**: Enter the API key for accessing the AI service.

### Accessing Settings

1. Go to **Administration > Plugins** in Redmine.
2. Locate the **Redmine AI Summary Plugin** and configure your settings.

## Permissions

The following permission is available:

- **Create Summaries**: Allows users to generate new summaries.

Ensure that this permission is assigned appropriately in the project settings.

## Localization

The plugin supports localization and is set to English by default. You can add additional languages by creating new locale files in the `/config/locales` directory.

## Contributing

Contributions are welcome! If you have suggestions for improvements or encounter bugs, feel free to submit an issue or a pull request in the GitHub repository.

## License

This plugin is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Support

For support, please open an issue on the GitHub repository, and we will do our best to assist you.

---

Thank you for using the Redmine AI Summary Plugin!