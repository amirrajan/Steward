class ViewLedgerScreen < UI::Screen
  include Hiccup
  include Styles

  def status_bar_style
    :hidden
  end

  def markup
    [:view, { background_color: '212225',
              padding_left: 20,
              padding_right: 20 },
     [:button, { id: :enter_expense,
                 title: 'hi',
                 tap: :enter_expense }]]
  end
end
