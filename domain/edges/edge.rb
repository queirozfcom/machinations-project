require_relative '../strategies/valid_types'
require_relative '../../domain/exceptions/no_elements_found'

class Edge

  attr_reader :from, :to, :name, :label, :types


  def initialize(hsh)

    @name = hsh.fetch(:name)

    @from = hsh.fetch(:from)

    @to = hsh.fetch(:to)

    #setting default values if needed.
    hsh = defaults.merge hsh

    @label = hsh.fetch(:label)
    @types = hsh.fetch(:types)

  end

  # Pinging an Edge means triggering it. It will try and move
  # as many resources (based on its type and those of
  # the two nodes) as it can..
  # @return [Boolean] true in case all required resources
  #  were moved, false otherwise.
  # def ping!
  #
  #   if from.enabled? and to.enabled?
  #
  #     strategy = ValidTypes.new(to.types, self.types)
  #     condition = strategy.get_condition
  #
  #     label.times do
  #
  #       begin
  #         res = from.take_resource! &condition
  #       rescue NoElementsFound
  #         return false
  #       end
  #
  #       to.put_resource!(res,self.freeze)
  #
  #     end
  #     true
  #   else
  #     false
  #   end
  #
  # end

  # Simulates a ping!, but no resources get actually
  # moved.
  #
  # @param [Boolean] require_all whether to require that the maximum
  #  number of Resources allowed (as per this Edge's label) be
  #  able to pass in order to return true.
  #
  # @return [Boolean] true in case a ping! on this Edge
  #  would return true. False otherwise.
  def test_ping?(require_all=false)
    return false if from.disabled? || to.disabled?

    condition = strategy.get_condition

    available_resources = from.resource_count(&condition)

    if available_resources == 0
      false
    elsif available_resources >= label
      true
    elsif available_resources < label && require_all
      false
    else
      # only some resources are able to pass
      true
    end

  end

  def supports?(type)
    types.empty? || types.include?(type)
  end

  alias_method :support?, :supports?

  def untyped?
    types.empty?
  end

  def typed?
    not untyped?
  end

  def from?(obj)
    from.equal?(obj)
  end

  def to?(obj)
    to.equal?(obj)
  end

  # Returns a block which will be later used by the calling node to search
  # for a suitable resource.
  #
  # @return [Proc] a condition block
  def push_expression
    strategy.push_condition
  end

  # Returns a block which will be later used as a parameter
  # to method pull!.
  #
  # @return [Proc] a condition block
  def pull_expression
    strategy.pull_condition
  end

  # Takes a resource and puts it into the node at the other
  # end of this Edge.
  #
  # @raise [StandardError] in case the receiving node or this Edge
  #  won't accept the resource sent.
  # @param res the resource to send.
  def push!(res)
    raise StandardError.new "This Edge does not support type: #{res.type}" unless supports?(res.type)

    begin
      to.put_resource!(res)
    rescue => e
      # just to make it clear
      raise e
    end
  end

  # Tries to take a resource matching given block
  # from the node at the other end.
  #
  # @param [Proc] blk  block that will define what resource the other node
  #  should send.
  # @raise [StandardError] in case the other node could provide no resources
  #  that satisfy this condition block.
  # @return a resource that satisfies the given block.
  def pull!(&blk)
    raise StandardError.new('didnt do pull! yet')
  end

  private

  def strategy
    ValidTypes.new(from.types, self.types, to.types)
  end

  def defaults
    {
        :label => 1,
        :types => []
    }
  end

end