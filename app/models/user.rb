class User < ActiveRecord::Base
  has_many :articles
  has_many :comments

 require "digest/sha1"

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
end
