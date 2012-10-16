require 'faraday'
require 'faraday_middleware'
require 'serious'

module SectionOne
  class LibratoMetricsClient
    def initialize(credentials)
      @email = credentials[:email]
      @token = credentials[:token]
    end

    def connection
      Faraday::Connection.new('https://metrics-api.librato.com/v1/') do |b|
        b.adapter Faraday.default_adapter
        b.use     Faraday::Response::RaiseError
        b.use     FaradayMiddleware::ParseJson, :content_type => /\bjson$/
      end.tap do |c|
        c.basic_auth @email, @token
      end
    end

    def valid?
      resp = connection.get('metrics') do |r|
        r.params = { :length => 1}
      end
      return resp.success?
    rescue => e
      return false
    end

    def all_metrics
      paginated_query('metrics') do |resp|
        resp['metrics'].map do |metric|
          Metric.new do |m|
            m.name        = metric['name']
            m.description = metric['description']
            m.units       = metric['attributes']['display_units_short']
            m.graph_url   = "https://metrics.librato.com/metrics/#{metric['name']}"

            m.service_identifier = {
              :name => metric['name'],
              :description => metric['description'],
              :type => 'metric'
            }
          end
        end
      end
    end

    def instruments
      paginated_query('instruments') do |resp|
        resp['instruments'].map do |instrument|
          Metric.new do |m|
            m.name  = instrument['name']
            m.units = instrument['attributes']['display_units_short']

            m.service_identifier = {
              :id => instrument['id'],
              :type => 'instrument'
            }
          end
        end
      end
    end

    def metrics
      results = [
        Serious.future { all_metrics },
        # Serious.future { instruments }
      ]

      results.flatten.map do |r|
        Serious.demand(r)
      end.flatten.compact
    end

    def paginated_query(path, &block)
      results = []

      resp = connection.get(path).body

      results << block.call(resp)

      length = resp['query']['length']
      found  = resp['query']['found']
      offset = resp['query']['offset']

      if length == 0
        return results
      end

      if length == found
        return results
      end

      offset += length

      while offset < found
        results << Serious.future(offset, length) do |offset, length|
          resp = connection.get(path) do |req|
            req.params = {
              :offset => offset,
              :length => length
            }
          end.body

          block.call(resp)
        end

        offset += length
      end

      results
    end
  end
end