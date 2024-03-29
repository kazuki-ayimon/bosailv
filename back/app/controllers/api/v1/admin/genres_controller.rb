class Api::V1::Admin::GenresController < Api::V1::ApplicationController
  before_action :authenticate_user!, only: %i[create update destroy]
  before_action :redirect_not_admin, only: %i[create update destroy]
  before_action :set_genre, only: %i[update destroy]

  # POST /api/v1/genres/create(.json) ジャンル作成API
  def create
    genre = Genre.new(genre_params)

    p genre
    if genre.save
      render './api/v1/success', locals: { notice: I18n.t('notice.genre.create') }
    else
      render './api/v1/failure', locals: { alert: I18n.t('alert.genre.create') }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/genres/:id/update(.json) 記事更新API(処理)
  def update
    if @genre.update(genre_params)
      render './api/v1/success', locals: { notice: I18n.t('notice.genre.update') }
    else
      render './api/v1/failure', locals: { alert: I18n.t('alert.genre.update') }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/genres/:id/delete(.json) ジャンル削除API
  def destroy
    if @genre.destroy
      render './api/v1/success', locals: { notice: I18n.t('notice.genre.destroy') }
    else
      render './api/v1/failure', locals: { alert: I18n.t('alert.genre.destroy') }, status: :unprocessable_entity
    end
  end

  private

  def set_genre
    @genre = Genre.find(params[:id])
  end

  def genre_params
    params.require(:genre).permit(:name, :image, :description, :icon)
  end
end
