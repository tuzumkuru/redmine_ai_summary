namespace :redmine do
  desc "Create a test project and a test issue"
  task create_test_data: :environment do
    # Check if a project with the identifier already exists
    project_identifier = "test-project"
    existing_project = Project.find_by(identifier: project_identifier)
    if existing_project
      puts "Project with identifier '#{project_identifier}' already exists. Skipping creation."
      project = existing_project
    else
      # Create the test project
      project = Project.new(
        name: "Test Project",
        identifier: project_identifier,
        description: "This is a test project."
      )
      if project.save
        puts "Test project created with ID: #{project.id}"
      else
        puts "Failed to create test project: #{project.errors.full_messages.join(', ')}"
        exit 1
      end
    end

    # Fetch the first user as the author (assuming default data is loaded)
    author = User.active.first
    unless author
      puts "No active user found to set as the author of the issue. Please ensure users exist."
      exit 1
    end

    # Create a test issue if it doesn't already exist
    issue_subject = "Test Issue"
    existing_issue = Issue.find_by(subject: issue_subject, project_id: project.id)
    if existing_issue
      puts "Issue with subject '#{issue_subject}' already exists in the project. Skipping creation."
    else
      issue = Issue.new(
        project_id: project.id,
        tracker: Tracker.first, # Assuming you have at least one tracker
        subject: issue_subject,
        description: "This is a description",
        author_id: author.id
      )
      if issue.save
        puts "Test issue created with ID: #{issue.id}"
      else
        puts "Failed to create test issue: #{issue.errors.full_messages.join(', ')}"
        exit 1
      end
    end
  end
end
