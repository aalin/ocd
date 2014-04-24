require 'spec_helper'

describe Ocd::Browser::FileList do
  let(:file_list) {
    Ocd::Browser::FileList.new(File.join(File.dirname(__FILE__), "..", ".."))
  }

  describe "#file_entry" do
    it "returns a FileEntry for a file" do
      file_entry = file_list.file_entry("spec_helper.rb")
      expect(file_entry).to be_a(Ocd::Browser::FileEntry)
      expect(file_entry.name).to eq("spec_helper.rb")
    end

    it "returns nil when a file can not be found" do
      expect(
        file_list.file_entry("this will never be found probably :)")
      ).to eq(nil)
    end
  end

  describe "#directory?" do
    it "returns true for .." do
      expect(file_list.directory?("..")).to eq(true)
    end

    it "returns true for directories" do
      expect(file_list.directory?("ocd")).to eq(true)
    end

    it "returns false for non-directories" do
      expect(file_list.directory?("spec_helper.rb")).to eq(false)
    end

    it "returns false for non-existant files" do
      expect(file_list.directory?("asdasd")).to eq(false)
    end
  end

  describe "#cd" do
    it "enters directories and returns true" do
      expect(file_list.cd("ocd")).to eq(true)
      expect(file_list.file_entry("browser")).to be_directory
    end

    it "returns false if it can't enter a directory" do
      expect(file_list.cd("non-existing directory")).to eq(false)
    end
  end
end
