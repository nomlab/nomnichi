module ArticlesHelper
  def fold_article(content)
    if /<!-- folding -->/ =~ content then
      $`
    else
      content.split(/\r?\n/)[0, 3].join
    end
  end

  def list_headline(nth)
    Article.where(promote_headline: true).order("published_on desc").slice(0..nth)
  end
end
