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

class GenNode
  def initialize(id, s="", substrings=[], accept=false)
    @id = id
    @s = s
    @substrings = substrings
    @accept = accept
  end

  attr :id, true
  attr :s, true
  attr :substrings, true
  attr :accept, true
end

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
  # ルールを解析して状態遷移機械を作成し、patにマッチするもののリストを返す
  #
  def generate(pat, app = nil)
    res = []
    patterns = pat.split.map { |p| p.downcase }

    scanner = Scanner.new(@s.join('|'))
    (startnode, endnode) = regexp(scanner,true) # top level
	
    listed = {}
    #
    # n個のノードを経由して生成される状態の集合をlists[n]に入れる
    #
    lists = []
    #
    # 初期状態
    #
    list = []
    list[0] = GenNode.new(startnode.id)
    lists[0] = list
    #
    (0..1000).each { |length|
      break if app && app.inputPending
      list = lists[length]
      newlist = []
# puts "#{length} - #{list.length}"
      list.each { |entry|
        srcnode = Node.node(entry.id)
        if list.length * srcnode.trans.length < 10000 then
          srcnode.trans.each { |trans|
            ss = entry.substrings.dup
            srcnode.pars.each { |i|
              ss[i-1] = ss[i-1].to_s + trans.arg
            }
            newlist << GenNode.new(trans.dest.id, entry.s+trans.str, ss, trans.dest.accept)
          }
        end
      }
break if newlist.length == 0
# if false then
      newlist.each { |entry| # |statestr,ruleno|
        # break if app && app.inputPending
        ruleno = entry.accept
        if ruleno then
          if !listed[entry.s] then
            matched = true
            #
            # 入力文字列とマッチング (ここが遅いはず)
            #
            patterns.each { |pat|
              if !entry.s.downcase.index(pat) then
                matched = false
                break
              end
            }
            if matched then
              if entry.substrings.length > 0 then
                patstr = "(.*)\t" * (entry.substrings.length-1) + "(.*)"
                /#{patstr}/ =~ entry.substrings.join("\t")
              end
              # 'set date #{$2}' のような記述の$変数にsubstringの値を代入
              res << [entry.s, eval('%('+@commands[ruleno]+')')]
            end
          end
          listed[entry.s] = true
        end
      }
# end
      lists << newlist
    }
    app.inputPending = false if app
    res
  end

  #
  # 正規表現をパースして状態遷移機械を作る
  #

  private
  #            n1     n2
  #        +-->□.....□--+
  # start /                \  end
  #     □ --->□.....□---> □
  #       \                /
  #        +-->□.....□--+
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
