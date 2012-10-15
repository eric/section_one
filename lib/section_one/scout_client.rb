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
          Metric.new('scout').tap do |metric|
            metric.name  = "#{name}: #{description['name']}"
            metric.units = description['units']
            metric.service_identifier = { :id => description['id'] }
          end
        end
      end.flatten.compact
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
  end
end