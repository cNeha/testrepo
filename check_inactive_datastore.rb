###############################################
##This method will check the inactive datastore
###################################################

begin
  require 'rest-client'
  @method = 'check_inactive_datastore'
#  $evm.log("info", "-----------EVM automate Method: started")
  @debug = true
  #
  # get variables
  #
  prov = $evm.root["miq_provision"]
  vm = prov.vm_template
  raise "VM not specified" if vm.nil?
  ems = vm.ext_management_system
 raise "EMS not found for VM[#{vm.name}"] if ems.nil?

$evm.log(:info, "vm=[#{vm.name}], space required=[#{vm.provisioned_storage}]")

  # Get token
   server = "<vmware ip address>"
   session_url = "https://#{server}/rest/com/vmware/cis/session"
   session_result = []
   session_result = JSON.load(RestClient::Request.execute({
                                  :method => :post,
                                  :url => session_url,
                                  :verify_ssl => false,
                                  :user => "administrator@vsphere.local",
                                  :password => "password",
                                  :headers => {:content_type => 'application/json'}}))
   $evm.log(:info, "Result is #{session_result}")
   session_id = session_result['value']
   puts "Session is #{session_id}"

host = storage = nil
min_registered_vms = nil

prov.eligibel_hosts.each do |h|
   next if h.maintenance
   next unless h.power_state == "on"
   nvm = h.vms.length
   if min_registered_length.nil? || nvms < min_registered_vms


h.writable_storages.find_all { |s| 
# Get Datastore infromaiton
url = "https://#{server}/rest/vcenter/datastore/#{s.name}"
  result = JSON.load(RestClient::Request.execute({
                        :method => :get,
                        :url => url,
                        :verify_ssl => false,
                        :headers => {:content_type => 'application/json', 'vmware-api-session-id' => session_id }}))
  puts "Result is #{result}"
  accessible = result['value']['accessible'] 
    storage = s
    host = h
    min_registered_vms = nvms
    break if accessible
  end
}
end

#set host and storage
 
prov.set_host(host) if host
prov.set_storage(storage) if storage

$evm.log("info", "vm=[#{vm.name}] host=[#{host}] storage=[#{storage}]")
end
