module Hiccup
  class << self
    attr_accessor :currently_focused_control,
                  :current_screen,
                  :platform,
                  :device_screen_height,
                  :device_screen_width
  end

  def self.ios?
    platform == :ios
  end

  def self.android?
    !ios?
  end

  def self.blur
    return unless currently_focused_control
    currently_focused_control.blur
    self.currently_focused_control = nil
  end

  def on_load
    $self = self
    Hiccup.current_screen = self
    render_main_screen
    view.update_layout
    on_load_core if respond_to? :on_load_core
  end

  def before_on_show
    view.background_color = css[:root][:background_color] if css[:root]
    view.children.first.alpha = 0
    animate { view.children.first.alpha = 1 }
  end

  def animate duration = 0.5, &block
    UIView.beginAnimations(nil, context: nil)
    UIView.setAnimationDuration(duration)
    instance_eval(&block)
    UIView.commitAnimations
  end

  def on_show
    navigation.hide_bar
    @flash_container.move_y_to(Hiccup.device_screen_height, false)
    on_show_core if respond_to? :on_show_core
  end

  def hiccup
    @__hiccup ||= {}
    @__hiccup
  end

  def debounce_flash
    hiccup[:flash_timer].stop && hiccup[:flash_timer] = nil if hiccup[:flash_timer]
  end

  def nav_push view
    navigation.push(view, false)
  end

  def nav_pop
    animate { view.children.first.alpha = 0 }
    navigation.pop(false)
  end

  def flash message
    debounce_flash

    @flash_container.alpha = 1
    @flash_container_lookup[:views][:flash_message][:view].text = message
    @flash_container.move_y_to(
      Hiccup.device_screen_height -
      @flash_container.proxy.frame.size.height -
      10,
      true
    )

    hiccup[:flash_timer] = Task.after 3 do
      dismiss_flash
    end
  end

  def dismiss_flash
    debounce_flash
    @flash_container.move_y_to(Hiccup.device_screen_height, true)
  end

  def wire_up_dismiss_keyboard_for_ios
    return unless Hiccup.ios?
    return if @responder
    @recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action: 'blur_current_responder'
    view.proxy.addGestureRecognizer(@recognizer)
  end

  def render_main_screen
    render markup, css, view, hiccup

    wire_up_dismiss_keyboard_for_ios

    @flash_container = UI::View.new
    @flash_container.width = Hiccup.device_screen_width
    @flash_container_lookup = {}
    render flash_view, css, @flash_container, @flash_container_lookup
    @flash_container.update_layout

    UIApplication.sharedApplication.keyWindow.addSubview @flash_container.proxy
  end

  def render definition, styles, parent, lookups
    parent.children.each do |c|
      parent.child c
    end

    views = {}
    classes = {}
    tab_orders = {}
    bar_button_tags = {}

    add_to_parent parent: parent,
                  definition: definition,
                  styles: styles,
                  views: views,
                  classes: classes,
                  tab_orders: tab_orders,
                  control_creation_order: []

    setup_responders views: views, tab_orders: tab_orders, bar_button_tags: bar_button_tags

    lookups[:tab_orders] = tab_orders
    lookups[:views] = views
    lookups[:classes] = classes
    lookups[:bar_button_tags] = bar_button_tags
  end

  def flash_view
    [:view, { id: :flash, padding: 20, class: :flash },
     [:label, { id: :flash_message, text: 'Flash' }]]
  end

  def control_map
    {
      view: UI::View,
      label: UI::Label,
      button: UI:: Button,
      input: UI::TextInput,
      web_view: UI::Web
    }
  end

  def special_keys
    [:id, :tap, :meta, :class, :focus, :proxy, :on_change, :keyboard]
  end

  def set_attribute view, k, v
    return if special_keys.include? k

    # https://github.com/HipByte/Flow/issues/68
    if v == :center
      view.send("#{k}=", :center)
    elsif v == :row
      view.send("#{k}=", :row)
    else
      view.send("#{k}=", v)
    end
  end

  def new_view opts
    view_symbol = opts[:view_symbol]
    attributes = opts[:attributes]
    styles = opts[:styles]

    unless control_map.keys.include? view_symbol
      puts "#{view_symbol} not supported as attributes"
      return nil
    end

    attributes = {} if attributes.is_a? Array

    attributes =
      (styles[view_symbol] || {})
        .merge(styles[attributes[:class]] || {})
        .merge(attributes)

    instance = control_map[view_symbol].new

    if view_symbol == :input
      instance.on(:focus) { Hiccup.currently_focused_control = instance }
      if attributes[:date_picker] && !attributes[:on_change]
        attributes[:on_change] = :__format_date_input
        attributes[:text] = __format_date(*Hiccup.current_date)
      end
    end

    if attributes[:on_change]
      instance.on(:change) { |*args| send(attributes[:on_change], instance, args) }
    end

    if attributes[:keyboard] && attributes[:keyboard] == :numbers_and_punctuation
      if Hiccup.ios?
        instance.proxy.keyboardType = UIKeyboardTypeNumbersAndPunctuation
      end
    end

    if attributes[:proxy]
      attributes[:proxy].each do |k, v|
        instance.proxy.send("#{k}=", v)
      end
    end

    attributes[:tap] && instance.on(:tap) do
      Hiccup.blur
      arity = method(attributes[:tap]).arity
      if arity.zero?
        send(attributes[:tap])
      elsif arity == 1
        send(attributes[:tap], instance)
      else
        send(attributes[:tap], instance, attributes)
      end
    end

    attributes.each do |k, v|
      set_attribute instance, k, v
    end

    instance
  end

  def __format_date_input sender, args
    sender.text = if args.length == 1
                    args.first
                  else
                    __format_date(*args)
                  end
  end

  def __format_date year, month, day
    "#{month}/#{day}/#{year}"
  end

  def control_definition? o
    return false unless o
    return false unless control_map.keys.include? o.first
    true
  end

  def find_first_unbox target, parent
    if target.first.is_a? Array
      find_first_unbox(target.first, target)
    else
      parent
    end
  end

  def last_attribute_definition definition, index = 1
    if definition[index + 1].is_a? Hash
      last_attribute_definition(definition, index + 1)
    else
      index
    end
  end

  def first_control_definition definition
    last_attribute_definition(definition) + 1
  end

  def attribute_definition definition
    last = last_attribute_definition(definition)
    all_attributes = definition[1..last]
    final = {}
    all_attributes.each { |a| final = final.merge(a) }
    final
  end

  def self.generate_string_id
    @id_seed ||= 0
    @id_seed += 1
    @id_seed.to_s
  end

  def self.generate_tag
    @id_seed ||= 0
    @id_seed += 1
  end

  def init_view opts
    definition = opts[:definition]
    styles = opts[:styles]
    views_collection = opts[:views]
    class_collection = opts[:classes]
    control_creation_order = opts[:control_creation_order]
    tab_order_collection = opts[:tab_orders]
    previous_control_id = control_creation_order.last
    view_symbol = definition[0]
    attributes = attribute_definition(definition)

    if view_symbol == :input
      attributes[:id] ||= Hiccup.generate_string_id
    end

    v = new_view view_symbol: view_symbol, attributes: attributes, styles: styles

    control_creation_order << attributes[:id] if attributes[:id]

    hash = { view: v, attributes: attributes, meta: attributes[:meta] }

    if attributes[:id]
      views_collection[attributes[:id]] = hash
    end

    if attributes[:class]
      class_collection[attributes[:class]] ||= []
      class_collection[attributes[:class]] << hash
    end

    if views_collection[previous_control_id] &&
       views_collection[previous_control_id][:view].is_a?(control_map[:input]) &&
       v.is_a?(control_map[:input])
      tab_order_collection[previous_control_id] = attributes[:id]
    end

    v
  end

  def add_to_parent opts
    parent = opts[:parent]
    definition = opts[:definition]
    styles = opts[:styles]
    views_collection = opts[:views]
    class_collection = opts[:classes]
    tab_order_collection = opts[:tab_orders]
    control_creation_order = opts[:control_creation_order]

    return unless definition
    return if definition.is_a?(Array) && definition.empty?

    if definition[0].is_a? Symbol
      v = init_view opts

      content = definition[first_control_definition(definition)..-1]

      add_to_parent parent: v,
                    definition: content,
                    styles: styles,
                    views: views_collection,
                    classes: class_collection,
                    tab_orders: tab_order_collection,
                    control_creation_order: control_creation_order

      parent.add_child v if v
    elsif definition[0].is_a? Array
      find_first_unbox(definition, definition).each do |unboxed|
        add_to_parent parent: parent,
                      definition: unboxed,
                      styles: styles,
                      views: views_collection,
                      classes: class_collection,
                      tab_orders: tab_order_collection,
                      control_creation_order: control_creation_order
      end
    else
      puts "first value of #{definition} wasn't a symbol or array"
    end
  end

  def add_input_accessory view, id, bar_button_tags, has_previous, has_next
    return unless defined? UIBarButtonItem
    return if view.proxy.inputAccessoryView

    next_button = UIBarButtonItem.alloc.initWithTitle('Next', style: UIBarButtonItemStylePlain, target: self, action: 'next_control')
    if has_next
      next_button.tag = Hiccup.generate_tag
      bar_button_tags[next_button.tag] = id
    else
      next_button.tag = -1
      next_button.setTitleTextAttributes({ NSForegroundColorAttributeName => UIColor.grayColor }, forState: UIControlStateNormal)
    end

    prev_button = UIBarButtonItem.alloc.initWithTitle('Prev', style: UIBarButtonItemStylePlain, target: self, action: 'previous_control')
    if has_previous
      prev_button.tag = Hiccup.generate_tag
      bar_button_tags[prev_button.tag] = id
    else
      prev_button.tag = -1
      prev_button.setTitleTextAttributes({ NSForegroundColorAttributeName => UIColor.grayColor }, forState: UIControlStateNormal)
    end

    done_button = UIBarButtonItem.alloc.initWithTitle('Done', style: UIBarButtonItemStyleDone, target: self, action: 'done')
    toolbar = UIToolbar.alloc.initWithFrame [[0, 0], [view.proxy.bounds.size.width, 40]]
    toolbar.items = [
      prev_button,
      next_button,
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target: nil, action: nil),
      done_button
    ]

    view.proxy.inputAccessoryView = toolbar
  end

  def next_control *args
    return if args.tag == -1
    hiccup[:views][hiccup[:tab_orders][hiccup[:bar_button_tags][args.tag]]][:view].focus
  end

  def previous_control *args
    return if args.tag == -1
    hiccup[:views][hiccup[:tab_orders].key(hiccup[:bar_button_tags][args.tag])][:view].focus
  end

  def done *_
    Hiccup.blur
  end

  def setup_responders opts
    views = opts[:views]
    tab_orders = opts[:tab_orders]
    bar_button_tags = opts[:bar_button_tags]

    tab_orders.each do |current_control_id, next_control_id|
      current_control = views[current_control_id][:view]
      next_control = views[next_control_id][:view]

      add_input_accessory current_control, current_control_id, bar_button_tags, tab_orders.key(current_control_id), true
      add_input_accessory next_control, next_control_id, bar_button_tags, true, tab_orders[next_control_id]
    end
  end

  def text id
    hiccup[:views][id][:view].text
  end

  def views
    hiccup[:views]
  end

  def classes
    hiccup[:classes]
  end

  def tab_orders
    hiccup[:tab_orders]
  end

  def blur_current_responder *_
    Hiccup.blur
    dismiss_flash
  end

  def self.current_date
    if ios?
      components =
        NSCalendar.currentCalendar.components(
          NSCalendarUnitDay |
          NSCalendarUnitMonth |
          NSCalendarUnitYear,
          fromDate: NSDate.date
        )

      return [components.year, components.month, components.day]
    end

    calendar = Java::Util::Calendar.getInstance
    year = calendar.get(Java::Util::Calendar::YEAR)
    month = calendar.get(Java::Util::Calendar::MONTH)
    day = calendar.get(Java::Util::Calendar::DAY_OF_MONTH)

    [year, month, day]
  end
end
