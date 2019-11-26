
require_relative '../config/environment'

Client.all.each do |cl|
  next if cl.code.present?

  cl.set_client_code
  if cl.save(validate: false)
    puts "Set code for client #{cl.id} to #{cl.code}"
  else
    puts "Error setting code for client #{cl.id}"
  end
end
