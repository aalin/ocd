require 'spec_helper'

describe Ocd::Browser::Table do
  let(:files) do
    # Rails project file structure
    %w(app config config.ru db doc lib log public Rakefile README.rdoc script test tmp vendor)
  end

  subject(:table) { Ocd::Browser::Table.new(files) }

  describe "#column_widths" do
    it "calculates and returns the column widths" do
      table.column_widths(100).should == [8, 11, 5, 8, 13, 8, 8]
    end
  end

  describe "#rows" do
    it "calculates and returns the table rows" do
      table.rows(100).should == [
        %w(app     config.ru  doc  log     Rakefile     script  tmp),
        %w(config  db         lib  public  README.rdoc  test    vendor)
      ]

      table.rows(50).should == [
        %w(app        db   log       README.rdoc  tmp),
        %w(config     doc  public    script       vendor),
        %w(config.ru  lib  Rakefile  test)
      ]

      table.rows(30).should == [
        %w(app        public),
        %w(config     Rakefile),
        %w(config.ru  README.rdoc),
        %w(db         script),
        %w(doc        test),
        %w(lib        tmp),
        %w(log        vendor)
      ]

      table.rows(1).should == files.map { |file| [file] }
    end
  end
end
