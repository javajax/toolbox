#!/usr/bin/env ruby

require 'rubygems'
require 'ruby-debug'

files = `find test | grep _test`
puts files

files.split(" ").each do |file|
  puts "START #{file}"

  test_file = File.open(file, "r")
  test_file.each_line do |line|
    if line.include?("create")

      ## replace create for build
      line.gsub("create", "build")

      ## run tests
      puts "LINE: #{line}"
      `ruby -Itest:lib #{file}`

      ## change based on tests
      if($?.exitstatus  == 0)
        puts "GOOD"
        `git commit -am "#{file}:#{line}"`
      else
        ## put things how i found them
        line.gsub("build", "create")
        puts "BAD"
      end

    end
  end
  test_file.close()

  puts "FILE END"
end



files.split(" ").each do |file|
  puts "START #{file}"

  test_file = File.open(file, "r")
  test_file.each_line do |line|
    if line.include?("create")

      ## replace create for build
      line.gsub("create", "new")

      ## run tests
      puts "LINE: #{line}"
      `ruby -Itest:lib #{file}`

      ## change based on tests
      if($?.exitstatus  == 0)
        puts "GOOD"
        `git commit -am "#{file}:#{line}"`
      else
        ## put things how i found them
        line.gsub("build", "create")
        puts "BAD"
      end

    end
  end
  test_file.close()

  puts "FILE END"
end
