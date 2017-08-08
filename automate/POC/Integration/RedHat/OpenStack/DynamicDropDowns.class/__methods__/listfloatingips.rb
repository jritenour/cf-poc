begin

  def dump_root()  
    $evm.log(:info, "Root:<$evm.root> Begin $evm.root.attributes")  
    $evm.root.attributes.sort.each { |k, v| $evm.log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}  
    $evm.log(:info, "Root:<$evm.root> End $evm.root.attributes")  

  end  

dump_root

provnet=$evm.vmdb(:ems).find_by_type("ManageIQ::Providers::Openstack::NetworkManager")
ip_hash = {}
provnet.floating_ips.each do |floatip|
ip_hash[floatip.id] = "#{floatip.address}" if floatip.status == "DOWN"
end
ip_hash[nil] = nil 

$evm.object['values'] = ip_hash
  if $evm.root['dialog_float_ip_checkbox'] == 't'
    $evm.object['visible'] = true
  else
    $evm.object['visible'] = false
  end

$evm.log(:info, "Dropdown Values Are #{$evm.object['values'].inspect}")

end
