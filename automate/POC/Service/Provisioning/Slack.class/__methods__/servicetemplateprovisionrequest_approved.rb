#
# Description: This method is used to email the provision requester that
# the Service provisioning request has been approved
#
# Events: request_approved
#
# Model Notes:
# 1. to_email_address - used to specify an email address in the case where the
#    requester does not have a valid email address. To specify more than one email
#    address separate email address with commas. (I.e. admin@example.com,user@example.com)
# 2. from_email_address - used to specify an email address in the event the
#    requester replies to the email
# 3. signature - used to stamp the email with a custom signature
#

require 'rest-client'
  $evm.log('info', "Requester email logic starting")

  # Get requester object
#  requester = miq_request.requester


  $evm.log('info', "Requester email:<#{requester_email}> Owner Email:<#{owner_email}>")

  # Build email body
 # message = "#{miq_request.id} for #{requester} has been approved. Reason was #{miq_request.reason}." 

  # Send email
  #$evm.log("info", "Sending email to <#{to}> from <#{from}> subject: <#{subject}>")
#  $evm.execute(:send_email, to, from, subject, body)


# Get miq_request from root
miq_request = $evm.root['miq_request']
raise "miq_request missing" if miq_request.nil?
$evm.log("info", "Detected Request:<#{miq_request.id}> with Approval State:<#{miq_request.approval_state}>")

RestClient.get "http://jmrlabs.slack.com/api/chat.postMessage?token=xoxb-299950798145-vKwmFPduTXyHondlNeK3VCn8&channel=cloudforms&text=#{miq_request.id} for #{requester} has been approved. Reason was #{miq_request.reason}."
