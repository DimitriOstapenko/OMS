class RoleRouteConstraint
  def initialize(&block)
    @block = block || lambda { |user| true }
  end

  def matches?(request)
    current_user.present? && @block.call(current_user)
  end

end
