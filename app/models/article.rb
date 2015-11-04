class Article < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  validates :user_id, presence: true
  validates :title, presence: true
  validates :perma_link, presence: true, uniqueness: true

  paginates_per 10

  default_scope { order("created_at desc") }
end
