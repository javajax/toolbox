require 'rubygems'
#require 'celluloid'
require 'ruby-debug'
require 'uuid'
require 'tempfile'

class FileManipulator
  # include Celluloid

  def initialize(file)
    @file = File.new(file, "r+")
  end

  def process()
    puts "START #{@file.path}"
    @text = []
    @file.each_line{ |line| @text << line }

    @text.each_with_index do |line, index|
      if line.include?('create')
        unless test_change(index, 'build')
          test_change(index, 'new')
        end
      end
    end
  end

  def test_change(index, replace_word)
    puts "TESTING:#{replace_word.upcase}:#{@text[index].lstrip}"
    tmp_file = Tempfile.new(UUID.new.generate)

    test_text = @text
    test_text[index].sub('create', replace_word)
    tmp_file.write(test_text.join("\n"))

    system("ruby -Itest:lib #{tmp_file.path}")

    if $?.exitstatus  == 0
      commit_change(test_text, "#{replace_word.upcase}:#{test_text[index].lstrip}")
      return true
    else
      return false
    end
  end

  def commit_change(text, message)
      puts "COMMITING FILE"
      @file.rewind
      @file.truncate(0)
      @file.write(@text.join("\n"))
      `git commit -am "#{@file.path}:#{message}"`
  end

end

files = `find test | grep _test`
puts files

#FileManipulator.new('test/unit/ad_details_test.rb').process()

pool = FileManipulator.pool(size: 6)
files.split("\n").each{ |file| pool.future(:process, file) }
=begin
=end

