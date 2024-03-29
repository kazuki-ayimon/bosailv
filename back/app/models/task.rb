# == Schema Information
#
# Table name: tasks
#
#  id              :bigint           not null, primary key
#  body(本文)      :text(4294967295) not null
#  summary(概要)   :string(50)       not null
#  title(タイトル) :string(30)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Task < ApplicationRecord
  has_many :task_completes, dependent: :destroy

  mount_uploader :image, ImageUploader

  validates :image, presence: true
  validates :title, presence: true
  validates :title, length: { maximum: Settings['task_title_maximum'] }
  validates :summary, presence: true
  validates :summary, length: { maximum: Settings['task_summary_maximum'] }
  validates :body, presence: true
  validates :icon, presence: true

  # 画像URLを返却
  def image_url(version)
    case version
    when :large
      image? ? image.large.url : "#{Settings['base_image_url']}/images/task/#{version}_noimage.jpeg"
    when :xlarge
      image? ? image.xlarge.url : "#{Settings['base_image_url']}/images/task/#{version}_noimage.jpeg"
    when :xxlarge
      image? ? image.xxlarge.url : "#{Settings['base_image_url']}/images/task/#{version}_noimage.jpeg"
    else
      logger.warn("[WARN]Not found: Task.image_url(#{version})")
      ''
    end
  end
end
