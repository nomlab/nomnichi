class WelcomeController < ApplicationController
  skip_before_filter :authenticate

  def index
    @headline = ArticlesController.helpers.list_headline(4)
  end
end
