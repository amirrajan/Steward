class NavScreen < UI::Screen
  include Hiccup
  include Styles

  def status_bar_style
    :hidden
  end

  def markup
    [:view, { background_color: '212225',
              flex: 1,
              justify_content: :center,
              padding_left: 20,
              padding_right: 20 },
     [:button, { id: :enter_expense,
                 title: 'Enter Expense',
                 tap: :enter_expense }],
     [:button, { id: :view_ledger, title: 'View Ledger', tap: :view_ledger }]]
  end

  def enter_expense
    nav_push ExpenseScreen.new
  end

  def view_ledger
    nav_push ViewLedgerScreen.new
  end
end
