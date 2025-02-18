class CreateIssueSummaries < ActiveRecord::Migration[6.1]
  def change
    create_table :issue_summaries do |t|
      t.integer :issue_id
      t.text :summary
      t.integer :created_by
      t.datetime :created_at
    end
    add_index :issue_summaries, :issue_id, unique: true
  end
end
