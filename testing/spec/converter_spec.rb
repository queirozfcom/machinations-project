require_relative 'spec_helper'

describe Converter do

  it 'is created with name as single argument' do

    expect { Converter.new name: 'foo' }.not_to raise_error

  end

  it 'is added into a diagram' do

    d = Diagram.new 'd'

    d.add_node! Converter, name: 'conv'

    expect(d.get_node('conv')).to be_a Converter

  end

  it 'is connected to one edge in and one edge out' do

    c = Converter.new name: 'c'

    c.attach_edge(double(:from => c, :to => double()))

    c.attach_edge(double(:from => double(), :to => c))

  end


  describe '#trigger!' do

    context 'simple tests' do

      before(:each) do

        @c = Converter.new name: 'c'
        @edge_in = double(from: double(), to: @c)
        @edge_out = double(from: @c, to: double())
        @c.attach_edge!(@edge_in).attach_edge!(@edge_out)

      end

      it 'pings incoming nodes' do

        expect(@edge_in).to receive(:test_ping?)
        @edge_out.as_null_object
        @c.trigger!

      end

      it "pings outgoing edges if incoming edge's ping was successful " do

        expect(@edge_in).to receive(:test_ping?).and_return(true)
        expect(@edge_in).to receive(:ping!)
        expect(@edge_out).to receive(:test_ping?).and_return(true)
        expect(@edge_out).to receive(:ping!)

        @c.trigger!
      end

      it "doesn't ping outgoing edges if incoming edge's ping! was not successful " do

        expect(@edge_in).to receive(:test_ping?).and_return(false)
        expect(@edge_in).not_to receive(:ping!)
        expect(@edge_out).not_to receive(:ping!)

        @c.trigger!

      end

    end

    context 'when pull_any' do

      before(:each) do

        @c = Converter.new name: 'c', mode: 'pull_any'
        @edge_in = double(from: double(), to: @c)
        @edge_in2 = double(from: double(), to: @c)
        @edge_out = double(from: @c, to: double())
        @edge_out2 = souble(from:@c, to: double())
        @c.attach_edge!(@edge_in).attach_edge!(@edge_in2).attach_edge!(@edge_out).attach_edge!(@edge_out2)

      end

      it 'receives from each incoming edge across 2 turns and only then pushes to outgoing edge' do

        expect(@edge_in).to receive_messages(:test_ping? => true, :ping! => true)
        expect(@edge_in2).to receive(:test_ping?).and_return(false)

        @c.trigger!

        expect(@edge_in).to receive(:test_ping?).and_return(false)
        expect(@edge_in2).to receive_messages(:test_ping? => true, :ping! => true)

        expect(@edge_out).to receive_messages(:test_ping? => true, :ping! => true)
        expect(@edge_out2).to receive_messages(:test_ping? => true, :ping! => true)

        @c.trigger!

      end

    end

    context 'when pull_all' do

      before(:each) do
        @c = Converter.new name: 'c', mode: 'pull_all'
        @edge_in = double(from: double(), to: @c)
        @edge_in2 = double(from: double(), to: @c)
        @edge_out = double(from: @c, to: double())
        @edge_out2 = double(from:@c, to: double())
        @c.attach_edge!(@edge_in).attach_edge!(@edge_in2).attach_edge!(@edge_out).attach_edge!(@edge_out2)
      end


      it 'pings if all edges test_ping' do

        expect(@edge_in).to receive_messages(:test_ping? => true,:ping! =>true)
        expect(@edge_in2).to receive_messages(:test_ping? => true,:ping! =>true)
        expect(@edge_out).to receive_messages(:test_ping? => true,:ping! =>true)
        expect(@edge_out2).to receive_messages(:test_ping? => true,:ping! =>true)

        @c.trigger!

      end


      it 'does not ping anything otherwise' do

        # they are shuffled and we stop sending test_ping? to edges
        # once one has returned false. Therefore we do not know which
        # edges will receive the message so we have to allow all to.

        allow(@edge_in).to receive_messages(:test_ping? => false)
        allow(@edge_in2).to receive_messages(:test_ping? => false)
        allow(@edge_out).to receive_messages(:test_ping? => false)
        allow(@edge_out2).to receive_messages(:test_ping? => false)

        # but none will get pinged
        expect(@edge_in).not_to receive(:ping!)
        expect(@edge_in2).not_to receive(:ping!)
        expect(@edge_out).not_to receive(:ping!)
        expect(@edge_out2).not_to receive(:ping!)

        @c.trigger!

      end

    end

  end

  describe '#put_resource!' do

    before(:each) do
      @c = Converter.new name: 'c'
      @edge_in = double(from: double(), to: @c)
      @edge_out = double(from: @c, to: double())
      @c.attach_edge!(@edge_out).attach_edge!(@edge_in)
    end

    it 'does not ping incoming edges' do

      expect(@edge_in).not_to receive(:test_ping?)
      @edge_out.as_null_object
      @c.put_resource!(@edge_in.freeze,double())

    end

    it 'pings as many outgoing nodes as there are when in all mode' do

      edge_out2 = double(from: @c, to: double())
      edge_out3 = double(from: @c, to: double())
      edge_out4 = double(from: @c, to: double())

      @c.attach_edge!(edge_out2).attach_edge!(edge_out3).attach_edge!(edge_out4)

      expect(@edge_out).to receive_messages(:test_ping? => true, :ping! => true)
      expect(edge_out2).to receive_messages(:test_ping? => true, :ping! => true)
      expect(edge_out3).to receive_messages(:test_ping? => true, :ping! => true)
      expect(edge_out4).to receive_messages(:test_ping? => true, :ping! => true)

      @c.put_resource!(@edge_in.freeze,double())

    end

  end

  describe '#take_resource!' do

  end

  describe '#in_conditions_met?' do

    before(:each) do
      @c = Converter.new name:'c',mode: 'pull_any'
      @edge1 = double().freeze
      @edge2 = double().freeze
      @c.attach_edge!(@edge1).attach_edge!(@edge2)
    end

    context 'when pull_any' do

      it 'is true when conditions are just enough' do
        # i.e. the amount store is precisely the amount needed
      end

      it 'is also true when conditions have some slack' do
        # i.e. if one edge's condition is overmet (more res than needed)
        # and another edge's condition is met.

      end

    end

  end

end