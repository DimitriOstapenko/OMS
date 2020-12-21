module ApplicationHelper
       
# Guess device type 	
# /mobile|android|iphone|blackberry|iemobile|kindle/
    def device_type
      ua  = request.user_agent.downcase rescue 'unknown'
      if ua.match(/macintosh|windows|linux/)
	 'desktop'
      else 
	 'mobile'
      end
    end

def device_is_desktop?
  device_type == 'desktop'
end

def mobile_device?
  device_type == 'mobile'
end

def sortable(column, title = nil)
      title ||= ActiveSupport::Inflector.titleize(column)
#      css_class = column == sort_column ? "current #{sort_direction}" : nil
      direction = (sort_direction == "asc") ? "desc" : "asc"
#      link_to title, { direction: direction, sort: column, date: params[:date]}, {class: "hdr-link"}
      link_to title, { direction: direction, sort: column, findstr: params[:findstr] }, class: "hdr-link"
end

# Returns the full title on a per-page basis.
    def full_title(page_title = '')
      base_title = PROJECT_NAME 
      if page_title.empty?
        base_title
      else
        page_title + " | " + base_title
      end
    end

    def short_title
      PROJECT_SHORT_NAME
    end    

    def project_url 
      PROJECT_URL	
    end

    def num_to_phone( phone, area_code = true )
      return '' if phone.blank?
      number_to_phone(phone, area_code: :true)
    end

    def to_currency (number, locale: :fr)
      number_to_currency(number, locale: locale)
    end

# Build suppliers hash     
    def get_suppliers
#      Supplier.all.pluck("CONCAT_WS(' ', fname, lname)",:id).to_h
      Supplier.all.pluck(Arel.sql("CONCAT_WS(' ', fname, lname)"),:id).to_h
    end

# Build managers hash     
    def get_managers
#      Manager.all.pluck("CONCAT_WS(' ', fname, lname)",:id).to_h
      Manager.all.pluck(Arel.sql("CONCAT_WS(' ', fname, lname)"),:id).to_h
    end

# Build array of clients with orders
    def get_clients_with_orders(geo = nil)
      if geo
        orders = Order.where(geo: geo)
      else 
        orders = Order.all
      end

      orders.joins(:client).group(:client_id,:name).reorder('').pluck('name,client_id')
    end

# Return symbol for client type
    def client_category_str(cltype)
      CLIENT_TYPES.invert[category] rescue '' 
    end    
    
# Return symbol for client_mail category
    def client_mail_category_str(category)
      CLIENT_MAIL_CATEGORIES.invert[category] rescue '' 
    end    

# Return symbol for order status
    def order_status_str(status)
      ORDER_STATUSES.invert[status] rescue '' 
    end    

    def cuser
#      User.current_scope
       current_user
    end 


end
