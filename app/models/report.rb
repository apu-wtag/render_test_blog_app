class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true
  enum :status, { pending: 0, resolved: 1, dismissed: 2 }
  validates :reportable, presence: true, length: { minimum: 10 }
end
