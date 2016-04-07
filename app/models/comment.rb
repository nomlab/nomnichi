class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :article
  default_scope { order("created_at desc").visible }
  scope :visible, -> { User.login? ? Comment.all : Comment.approved }
  scope :approved, -> { joins(:article).where("approved = ?", true) }
end
