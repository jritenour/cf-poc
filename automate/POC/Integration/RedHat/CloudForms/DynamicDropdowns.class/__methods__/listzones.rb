####################################  
#  
# CloudForms Automate Method: BigIP_List_Pools  
#  
# This method is used generate a list of pools from a v11.x F5 appliance  
#  
###################################  
#  
# Method for logging  
begin  
  @method = 'BigIP_List_Pools'  
  
  $evm.log(:info, "#{@method} - EVM Automate Method Started")  
  
  # Turn of verbose logging  
  @debug = true  
  
  
  ###################################  
  # Method: dumpRoot  
  #  
  ###################################  
  def dumpRoot  
    $evm.log(:info, "#{@method} - Root:<$evm.root> Begin Attributes")  
    $evm.root.attributes.sort.each { |k, v| $evm.log(:info, "#{@method} - Root:<$evm.root> Attributes - #{k}: #{v}")}  
    $evm.log(:info, "#{@method} - Root:<$evm.root> End Attributes")  
    $evm.log(:info, "")  
  end  
  
  dumpRoot  
  
  $evm.log(:info, "#{@method} - ================================= EVM Automate Method Started")  
  
  require 'rest-client'  
  require 'json'  
  require "active_support/core_ext"  
  require 'rubygems'  
  
  
  @cfhost = nil || $evm.object['cfhost']  
  @cfuser = nil || $evm.object['cfuser']  
  @cfpass = nil || $evm.object.decrypt('cfpass')
  @url="https://#{@cfhost}/api/zones?expand=resources"  
    
  def call_bigip()  
    params = {  
        :method=>"get",  
        :url=>@url,  
        :user=>@cfuser,  
        :password=>@cfpass,  
        :verify_ssl => OpenSSL::SSL::VERIFY_NONE,  
        :headers=>{ :content_type=>:json, :accept=>:json }  
    }  
    $evm.log(:info, "Calling -> CloudForms:<#{@url}> payload:<#{params[:payload]}>")  
    response = RestClient::Request.new(params).execute  
    $evm.log(:info, "Success <- F5 BigIP Response:<#{response.code}>")  
    response_hash = JSON.parse(response)  
    $evm.log(:info, "Inspecting response_hash: #{response_hash.inspect}")  
    return response_hash  
  end  
  
  pools = call_bigip()  
  
  names=pools['resources'].map { |x| [x["id"],x["description"]] }  
  $evm.log(:info, "Inspecting Pool Names: #{names.inspect}")  
  list_values = {  
    'sort_by' => :none,  
    'data_type'  => :string,  
    'required'   => false,  
    'values'     => [[nil, nil]] + names.to_a,  
    }  
  $evm.log(:info, "Dynamic drop down values: Names drop-down: [#{list_values}]")   
  list_values.each { |k,v| $evm.object[k] = v }  
    
  # Exit method  
  $evm.log(:info, "CFME Automate Method Ended")  
  exit MIQ_OK  
  
    # Set Ruby rescue behavior  
rescue => err  
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")  
  exit MIQ_STOP  
end  
