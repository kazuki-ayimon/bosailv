require 'rails_helper'

RSpec.describe Api::V1::Admin::TasksController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/api/v1/admin/tasks/create.json').to route_to('api/v1/admin/tasks#create', format: 'json')
    end
    it 'routes to #update' do
      expect(post: '/api/v1/admin/tasks/1/update.json').to route_to('api/v1/admin/tasks#update', id: '1', format: 'json')
    end
    it 'routes to #destroy' do
      expect(post: '/api/v1/admin/tasks/1/delete.json').to route_to('api/v1/admin/tasks#destroy', id: '1', format: 'json')
    end
  end
end
