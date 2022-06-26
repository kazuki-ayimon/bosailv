# == Schema Information
#
# Table name: prefectures
#
#  id               :bigint           not null, primary key
#  name(都道府県名) :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_prefectures_on_name  (name) UNIQUE
#
require 'rails_helper'

RSpec.describe Prefecture, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
