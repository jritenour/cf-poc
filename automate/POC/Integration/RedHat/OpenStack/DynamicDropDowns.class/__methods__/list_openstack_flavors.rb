begin

  def dump_root()  
    $evm.log(:info, "Root:<$evm.root> Begin $evm.root.attributes")  
    $evm.root.attributes.sort.each { |k, v| $evm.log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}  
    $evm.log(:info, "Root:<$evm.root> End $evm.root.attributes")  

  end  

dump_root

prov=$evm.vmdb(:ems).find_by_type("ManageIQ::Providers::Openstack::CloudManager")
flav_hash = {}
prov.flavors.each do |flavor|
flav_hash[flavor.id] = "#{flavor.name}"
end
flav_hash[nil] = nil 

$evm.object['values'] = flav_hash

$evm.log(:info, "Dropdown Values Are #{$evm.object['values'].inspect}")

end
