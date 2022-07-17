# == Schema Information
#
# Table name: task_achieves
#
#  id                    :bigint           not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  task_id(防災タスクID) :bigint           not null
#  user_id(ユーザーID)   :bigint           not null
#
# Indexes
#
#  index_task_achieves_on_task_id              (task_id)
#  index_task_achieves_on_user_id              (user_id)
#  index_task_achieves_on_user_id_and_task_id  (user_id,task_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (task_id => tasks.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe TaskAchieve, type: :model do
  describe "correct_article_favorite" do
    let(:user) { create(:user) }
    let(:task) { create(:task) }
    let(:task_achieve) { build(:task_achieve, task: task, user: user) }

    it "データが正しく作成されていること" do
      expect(task_achieve).to be_valid
    end
  end

  describe "validate presence" do
    context "userがNULLの時" do
      let(:task_achieve) { build(:task_achieve, user: nil) }
      it "エラーメッセージが返る" do
        task_achieve.valid?
        expect(task_achieve).to be_invalid
      end
    end

    context "taskがNULLの時" do
      let(:task_achieve) { build(:task_achieve, task: nil) }
      it "エラーメッセージが返る" do
        task_achieve.valid?
        expect(task_achieve).to be_invalid
      end
    end
  end

  describe "association" do
    it "Userテーブルに正しく紐づいていること" do
      rel = described_class.reflect_on_association(:user)
      expect(rel.macro).to eq :belongs_to
    end

    it "Taskテーブルに正しく紐づいていること" do
      rel = described_class.reflect_on_association(:task)
      expect(rel.macro).to eq :belongs_to
    end
  end
end
