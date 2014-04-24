class Ocd::Browser::FileEntry
  FLASH_TIME_SECONDS = 1.0
  FLASH_NUMBER_OF_TIMES = 2
  SIZE_UPDATE_FLASH_SECONDS = 0.5

  HILIGHT_COLOR_CODE = 243
  FLASH_COLOR_CODES = [0] + (232..255).to_a + [15]

  attr_reader :name
  attr_reader :full_path

  def initialize(full_path)
    @full_path = full_path
    @name = File.basename(full_path)
    @size = File.size(@full_path)

    @render_cache = Ocd::ValueCache.new
    @position_cache = Ocd::ValueCache.new
    @flash_cache = Ocd::ValueCache.new
  end

  def update(s)
    new_size = File.size(@full_path)

    unless @size == new_size
      if @size_updated_at
        if Time.now - @size_updated_at > SIZE_UPDATE_FLASH_SECONDS
          @size_updated_at = Time.now
        end
      else
        @size_updated_at = Time.now
      end

      @size = new_size
    end
  end

  def length
    @name.length
  end

  def to_s
    @name
  end

  def render(display, x, y, width, hilight_text)
    @render_cache.update(parts(hilight_text))
    @position_cache.update([x, y])
    @flash_cache.update(flash_t)

    caches = [
      @render_cache,
      @position_cache,
      @flash_cache
    ]

    if caches.any?(&:updated?)
      display.set_cursor_position(x, y)
      display.print " " * width

      display.set_cursor_position(x, y)

      parts = @render_cache.value

      hilight = parts.fetch(:hilight).to_s
      name = parts.fetch(:name).to_s

      unless hilight.empty?
        display.color(15, hilight_color) do
          display.print(hilight)
        end
      end

      display.color(color_code) do
        display.print(name)
      end
    end
  end

  def match?(text)
    !!@name.match(file_match_re(text))
  end

  def directory?
    File.directory?(@full_path)
  end

  def executable?
    File.executable?(@full_path)
  end

  def flash!
    @flash_at = Time.now
  end

  def flash_t
    return unless @flash_at

    t = (Time.now - @flash_at) / FLASH_TIME_SECONDS

    return if t > 1.0

    t
  end

  private

  def parts(hilight_text)
    match = @name.match(/^(?<hilight>#{ Regexp.escape(hilight_text) })?(?<name>.*)$/)

    hilight = match[:hilight].to_s
    name = match[:name].to_s
    name += "/" if directory?

    { hilight: hilight, name: name }
  end

  def icons
    icons = []

    if executable? && !directory?
      icons << "\e[38;5;010m×"
    end

    if @name.match(/\.(mp3|m4a|ogg|aif)$/)
      icons << "\e[38;5;100m♫ "
    end

    if @size_updated_at
      t = Time.now - @size_updated_at
      if t < SIZE_UPDATE_FLASH_SECONDS
        colors = (235..244).to_a.reverse
        color = colors[(t / SIZE_UPDATE_FLASH_SECONDS * colors.size).floor]
        icons << "\e[38;5;#{color}m⟲ "
      else
        @size_updated_at = nil
      end
    end

    icons
  end

  def file_match_re(text)
    if text.empty?
      /a^/ # Matches nothing.
    else
      /^(#{ Regexp.escape(text) })/
    end
  end

  COLOR_CODES = {
    %w(.rb) => 160,
    %w(.c .cpp) => 178,
    %w(.h .hpp) => 94,
    %w(.html) => 112,
    %w(.png) => 199,
    %w(.gif) => 197
  }

  def color_code
    return 33 if directory?

    COLOR_CODES.find do |extensions, code|
      if extensions.include?(File.extname(@full_path))
        return code
      end
    end
  end


  def hilight_color
    flash = @flash_cache.value

    if flash
      x = Math.sin(flash * Math::PI * FLASH_NUMBER_OF_TIMES * 2) / 2.0 + 0.5
      i = (x * FLASH_COLOR_CODES.size).to_i
      FLASH_COLOR_CODES[i]
    else
      color_code || HILIGHT_COLOR_CODE
    end
  end
end
