class Ocd::Browser::FileList
  attr_reader :table

  def initialize(path)
    update_path(path)
  end

  def matched_files(text)
    @files.select { |f| f.match?(text) }
  end

  def absolute_path
    if File.directory?(@path)
      File.absolute_path(@path) + "/"
    else
      File.absolute_path(@path)
    end
  end

  def file_entry(name)
    @files.find do |file_entry|
      file_entry.name == name
    end
  end

  def directory?(name)
    return true if name == ".."

    if entry = file_entry(name)
      entry.directory?
    else
      false
    end
  end

  def cd(directory)
    path = join_path(directory)

    if directory?(directory)
      update_path(path)
      update_files
      true
    else
      false
    end
  end

  def update(s)
    @files.each do |file|
      file.update(s)
    end
  end

  def path_updated?
    !!@path_updated
  end

  private

  def update_path(path)
    if @path == path
      @path_updated = false
    else
      @path = path
      update_files
    end
  end

  def update_files
    @files = Dir[glob_str].sort.map do |file|
      Ocd::Browser::FileEntry.new(file)
    end

    @table = Ocd::Browser::Table.new(@files)
  end

  def glob_str
    File.join(absolute_path, "*")
  end

  def join_path(path)
    File.expand_path(File.join(absolute_path, path))
  end
end
