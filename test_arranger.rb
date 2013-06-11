#!/usr/bin/env ruby

require 'rubygems'
require 'celluloid'

class FileManipulator
  include Celluloid

  def to_build(file)
    replace_in_file(file, "build")
  end

  def to_create(file)
    replace_in_file(file, "new")
  end

  def replace_in_file(file, sub_word)
    puts "START #{file}"
    test_file = File.open(file)
    text = test_file.read()

    text.each_line do |line|
      if line.include?("create")
        puts "LINE: #{line}"

        ## replace create for build
        ## and run tests
        line.gsub("create", sub_word)
        test_file.write(text)
        `ruby -Itest:lib #{file}`

        ## change based on tests
        if $?.exitstatus  == 0
          puts "COMMITING FILE"
          `git commit -am "#{file}:#{line}"`
        else
          ## put things how i found them
          line.gsub(sub_file, "create")
          test_file.write(text)
        end

      end
    end
    test_file.close()
  end
end

files = `find test | grep _test`
puts files


pool = FileManipulator.pool(size: 6)
futures = files.split("\n").map { |file| pool.future(:to_build, file) }

# output = futures.map(&:inspect)

