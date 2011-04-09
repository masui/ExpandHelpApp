# Lib.rb
# ExpandHelpApp
#
# Created by Toshiyuki Masui on 11/02/27.
# Copyright 2011 Pitecan Systems. All rights reserved.

def alarm
  alarmfile = NSBundle.mainBundle.pathForResource("alarm", ofType:"mp3")
  NSSound.alloc.initWithContentsOfFile(alarmfile, byReference:false).play
end

def bigfiles(size)
  files = []
  Dir.open(".").each { |file|
    next if file == '.'
    next if file == '..'
    next if File.ftype(file) != 'file'
    files << file if File.size(file) >= size
  }
  files.join("\n")
end

def ls
  Dir.open(".").collect { |file|
    next if file == '.'
    next if file == '..'
    next if File.ftype(file) != 'file'
    file
  }.join("|")
end

def show(file)
  File.read(file)
end

def ps
  pslines = `ps -eaf`.split(/[\r\n]/)
  pslines.shift
  pslines.collect { |line|
    line.sub!(/^\s+/,'')
    elements = line.split(/ +/)
    pid = elements[1].to_i
    pname = elements[7].to_s
    pname.sub!(/^.*\//,'')
    "#{pname}\t#{pid}"
  }.join('|')
end
