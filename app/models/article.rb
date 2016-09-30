class Article < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  validates :user_id, presence: true
  validates :title, presence: true
  validates :perma_link, presence: true, uniqueness: true, unless: proc { [:except_preview].include?(validation_context) }
  validates :format, presence: true, inclusion: {in: ["Kramdown", "GFM"]}

  paginates_per 10

  default_scope { order("published_on desc").visible }
  scope :visible, -> { User.login? ? Article.all : Article.approved }
  scope :approved, -> { where("approved = ?", true) }
  scope :search, ->(query) {
    where("title LIKE ? or content LIKE ?", "%#{query}%", "%#{query}%")
  }

  def previous
    Article.where("published_on < ?", published_on).first
  end

  def next
    Article.where("published_on > ?", published_on).reorder("published_on asc").first
  end
end
