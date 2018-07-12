Puppet::Functions.create_function(:redis_lookup_key) do
  begin
    require 'redis'
  rescue LoadError
    raise Puppet::DataBinding::LookupError, '[hiera-redis] The redis gem must be installed to use hiera-redis'
  end

  dispatch :redis_lookup_key do
    param 'Variant[String, Numeric]', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def redis_lookup_key(key, options, context)
    return context.cached_value(key) if context.cache_has_key(key)

    result = redis_get(key, options)

    context.not_found if result.nil?
    context.cache(key, result)
  end

  def redis_get(key, options)
    redis = Redis.new(host: 'localhost', port: 6379, db: 0)

    scopes = options['scopes']

    scopes.each do |scope|
      result = redis.get([scope, key].join(':'))
      return result unless result.nil?
    end

    nil
  end
end
