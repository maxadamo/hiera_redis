Puppet::Functions.create_function(:redis_lookup_key) do
  begin
    require 'redis'
  rescue LoadError
    raise Puppet::DataBinding::LookupError, 'The redis gem must be installed to use redis_lookup_key'
  end

  dispatch :redis_lookup_key do
    param 'Variant[String, Numeric]', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def redis_lookup_key(key, options, context)
    return context.cached_value(key) if context.cache_has_key(key)

    host      = options['host']      || 'localhost'
    port      = options['port']      || 6379
    db        = options['db']        || 0
    scopes    = options['scopes']    || [options['scope']]
    separator = options['separator'] || ':'

    redis  = Redis.new(host: host, port: port, db: db)
    result = nil

    scopes.each do |scope|
      redis_key = scope.nil? ? key : [scope, key].join(separator)
      result = redis_get(redis, redis_key)
      break unless result.nil?
    end

    context.not_found if result.nil?
    context.cache(key, result)
  end

  def redis_get(redis, key)
    case redis.type(key)
    when 'string'
      redis.get(key)
    when 'list'
      redis.lrange(key, 0, -1)
    when 'set'
      redis.smembers(key)
    when 'zset'
      redis.zrange(key, 0, -1)
    when 'hash'
      redis.hgetall(key)
    end
  end
end
