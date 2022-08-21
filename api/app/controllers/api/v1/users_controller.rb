class Api::V1::UsersController < Api::V1::ApplicationController

  # GET /api/v1/users/ranking(.json) ユーザーランキング取得API
  def index
    # ユーザーを獲得ポイント順に取得
    @users = User.point_ranking.page(params[:page]).per(Settings['default_users_limit'])
    render './api/v1/users/index'
  end

  # GET /api/v1/users/:username(.json) ユーザー情報詳細取得API
  def show
    @user = User.find_by(username: params[:username])

    if @user
      render './api/v1/users/show'
    else
      head :not_found
    end
  end

  # GET /api/v1/users/:username/genres/:id(.json) ユーザーのジャンル別記事一覧取得API
  def genre_articles
    @user = User.find_by(username: params[:username])
    @genre = Genre.find(params[:id])
    if params[:favorite]
      # お気に入りした記事一覧を取得
      @articles = @user.favorited_articles.preload(:genres).page(params[:page]).per(Settings['default_articles_limit']).joins(:article_genre_relations).where("genre_id = #{@genre.id}")
    else
      # 投稿した記事一覧を取得
      @articles = @user.articles.preload(:genres).page(params[:page]).per(Settings['default_articles_limit']).joins(:article_genre_relations).where("genre_id = #{@genre.id}")
    end

    if @user
      render './api/v1/users/genre_articles'
    else
      head :not_found
    end
  end

  # GET /api/v1/users/:username/shelters(.json) ユーザー避難所一覧取得API
  def shelters
    if params[:prefecture_id].present?
      @prefecture = Prefecture.find(params[:prefecture_id]).name
      @city = City.find(params[:id]).name
    else
      @prefecture = Prefecture.find(current_user.prefecture_id).name
      @city = City.find(current_user.city_id).name
    end
    @city_name = @prefecture + @city
  
    @shelters = current_user.registered_shelters.page(params[:page]).per(Settings['default_shelters_limit'])
    @shelters = @shelters.where("city_id = #{params[:id]}") if params[:id]
    @shelters = @shelters.where("#{params[:disaster_type]} = true") if params[:disaster_type]
    render './api/v1/shelters/index'
  end
end
