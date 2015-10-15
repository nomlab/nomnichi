class User < ActiveRecord::Base
  has_many :articles
  has_many :comments

  require "digest/sha1"

  validates_uniqueness_of :ident
  validates_uniqueness_of :uid, :scope => :provider

  validates_format_of :ident, :with => /\A[a-zA-Z\d]+(-[a-zA-Z\d]+)*\z/

  def self.current=(user)
    @current_user = user
  end

  def self.current
    @current_user
  end

  def self.authenticate(ident, password)
    user = find_by("ident = ?", ident)
    return false if user.nil?
    pass_sha = Digest::SHA1.hexdigest(user.salt + password)
    return where(["ident=? AND password=?", ident, pass_sha]).first
  end

  # Omniauth-github has these info:
  #   https://github.com/intridea/omniauth-github/blob/master/lib/omniauth/strategies/github.rb
  #
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid      = auth["uid"]
      user.ident    = auth["info"]["nickname"]
    end
  end
end
