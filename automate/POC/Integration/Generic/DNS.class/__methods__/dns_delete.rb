#dns_delete
#Jason Ritenour
#April 19, 2017
# This method uses IO.popen to call nsdupate to create/update DNS A records on BIND platforms.  
begin
  # dump_root  
  def dump_root()  
    $evm.log(:info, "Root:<$evm.root> Begin $evm.root.attributes")  
    $evm.root.attributes.sort.each { |k, v| $evm.log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}  
    $evm.log(:info, "Root:<$evm.root> End $evm.root.attributes")  

  end  
#miq_request = $evm.root['service_template_provision_task'].miq_request
#tasks=miq_request.miq_request.tasks
#tasks.attributes.sort.each { |k, v| $evm.log(:info, "Task info:<tasks> Attribute - #{k}: #{v}")} 

dump_root
prov = $evm.root['miq_provision']
vm = $evm.root['vm'] || prov.vm
fqdn=vm.name
#domain=".home.lab"
#fqdn=hostname+domain
ip=vm.ipaddresses[0]
dnsserver=$evm.object['dnsserver']
dnskey=$evm.object['dnskey']
dnssecret=$evm.object.decrypt('dnssecret')

#dump_root
      $evm.log(:info, "Using DNS Server at #{dnsserver}")  

#dnsserver        = Resolv.getaddress(dnsserver) rescue nil 
  IO.popen("nsupdate -y #{dnskey}:#{dnssecret} -v", 'r+') do |f|
   f.puts("server #{dnsserver}")
    f.puts("update delete #{fqdn} A ")  
    $evm.log("info","IAAS: #{@method} Deleting DNS record for #{fqdn} #{ip}")  
   f.puts("send")
   f.close_write
  end
end
