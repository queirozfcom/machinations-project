require_relative '../spec_helper'

describe Diagram do
  using NumberModifiers

  context 'diagram tests using the dsl' do

    it 'runs with one pool with no name' do
      d = diagram do
        pool
      end

      d.run! 5

    end

    it 'runs with one pool with some params' do

      d = diagram do
        pool 'p', initial_value: 9, mode: :pull_all
      end

      d.run! 5
      expect(d.p.resource_count).to eq 9
    end

    it 'runs with conditions' do

      d = diagram 'conditions' do
        source 's1'
        pool 'p1'
        source 's2', condition: lambda{ p1.resource_count > 3 }
        pool 'p2'
        edge from: 's1', to: 'p1'
        edge from: 's2', to: 'p2'
      end

      d.run! 10

      expect(d.p2.resource_count).to eq 6

    end

    it 'runs with triggers'do
      d = diagram 'triggers' do
        source 's1'
        pool 'p1'
        source 's2', activation: :passive, triggered_by: 'p1'
        pool 'p2'
        edge from: 's1',to: 'p1'
        edge from: 's2', to: 'p2'
      end

      d.run! 10

      expect(d.p2.resource_count).to eq 10

    end

    it 'runs with a three-way, default gate' do

      d = diagram do
        source 's1'
        gate 'g1'
        edge from: 's1', to: 'g1'
        pool 'p1'
        pool 'p2'
        pool 'p3'
        edge 'e1', from: 'g1', to: 'p1',label: 1/3
        edge 'e1', from: 'g1', to: 'p2',label: 1/3
        edge 'e1', from: 'g1', to: 'p3',label: 1/3
      end


      d.run! 20
      #this gate is conservative - each resource necessarily goes to
      #either p1, p2 or p3 so the sum must be equal to the total amount
      #created by the source
      expect(d.p1.resource_count + d.p2.resource_count + d.p3.resource_count).to eq 20

    end

  end
end