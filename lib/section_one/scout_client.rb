require 'faraday'
require 'faraday_middleware'
require 'serious'

module SectionOne
  class ScoutClient
    def initialize(credentials)
      @account  = credentials[:account]
      @email    = credentials[:email]
      @password = credentials[:password]
    end

    def connection
      Faraday::Connection.new("https://scoutapp.com/#{@account}/") do |b|
        b.adapter Faraday.default_adapter
        b.use     Faraday::Response::RaiseError
        b.use     FaradayMiddleware::ParseXml, :content_type => /\bxml$/
      end.tap do |c|
        c.basic_auth @email, @password
      end
    end

    def valid?
      resp = connection.get('clients.xml') do |r|
        r.params = { :limit => 1 }
      end

      return resp.success?
    rescue
      return false
    end

    def values_for(identifier, start_at, end_at)
      resp = connection.get('descriptors/series.xml') do |req|
        req.params = {
          :ids   => identifier['id'],
          :start => start_at.to_i,
          :end   => end_at.to_i
        }
      end

      resp.body['records']['data'].map do |record|
        record['value'].to_f
      end
    end

    def metrics
      clients.map do |client|
        Serious.future(client) do |client|
          metrics_for_client(client)
        end
      end.map do |m|
        Serious.demand(m)
      end.flatten.compact
    end

    def clients
      connection.get('clients.xml').body['clients']
    end

    def metrics_for_client(client)
      client_id = client['id']
      name      = client['name']

      plugins = connection.get("clients/#{client_id}/plugins.xml").body['plugins']
      plugins.map do |plugin|
        descriptors = plugin['descriptors']
        next unless descriptors
        descriptor = descriptors['descriptor']
        next unless descriptor

        descriptor = [ descriptor ].flatten

        descriptor.map do |description|
          Metric.new do |m|
            m.name        = metric_name(name, description['name'])
            m.description = metric_description(name, description['name'])
            m.units       = description['units']
            m.graph_url   = "https://scoutapp.com/#{@account}/charts?d=#{description['id']}"

            m.service_identifier = { :id => description['id'] }
          end
        end
      end.flatten.compact
    end

    def metric_name(client_name, metric_description)
      _, plugin_name, metric_name = *metric_description.match(%r{(.*)/([^/]+)$})

      regex = %r{[ \(\)_\-\.]+}

      client_name = client_name.gsub(regex, ' ').strip.downcase

      plugin_name = plugin_name.gsub(regex, ' ').strip.downcase
      plugin_name = plugin_name.gsub(%r{ w/}, ' with ')
      plugin_name = plugin_name.gsub(%r{ /$}, ' root ')
      plugin_name = plugin_name.gsub(%r{ /}, ' ')

      plugin_name = plugin_name.gsub('/', 'slash')
      plugin_name = plugin_name.gsub('%', 'percent')

      metric_name = metric_name.gsub(regex, ' ').strip.downcase
      metric_name = metric_name.gsub('/', 'slash')
      metric_name = metric_name.gsub('%', 'percent')

      "#{client_name}.#{plugin_name}.#{metric_name}".tr(' ', '_')
    end

    def metric_description(client_name, metric_description)
      _, plugin_name, metric_name = *metric_description.match(%r{(.*)/([^/]+)$})

      "#{client_name}: #{plugin_name}: #{metric_name}"
    end
  end
end