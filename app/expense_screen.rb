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
    ReverseProxy.debug = 2
    ReverseProxy.delegate = self
    NSURLProtocol.registerClass(ReverseProxy)
    urlAddress = "https://www.saveohno.org/"
    url = NSURL.URLWithString(urlAddress)
    requestObj = NSURLRequest.requestWithURL(url)
    views[:web][:view].proxy.loadRequest(requestObj)
    views[:web][:view].proxy.delegate = self
  end

  def startedLoading url
    puts "started #{url}"
  end

  def completedLoading url
    puts "completed: #{url}"
    intercept('input[name=commit]', 'click', :hello_world)
    # if url =~ /basecamp\.com\/sign_in/
    #   intercept('form', 'submit', :hello_world)
    # elsif url =~ /forgot_password/
    #   intercept('input[name=commit]', 'click', :hello_world)
    #   intercept('input[name=commit]', 'submit', :hello_world)
    # end
  end

  def run_after(delay, &block)
    NSTimer.scheduledTimerWithTimeInterval(
      delay,
      target: block,
      selector: 'call:',
      userInfo: nil,
      repeats: false
    )
  end

  def webView webView, shouldStartLoadWithRequest: request, navigationType: navigation
    if request.URL.absoluteString =~ /^steward:/
      send(request.URL.absoluteString.split(':').last)
      return false
    end

    true
  end

  def hello_world
    flash "it worked"
  end

  def wow
    flash "wow"
  end

  def lol
    flash "lol"
  end

  def query_selector_all css
    value = <<-SCRIPT
      var x = document.querySelectorAll('#{css}');
      var results = [ ];
      var index = 0;
      for(index = 0; index < x.length; index++) {
        console.log(x);
        var attributes = {};
        for (var attributeIndex = 0; attributeIndex < x[index].attributes.length; attributeIndex++) {
          var attribute = x[index].attributes[attributeIndex];
          attributes[attribute.nodeName] = attribute.nodeValue;
        }
        results.push(attributes);
      }
      JSON.stringify(results);
    SCRIPT

    parse(eval_js(value))
  end

  def intercept css, event, method, trys = 0
    success = intercept_js(css, event, method)

    if success
      puts "Found #{css}."
      return
    end

    raise "Can't find #{css}." if trys == 50

    run_after(0.1) do
      intercept css, event, method, trys + 1
    end
  end

  def intercept_js css, event, method
    value = <<-SCRIPT
      if (typeof window.tryApply == "undefined") {
        window.tryApply = function(css, event, method) {
            var x = document.querySelectorAll(css);
            if(x.length == 0) {
              return false;
            }

            x[0].addEventListener(event, function(evt) {
                evt.preventDefault();
                window.location = 'steward:' + method;
                return false;
            });

          return true;
        }
      }

      window.tryApply('#{css}', '#{event}', '#{method}').toString();
    SCRIPT

    return eval_js(value) == 'true'
  end

  class ParserError < StandardError; end

  def parse(str_data)
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
