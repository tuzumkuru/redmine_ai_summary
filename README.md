# Redmine AI Summary Plugin

This plugin for Redmine generates AI-powered summaries for issues, providing quick insights and improving project management efficiency.

## Features

*   **Manual Summary Generation**: Generate a summary for any issue with a single click.
*   **Automatic Summary Generation**: Automatically generate a summary when a new note is added to an issue.
*   **Permissions Control**: Fine-grained access control through Redmine's permission system.
*   **Customizable**: Configure the AI model, API endpoint, and prompts to suit your needs.
*   **Localizable**: Easily translate the plugin into different languages.

## How It Works

### Manual Generation

1.  Navigate to any issue in Redmine.
2.  If you have the required permissions, you will see a "Generate Summary" button.
3.  Click the button to generate a new summary. The latest summary will be saved and displayed.

### Automatic Generation

When a user adds a note to an issue, the plugin can automatically trigger the generation of a new summary. This feature can be enabled or disabled in the plugin's settings.

## Installation

1.  **Clone the repository** into your Redmine `plugins` directory:
    ```bash
    cd /path/to/redmine/plugins
    git clone https://github.com/tuzumkuru/redmine_ai_summary.git
    ```
2.  **Install dependencies**:
    ```bash
    cd /path/to/redmine
    bundle install
    ```
3.  **Run database migrations**:
    ```bash
    cd /path/to/redmine
    bundle exec rake redmine:plugins:migrate RAILS_ENV=production
    ```
4.  **Restart Redmine**.

## Configuration

To configure the plugin, go to **Administration > Plugins** and click on **Configure** for the **Redmine AI Summary Plugin**.

*   **Auto Generate**: Enable or disable automatic summary generation when a new note is added.
*   **API Endpoint**: The endpoint of your OpenAI-compatible API.
*   **API Key**: Your API key.
*   **Model**: The AI model to use for summary generation (e.g., `gpt-4o-mini`).
*   **System Prompt**: The instructions given to the AI model on how to summarize the issue.
*   **Max Tokens**: The maximum number of tokens for the generated summary.

## Future Development

To improve performance and user experience, the summary generation process will be moved to a background job. This will prevent delays in the UI when a summary is being generated.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue on the GitHub repository.

## License

This plugin is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
