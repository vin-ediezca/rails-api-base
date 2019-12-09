class ArticlesController < ApplicationController
  before_action :set_article, only: [:show]

  def index                                                                            
    paginated = Article.recent.page(params[:page]).per(params[:per_page])
    options = Pagination::PaginationMetaGenerator.new(Article, request: request, total_pages: paginated.total_pages).call

    @articles = ArticleSerializer.new(paginated, options)
    render json: @articles
  end

  def show
    render json: @article
  end

  private
    def set_article
      @article = ArticleSerializer.new(Article.find(params[:id]))
    end
end