xml.instruct! :xml, :version => "1.0"
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title "Nomnichi articles"
    xml.author "Nomura laboratory"
    xml.link url_for(controller: "articles", action: "index")

    @articles.each do |article|
      url = url_for(controller: "articles", action: "show", perma_link: article.perma_link, only_path: false)
      xml.item do
        xml.title article.title
        xml.author article.user.ident
        xml.description fold_article(article.content)
        xml.pubDate article.published_on.to_s(:rfc822)
        xml.guid url
        xml.link url
      end
    end
  end
end
