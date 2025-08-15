Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") }

  # Dynamically determine the queue name
  prefix = Rails.application.config.active_job.queue_name_prefix
  default_queue = prefix.present? ? "#{prefix}_default" : "default"

  config.options[:queues] = [default_queue]
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") }
end
