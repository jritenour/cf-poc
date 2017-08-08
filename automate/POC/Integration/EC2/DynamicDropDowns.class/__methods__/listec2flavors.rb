begin

  def dump_root()  
    $evm.log(:info, "Root:<$evm.root> Begin $evm.root.attributes")  
    $evm.root.attributes.sort.each { |k, v| $evm.log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}  
    $evm.log(:info, "Root:<$evm.root> End $evm.root.attributes")  

  end  

dump_root

prov=$evm.vmdb(:ems).find_by_type("ManageIQ::Providers::Amazon::CloudManager")
#rov_net=$evm.vmdb(:ems).find_by_id(10000000000004)
flavor_hash = {}
prov.flavors.each do |flavor|
flavor_hash[flavor.id] = "#{flavor.name}" 
end
flavor_hash[nil] = nil 

$evm.object['values'] = flavor_hash

$evm.log(:info, "Dropdown Values Are #{$evm.object['values'].inspect}")

end
