json.success true

json.task do
  json.id @task.id
  json.title @task.title
  json.body @task.body
  json.image_url do
    json.large "#{Settings['base_image_url']}#{@task.image_url(:large)}"
    json.xlarge "#{Settings['base_image_url']}#{@task.image_url(:xlarge)}"
    json.xxlarge "#{Settings['base_image_url']}#{@task.image_url(:xxlarge)}"
  end
end
