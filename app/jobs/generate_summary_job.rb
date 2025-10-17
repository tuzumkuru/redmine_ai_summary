class GenerateSummaryJob < ActiveJob::Base
  queue_as :default

  def perform(issue_id, user_id)
    issue = Issue.find_by(id: issue_id)
    user = User.find_by(id: user_id)
    return unless issue && user

    summary = IssueSummary.find_or_initialize_by(issue_id: issue.id)
    summary.status = 'generating'
    summary.save!

    success, _ = RedmineAiSummary::SummaryGenerator.generate(issue, user)

    if success
      summary.update(status: 'up_to_date')
    else
      summary.update(status: 'error')
    end
  end
end