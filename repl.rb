class ViewLedgerScreen
  def header
    [:view, { flex_direction: :row },
     [:button, { class: :hamburger, tap: :show_menu }],
     [:label, { flex: 1, text: 'Ledger', font: font.merge({ size: 20 }), align_self: :center }],
     [:view, { width: 50 }]]
  end

  def expense_view
    [:view, { border_color: '5f5f60',
              border_width: 1 },
     [:label, { margin_bottom: 0, class: :nasty, text: '$150.00', text_alignment: :left, font: font.merge({ size: 25 }) }],
     [:view, { flex_direction: :row },
      [:label, { flex: 1, margin_left: 30, margin_top: 0, class: :nasty, text: 'Food', text_alignment: :left }],
      [:label, { flex: 1, margin_top: 0, class: :nasty, text: '1/15/2006', text_alignment: :right }]]]
  end

  def css
    Styles.new.css
  end

  def markup
    [:view, { background_color: '212225',
              padding_left: 20,
              padding_right: 20 },
     header,
     expense_view,
     expense_view]
  end
end

$self.render $self.markup, $self.css
