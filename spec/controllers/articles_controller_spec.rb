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

  describe '#show' do
    let(:article) { FactoryBot.create :article }
    subject { get :show, params: { id: article.id } }

    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      subject
      json = JSON.parse(response.body)
      json_data = json['data']
      expect(json_data['attributes']).to eq({
        'title' => article.title,
        'content' => article.content,
        'slug' => article.slug
      })
    end
  end

  describe '#create' do
    subject { post :create }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code is provided' do
      before { request.headers['autorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      let(:access_token) { FactoryBot.create :access_token }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end
        
        subject { post :create, params: invalid_attributes }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should retrun proper json' do
          subject
          json = JSON.parse(response.body)
          expect(json['errors']).to include(
            {
              "status" => "422",
              "source" => { "pointer" => "/data/attributes/title" },
              "title" => "Invalid Attribute",
              "detail" => "can't be blank"
            },
            {
              "status" => "422",
              "source" => { "pointer" => "/data/attributes/slug" },
              "title" => "Invalid Attribute",
              "detail" => "can't be blank"
            },
            {
              "status" => "422",
              "source" => { "pointer" => "/data/attributes/content" },
              "title" => "Invalid Attribute",
              "detail" => "can't be blank"
            }
          )
        end
      end

      context 'when success request sent' do
        let(:valid_attributes) do
          {
            'data' => {
              'attributes' => {
                'title' => 'Article Title',
                'content' => 'Article Content',
                'slug' => 'article-slug'
              }
            }
          }
        end

        subject { post :create, params: valid_attributes }

        it 'should have 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'should have proper json body' do
          subject
          json = JSON.parse(response.body)
          json_data = json['data']
          expect(json_data['attributes']).to include(valid_attributes['data']['attributes'])
        end

        it 'should create the article' do
          expect { subject }.to change { Article.count }.by(1)
        end
      end
    end
  end

  describe '#update' do
    let(:article) { FactoryBot.create :article }
    
    subject { patch :update, params: { id: article.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code is provided' do
      before { request.headers['autorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      let(:access_token) { FactoryBot.create :access_token }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end
        
        subject { patch :update, params: invalid_attributes.merge(id: article.id) }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should retrun proper json' do
          subject
          json = JSON.parse(response.body)
          expect(json['errors']).to include(
            {
              "status" => "422",
              "source" => { "pointer" => "/data/attributes/title" },
              "title" => "Invalid Attribute",
              "detail" => "can't be blank"
            },
            {
              "status" => "422",
              "source" => { "pointer" => "/data/attributes/content" },
              "title" => "Invalid Attribute",
              "detail" => "can't be blank"
            }
          )
        end
      end

      context 'when success request sent' do
        let(:valid_attributes) do
          {
            'data' => {
              'attributes' => {
                'title' => 'Article Title',
                'content' => 'Article Content',
                'slug' => 'article-slug'
              }
            }
          }
        end

        subject { patch :update, params: valid_attributes.merge(id: article.id) }

        it 'should have 200 status code' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'should have proper json body' do
          subject
          json = JSON.parse(response.body)
          json_data = json['data']
          expect(json_data['attributes']).to include(valid_attributes['data']['attributes'])
        end

        it 'should update the article' do
          subject
          expect(article.reload.title).to eq(
            valid_attributes['data']['attributes']['title']
          )
        end
      end
    end
  end
end