# -*- coding: utf-8 -*-
# Generator.rb
# ExpandHelpApp
#
# Created by Toshiyuki Masui on 11/02/26.
# Copyright 2011 Pitecan Systems. All rights reserved.

#
#          ( (  )  )  ( (    ) (  (  )  ) (   )  )  | (  (  )  )
#  pars   [1]     
#           [1,2]
#                    [3]
#                     [3,4]
#                             [3,5]

require 'Scanner'
require 'Node'

class Generator
  def initialize(s = nil)
    @s = (s ? [s] : [])
    @matchedlist = []
    @par = 0
    @commands = []
  end

  def add(pat,command)
    @s << pat
    @commands << command
  end

  #
  # patから状態遷移機械を作成し、
  #
  def generate(pat, app = nil)
    res = []
	
    patterns = pat.split

    scanner = Scanner.new(@s.join('|'))
    (startnode, endnode) = regexp(scanner,true) # top level
	
    output = {}
    #
    # 長さがnの候補をlists[n]に入れる
    # 候補の文字列は "123<tab>abcというファイル" のような形式
    #
    lists = []
    #
    # 初期状態
    #
    list = {}
    list["#{startnode.id}\t"] = false
    lists[0] = list
    #
    #
    #
    (0..1000).each { |length|
      break if app && app.inputPending
      list = lists[length]
      newlist = {}
      list.keys.each { |entry|
        (id, s, *substrings) = entry.split(/\t/)
        s = "" if s.nil?
        substrings = [] if substrings.nil?

        srcnode = Node.node(id.to_i)
        if list.keys.length * srcnode.trans.length < 10000 then
          srcnode.trans.each { |trans|
            sss = substrings.dup
            destnode = trans.dest
            destid = destnode.id
            srcnode.pars.each { |i|
              sss[i-1] = sss[i-1].to_s + trans.pat
            }
            ss = sss.join("\t")
            newlist["#{destid}\t#{s+trans.pat}\t#{ss}"] = destnode.accept
          }
        end
      }
      newlist.each { |key,value|
        break if app && app.inputPending
        if value then
          ruleno = value
          (id, s, *substrings) = key.split(/\t/)
          if !output[s] then
            # substringsの配列を$1, $2...に入れる工夫
            b = []
            substrings.each { |string|
              b << (string =~ /\t(.*)$/ ? $1 : string)
            }
            patstr = Array.new(b.length,"(.*)").join("\t")
            /#{patstr}/ =~ b.join("\t")
            matched = true
            patterns.each { |pat|
              if !s.downcase.index(pat.downcase) then
                matched = false
                break
              end
            }
            if matched then
              res << [s, eval('%('+@commands[ruleno]+')')]
            end
          end
          output[s] = true
        end
      }
      lists << newlist
    }
    app.inputPending = false if app
    res
  end

  #
  # 正規表現をパースして状態遷移機械を作る
  #

  private

  #
  #  n1  'abc'  n2
  #  □ ------> □
  #
  def regexp(s,toplevel=false) # regcat { '|' regcat }
    startnode = Node.new
    endnode = Node.new
    if toplevel then
      @pars = []
      @parno = 0
      @ruleid = 0
    end
    startnode.pars = @pars
    endnode.pars = @pars
    (n1, n2) = regcat(s)
    startnode.addTrans('',n1)
    if toplevel then
      n2.accept = @ruleid
    end
    n2.addTrans('',endnode)
    while s.gettoken == '|' && s.nexttoken != '' do
      if toplevel then
        @pars = []
        @parno = 0
        @ruleid += 1
      end
      (n1, n2) = regcat(s)
      startnode.addTrans('',n1)
      if toplevel then
        n2.accept = @ruleid
      end
      n2.addTrans('',endnode)
    end
    s.ungettoken
    return [startnode, endnode]
  end

  def regcat(s) # regfactor { regfactor }
    (startnode, endnode) = regfactor(s)
    while s.gettoken !~ /^[\)\]\|]$/ && s.nexttoken != '' do
      s.ungettoken
      (n1, n2) = regfactor(s)
      endnode.addTrans('',n1)
      endnode = n2
    end
    s.ungettoken
    return [startnode, endnode]
  end

  def regfactor(s) # regterm [ '?' | '+' | '*' ]
    (startnode, endnode) = regterm(s)
    t = s.gettoken
    if t =~ /^[\?]$/ then
      startnode.addTrans('',endnode)
    elsif t =~ /^[\+]$/ then
      endnode.addTrans('',startnode)
    elsif t =~ /^[\*]$/ then
      startnode.addTrans('',endnode)
      endnode.addTrans('',startnode)
    else
      s.ungettoken
    end
    return [startnode,endnode]
  end

  def regterm(s) # '(' regexp ')' | token
    t = s.gettoken
    if t == '(' then
      @parno += 1
      @pars.push(@parno)
      (n1, n2) = regexp(s)
      n1.pars = @pars.dup
      t = s.gettoken
      if t == ')' then
        @pars.pop
        n2.pars = @pars.dup
        return [n1, n2]
      else
        puts 'missing )'
        exit
      end
    else
      startnode = Node.new
      startnode.pars = @pars.dup
      endnode = Node.new
      endnode.pars = @pars.dup
      startnode.addTrans(t,endnode)
      return [startnode, endnode]
    end
  end
end
