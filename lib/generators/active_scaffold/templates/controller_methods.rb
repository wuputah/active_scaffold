class <%= controller_class_name %>Controller < ApplicationController
	before_filter  :authorize
  
  <%= template_for_inclusion %>

 	protected

 	# ===================
  # = Authorize BEGIN =
  # ===================
  
  def create_authorized?
    permit? [:super]
  end
  
  def delete_authorized?
    permit? [:super]
  end
  
  def list_authorized?
    permit? [:super]
  end
  
  def show_authorized?
    permit? [:super]
  end
  
  def update_authorized?
    permit? [:super]
  end
  
  # =================
  # = Authorize END =
  # =================

end
