class ArticlesController < ApplicationController
  before_filter :authenticate, except: [:index, :show]
  before_action :set_article, only: [:edit, :update, :destroy]
  before_action :set_article_by_perma_link, only: [:show]
  before_action :count_up, only: [:show]

  # GET /articles
  # GET /articles.json
  def index
    if User.current
      if params[:start] && params[:end]
        articles = Article.where("created_at >= ? and created_at <= ?",
                                 DateTime.parse(params[:start]),
                                 DateTime.parse(params[:end])).page(params[:page])
      else
        articles = Article.all.page(params[:page])
      end
    else
      if params[:start] && params[:end]
        articles = Article.where("approved = ? and created_at >= ? and created_at <= ?",
                                 true,
                                 DateTime.parse(params[:start]),
                                 DateTime.parse(params[:end])).page(params[:page])
      else
        articles = Article.where("approved = ?",true).page(params[:page])
      end
    end
    @articles = articles.order("created_at desc")
    @article_all = Article.all.order("created_at desc")
    @comments = Comment.all.order("created_at desc").slice(0..4)
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @comment = Comment.new
  end

  # GET /articles/new
  def new
    @article = Article.new
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
    render text: Kramdown::Document.new(article_params[:content]).to_html
  end

  def archive
    year = params[:year].to_i
    month = params[:month].to_i

    if params[:month] != nil
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

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_article
    @article = Article.find(params[:id])
  end

  def set_article_by_perma_link
    @article = Article.find_by(perma_link: params[:perma_link])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def article_params
    params.require(:article).permit(:user_id, :title, :perma_link, :content, :published_on, :approved, :count, :promote_headline)
  end

  #count up the number of view
  def count_up
    @article.count = @article.count + 1
    @article.save
  end
end
