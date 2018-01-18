#dns_update
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
dnsserver=$evm.object['dnsserver']
  attributes = $evm.root.attributes
  ip = attributes['dialog_option_1_floating_ip_address']  

#dump_root
      $evm.log(:info, "Using DNS Server at #{dnsserver}")  

#dnsserver        = Resolv.getaddress(dnsserver) rescue nil 
  hostname=IO.popen("nslookup #{ip} |grep arpa | cut -f 3 -d ' '|awk -F '\\.1.168' '{print $1}'") 
  output=hostname.read
  hostname.close
      $evm.log("info","IAAS: #{@method} DNS update add #{output}")  
    list_values = {  
    'sort_by' => :none,  
    'data_type'  => :string,  
    'required'   => false,  
    'values'     => [[ output, output]],  
    }  
  $evm.log(:info, "Dynamic drop down values: Names drop-down: [#{list_values}]")   
  list_values.each { |k,v| $evm.object[k] = v }  

end
