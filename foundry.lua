-- foundry - view norns fonts
--
-- E1 at any time to change font
--    hold E1 to see font names
--
-- K3 descends down a UI level
-- K2 ascends up a UI level
--
-- first level: glyph selector
--   E2 selects y position
--
--   E3 selects x position
--
--   hold K2: y scrolls 8x
--
-- second level: glyph viewer
--   E2 selects parameter
--
--   E3 selects parameter value
--
--   hold K3: scroll glyphs 100x
--
--   press K3 on 'code':
--   print glyph drawing code to
--   the console (maiden)
--
--   press K3 on 'text':
--   enter text input mode
--
-- third level: text input
--   attach a keyboard to
--   type example text
--   K3 to clear

local keycodes = include("lib/keycodes")

local font_names = {
  '04B_03',
  'ALEPH',
  'Roboto-Thin',
  'Roboto-Light',
  'Roboto-Regular',
  'Roboto-Medium',
  'Roboto-Bold',
  'Roboto-Black',
  'Roboto-ThinItalic',
  'Roboto-LightItalic',
  'Roboto-Italic',
  'Roboto-MediumItalic',
  'Roboto-BoldItalic',
  'Roboto-BlackItalic',
  'VeraBd',
  'VeraBI',
  'VeraIt',
  'VeraMoBd',
  'VeraMoBI',
  'VeraMoIt',
  'VeraMono',
  'VeraSeBd',
  'VeraSe',
  'Vera',
  'bmp/tom-thumb',
  'creep',
  'ctrld-fixed-10b',
  'ctrld-fixed-10r',
  'ctrld-fixed-13b',
  'ctrld-fixed-13b-i',
  'ctrld-fixed-13r',
  'ctrld-fixed-13r-i',
  'ctrld-fixed-16b',
  'ctrld-fixed-16b-i',
  'ctrld-fixed-16r',
  'ctrld-fixed-16r-i',
  'scientifica-11',
  'scientificaBold-11',
  'scientificaItalic-11',
  'ter-u12b',
  'ter-u12n',
  'ter-u14b',
  'ter-u14n',
  'ter-u14v',
  'ter-u16b',
  'ter-u16n',
  'ter-u16v',
  'ter-u18b',
  'ter-u18n',
  'ter-u20b',
  'ter-u20n',
  'ter-u22b',
  'ter-u22n',
  'ter-u24b',
  'ter-u24n',
  'ter-u28b',
  'ter-u28n',
  'ter-u32b',
  'ter-u32n',
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
font_size = 8
font_level = 10
glyph_sel = 48
glyph_sel_x = 0
glyph_sel_y = 3
font_param_sel = 1
antialias = 0
glyph_fastforward = false
keys_held = {false, false}
text_lines = {''}

-- 'glyphsel', 'glyphviz', 'textinput'
ui_page = 'glyphsel'

MAX_GLYPH = 32767

function sign(x)
  return (x > 0 and 1) or (x == 0 and 0) or -1
end

function encode_glyph(x)
  return '\\u{' .. string.format('%03x', x) .. '}'
end

function set_glyph(i)
  glyph_sel = i
  glyph_sel_y = math.floor(glyph_sel / 16)
  glyph_sel_x = glyph_sel % 16
end

function glyph_delta(d)
  local change = sign(d)
  if glyph_fastforward then
    change = change * 100
  end
  set_glyph(util.clamp(glyph_sel + change, 0, MAX_GLYPH))
end

local font_params = {
  {
    name = 'glyph',
    show = function() return string.format('%d', glyph_sel) end,
    delta = function(d)
      if d == 0 then return end
      glyph_delta(d)
      redraw()
    end,
    click = function(z)
      glyph_fastforward = z == 1
    end,
  },
  {
    name = 'size',
    show = function() return string.format('%d', font_size) end,
    delta = function(d)
      if d == 0 then return end
      font_size = util.clamp(font_size + sign(d), 1, 64)
      redraw()
    end,
  },
  {
    name = 'level',
    show = function() return string.format('%d', font_level) end,
    delta = function(d)
      if d == 0 then return end
      font_level = util.clamp(font_level + sign(d), 0, 15)
      redraw()
    end,
  },
  {
    name = 'aa',
    show = function() return antialias and 'on' or 'off' end,
    delta = function(d)
      if d == 0 then return end
      antialias = not antialias
      screen.aa(antialias and 1 or 0)
      redraw()
    end,
    click = function(z)
      if z == 0 then return end
      antialias = not antialias
      screen.aa(antialias and 1 or 0)
      redraw()
    end,
  },
  {
    name = 'code',
    show = function()
      return encode_glyph(glyph_sel)
    end,
    delta = function(d)
      if d == 0 then return end
      glyph_delta(d)
      redraw()
    end,
    click = function(z)
      if z == 0 then return end
      print('screen.level(' .. font_level .. ')')
      print('screen.font_face(' .. font_sel .. ')')
      print('screen.font_size(' .. font_size .. ')')
      print('screen.text(\'' .. encode_glyph(glyph_sel) .. '\')')
    end,
  },
  {
    name = 'text',
    click = function(z)
      if z == 0 then return end
      ui_page = 'textinput'
      glyph_fastforward = false
    end
  },
}

local show_font_list = false

function init()
  screen.aa(0)

  keyb = hid.connect()
  keyb.event = keyboard_event
end

-- gpio
function key(n, z)
  if n==1 then
    show_font_list = z == 1
    redraw()
  elseif n == 2 then
    if ui_page == 'glyphviz' then
      ui_page = 'glyphsel'
      glyph_fastforward = false
      redraw()
    elseif ui_page == 'glyphsel' then
      glyph_fastforward = z == 1
    elseif ui_page == 'textinput' then
      ui_page = 'glyphviz'
      redraw()
    end
  elseif n == 3 then
    if ui_page == 'glyphsel' then
      glyph_fastforward = false
      ui_page = 'glyphviz'
    elseif ui_page == 'glyphviz' then
      local font_param = font_params[font_param_sel]
      if font_param.name ~= 'glyph' then
        glyph_fastforward = 1
      end
      if font_param.click ~= nil then
        font_param.click(z)
      end
    elseif ui_page == 'textinput' and z == 1 then
      text_lines = {''}
      redraw()
    end
    redraw()
  end
end

function enc(n, d)
  if n == 1 then
    font_sel = util.clamp(font_sel + sign(d), 1, #font_names)
    redraw()
  else
    -- glyph select
    if ui_page == 'glyphsel' then
      if n == 2 then
        local change = sign(d)
        if glyph_fastforward then
          change = change * 8
        end
        glyph_sel_y = util.clamp(glyph_sel_y + change, 0, MAX_GLYPH / 16)
        set_glyph(16*glyph_sel_y + glyph_sel_x)
        redraw()
      elseif n == 3 then
        glyph_sel_x = util.clamp(glyph_sel_x + sign(d), 0, 15)
        set_glyph(16*glyph_sel_y + glyph_sel_x)
        redraw()
      end
    -- glyph viewer
    elseif ui_page == 'glyphviz' then
      if n == 2 then
        font_param_sel = util.clamp(font_param_sel + sign(d), 1, #font_params)
        redraw()
      elseif n == 3 then
        local font_param = font_params[font_param_sel]
        if font_param.delta ~= nil then
         font_param.delta(d)
        end
      end
    end
  end
end

-- keyboard
function get_key(code, val, shift)
  if keycodes.keys[code] ~= nil and val == 1 then
    if shift then
      if keycodes.shifts[code] ~= nil then
        return keycodes.shifts[code]
      else
        return keycodes.keys[code]
      end
    else
      return string.lower(keycodes.keys[code])
    end
  end
end

shift_held = false
function keyboard_event(typ, code, val)
  if code == hid.codes.KEY_BACKSPACE and val > 0 then
    backspace()
  elseif code == hid.codes.KEY_LEFTSHIFT or code == hid.codes.KEY_RIGHTSHIFT then
    if val == 1 then
      shift_held = true
    else
      shift_held = false
    end
  end
  keyinput = get_key(code, val, shift_held)
  if keyinput ~= nil then
    keystroke(keyinput)
  end
end

function keystroke(k)
  if ui_page == 'textinput' then
    local new_text = text_lines[#text_lines] .. k
    screen.font_face(font_sel)
    screen.font_size(font_size)
    local text_width = screen.text_extents(new_text)
    if text_width > 128 then
      if (#text_lines + 1) * font_size > 64 then
        return
      end
      text_lines[#text_lines + 1] = k
    else
      text_lines[#text_lines] = new_text
    end
    redraw()
  end
end

function backspace()
  if ui_page == 'textinput' then
    local line = text_lines[#text_lines]
    local line_len = string.len(line)
    if line_len == 0 then
      if #text_lines == 1 then
        return
      else
        table.remove(text_lines)
        line = text_lines[#text_lines]
        line_len = string.len(line)
      end
    end
    text_lines[#text_lines] = string.sub(line, 0, line_len - 1)
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
    for i=show_font_start,show_font_end do
      if font_sel == i then
        l = 10
      else
        l = 4
      end

      screen.move(x, y)
      screen.font_face(i)
      screen.font_size(8)
      screen.level(l)
      screen.text(font_names[i])

      y = y + 8
    end
  else
    if ui_page == 'glyphsel' then
      local glyph_y_start = math.max(glyph_sel_y - 3, 1)
      local glyph_y_end = math.min(glyph_sel_y + 7, MAX_GLYPH / 16)

      y = 8

      screen.font_face(font_sel)
      for fy=glyph_y_start,glyph_y_end do
        x = 0
        for fx=0,15 do
          if glyph_sel_x == fx and glyph_sel_y == fy then
            l = 10
          else
            l = 4
          end
          screen.move(x, y)
          screen.level(l)
          screen.font_size(8)
          screen.text(utf8.char(16*fy + fx))
          x = x + 8
        end
        y = y + 8
      end
    elseif ui_page == 'glyphviz' then
      x = 0
      y = font_size
      l = 10

      screen.move(x, y)
      screen.level(font_level)
      screen.font_face(font_sel)
      screen.font_size(font_size)
      screen.text(utf8.char(glyph_sel))

      x = 48
      y = 0
      screen.font_size(8)
      screen.font_face(1)

      y = y + 8
      screen.move(x, y)
      screen.level(1)
      screen.text(font_sel .. ' ' .. font_names[font_sel])

      for i=1,#font_params do
        local font_param = font_params[i]

        screen.level(font_param_sel == i and 10 or 4)
        y = y + 8
        screen.move(x, y)
        screen.text(font_param.name)
        if font_param.show ~= nil then
          screen.move(x + 32, y)
          screen.text(font_param.show())
        end
      end
    elseif ui_page == 'textinput' then
      x = 0
      y = font_size
      screen.level(font_level)
      screen.font_face(font_sel)
      screen.font_size(font_size)
      for i=1,#text_lines do
        screen.move(x, y)
        screen.text(text_lines[i])
	y = y + font_size
      end
    end
  end

  screen.update()
end
