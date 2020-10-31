class PagesController < ApplicationController
  def index
    @user = current_user
    @errors ||= nil
    @login ||= true
  end
end