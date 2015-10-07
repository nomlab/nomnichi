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

  def link_to_article_by_perma_link(str, article, option = {})
    link_to str, {controller: :articles, action: :show, perma_link: article.perma_link}, option
  end

  def fold_comment(body)
    comment_size = 40
    if get_str_bytesize(body) > comment_size
      bytes, fold_pos = get_fold_position(body, comment_size)
      return body.slice(0..fold_pos) + " ..."
    else
      return body
    end
  end

  def list_year_archives(articles)
    year_archives = []
    newest_year = articles.first.created_at.year
    oldest_year = articles.last.created_at.year
    newest_year.downto(oldest_year - 1).each do |year|
      start_time = DateTime.new(year, 4, 1)
      end_time = DateTime.new(year + 1, 3, 31, 23, 59, 59, 99)
      item = articles.where("created_at >= ? and created_at <= ?", start_time, end_time).length
      year_archives << {:year => "#{start_time.year}年度", :item => item}
    end
    year_archives.select {|year| year[:item] != 0}
  end

  private

  def get_char_bytesize(c)
    c.bytesize == 1 ? 1 : 2
  end

  def get_str_bytesize(str)
    str.each_char.map {|char| get_char_bytesize(char)}.inject(:+)
  end

  def get_fold_position(str, length)
    bytes = 0
    str.chars.each_with_index do |c, i|
      bytes += get_char_bytesize(c)
      return bytes, i if bytes >= length
    end
  end
end
