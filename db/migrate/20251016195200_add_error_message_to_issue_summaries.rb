class AddErrorMessageToIssueSummaries < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_summaries, :error_message, :text
  end
end