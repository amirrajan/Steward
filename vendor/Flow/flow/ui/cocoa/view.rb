module UI
  class View < CSSNode
    ANIMATION_OPTIONS = {
      ease_out: UIViewAnimationOptionCurveEaseOut,
      ease_in:  UIViewAnimationOptionCurveEaseIn,
      linear:   UIViewAnimationOptionCurveLinear
    }

    attr_accessor :_previous_width, :_previous_height

    def animate(options = {}, &block)
      animation_options = options.fetch(:options, :linear)

      UIView.animateWithDuration(options.fetch(:duration, 0),
        delay: options.fetch(:delay, 0),
        options: ANIMATION_OPTIONS.values_at(*animation_options).reduce(&:|),
        animations: lambda {
          self.root.update_layout
        },
        completion: lambda {|completion|
          block.call if block
        })
    end

    def border_width=(width)
      proxy.layer.borderWidth = width
    end

    def border_color=(color)
      proxy.layer.borderColor = UI::Color(color).proxy.CGColor
    end

    def border_radius=(radius)
      layer = proxy.layer
      layer.masksToBounds = !!radius
      layer.cornerRadius = (radius or 0)
    end

    # Shadow attributes are applied on the layer of a separate super view that we create on demand, because it's not possible to have both shadow attributes and other attributes (ex. corner radius) at the same time in UIKit.
    def _shadow_layer
      @_shadow_layer ||= begin
        @_shadow_view = UIView.new
        @_shadow_view.addSubview(proxy)
        layer = @_shadow_view.layer
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer
      end
    end

    def shadow_offset=(offset)
      _shadow_layer.shadowOffset = offset
    end

    def shadow_color=(color)
      _shadow_layer.shadowColor = UI::Color(color).proxy.CGColor
    end

    def shadow_radius=(radius)
      _shadow_layer.shadowRadius = radius
    end

    def border_width=(width)
      proxy.layer.borderWidth = width
    end

    def border_color
      proxy.layer.borderColor
    end

    def border_radius
      proxy.layer.cornerRadius
    end

    def border_width
      proxy.layer.borderWidth
    end

    def background_color
      UI::Color(proxy.backgroundColor)
    end

    def _reset_background_layer(layer=nil)
      @_background_layer.removeFromSuperlayer if @_background_layer
      @_background_layer = layer
    end

    def _layout_background_layer
      @_background_layer.frame = proxy.bounds if @_background_layer
    end

    def background_color=(color)
      proxy.backgroundColor = UI::Color(color).proxy
      _reset_background_layer
    end

    def background_gradient=(gradient)
      layer = gradient.proxy
      proxy.layer.insertSublayer(layer, atIndex:0)
      _reset_background_layer(layer)
      _layout_background_layer
    end

    def hidden?
      proxy.hidden?
    end

    def hidden=(hidden)
      if hidden
        if !self.width.nan?
          self._previous_width = self.width
          self.width = 0
        end

        if !self.height.nan?
          self._previous_height = self.height
          self.height = 0
        end
      else
        self.width = self._previous_width if self._previous_width
        self.height = self._previous_height if self._previous_height
      end

      proxy.hidden = hidden

      self.root.update_layout
    end

    def alpha
      proxy.alpha
    end

    def alpha=(value)
      proxy.alpha = value
    end

    def _proxy_or_shadow_view
      @_shadow_view or proxy
    end

    def add_child(child)
      super
      proxy.addSubview(child._proxy_or_shadow_view)
    end

    def insert_child(index, child)
      super
      proxy.insertSubview(child._proxy_or_shadow_view, atIndex:index)
    end

    def delete_child(child)
      if super
        child._proxy_or_shadow_view.removeFromSuperview
      end
    end

    def update_layout
      super
      _apply_layout([0, 0], _proxy_or_shadow_view.frame.origin)
      _layout_background_layer
    end

    def proxy
      @proxy ||= UIView.alloc.init
    end

    def set_frame(x, y, width, height)
      new_frame = [[x, y], [width, height]]

      if @_shadow_view
        @_shadow_view.frame = new_frame
        new_frame[0] = [0, 0]
      end

      proxy.frame = new_frame
    end

    def move_y_to y, animated = false
      if animated
        UIView.beginAnimations(nil, context:nil)
        UIView.setAnimationDuration(0.25)
        UIView.setAnimationCurve(UIViewAnimationCurveEaseOut)
      end
      set_frame(
        proxy.frame.origin.x,
        y,
        proxy.frame.size.width,
        proxy.frame.size.height
      )
      UIView.commitAnimations if animated
    end

    def move_y_by dy, animated = false
      move_y_to proxy.frame.origin.y + dy, animated
    end

    def _apply_layout(absolute_point, origin_point)
      left, top, width, height = layout

      top_left = [absolute_point[0] + left, absolute_point[1] + top]
      bottom_right = [absolute_point[0] + left + width, absolute_point[1] + top + height]
      set_frame(left + origin_point[0], top + origin_point[1], bottom_right[0] - top_left[0], bottom_right[1] - top_left[1])

      proxy.autoresizingMask = UIViewAutoresizingNone
      proxy.translatesAutoresizingMaskIntoConstraints = true

      absolute_point[0] += left
      absolute_point[1] += top

      children.each { |x| x._apply_layout(absolute_point, [0, 0]) }
    end
  end
end
