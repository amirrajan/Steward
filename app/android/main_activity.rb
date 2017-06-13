class MainActivity < Android::Support::V7::App::AppCompatActivity
  def onCreate(savedInstanceState)
    super

    Hiccup.platform = :android
    Hiccup.device_screen_height = device_screen_height
    UI.context = self
    Store.context = self

    main_screen = ExpenseScreen.new
    navigation = UI::Navigation.new(main_screen)
    flow_app = UI::Application.new(navigation, self)
    flow_app.start
  end

  def device_screen_height
    return @dm.heightPixels if @dm

    @dm = Android::Util::DisplayMetrics.new
    getWindowManager.getDefaultDisplay.getMetrics @dm
    @dm.heightPixels
  end

  def device_screen_width
    return @dm.widthPixels if @dm

    @dm ||= Android::Util::DisplayMetrics.new
    getWindowManager.getDefaultDisplay.getMetrics @dm
    @dm.widthPixels
  end
end
