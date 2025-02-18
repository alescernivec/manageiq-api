module Api
  class PhysicalStoragesController < BaseController
    def refresh_resource(type, id, _data = nil)
      enqueue_ems_action(type, id, "Refreshing", :method_name => :refresh_ems)
    end

    def create_resource(type, _id = nil, data = {})
      # TODO: introduce supports for ems specific physical storage
      create_ems_resource(type, data) do |ems, klass|
        {:task_id => klass.create_physical_storage_queue(User.current_userid, ems, data)}
      end
    end

    def edit_resource(type, id, data = {})
      raise BadRequestError, "Must specify an id for editing a #{type} resource" unless id

      physical_storage = resource_search(id, type)

      raise BadRequestError, physical_storage.unsupported_reason(:update) unless physical_storage.supports?(:update)

      task_id = physical_storage.update_physical_storage_queue(User.current_user, data)
      action_result(true, "Updating #{physical_storage.name}", :task_id => task_id)
    rescue => err
      action_result(false, err.to_s)
    end

    def delete_resource_action(type, id = nil, _data = nil)
      api_resource(type, id, "Detaching", :supports => :delete) do |physical_storage|
        {:task_id => physical_storage.delete_physical_storage_queue(User.current_user)}
      end
    end
  end
end
