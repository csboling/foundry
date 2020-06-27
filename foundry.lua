-- foundry - view and modify norns fonts
--
-- E1 at any time to change font
--    hold E1 to see the font name list
--
-- K3 descends down a UI level, K2 ascends
--
-- first level: glyph selector
--   E2 selects x position
--   E3 selects y position

local font_names = {
  '04B_03',
  'ALEPH',
  'Roboto-Thin',
  'Roboto-Light',
  'Roboto-Regular',
  'Roboto-Medium',
  'Roboto-Bold',
  'Roboto-Black',
  'Roboto-ThinItalic.ttf',
  'Roboto-LightItalic.ttf',
  'Roboto-Italic.ttf',
  'Roboto-MediumItalic.ttf',
  'Roboto-BoldItalic.ttf',
  'Roboto-BlackItalic.ttf',
  'VeraBd.ttf',
  'VeraBI.ttf',
  'VeraIt.ttf',
  'VeraMoBd.ttf',
  'VeraMoBI.ttf',
  'VeraMoIt.ttf',
  'VeraMono.ttf',
  'VeraSeBd.ttf',
  'VeraSe.ttf',
  'Vera.ttf',
  'bmp/tom-thumb.bdf',
  'creep.bdf',
  'ctrld-fixed-10b.bdf',
  'ctrld-fixed-10r.bdf',
  'ctrld-fixed-13b.bdf',
  'ctrld-fixed-13b-i.bdf',
  'ctrld-fixed-13r.bdf',
  'ctrld-fixed-13r-i.bdf',
  'ctrld-fixed-16b.bdf',
  'ctrld-fixed-16b-i.bdf',
  'ctrld-fixed-16r.bdf',
  'ctrld-fixed-16r-i.bdf',
  'scientifica-11.bdf',
  'scientificaBold-11.bdf',
  'scientificaItalic-11.bdf',
  'ter-u12b.bdf',
  'ter-u12n.bdf',
  'ter-u14b.bdf',
  'ter-u14n.bdf',
  'ter-u14v.bdf',
  'ter-u16b.bdf',
  'ter-u16n.bdf',
  'ter-u16v.bdf',
  'ter-u18b.bdf',
  'ter-u18n.bdf',
  'ter-u20b.bdf',
  'ter-u20n.bdf',
  'ter-u22b.bdf',
  'ter-u22n.bdf',
  'ter-u24b.bdf',
  'ter-u24n.bdf',
  'ter-u28b.bdf',
  'ter-u28n.bdf',
  'ter-u32b.bdf',
  'ter-u32n.bdf',
  'unscii-16-full.pcf',
  'unscii-16.pcf',
  'unscii-8-alt.pcf',
  'unscii-8-fantasy.pcf',
  'unscii-8-mcr.pcf',
  'unscii-8.pcf',
  'unscii-8-tall.pcf',
  'unscii-8-thin.pcf',
}

font_sel = 1
glyph_sel_x = 7
glyph_sel_y = 3

local show_font_list = false

function init()
  screen.aa(0)
end

function key(n, z)
  if n==1 then
    show_font_list = z == 1
    redraw()
  end
end

function sign(x)
  return (x > 0 and 1) or (x == 0 and 0) or -1
end

function enc(n, d)
  if n == 1 then
    font_sel = util.clamp(font_sel + sign(d), 1, #font_names)
    redraw()
  elseif n == 2 then
    glyph_sel_x = util.clamp(glyph_sel_x + sign(d), 0, 15)
    redraw()
  elseif n == 3 then
    glyph_sel_y = util.clamp(glyph_sel_y + sign(d), 0, 7)
    redraw()
  end
end

function redraw()
  screen.clear()

  local x = 0
  local y = 8
  local l = 0

  if show_font_list then
    local show_font_start = math.max(font_sel - 4, 1)
    local show_font_end = math.min(font_sel + 7, #font_names)
    print('show fonts ' .. show_font_start .. ' thru ' .. show_font_end)
    for i=show_font_start,show_font_end do
      if font_sel == i then
    	l = 10
      else
    	l = 4
      end

      screen.move(x, y)
      screen.font_face(i)
      screen.level(l)
      screen.text(font_names[i])
      y = y + 8
    end
  else
    y = 8

    screen.font_face(font_sel)
    for fy=0,7 do
      x = 0
      for fx=0,15 do
	if glyph_sel_x == fx and glyph_sel_y == fy then
          l = 10
	else
	  l = 4
	end
        screen.move(x, y)
        screen.level(l)
        screen.text(string.char(16*fy + fx))
	x = x + 8
      end
      y = y + 8
    end
  end

  screen.update()
end
