class ArticlesController < ApplicationController
  before_filter :authenticate, except: [:index, :show, :archive, :search]
  before_action :set_article, only: [:edit, :update, :destroy]
  before_action :set_parameters_for_sidebar, only: [:index, :search]
  before_action :set_article_by_perma_link, only: [:show]
  before_action :call_auth_if_private_article, only: [:show]
  before_action :count_up, only: [:show]

  # GET /articles
  # GET /articles.json
  def index
    if User.current
      if params[:start] && params[:end]
        articles = Article.visible.where("created_at >= ? and created_at <= ?",
                                 DateTime.parse(params[:start]),
                                 DateTime.parse(params[:end]))
      else
        articles = Article.visible.all
      end
    else
      if params[:start] && params[:end]
        articles = Article.visible.where("approved = ? and created_at >= ? and created_at <= ?",
                                 true,
                                 DateTime.parse(params[:start]),
                                 DateTime.parse(params[:end]))
      else
        articles = Article.visible.where("approved = ?",true)
      end
    end
    @articles = articles.page(params[:page])

    respond_to do |format|
      format.html
      format.json
      format.rss { render layout: false }
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @comment = Comment.new
  end

  # GET /articles/new
  def new
    @article = Article.new
    @article.content = "<!-- folding -->"
    @article.perma_link = User.current.ident + "-" + Time.now.to_s(:perma_link)
    @article.user_id = User.current.id
    @article.published_on = Time.now
    @article.format = "GFM"
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.json
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to action: :show, perma_link: @article.perma_link, notice: 'Article was successfully created.' }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to action: :show, perma_link: @article.perma_link, notice: 'Article was successfully updated.' }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def preview
    if Article.new(article_params).invalid?(:except_preview)
      render text: "Bad request", status: 400
    else
      title =
        """
        <div class='title-bar'>
          <span class='title'>
            #{article_params[:title]}
          </span>
        </div>
        """
      clear = "<div class='clear'></div>"

      render text: title + Kramdown::Document.new(article_params[:content],
                                                  input: article_params[:format],
                                                  syntax_highlighter: :rouge,
                                                  syntax_highlighter_opts: {css_class: 'highlight'}
                                                 ).to_html + clear
    end

  end

  def archive
    year = params[:param].split("-")[0].to_i
    month = params[:param].split("-")[1].to_i

    if month != 0
      start_time = DateTime.new(year, month, 1)
      end_time = (start_time >> 1) - Rational(1, 24 * 60 * 60)
    else
      start_time = DateTime.new(year, 4, 1)
      end_time = DateTime.new(year + 1, 3, 31, 23, 59, 59, 99)
    end

    respond_to do |format|
      format.html { redirect_to action: :index, start: start_time, end: end_time}
    end

  end

  def search
    articles = User.current ? Article.visible.all : Article.visible.approved
    articles = articles.search(params[:query]) if params[:query].present?
    @articles = articles.page(params[:page])
    respond_to do |format|
      format.html { render action: "index" }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_article
    @article = Article.find(params[:id])
  end

  def call_auth_if_private_article
    if !@article.approved
      authenticate()
    end
  end

  def set_article_by_perma_link
    @article = Article.find_by!(perma_link: params[:perma_link])
  end

  def set_parameters_for_sidebar
    @article_all = Article.visible.all
    @comments = Comment.all.slice(0..4)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def article_params
    params.require(:article).permit(:user_id, :title, :perma_link, :content, :published_on, :approved, :count, :promote_headline, :format)
  end

  #count up the number of view
  def count_up
    @article.count = @article.count + 1
    @article.save
  end
end
