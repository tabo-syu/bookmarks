# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :loggedin_user

  private

  def loggedin_user
    @user = current_user
  end
end
