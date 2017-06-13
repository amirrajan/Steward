class ViewState
  class << self
    attr_accessor :currently_focused_control, :current_screen
  end

  def self.blur
    return unless currently_focused_control
    currently_focused_control.blur
    currently_focused_control = nil
  end
end
