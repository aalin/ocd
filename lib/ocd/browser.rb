class Ocd::Browser
  LIST_TOP = 2

  def initialize(app, path = File.expand_path(Dir.pwd))
    @app = app
    @file_list = FileList.new(path)
    @command_line = CommandLine.new
    @offset_y = 0

    @path_cache = Ocd::ValueCache.new
  end

  def handle_input_tab
    attempt_cd || attempt_autocomplete
  end

  def handle_input_return
    attempt_cd || attempt_open_file
  end

  def handle_input_eof
    @app.stop
    true
  end

  def add_char(char)
    if char.value == "/" && handle_input_tab
      @command_line.reset_buffer!
      return
    end

    @command_line.add_char(char, self)

    # "cd .." instantly when ".." has been entered
    if text == ".."
      attempt_cd
      @command_line.reset_buffer!
    end
  end

  def scroll_up
    @offset_y -= 1
  end

  def scroll_down
    @offset_y += 1
  end

  def text
    @command_line.text
  end

  def update(app, s)
    @file_list.update(s)
    @command_line.update(self)

    @path_cache.update(absolute_path)
  end

  def draw(display)
    display.hide_cursor

    if @path_cache.updated?
      LIST_TOP.upto(display.height) do |y|
        display.set_cursor_position(1, y)
        display.clear_line
      end
    end

    rows = []

    @file_list.table.draw(display.width) do |table_row, y|
      row = []

      table_row.inject(1) do |x, (file, column_width)|
        row << [file, x, column_width]
        x + column_width
      end

      rows << row
    end

    list_top = LIST_TOP
    list_bottom = display.height - 1
    list_height = list_bottom - list_top

    overflow = rows.size - 1 - list_height

    @offset_y = 0 if @offset_y < 0

    if overflow > 0
      @offset_y = [@offset_y, overflow].min
    elsif overflow <= 0
      @offset_y = 0
    end

    rows_to_draw = rows[@offset_y, list_height]

    rows_to_draw.each.with_index(list_top) do |row, y|
      row.each do |file, x, column_width|
        file.render(display, x, y, column_width, text)
      end
    end

    @command_line.draw(display, display.height)
  end

  def absolute_path
    @file_list.absolute_path
  end

  private

  def attempt_cd
    if @file_list.directory?(text)
      @file_list.cd(text)
      true
    end
  end

  def attempt_autocomplete
    matched_files = @file_list.matched_files(text)

    if matched_files.size == 1
      name = matched_files.first.name
    else
      matched_files.each(&:flash!)

      filenames = matched_files.map(&:name)
      name = longest_common_start_string(filenames)
    end

    if name
      name.chars.to_a[text.length..-1].each do |char|
        @command_line.append(char)
      end
    end

    false
  end

  def attempt_open_file
    file_entry = @file_list.file_entry(text)

    if file_entry
      @app.push_state(Ocd::OpenFileDialog.new(@app, file_entry.full_path))
      true
    end
  end

  def longest_common_start_string(strings)
    # http://stackoverflow.com/questions/1916218/find-the-longest-common-starting-substring-in-a-set-of-strings/1916480#1916480
    strings.inject do |l, s|
      l = l.chop while l != s[0...l.length]
      l
    end
  end

  def log(message)
    return
    time_str = Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")
    str = format("%s: %s\r\n", time_str, message)
    File.write("browser.log", str, mode: "a")
  end
end
