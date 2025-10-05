class GenerateSummaryJob < ActiveJob::Base
  queue_as :default

  def perform(issue_id, user_id)
    issue = Issue.find_by(id: issue_id)
    user = User.find_by(id: user_id)
    return unless issue && user

    summary = IssueSummary.find_or_initialize_by(issue_id: issue.id)
    summary.status = 'generating'
    summary.save!

    generated_summary = RedmineAiSummary::SummaryGenerator.generate(issue, user)

    if generated_summary
      summary.status = 'up_to_date'
      summary.save!
    else
      summary.status = 'stale'
      summary.save!
    end
  end
end