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
   if password.blank?
      return where(["ident=? AND (password=? OR password IS NULL)",
                   ident, password]).first
    else
      salt = find_by("ident = ?", ident).salt
      pass_sha = Digest::SHA1.hexdigest(salt + password)
      return where(["ident=? AND password=?",
                   ident, pass_sha]).first
    end
  end
end
