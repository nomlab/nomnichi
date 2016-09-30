# coding: utf-8
module ArticlesHelper
  def fold_article(content)
    if /<!-- folding -->/ =~ content then
      Sanitize.clean($`)
    else
      Sanitize.clean(content.split(/\r?\n/)[0, 3].join)
    end
  end

  def list_headline(nth)
    Article.visible.where(promote_headline: true).order("published_on desc").slice(0..nth)
  end

  def link_to_article_by_perma_link(str, article, option = {})
    link_to str, {controller: :articles, action: :show, perma_link: article.perma_link}, option
  end

  def fold_comment(body)
    comment_size = 30
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
      item = articles.where("created_at >= ? and created_at <= ?", start_time, end_time)
      item = item.where("approved = ?", true) unless User.current
      year_archives << {:year => "#{start_time.year}", :item => item.length, :month => list_month_archives(item, start_time.year)} unless item.empty?
    end
    year_archives.select
  end

  def list_month_archives(articles, year)
    month_archives = []
    newest_month = articles.first.created_at.month
    oldest_month = articles.last.created_at.month
    ["04","05","06","07","08","09","10","11","12","01","02","03"].each do |month|
      item = articles.where("strftime('%m',created_at) = ?",month)
      item = item.where("approved = ?", true) unless User.current
      if ["01", "02", "03"].include?(month)
        month_archives << {:month => "#{month}", :item => item.length, :param => (year + 1).to_s + "-" + month}
      else
        month_archives << {:month => "#{month}", :item => item.length, :param => year.to_s + "-" + month}
      end
    end
    month_archives.select {|month| month[:item] != 0}
  end

  def tweet_button(title, author)
    str = "<a href='https://twitter.com/share' class='twitter-share-button' data-url='#{request.url}' data-text='#{title} by #{author}  - ノムニチ'></a>".html_safe
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
