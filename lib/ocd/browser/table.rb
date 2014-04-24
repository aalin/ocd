class Ocd::Browser::Table
  def initialize(file_entries)
    @file_entries = file_entries
    @display_width = nil
  end

  def draw(display_width)
    update(display_width)

    @rows.each_with_index do |values, y|
      values_with_column_widths = values.compact.map.with_index do |value, x|
        width = @column_widths[x] || 0
        [value, width]
      end

      yield values_with_column_widths, y
    end
  end

  def rows(display_width)
    update(display_width)
    @rows
  end

  def column_widths(display_width)
    update(display_width)
    @column_widths
  end

  private

  def update(display_width)
    return if @display_width == display_width # Cache
    @display_width = display_width

    space = 4

    i = 0
    loop do
      i += 1
      columns = @file_entries.each_slice(i).map { |x| Array.new(i) { |n| x[n] } }
      rows = columns.transpose
      column_widths = columns.map { |values| values.map(&:to_s).map(&:length).max + space }

      total_width = column_widths.inject(0, :+) # sum

      if total_width < display_width || i >= @file_entries.size
        @rows = rows.map(&:compact)
        @column_widths = column_widths

        return
      end
    end
  end
end
