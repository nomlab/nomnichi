module ArticlesHelper
  def fold_article(content)
    if /<!-- folding -->/ =~ content then
      $`
    else
      content.split(/\r?\n/)[0, 3].join
    end
  end
end
