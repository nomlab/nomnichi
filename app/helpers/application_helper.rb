module ApplicationHelper
  def glyphicon(name)
    raw %(<span class="glyphicon glyphicon-#{name}" aria-hidden="true"></span>)
  end

  def root_path
    Rails.application.config.relative_url_root ? Rails.application.config.relative_url_root + "/" : '/'
  end
end
