class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: [:index, :show]
  before_action :article, only: [:show]

  def index                                                                            
    paginated = Article.recent.page(params[:page]).per(params[:per_page])
    options   = Pagination::PaginationMetaGenerator.new(Article, request: request, total_pages: paginated.total_pages).call
    articles  = ArticleSerializer.new(paginated, options)
    
    render json: articles
  end

  def show
    render json: article
  end

  def create
    article = Article.new(article_params)

    if article.valid?
      # render json: ArticleSerializer.new(article)
    else
      render json: ErrorSerializer.new(article).call, status: 422
    end
  end

  private
    def article
      ArticleSerializer.new(Article.find(params[:id]))
    end

    def article_params
      ActionController::Parameters.new
      # params.require(:article).allow(:title, :content, :slug)
    end
end