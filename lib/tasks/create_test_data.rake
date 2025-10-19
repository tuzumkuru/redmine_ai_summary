namespace :redmine do
  desc "Create a test project and a test issue with a detailed history"
  task create_test_data: :environment do
    # --- 1. SETUP PROJECT AND AUTHOR ---
    project = Project.find_or_create_by!(identifier: "test-project") do |p|
      p.name = "Test Project"
      p.description = "This is a test project."
      puts "Test project created."
    end

    author = User.active.first
    unless author
      puts "No active user found. Please ensure users exist."
      return
    end

    # --- 2. CREATE THE ISSUE (if it doesn't exist) ---
    issue_subject = "Signup confirmation emails not sent"
    issue = Issue.find_or_initialize_by(subject: issue_subject, project_id: project.id)

    if issue.new_record?
      issue.assign_attributes(
        tracker: Tracker.first,
        description: "Users are not receiving signup confirmation emails in production...",
        author: author
      )
      issue.save!
      puts "Test issue created with ID: #{issue.id}"

      # --- 3. ADD SEPARATE UPDATES TO THE ISSUE HISTORY ---
      # Each block now starts by re-finding the issue to guarantee a fresh object.

      # Update 1: Add initial analysis note
      issue = Issue.find(issue.id) # Re-find the issue
      issue.init_journal(author, "Initial analysis: no emails found in the mailer logs for recent signups. Repro steps: 1) Go to /signup 2) Create a new account 3) Observe no confirmation email received.")
      issue.save!
      puts "Added initial note to issue ##{issue.id}."

      # Update 2: Assign, raise priority, and add a note
      issue = Issue.find(issue.id) # Re-find the issue
      assignee = User.active.where.not(id: author.id).first || author
      high_priority = IssuePriority.order(:position).last
      issue.init_journal(author, "Assigning to #{assignee.login} to investigate SMTP and mailer settings.")
      issue.assigned_to = assignee
      issue.priority = high_priority
      issue.save!
      puts "Assigned issue ##{issue.id} to #{assignee.login} and set priority."

      # Update 3: Change status to 'In Progress' without a note
      issue = Issue.find(issue.id) # Re-find the issue
      in_progress_status = IssueStatus.find_by(name: 'In Progress')
      if in_progress_status
        issue.init_journal(assignee) # Journal entry is created by the new assignee
        issue.status = in_progress_status
        issue.save!
        puts "Changed status of issue ##{issue.id} to '#{in_progress_status.name}'."
      end

      # Update 4: Developer adds a follow-up note
      issue = Issue.find(issue.id) # Re-find the issue
      issue.init_journal(assignee, "Follow-up: found MAILER_HOST environment variable missing in production. Will add default and redeploy.")
      issue.save!
      puts "Added developer follow-up note to issue ##{issue.id}."
      
      puts "Successfully created issue ##{issue.id} with multiple history entries."
    else
      puts "Issue with subject '#{issue_subject}' already exists. Skipping."
    end
  end
end