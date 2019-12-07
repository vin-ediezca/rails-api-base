class ArticlesController < ApplicationController
  before_action :set_article, only: [:show]

  def index                                                                            
    paginated = Article.recent.page(params[:page]).per(params[:per_page])
    options = {
      links: {
        first: articles_url(page: '1', per_page: params[:per_page]),
        prev: articles_url(page: prev_page, per_page: params[:per_page]),
        self: articles_url(page: params[:page], per_page: params[:per_page]),
        next: articles_url(page: next_page, per_page: params[:per_page]),
        last: articles_url(page: paginated.total_pages, per_page: params[:per_page])
      }
    }

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

    def prev_page
      paginated = Article.recent.page(params[:page]).per(params[:per_page])
      page = params[:page].to_i
      
      if (page > 1 && page <= paginated.total_pages)
        page -= 1
      else
        1
      end
    end

    def next_page
      paginated = Article.recent.page(params[:page]).per(params[:per_page])
      page = params[:page].to_i
      
      if (page < paginated.total_pages && page >= 1)
        page += 1
      else
        paginated.total_pages
      end
    end
end