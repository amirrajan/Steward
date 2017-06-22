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
     [:label, { flex: 1,
                text: 'Budget Simple',
                font: font.merge({ size: 20 }),
                align_self: :center }],
     [:view, { width: 50 }]]
  end

  def expense_form
    [:view, { flex: 1 },
     [:web_view, { id: :web, flex: 1 }]]
  end

  def markup
    [:view, { background_color: '212225', flex: 1 },
     # header,
     expense_form]
  end

  def on_load_core
    urlAddress = "https://3.basecamp.com/sign_in"
    url = NSURL.URLWithString(urlAddress)
    requestObj = NSURLRequest.requestWithURL(url)
    views[:web][:view].proxy.loadRequest(requestObj)
    views[:web][:view].proxy.delegate = self
  end

  def webView _, shouldStartLoadWithRequest: request, navigationType: navigation
    puts request.URL.absoluteString
    true
  end

  def webViewDidStartLoad _
    puts "starting"
  end

  def webViewDidFinishLoad _
    puts query_selector_all('input')
  end

  def query_selector_all css
    value = <<-SCRIPT
      var x = document.querySelectorAll('#{css}');
      var results = [ ];
      var index = 0;
      for(index = 0; index < x.length; index++) {
        results.push({
          id: x[index].getAttribute('id'),
          href: x[index].getAttribute('href'),
          value: x[index].getAttribute('val')
        });
      }
      JSON.stringify(results);
    SCRIPT

    parse(eval_js(value))
  end

  class ParserError < StandardError; end

  def parse(str_data)
    puts str_data
    return nil unless str_data
    data = str_data.respond_to?('dataUsingEncoding:') ? str_data.dataUsingEncoding(NSUTF8StringEncoding) : str_data
    opts = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
    error = Pointer.new(:id)
    obj = NSJSONSerialization.JSONObjectWithData(data, options: opts, error: error)
    raise ParserError, error[0].description if error[0]
    if block_given?
      yield obj
    else
      obj
    end
  end

  def show_menu
    nav_pop
  end

  def eval_js js
    web_view.stringByEvaluatingJavaScriptFromString(js)
  end

  def web_view
    views[:web][:view].proxy
  end

  def save_expense
    flash 'Amount is required.' and return if text(:amount) == ''
    flash 'Category is required.' and return if text(:category) == ''
  end
end
