class AddUpdatedByToIssueSummaries < ActiveRecord::Migration[6.1]
  # Temporary model for data migration
  class IssueSummary < ActiveRecord::Base
  end

  def up
    add_column :issue_summaries, :updated_at, :datetime
    add_column :issue_summaries, :updated_by, :integer

    # Reset column information to make the new columns available
    IssueSummary.reset_column_information

    # Populate existing records using ActiveRecord
    IssueSummary.find_each do |summary|
      summary.update_columns(updated_at: summary.created_at)
    end
  end

  def down
    remove_column :issue_summaries, :updated_at
    remove_column :issue_summaries, :updated_by
  end
end
