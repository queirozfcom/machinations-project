module Invariant

  #used to insert assertions into code
  #remember that assertions should not be used to control program flow!!! assert things that should ALWAYS be false.

  class AssertionError < RuntimeError

  end

  alias_method :inv, :invariant

  def invariant &block
    raise AssertionError unless yield
  end

end
