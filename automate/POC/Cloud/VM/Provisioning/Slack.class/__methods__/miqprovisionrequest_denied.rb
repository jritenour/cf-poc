#
# Description: This method is used to send a notification to slack that a request has been approved
#
# Events: request_approved
#
# Model Notes:
# 1. token - the slack API token to make the request
# 2. channel - the channel to send the notification to

# As this is a simple API call that can be done with get, we'll require rest-client

require 'rest-client'
# Get miq_request from root
miq_request = $evm.root['miq_request']
token=$evm.object.decrypt('token')
channel ||= $evm.object['channel']

raise "miq_request missing" if miq_request.nil?
$evm.log("info", "Detected Request:<#{miq_request.id}> with Approval State:<#{miq_request.approval_state}>")

# Override the default appliance IP Address below
appliance = nil
# appliance ||= 'evmserver.example.com'
appliance ||= $evm.root['miq_server'].ipaddress

RestClient.get "http://slack.com/api/chat.postMessage?token=#{token}&channel=#{channel}&text=Request ID #{miq_request.id} has been denied by Administrator because #{miq_request.reason}"

