# Redmine AI Summary Plugin
## Table of Contents
1. [Introduction](#introduction)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Configuration](#configuration)
7. [Permissions](#permissions)
8. [Localization](#localization)
9. [Contributing](#contributing)
10. [License](#license)
11. [Support](#support)
12. [Roadmap and Future Development](#roadmap-and-future-development)

## Introduction
Redmine AI Summary Plugin is a plugin for Redmine that enables users to generate AI-generated summaries for issues. This functionality enhances the project management experience by providing quick insights into issues through automated summaries.

## Features
* Generate summaries for issues with a single click
* Control access to summary generation through Redmine's permission system
* Fully localizable, allowing for easy translation to different languages
* Configure plugin options including API address and key for potential AI services

## Requirements
* Redmine version 5.0 or later

## Installation
1. **Clone the Plugin Repository**:
   Navigate to your Redmine `plugins` directory and clone the repository:
   ```bash
   cd /path/to/redmine/plugins
   git clone https://github.com/tuzumkuru/redmine_ai_summary.git
   ```
2. **Install Dependencies**:
   Run the following command to install the required gems:
   ```bash
   cd /path/to/redmine
   bundle install
   ```
3. **Migrate the Database**:
   Run the following command to create the necessary database tables:
   ```bash
   cd /path/to/redmine
   bundle exec rake redmine:plugins:migrate RAILS_ENV=production
   ```
4. **Restart Redmine**:
   Restart your Redmine application to load the plugin.

## Usage
### Generating a Summary
1. Navigate to any issue within Redmine.
2. If you have the necessary permissions, you will see a "Generate Summary" button.
3. Click the button to generate a new summary. The latest summary will be saved in the database for future reference.

### Viewing a Summary
1. The most recent summary for each issue will be displayed on the issue details page.
2. If no summary is available, a default message will indicate that no summary is present.

## Configuration
The plugin provides several configuration options:
* **Auto Generate**: Enables or disables auto-generated summaries.
* **API Address**: Specify the address of your own AI service.
* **API Key**: Enter the API key for accessing your AI service.
* **Model**: Select the model to use for generating summaries (default is `gpt-4o-mini`).

### Accessing Settings
1. Go to **Administration > Plugins** in Redmine.
2. Locate the **Redmine AI Summary Plugin** and configure your settings.

## Permissions
The following permission is available:
* **Generate Summaries**: Allows users to generate new summaries.

## Localization
The plugin supports localization and is set to English by default. You can add additional languages by creating new locale files in the `/config/locales` directory.

## Contributing
Contributions are welcome! If you have suggestions for improvements or encounter bugs, feel free to submit an issue or a pull request in the GitHub repository.

## License
This plugin is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Support
For support, please open an issue on the GitHub repository, and we will do our best to assist you.

## Roadmap and Future Development
This is the initial working version of the Redmine AI Summary Plugin. As such, it may contain minor errors or inconsistencies. I will continue to improve the plugin, fixing any issues that arise. Your feedback is appreciated and will help shape the future of this plugin.

---
Thank you for using the Redmine AI Summary Plugin!