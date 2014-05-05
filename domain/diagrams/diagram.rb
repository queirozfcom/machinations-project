require_relative '../../domain/modules/common/invariant'
require_relative '../edge_collection'
require_relative '../node_collection'

class Diagram

  include Invariant

  attr_accessor :name
  attr_accessor :max_iterations


  def initialize(name)
    @nodes = NodeCollection.new
    @edges = EdgeCollection.new
    @name = name
    @max_iterations = 999
  end

  def get_node(name)
    nodes.each do |node|
      if node.name == name
        return node
      end
    end

    raise RuntimeError, "Node with name='#{name}' not found."
  end

  def add_node!(node_klass, params)

    params.store(:diagram, self)

    node = node_klass.new(params)

    nodes.push(node)

    nil
  end

  def add_edge!(edge_klass, params)

    params.store(:diagram, self)

    #we need to send the actual nodes, not their names
    from = get_node(params.fetch(:from))
    to = get_node(params.fetch(:to))

    params.store(:from, from)
    params.store(:to, to)

    edge = edge_klass.new(params)

    from.attach_edge(edge)
    to.attach_edge(edge)

    edges.push(edge)

    nil
  end

  def run!(rounds=5)

    run_while! do |i|
      i<=rounds
    end

  end

  def run_while!

    before_run

    i=1

    #if condition block turned false, it's time to stop
    while yield i do
      before_round i
      run_round!
      after_round i
      break unless sanity_check? i
      i+=1
    end

    after_run

    self

  end

  def to_s
    nodes.reduce("") { |carry, n| carry+n.to_s }
  end

  def sanity_check?(round_no)
    if round_no >= @max_iterations
      sanity_check_message
      false
    else
      true
    end
  end

  def run_round!

    nodes.shuffle.each{ |node| node.stage! }

    #only after all nodes have run do we update the actual resources and changes, to be used in the next round.
    nodes.each{ |n| n.commit! }

  end



  def nodes
    @nodes
  end

  def nodes=(what)
    @nodes=what
  end

  def edges
    @edges
  end

  def edges=(what)
    @edges=what
  end

  def before_round(node_no); end #template method

  def after_round(node_no); end #template method

  def before_run; end #template method

  def after_run; end  #template method

  def sanity_check_message;  end #template method

  def resource_count(klass=nil)
    total=0
    @nodes.each do |n|
      total+=n.resource_count(klass)
    end
    total
  end

end
