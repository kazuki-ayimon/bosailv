class Api::V1::ShelterRegistrationsController < Api::V1::ApplicationController
  before_action :authenticate_user!, only: %i[create destroy]
  before_action :set_shelter, only: %i[create destroy]
  before_action :check_count, only: %i[create]

  # POST /api/v1/shelters/:id/shelter_registrations/create(.json) 避難所登録API(処理)
  def create
    if current_user.shelter_registration!(@shelter)
      ActiveRecord::Base.transaction do
        # ポイント獲得
        PointRecorder.new(current_user).record(Settings['shelter_registration_obtained_point'])

        render './api/v1/auth/success', locals: { notice: I18n.t('notice.shelter_registration.create') }
      end
    else
      render './api/v1/failure', locals: { alert: I18n.t('alert.shelter_registration.create') }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/shelters/:id/shelter_registrations/delete(.json) 避難所登録解除API(処理)
  def destroy
    if current_user.shelter_unregistration!(@shelter)
      ActiveRecord::Base.transaction do
        # ポイントを減らす
        PointRecorder.new(current_user).delete_record(Settings['shelter_registration_obtained_point'])

        render './api/v1/auth/success', locals: { notice: I18n.t('notice.shelter_registration.destroy') }
      end
    else
      render './api/v1/failure', locals: { alert: I18n.t('alert.shelter_registration.destroy') }, status: :unprocessable_entity
    end
  end

  private

  def set_shelter
    @shelter = Shelter.find(params[:id])
  end

  def check_count
    return if current_user.registered_shelters.count < Settings['maximum_registered_shelters_length']

    render './api/v1/failure', locals: { alert: I18n.t('alert.shelter_registration.create') }, status: :unprocessable_entity
  end
end
