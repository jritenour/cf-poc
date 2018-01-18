#
# Description: This method sends a Slack notification when the following event is raised:
#
# Events: vm_provisioned
#
# Model Notes:
# 1. token - slack API token to authenticate in order to post the message
# 2. channel - channel to send the notifcation to
#

require 'rest-client'
# Get vm from miq_provision object
prov = $evm.root['miq_provision']
vm = prov.vm
raise "VM not found" if vm.nil?

token=$evm.object.decrypt('token')
channel ||= $evm.object['channel']
#Get appliance info - will use this in a later version
appliance ||= $evm.root['miq_server'].ipaddress

# Get owner info - will use this in a later revision
#
evm_owner_id = vm.attributes['evm_owner_id']
owner = nil
owner = $evm.vmdb('user', evm_owner_id) unless evm_owner_id.nil?
$evm.log("info", "VM Owner: #{owner.inspect}")

# Post the actual message to slack
RestClient.get "http://slack.com/api/chat.postMessage?token=#{token}&channel=#{channel}&text=Virtual machine #{vm['name']} has completed provisioning at #{Time.now.strftime('%A, %B %d, %Y at %I:%M%p')}."
