module Fluent
  class RiakStatsInput < Fluent::Input
    Fluent::Plugin.register_input('riak_stats', self)

    def initialize
      super
      require 'net/http'
      require 'json'
    end

    config_param :bind,     :string,  default: '127.0.0.1'
    config_param :port,     :integer, default: 8098
    config_param :interval, :integer, default: 30

    def configure(conf)
      super
    end

    def start
      super
      @loop = Coolio::Loop.new
      @timer = RiakStatsInputTimerWatcher.new(@interval, true, &method(:watch))
      @loop.attach(@timer)
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      super
      @loop.watchers.each { |w| w.detach }
      @loop.stop
      @thread.terminate
      @thread.join
    end

    def run
      @loop.run
    rescue => e
      $log.error "#{e.class.name} - #{e.message}"
    end

    private
    def riak_stats
      # see. http://docs.basho.com/riak/latest/cookbooks/Statistics-and-Monitoring/
      #   Counters "Gets and Puts" and Riak Metrics To Graph
      m = ["node_gets", "node_gets_total", "node_puts", "node_puts_total",
           "vnode_gets", "vnode_gets_total", "vnode_puts_total",
           "node_get_fsm_objsize_mean", "node_get_fsm_objsize_median", "node_get_fsm_objsize_95",
           "node_get_fsm_objsize_100", "node_get_fsm_time_mean", "node_get_fsm_time_median",
           "node_get_fsm_time_95", "node_get_fsm_time_100", "node_put_fsm_time_mean",
           "node_put_fsm_time_median", "node_put_fsm_time_95", "node_put_fsm_time_100",
           "node_get_fsm_siblings_mean", "node_get_fsm_siblings_median", "node_get_fsm_siblings_95",
           "node_get_fsm_siblings_100", "memory_processes_used", "read_repairs",
           "read_repairs_total", "sys_process_count", "coord_redirs_total",
           "pbc_connect", "pbc_active"
          ]
      response = Net::HTTP.get_response(@bind, "/stats", @port)
      stats = response.body
      data = JSON.parse(stats)
      h = Hash::new
      m.map do |key_name|
        h[key_name] = data[key_name]
      end
      return h
    end

    def watch
      Fluent::Engine.emit("riak_stats", Fluent::Engine.now, riak_stats)
    end
  end

  class RiakStatsInputTimerWatcher < Coolio::TimerWatcher
    def initialize(interval, repeat, &callback)
      @callback = callback
      super(interval, repeat)
    end

    def on_timer
      @callback.call
    rescue => e
      $log.error "#{e.class.name} - #{e.message}"
    end
  end
end
