json.array!(@articles) do |article|
  json.extract! article, :id, :user_id, :title, :perma_link, :content, :published_on, :approved, :count, :promote_headline
  json.url article_url(article, format: :json)
end
