class ArticlesController < ApplicationController
  before_action :set_article, only: [:show]

  def index
    @articles = ArticleSerializer.new(Article.recent)
    render json: @articles
  end

  def show
  end

  private
    def set_article
      @article = ArticleSerializer.new(Article.find(params[:id]))
    end
end