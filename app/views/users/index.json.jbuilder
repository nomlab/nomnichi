json.array!(@users) do |user|
  json.extract! user, :id, :ident, :password, :salt
  json.url user_url(user, format: :json)
end
