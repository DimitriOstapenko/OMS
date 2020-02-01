module ProductsHelper

  def product_editable?
    current_user && (current_user.admin? || current_user.staff?)
  end
end
