class IssueSummary < ActiveRecord::Base
    belongs_to :issue
    belongs_to :user, foreign_key: :created_by
  
    validates :summary, presence: true
  end
  