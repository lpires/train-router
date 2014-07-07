class TrainRouter
  attr_accessor :nodes

  UNTIL = {:steps => "path.nodes.length>=", :cost => "path.cost>="}
  EG = {:steps => "path.nodes.length==", :cost => "path.cost=="}
  LESS = {:steps => "path.nodes.length<=", :cost => "path.cost<="}


  # TrainRouter constructor
  def initialize
    @nodes = Hash.new
  end

  # get(Symbol) method that returns a node by the id
  # returns <Edge>
  def get id
    @nodes[id]
  end

  # add(Symbol) method that initialize a node
  def add id
    return unless @nodes[id].nil?
    @nodes[id] = Array.new
  end

  # connect(Edge) method that adds a connection to the list of nodes
  # returns <Edge>
  def connect edge
    self.add edge.src
    self.add edge.dst
    @nodes[edge.src] << edge
    edge
  end

  # distance(List<Symbol>) return the cost of a given route
  # returns <Integer>
  def distance *path
    cost, edge_exists = 0, false

    # Adds the cost of the next move
    neighbors = @nodes[path.shift]
    neighbors.each do |node|
      if node.dst == path.first
        edge_exists = true
        cost += node.length
        break
      end
    end

    # Iterates in depth when neighbor exists
    return -1 unless edge_exists
    if path.length > 1
      sub_cost = distance *path
      return -1 if sub_cost == -1
      cost += sub_cost
    end
    cost
  end

  # step_number(List<Path>, Symbol, Hash, String) return the number of steps from the first route
  # returns <Integer>
  def step_number visit_path, dst, limits, condition=nil
    return route(visit_path, dst, limits, UNTIL).first.nodes.length - 1
  end

  # path_number(List<Path>, Symbol, Hash, String) return the number of paths with in the limits
  # returns <Integer>
  def path_number visit_path, dst, limits, condition=EG
    paths = route(visit_path, dst, limits, condition)
    select_condition = condition == EG ? EG : condition == UNTIL ? LESS : UNTIL
    return (paths.select {|path| eval final_eval( select_condition, limits )}).length
  end

  # step_number(List<Path>, Symbol, String) return cost of the shortest route
  # returns <Integer>
  def shortest_route visit_path, dst, condition=nil
    return route(visit_path, dst).first.cost
  end


  private

  # route(List<Path>, Symbol, Hash, String) return a list of routes
  # returns <List>
  def route visit_path, dst=nil, limits=nil, condition=UNTIL
    paths = trips(visit_path, dst, limits, condition)
    return paths
  end

  # route(List<Path>, Symbol, Hash, String) method that calculate all the possible routs from a source to a destination
  # params:
  #         - visit_path:
  #         A list of nodes that represent a path that is been visit
  #         - dst:
  #         The end node
  #         - limits
  #         There are two types of limits that restrict the search by cost and by depth
  #         - condition
  #         The conditions that the limits need to valid
  #         - paths
  #         Paths to explore
  #         - dst_paths
  #         Path that reached condition
  def trips visit_path, dst, limits, condition, paths=Array.new, dst_paths=Array.new
    node = visit_path.nodes.last
    neighbors = @nodes[node]
    if neighbors.empty?
      visit_path.fanal = true
      paths << visit_path
      return paths
    end

    neighbors = neighbors.sort_by {|node| node.length}
    neighbors.each do |neighbor|
      path = Path.new visit_path.nodes.clone
      path.cost = visit_path.cost + neighbor.length
      path.final = path.nodes.include? neighbor.dst
      path.final = eval final_eval( condition, limits ) unless limits.nil?
      path.nodes << neighbor.dst
      if (neighbor.dst == dst && !path.final)
        d_path = Path.new path.nodes.clone
        d_path.cost = path.cost
        d_path.final = true
        dst_paths << d_path
      end

      paths << path
    end

    while(paths.length > 0 && paths.map {|path| path.final}.include?(false))
      path = paths.shift
      unless path.final
        trips( path, dst, limits, condition, paths, dst_paths)
      else
        dst_paths << path
      end
    end

    paths = (dst_paths + paths).select { |path| path.nodes.last == dst && path.final == true }
    return paths
  end

  # step_number(Hash, String) return the eval expression for the conditions
  # returns <String>
  def final_eval condition, limits
    return "#{condition[:steps]}#{limits[:steps]}" if limits.has_key? :steps
    return "#{condition[:cost]}#{limits[:cost]}" if limits.has_key? :cost
    false
  end
end