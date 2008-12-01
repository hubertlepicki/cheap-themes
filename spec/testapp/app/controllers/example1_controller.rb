class Example1Controller < ApplicationController
  
  has_themable_views :find_view_theme
  has_customizable_actions :find_action_theme

  def index
  end
 
  def find_view_theme
    User.theme
  end

  def find_action_theme
    User.theme
  end
end
