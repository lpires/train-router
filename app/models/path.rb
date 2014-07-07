class Path
  attr_accessor :nodes, :cost, :final

  def initialize node, cost=0, final=false
    @nodes = node.kind_of?(Array)? node : [node]
    @cost = cost
    @final = final
  end
end

