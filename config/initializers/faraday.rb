# makes sure faraday 400 and 500 responses raise an error, see: https://lostisland.github.io/faraday/#/middleware/included/raising-errors

Faraday.default_connection = Faraday.new do |conn|
  conn.response :raise_error
end
