Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # ユーザー
      get  'users',                      to: 'users#index',          as: 'users'
      get  'users/:username',            to: 'users#show',           as: 'show_users'
      get  'users/:username/genres/:id', to: 'users#genre_articles', as: 'genre_articles_users'
      
      # 記事
      get  'articles',            to: 'articles#index',        as: 'articles'
      post 'articles/create',     to: 'articles#create',       as: 'create_article'
      post 'articles/:id/update', to: 'articles#update',       as: 'update_article'
      post 'articles/:id/delete', to: 'articles#destroy',      as: 'destroy_article'
      get  'articles/search',     to: 'articles#search',       as: 'search_articles'
      get  'articles/:id',        to: 'articles#show',         as: 'article'

      # 記事コメント
      post 'article_comments/create',     to: 'article_comments#create',    as: 'create_comment'
      post 'article_comments/:id/delete', to: 'article_comments#destroy',   as: 'delete_comment'

      # 記事お気に入り
      post 'articles/:id/article_favorites/create', to: 'article_favorites#create',    as: 'favorite_article'
      post 'articles/:id/article_favorites/delete', to: 'article_favorites#destroy',   as: 'unfavorite_article'

      # ジャンル
      get  'genres',              to: 'genres#index',   as: 'genres'
      get  'genres/:id',          to: 'genres#show',    as: 'show_genre'

      # お知らせ
      get  'infomations',            to: 'infomations#index',     as: 'infomations'
      get  'infomations/important',  to: 'infomations#important', as: 'important_infomations'
      get  'infomations/:id',        to: 'infomations#show',      as: 'infomation'
      post 'infomations/create',     to: 'infomations#create',    as: 'create_infomation'
      post 'infomations/:id/delete', to: 'infomations#destroy',   as: 'destroy_infomation'

      # 市町村
      get 'set_cities/:id', to: 'cities#set_cities', as: 'set_cities'
    end
  end

  scope :api do
    scope :v1 do
      # Devise Token Auth
      devise_for :users, skip: :all
      devise_scope :user do
        post 'auth/sign_up',         to: 'api/v1/auth/registrations#create',             as: 'create_auth_registration'
        post 'auth/update',          to: 'api/v1/auth/registrations#update',             as: 'update_auth_registration'
        post 'auth/image/update',    to: 'api/v1/auth/registrations#image_update',       as: 'update_auth_image_registration'
        post 'auth/image/delete',    to: 'api/v1/auth/registrations#image_destroy',      as: 'delete_auth_image_registration'
        post 'auth/delete',          to: 'api/v1/auth/registrations#destroy',            as: 'destroy_auth_registration'
        post 'auth/confirmation',    to: 'api/v1/auth/confirmations#create',             as: 'create_auth_confirmation'
        get  'auth/confirmation',    to: 'api/v1/auth/confirmations#show',               as: 'auth_confirmation'
        post 'auth/sign_in',         to: 'api/v1/auth/sessions#create',                  as: 'create_auth_session'
        post 'auth/guest_sign_in',   to: 'api/v1/auth/sessions#create_guest',            as: 'create_guest_auth_session'
        post 'auth/sign_out',        to: 'api/v1/auth/sessions#destroy',                 as: 'destroy_auth_session'
        post 'auth/unlock',          to: 'api/v1/auth/unlocks#create',                   as: 'create_auth_unlock'
        get  'auth/unlock',          to: 'api/v1/auth/unlocks#show',                     as: 'auth_unlock'
        post 'auth/password',        to: 'api/v1/auth/passwords#create',                 as: 'create_auth_password'
        get  'auth/password',        to: 'api/v1/auth/passwords#edit',                   as: 'edit_auth_password'
        post 'auth/password/update', to: 'api/v1/auth/passwords#update',                 as: 'update_auth_password'
        get  'auth/validate_token',  to: 'api/v1/auth/token_validations#validate_token', as: 'auth_validate_token'
      end
    end
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
