class MainActivity < Android::Support::V7::App::AppCompatActivity
  def onCreate(savedInstanceState)
    super
    UI.context = self
    Store.context = self

    main_screen = ExpenseScreen.new
    navigation = UI::Navigation.new(main_screen)
    flow_app = UI::Application.new(navigation, self)
    flow_app.start
  end
end
