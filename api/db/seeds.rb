Dir.glob("#{Rails.root}/db/seed/*.yml").each do |filename|
  puts "filename: #{filename}"

  target_model = File.basename(filename, '.yml').classify.constantize
  puts "model: #{target_model}"

  File.open(filename) do |file_contents|
    yaml_contents = YAML.safe_load(file_contents)
    yaml_contents.each do |yaml_record|
      id = yaml_record['id']

      if target_model.find_by(id: id)
        puts "id: #{id} Skip create"
        next
      end

      puts "id: #{id} Create"
      target_model.create(yaml_record)
    end
  end
end
