module Hiccup
  def render definition, styles
    view.children.each do |c|
      view.delete_child c
    end

    if defined? UITapGestureRecognizer
      if !@recognizer
        @recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action: 'blur_current_responder'
        view.proxy.addGestureRecognizer(@recognizer)
      end
    end

    views = {}
    classes = {}
    tab_orders = {}
    bar_button_tags = {}

    add_to_parent parent: view,
                  definition: definition,
                  styles: styles,
                  views: views,
                  classes: classes,
                  tab_orders: tab_orders,
                  control_creation_order: []

    setup_responders views: views, tab_orders: tab_orders, bar_button_tags: bar_button_tags

    @tab_orders = tab_orders
    @views = views
    @classes = classes
    @bar_button_tags = bar_button_tags
  end

  def control_map
    {
      view: UI::View,
      label: UI::Label,
      button: UI:: Button,
      input: UI::TextInput
    }
  end

  def special_keys
    [:id, :tap, :meta, :class, :focus]
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

    attributes.each do |k, v|
      set_attribute instance, k, v
    end

    if view_symbol == :input
      instance.on(:focus) { ViewState.currently_focused_control = instance }
    end

    attributes[:tap] && instance.on(:tap) { send(attributes[:tap], instance, attributes) }

    instance
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

    if has_next
      next_button = UIBarButtonItem.alloc.initWithTitle('Next', style: UIBarButtonItemStylePlain, target: self, action: 'next_control')
      next_button.tag = Hiccup.generate_tag
      bar_button_tags[next_button.tag] = id
    end

    if has_previous
      prev_button = UIBarButtonItem.alloc.initWithTitle('Prev', style: UIBarButtonItemStylePlain, target: self, action: 'previous_control')
      prev_button.tag = Hiccup.generate_tag
      bar_button_tags[prev_button.tag] = id
    end

    done_button = UIBarButtonItem.alloc.initWithTitle('Done', style: UIBarButtonItemStyleDone, target: self, action: 'done')
    toolbar = UIToolbar.alloc.initWithFrame [[0, 0], [view.proxy.bounds.size.width, 44]]
    toolbar.items = [
      prev_button,
      next_button,
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target: nil, action: nil),
      done_button
    ].reject(&:nil?)

    view.proxy.inputAccessoryView = toolbar
  end

  def next_control *args
    @views[@tab_orders[@bar_button_tags[args.tag]]][:view].focus
  end

  def previous_control *args
    @views[@tab_orders.key(@bar_button_tags[args.tag])][:view].focus
  end

  def done *args
    ViewState.blur
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

  def views
    @views
  end

  def classes
    @classes
  end

  def tab_orders
    @tab_orders
  end

  def blur_current_responder *_
    ViewState.blur
  end
end
