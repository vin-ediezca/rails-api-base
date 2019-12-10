require 'rails_helper'

describe ArticlesController do
  describe '#index' do
    it 'should return success response' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      FactoryBot.create_list :article, 2
      get :index
      json = JSON.parse(response.body)
      json_data = json['data']
      Article.recent.each_with_index do |article, index|
        expect(json_data[index]['attributes']).to eq({
          "title" => article.title,
          "content" => article.content,
          "slug" => article.slug
        })
      end
    end

    it 'should return articles in proper order' do
      old_article = FactoryBot.create :article
      newer_article = FactoryBot.create :article
      get :index
      json = JSON.parse(response.body)
      json_data = json['data']
      expect(json_data.first['id']).to eq(newer_article.id.to_s)
      expect(json_data.last['id']).to eq(old_article.id.to_s)
    end

    it 'should paginate results' do
      FactoryBot.create_list :article, 3
      get :index, params: { page: 2, per_page: 1}
      json = JSON.parse(response.body)
      json_data = json['data']
      expect(json_data.length).to eq 1
      expected_aricle = Article.recent.second.id.to_s
      expect(json_data.first['id']).to eq(expected_aricle)
    end

    it 'should not include next, last, prev and first link' do
      FactoryBot.create_list :article, 4
      get :index
      json = JSON.parse(response.body)
      json_data = json['links']
      expect(json_data.key?('next')).to eq false
      expect(json_data.key?('last')).to eq false

       get :index, params: {page: 4, per_page: 1}
      json = JSON.parse(response.body)
      json_data = json['links']
      expect(json_data.key?('next')).to eq false
      expect(json_data.key?('last')).to eq false

      get :index, params: {page: -1, per_page: -1}
      json = JSON.parse(response.body)
      json_data = json['links']
      expect(json_data['self']).to_not match(/page=/)
      expect(json_data['self']).to_not match(/per_page=/)
      expect(json_data.key?('next')).to eq false
      expect(json_data.key?('last')).to eq false
      expect(json_data.key?('prev')).to eq false
      expect(json_data.key?('first')).to eq false

      get :index, params: {page: 1, per_page: 1}
      json = JSON.parse(response.body)
      json_data = json['links']
      expect(json_data.key?('prev')).to eq false
      expect(json_data.key?('first')).to eq false

      get :index, params: {page: 1}
      json = JSON.parse(response.body)
      json_data = json['links']
      expect(json_data.key?('prev')).to eq false
      expect(json_data.key?('first')).to eq false
      expect(json_data.key?('next')).to eq false
      expect(json_data.key?('last')).to eq false

      get :index, params: {per_page: 1}
      json = JSON.parse(response.body)
      json_data = json['links']
      expect(json_data.key?('prev')).to eq false
      expect(json_data.key?('first')).to eq false

      get :index, params: {page: 4}
      json = JSON.parse(response.body)
      json_data = json['links']
      expect(json_data['self']).to_not match(/page=/)
      expect(json_data['self']).to_not match(/per_page=/)
      expect(json_data.key?('next')).to eq false
      expect(json_data.key?('last')).to eq false
      expect(json_data.key?('prev')).to eq false
      expect(json_data.key?('first')).to eq false
    end

    it 'should include next, last, prev and first link' do
      FactoryBot.create_list :article, 4
      get :index, params: {page: 1, per_page: 1}
      json = JSON.parse(response.body)
      json_data = json['links']
      expect(json_data.key?('next')).to eq true
      expect(json_data['next']).to match(/page=2{1}/)
      expect(json_data['next']).to match(/per_page=1{1}/)
      expect(json_data.key?('last')).to eq true
      expect(json_data['last']).to match(/page=4{1}/)
      expect(json_data['last']).to match(/per_page=1{1}/)

      get :index, params: {page: 2, per_page: 1}
      json = JSON.parse(response.body)
      json_data = json['links']
      expect(json_data.key?('next')).to eq true
      expect(json_data['next']).to match(/page=3{1}/)
      expect(json_data['next']).to match(/per_page=1{1}/)
      expect(json_data.key?('last')).to eq true
      expect(json_data['last']).to match(/page=4{1}/)
      expect(json_data['last']).to match(/per_page=1{1}/)
      expect(json_data['prev']).to match(/page=1{1}/)
      expect(json_data['prev']).to match(/per_page=1{1}/)
      expect(json_data['first']).to match(/page=1{1}/)
      expect(json_data['first']).to match(/per_page=1{1}/)

      get :index, params: {per_page: 1}
      json = JSON.parse(response.body)
      json_data = json['links']
      expect(json_data.key?('next')).to eq true
      expect(json_data['next']).to match(/page=2{1}/)
      expect(json_data['next']).to match(/per_page=1{1}/)
      expect(json_data.key?('last')).to eq true
      expect(json_data['last']).to match(/page=4{1}/)
      expect(json_data['last']).to match(/per_page=1{1}/)
    end
  end
end