require_relative 'spec_helper'

describe Diagram do

  it 'can be empty' do
    d = Diagram.new 'empty'
    expect(d.name).to eq 'empty'
  end

  it 'should be created with a source and a pool and run n times with no errors' do

    d=Diagram.new 'simple'

    d.add_node! Source, {
        :name => 'source'
    }

    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }


    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.run!(10)

  end

  it "runs for 2 turns with two pools using PULL and there's the correct amount of resources at the end" do

    d = Diagram.new 'some_name'

    d.add_node! Pool, name: 'pool1', initial_value: 5

    d.add_node! Pool, name: 'pool2', activation: :automatic

    d.add_edge! Edge, name: 'edge', from: 'pool1', to: 'pool2'

    d.run!(2)

    expect(d.get_node('pool1').resource_count).to eq 3
    expect(d.get_node('pool2').resource_count).to eq 2

  end

  it "runs for two turns with two pools using PUSH and there's the correct amount of resources at the end" do

    d = Diagram.new 'some_name'

    d.add_node! Pool, name: 'pool1', initial_value: 5, mode: :push, activation: :automatic

    d.add_node! Pool, name: 'pool2'

    d.add_edge! Edge, name: 'edge', from: 'pool1', to: 'pool2'

    d.run!(2)

    expect(d.get_node('pool1').resource_count).to eq 3
    expect(d.get_node('pool2').resource_count).to eq 2

  end

  it "runs for a single turn with one source and two pools and there's the correct amount of resources at the end" do
    p = Diagram.new('one source two pools')

    p.add_node!(Source, {name: 'source'})

    p.add_node!(Pool, {name: 'pool1'})

    p.add_node!(Pool, {name: 'pool2', activation: :automatic})

    p.add_edge!(Edge, {name: 'edge1', from: 'source', to: 'pool1'})

    p.add_edge!(Edge, {name: 'connector2', from: 'pool1', to: 'pool2'})

    p.run!(1)

    expect(p.get_node('pool1').resource_count).to eq 1
    expect(p.get_node('pool2').resource_count).to eq 0

  end

  it 'takes staging and commit steps into account when run with 3 pools for 1 turn only' do

    d = Diagram.new 'some_name'

    d.add_node! Pool, name: 'pool1', initial_value: 2, mode: :push, activation: :automatic

    d.add_node! Pool, name: 'pool2'

    d.add_node! Pool, name: 'pool3', activation: :automatic

    d.add_edge! Edge, name: 'edge1', from: 'pool1', to: 'pool2'

    d.add_edge! Edge, name: 'edge2', from: 'pool2', to: 'pool3'

    d.run!(1)

    expect(d.get_node('pool1').resource_count).to eq 1
    expect(d.get_node('pool2').resource_count).to eq 1
    expect(d.get_node('pool3').resource_count).to eq 0

  end

  it 'takes staging and commit steps into account when run with 3 pools for 4 turns' do

    d = Diagram.new 'some_name'

    d.add_node! Pool, name: 'pool1', initial_value: 10, mode: :push, activation: :automatic

    d.add_node! Pool, name: 'pool2'

    d.add_node! Pool, name: 'pool3', activation: :automatic

    d.add_edge! Edge, name: 'edge1', from: 'pool1', to: 'pool2'

    d.add_edge! Edge, name: 'edge2', from: 'pool2', to: 'pool3'


    d.run!(4)

    expect(d.get_node('pool1').resource_count).to eq 6
    expect(d.get_node('pool2').resource_count).to eq 1
    expect(d.get_node('pool3').resource_count).to eq 3


  end

  it 'runs with a source and a pool and have the expected amount of resources at the end' do

    d=Diagram.new 'simple'


    d.add_node! Source, {
        :name => 'source'
    }

    d.add_node! Pool, {
        :name => 'deposit',
    }

    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.run!(10)

    expect(d.get_node('deposit').resource_count).to eq 10

  end

  it 'can be run until a given condition is true' do
    d=Diagram.new 'simple'
    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }
    d.add_node! Source, {
        :name => 'source'
    }
    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.run_while! { d.get_node('deposit').resource_count < 10 }
    expect(d.get_node('deposit').resource_count).to eq 10

  end

  it 'aborts after 999 turns as a safeguard against infinite loops given as stopping condition' do

    # create a subclass for diagram (I recommend the name UnsafeDiagram) in
    # order to allow arbitrarily long execution loops

    d=Diagram.new 'simple'
    d.add_node! Pool, {
        :name => 'deposit',
        :initial_value => 0
    }
    d.add_node! Source, {
        :name => 'source'
    }
    d.add_edge! Edge, {
        :name => 'connector',
        :from => 'source',
        :to => 'deposit'
    }

    d.run_while! { true == true }

    #not hanging on forever is the success condition.

  end

  it "does not raise errors when active pushes or pulls are not possible" do

    pending "active pushes from an empty node should not cause errors and neither should active pulls from empty nodes"

  end

  it "correctly carries typed tokens from suitable nodes via suitable edges" do

    pending 'should i subclass edge so as to place type-specific behaviour elsewhere?'

  end





end
