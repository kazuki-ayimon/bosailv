class Api::V1::Admin::InfomationsController < Api::V1::ApplicationController
  before_action :redirect_not_admin, only: %i[create destroy]

  # POST /api/v1/admin/infomations/create(.json) お知らせ作成API
  def create
    infomation = Infomation.new(infomation_params)

    if infomation.save
      render './api/v1/success', locals: { notice: I18n.t('notice.infomation.create') }
    else
      render './api/v1/failure', locals: { alert: I18n.t('alert.infomation.create') }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/admin/infomations/:id/delete(.json) お知らせ削除API
  def destroy
    infomation = Infomation.find(params[:id])

    if infomation.destroy
      render './api/v1/success', locals: { notice: I18n.t('notice.infomation.destroy') }
    else
      render './api/v1/failure', locals: { alert: I18n.t('alert.infomation.destroy') }, status: :unprocessable_entity
    end
  end

  private

  def infomation_params
    params.require(:infomation).permit(:label, :title, :summary, :body, :started_at, :ended_at, :force_started_at, :force_ended_at, :target)
  end
end