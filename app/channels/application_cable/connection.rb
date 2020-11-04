module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = env['warden']&.user || cookies.encrypted[:session_id]
    end
  end
end
