require 'rubygems'
require 'ruby-debug'
require 'uuid'
require 'tempfile'

class FileManipulator
  def process(file)
    @file = File.new(file, "r+")
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
    #tmp_file = Tempfile.new( UUID.generate )

    test_text = @text
    test_text[index].sub('create', replace_word)
    #tmp_file.write(test_text.join())
    @file.rewind
    @file.truncate(0)
    @file.write(@text.join())

    #`ruby -Itest:lib #{tmp_file.path}`
    `bundle exec rake test:units TEST=#{@file.path}`

    if $?.exitstatus  == 0
      commit_change(test_text, "#{replace_word.upcase}:#{test_text[index].lstrip}")
      return true
    else
      return false
    end
  end

  def commit_change(text, message)
    puts "COMMITING FILE"
=begin
    @file.rewind
    @file.truncate(0)
    @file.write(@text.join("\n"))
=end
    `git commit -am "#{@file.path}:#{message}"`
  end

end

files = `find test | grep _test`
puts files

files.split("\n").each do  |file|
  FileManipulator.new.process(file)
end

