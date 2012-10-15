class DashboardsController < ApplicationController
  def index
  end

  def show
    @data = [
      [
        { 
          :name => 'Web',
          :metrics => [
            { 
              :name => 'Request Rate',
              :unit => 'reqs/sec',
              :values => 60.times.map { rand(40) }
            },
            { 
              :name => 'Request Time',
              :unit => 'ms',
              :values => 60.times.map { rand(100) }
            },
          ]
        },
        { 
          :name => 'API',
          :metrics => [
            { 
              :name => 'Request Rate',
              :unit => 'reqs/sec',
              :values => 60.times.map { rand(20) }
            },
            { 
              :name => 'Request Time',
              :unit => 'ms',
              :values => 60.times.map { rand(20) }
            },
          ]
        },
      ],
      [
        { 
          :name => 'Database',
          :metrics => [
            { 
              :name => 'Insert Rate',
              :unit => 'cmds/sec',
              :values => 60.times.map { rand(20) }
            },
            { 
              :name => 'Select Rate',
              :unit => 'cmds/sec',
              :values => 60.times.map { rand(20) }
            },
          ]
        },
        { 
          :name => 'CPU',
          :metrics => [
            { 
              :name => 'CPU usage/system',
              :unit => '%',
              :values => [1.0065, 1.0844, 0.9265, 1.0698, 0.9848, 0.9744, 0.966, 1.0757, 0.9985, 1.0596, 1.0533, 0.9794, 1.0899, 0.9844, 1.0526, 1.0366, 1.0119, 1.0229, 0.9696, 0.9384, 1.021, 1.0054, 0.9471]
            }
          ]
        },
        
      ],
      [
        { 
          :name => 'Queues',
          :metrics => [
            { 
              :name => 'Queue Depth',
              :unit => 'messages',
              :values => 60.times.map { rand(20) }
            },
            { 
              :name => 'Queue Age',
              :unit => 'seconds',
              :values => 60.times.map { rand(20) }
            },
            { 
              :name => 'Queue Rate',
              :unit => 'msgs/sec',
              :values => 60.times.map { rand(20) }
            }
          ]
        },
      ]
    ]
  end
end
