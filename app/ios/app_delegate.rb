class AppDelegate
  attr_accessor :window

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    Hiccup.platform = :ios
    Hiccup.device_screen_height = device_screen_height
    Hiccup.device_screen_width = device_screen_width

    NSNotificationCenter.defaultCenter.addObserver(
      self,
      selector: 'keyboard_did_show',
      name: UIKeyboardWillShowNotification,
      object: nil
    )

    NSNotificationCenter.defaultCenter.addObserver(
      self,
      selector: 'keyboard_will_hide',
      name: UIKeyboardWillHideNotification,
      object: nil
    )

    main_screen = NavScreen.new
    navigation = UI::Navigation.new(main_screen)
    main_screen.navigation.push(ExpenseScreen.new, false)
    flow_app = UI::Application.new(navigation, self)
    flow_app.start
  end

  def keyboard_will_hide
    Hiccup.current_screen.view.move_y_to 0, true
  end

  def current_view_y_shift
    Hiccup.current_screen.view.proxy.frame.origin.y
  end

  def keyboard_did_show *notification
    return unless Hiccup.currently_focused_control
    absolute_control_rect = Hiccup.currently_focused_control.proxy.convertRect(
      Hiccup.currently_focused_control.proxy.bounds,
      toView: window
    )

    result =
      calc_behind_keyboard_offset notification.userInfo[UIKeyboardFrameEndUserInfoKey].CGRectValue.size.height,
                                  absolute_control_rect,
                                  device_screen_height

    if result > 0
      Hiccup.current_screen.view.move_y_to 0, true
    else
      Hiccup.current_screen.view.move_y_by result, true
    end
  end

  def calc_behind_keyboard_offset keyboard_height, control_rect, device_height
    bottom = control_rect.origin.y + control_rect.size.height

    top_of_keyboard = device_height - keyboard_height

    (top_of_keyboard - bottom) - 10
  end

  def device_screen_height
    UIScreen.mainScreen.bounds.size.height
  end

  def device_screen_width
    UIScreen.mainScreen.bounds.size.width
  end
end
