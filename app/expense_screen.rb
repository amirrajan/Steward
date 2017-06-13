# coding: utf-8
class ExpenseScreen < UI::Screen
  include Hiccup
  include Styles

  def status_bar_style
    :hidden
  end

  def header
    [:view, { flex_direction: :row },
     [:button, { class: :hamburger, tap: :show_menu }],
     [:label, { flex: 1, text: 'Budget Simple', font: font.merge({ size: 20 }),
                align_self: :center }],
     [:view, { width: 50 }]]
  end

  def expense_form
    [:view, { padding_left: 0, padding_right: 0, flex: 1 },
     [:web_view, { id: :web, flex: 1 }]]
  end

  def markup
    [:view, { background_color: '212225', flex: 1 },
     header,
     expense_form]
  end

  def on_load_core
    urlAddress = "http://www.apple.com"
    url = NSURL.URLWithString(urlAddress)
    requestObj = NSURLRequest.requestWithURL(url)
    views[:web][:view].proxy.loadRequest(requestObj)
  end

  def show_menu
    nav_pop
  end

  def save_expense
    flash 'Amount is required.' and return if text(:amount) == ''
    flash 'Category is required.' and return if text(:category) == ''
  end
end
