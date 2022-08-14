json.user do
  json.provider user.provider
  json.upload_image user.image?
  json.image_url do
    json.mini "#{Settings['base_image_url']}#{user.image_url(:mini)}"
    json.small "#{Settings['base_image_url']}#{user.image_url(:small)}"
    json.medium "#{Settings['base_image_url']}#{user.image_url(:medium)}"
    json.large "#{Settings['base_image_url']}#{user.image_url(:large)}"
    json.xlarge "#{Settings['base_image_url']}#{user.image_url(:xlarge)}"
  end
  json.id user.id
  json.name user.name
  json.email user.email
  json.username user.username
  json.level user.level
  json.lifelong_point user.lifelong_point
  json.admin user.is_admin?
  if user.prefecture_id.present?
    json.prefecture do
      json.id @prefecture.id
      json.name @prefecture.name
    end
  end
  if user.city_id.present?
    json.city do
      json.id @city.id
      json.name @city.name
    end
  end
  json.point_to_next user.point_to_next
  json.profile user.profile if user.profile.present?
  json.destroy_schedule_at user.destroy_schedule_at
  json.infomation_unread_count user.infomation_unread_count
  json.required_point @required_point
  json.is_completed_sns_tasks user.prepare_task_profile.sns_tasks.raw == 2097151
  json.is_completed_house_tasks user.prepare_task_profile.house_tasks.raw == 134217727
  json.is_completed_family_rules_tasks user.is_completed_family_rule_tasks?(user)
  json.is_family_present user.families.present?
  json.is_hazard_map_confirmed user.task_profile.hazard_map_confirmed?
end
