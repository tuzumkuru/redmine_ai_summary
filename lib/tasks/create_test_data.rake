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
    issue_subject = "Signup confirmation emails not sent"
    existing_issue = Issue.find_by(subject: issue_subject, project_id: project.id)
    if existing_issue
      puts "Issue with subject '#{issue_subject}' already exists in the project. Skipping creation."
    else
      issue = Issue.new(
        project_id: project.id,
        tracker: Tracker.first, # Assuming you have at least one tracker
        subject: issue_subject,
        description: "Users are not receiving signup confirmation emails in production.\nObserved: multiple users report they never receive the confirmation email after registering.\nExpected: users should receive a confirmation email that contains an activation link.",
        author_id: author.id
      )

      if issue.save
        puts "Test issue created with ID: #{issue.id}"

        # reload to obtain the latest lock_version before further updates
        issue.reload

        # 1) Add an initial note with reproduction steps and observations
        issue.init_journal(author, "Initial analysis: no emails found in the mailer logs for recent signups. Repro steps: 1) Go to /signup 2) Create a new account 3) Observe no confirmation email received.")
        if issue.save
          puts "Added initial note to issue ##{issue.id}."
        else
          puts "Failed to add initial note: #{issue.errors.full_messages.join(', ')}"
        end

        issue.reload

        # 2) Assign to a developer and raise priority with a note describing next actions
        assignee = User.active.where.not(id: author.id).first || author
        high_priority = IssuePriority.order(:id).last || IssuePriority.first
        issue.init_journal(author, "Assigning to #{assignee.login} to investigate SMTP and mailer settings. Will check environment variables and mailer host.")
        issue.assigned_to = assignee
        issue.priority = high_priority
        if issue.save
          puts "Assigned issue ##{issue.id} to #{assignee.login} and set priority to '#{high_priority.name}'."
        else
          puts "Failed to assign or set priority: #{issue.errors.full_messages.join(', ')}"
        end

        issue.reload

        # 3) Change status to 'In Progress' without a note (simulating a status-only update)
        in_progress = IssueStatus.find_by(name: 'In Progress') || IssueStatus.find_by(is_default: false) || IssueStatus.first
        issue.init_journal(author)
        issue.status = in_progress
        # Ensure no notes are saved for this transition
        issue.notes = nil
        if issue.save
          puts "Changed status of issue ##{issue.id} to '#{in_progress.name}' without a note."
        else
          puts "Failed to change status: #{issue.errors.full_messages.join(', ')}"
        end

        issue.reload

        # 4) Developer adds a follow-up note with findings (e.g. missing MAILER_HOST) and marks for fix
        issue.init_journal(assignee, "Follow-up: found MAILER_HOST environment variable missing in production. Will add default and redeploy to staging for verification.")
        issue.status = in_progress
        if issue.save
          puts "Added developer follow-up note to issue ##{issue.id}."
        else
          puts "Failed to add developer note: #{issue.errors.full_messages.join(', ')}"
        end

      else
        puts "Failed to create test issue: #{issue.errors.full_messages.join(', ')}"
        exit 1
      end
    end
  end
end



