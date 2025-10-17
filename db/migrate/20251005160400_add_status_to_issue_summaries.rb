class AddStatusToIssueSummaries < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_summaries, :status, :string, default: 'stale'
  end
end