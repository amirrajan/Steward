module Styles
  def css
    { root: { background_color: '212225' },
      label: { text_alignment: :center,
               margin: 10,
               color: 'bcc4ca',
               font: font },
      link: { border_width: 0,
              color: :white,
              font: font.merge(size: 20) },
      input: { border_width: 1,
               border_color: '5f5f60',
               background_color: :clear,
               color: 'bcc4ca',
               margin: 5,
               height: 32,
               padding: 20,
               font: font,
               input_offset: 10 },
      flash: { background_color: '363a44', margin: 10 },
      hamburger: { id: :hamburger,
                   background_color: :clear,
                   font: font_awesome,
                   title: '0xf0c9'.hex.chr(Encoding::UTF_8),
                   width: 50, height: 50 },
      button: { color: :white,
                height: 40,
                background_color: '5a82a5',
                border_width: 1,
                border_color: '212225',
                font: font,
                margin: 2 } }
  end

  def font_awesome
    { name: 'FontAwesome', size: 18, extension: :ttf }
  end

  def font
    { name: 'Courier', size: 18 }
  end
end
