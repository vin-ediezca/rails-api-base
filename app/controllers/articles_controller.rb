class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: [:index, :show]
  before_action :set_article, only: [:show]

  def index                                                                            
    paginated = Article.recent.page(params[:page]).per(params[:per_page])
    options   = Pagination::PaginationMetaGenerator.new(Article, request: request, total_pages: paginated.total_pages).call
    articles  = ArticleSerializer.new(paginated, options)
    
    render json: articles
  end

  def show
    render json: ArticleSerializer.new(@article)
  end

  def create
    article = current_user.articles.build(article_params)
    article.save!
    render json: ArticleSerializer.new(article), status: :created
  rescue
    render json: ErrorSerializer.new(article), status: :unprocessable_entity
  end

  def update
    article = current_user.articles.find(params[:id])
    article.update!(article_params)
    render json: ArticleSerializer.new(article), status: :ok
  rescue ActiveRecord::RecordNotFound
    authorization_error
  rescue
    render json: ErrorSerializer.new(article), status: :unprocessable_entity
  end

  private
    def set_article
      @article = Article.find(params[:id])
    end

    def article_params
      params.require(:data)
            .require(:attributes)
            .permit(:title, :content, :slug) || ActionController::Parameters.new
    end
end