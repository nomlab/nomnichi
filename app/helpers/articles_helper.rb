module ArticlesHelper
  def fold_article(content)
    if /<!-- folding -->/ =~ content then
      Sanitize.clean($`)
    else
      Sanitize.clean(content.split(/\r?\n/)[0, 3].join)
    end
  end

  def list_headline(nth)
    Article.where(promote_headline: true).order("published_on desc").slice(0..nth)
  end

  def link_to_article_by_perma_link(article, option = {})
    link_to "#{article.title}", {controller: :articles, action: :show, perma_link: article.perma_link}, option
  end
end
