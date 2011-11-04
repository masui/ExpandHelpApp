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
  Dir.open(".").find_all { |file|
    file != '.' && 
    file != '..' &&
    File.ftype(file) == 'file'
  }.join("|")
end

def show(file)
  File.read(file)
end

def ps
  pslines = `ps -eaf`.split(/[\r\n]/)
  pslines.shift
  s = pslines.collect { |line|
    line.sub!(/^\s+/,'')
    elements = line.split(/ +/)
    pid = elements[1].to_i
    pname = elements[7].to_s
    pname.sub!(/^.*\//,'')
    pname = 'mmm' if pname == ''
    "#{pname}\t#{pid}"
  }[0..30].join('|')
  File.open("/tmp/loglog","w"){ |f|
    f.puts s
  }
  s
end

def setdate(h,m1,m2)
  t = Time.now
  s = sprintf("%02d%02d%02d%d%d",t.month,t.day,h.to_i,m1.to_i,m2.to_i)
  system "/Users/masui/bin/date #{s}"
  ''
end

