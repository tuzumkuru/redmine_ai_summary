class IssueSummary < ActiveRecord::Base
  belongs_to :issue
  belongs_to :creator, class_name: 'User', foreign_key: :created_by, optional: true
  belongs_to :updater, class_name: 'User', foreign_key: :updated_by, optional: true

  validates :summary, presence: true, if: :up_to_date?
  validates :issue_id, uniqueness: true

  def up_to_date?
    status == 'up_to_date'
  end
end
