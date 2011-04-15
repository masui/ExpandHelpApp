# -*- coding: utf-8 -*-
#
#  ノードとノード間遷移
#
#  (self)  pat     dest
#    ■ ----------> □
#       ----------> □
#       ----------> □
#

class Trans
  def initialize(pat,dest)
    # pat にマッチしたら dest に遷移
    @pat = pat
    @dest = dest
  end

  attr_reader :pat, :dest
end

class Node
  @@id = 1
  @@nodes = {}

  def initialize
    @accept = nil
    @trans = []
    @id = @@id
    @@nodes[@id] = self
    @@id += 1
    @pars = []
  end

  attr_reader :id
  attr_reader :trans
  attr :accept, true
  attr :pars, true

  def addTrans(pat,dest)
    t = Trans.new(pat,dest)
    @trans << t
  end

  def Node.node(id) # ノードidからノードを取得
    @@nodes[id.to_i]
  end

  def Node.nodes
    @@nodes.values
  end
end
