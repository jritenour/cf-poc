# ListCloudTenants.rb
#
# Description: List Cloud Tenants in OpenStack
#
def dump_user
  user = $evm.root['user']
  unless user.nil?
    $evm.log("info","#{@method} - User:<#{user.name}> Begin Attributes [user.attributes]")
    user.attributes.sort.each { |k, v| $evm.log("info", "#{@method} - User:<#{user.name}> Attributes - #{k}: #{v.inspect}")}
    $evm.log("info","#{@method} - User:<#{user.name}> End Attributes [user.attributes]")
    $evm.log("info", "")

    $evm.log("info","#{@method} - User:<#{user.name}> Begin Associations [user.associations]")
    user.associations.sort.each { |assc| $evm.log("info", "#{@method} - User:<#{user.name}> Associations - #{assc}")}
    $evm.log("info","#{@method} - User:<#{user.name}> End Associations [user.associations]")
    $evm.log("info","")

    unless user.tags.nil?
      $evm.log("info","#{@method} - User:<#{user.name}> Begin Tags [user.tags]")
      user.tags.sort.each { |tag_element| tag_text = tag_element.split('/'); $evm.log("info", "#{@method} - User:<#{user.name}> Category:<#{tag_text.first.inspect}> Tag:<#{tag_text.last.inspect}>")}
      $evm.log("info","#{@method} - User:<#{user.name}> End Tags [user.tags]")
      $evm.log("info","")
    end

    $evm.log("info","#{@method} - User:<#{user.name}> Begin Virtual Columns [user.virtual_column_names]")
    user.virtual_column_names.sort.each { |vcn| $evm.log("info", "#{@method} - User:<#{user.name}> Virtual Columns - #{vcn}: #{user.send(vcn).inspect}")}
    $evm.log("info","#{@method} - User:<#{user.name}> End Virtual Columns [user.virtual_column_names]")
    $evm.log("info","")
  end
end

def dump_group
  user = $evm.root['user']
  unless user.nil?
    miq_group = user.current_group
    unless miq_group.nil?
      $evm.log("info","#{@method} - Group:<#{miq_group.description}> Begin Attributes [miq_group.attributes]")
      miq_group.attributes.sort.each { |k, v| $evm.log("info", "#{@method} - Group:<#{miq_group.description}> Attributes - #{k}: #{v.inspect}")} unless $evm.root['user'].miq_group.nil?
      $evm.log("info","#{@method} - Group:<#{miq_group.description}> End Attributes [miq_group.attributes]")
      $evm.log("info", "")

      $evm.log("info","#{@method} - Group:<#{miq_group.description}> Begin Associations [miq_group.associations]")
      miq_group.associations.sort.each { |assc| $evm.log("info", "#{@method} - Group:<#{miq_group.description}> Associations - #{assc}")}
      $evm.log("info","#{@method} - Group:<#{miq_group.description}> End Associations [miq_group.associations]")
      $evm.log("info","")

      unless miq_group.tags.nil?
        $evm.log("info","#{@method} - Group:<#{miq_group.description}> Begin Tags [miq_group.tags]")
        miq_group.tags.sort.each { |tag_element| tag_text = tag_element.split('/'); $evm.log("info", "#{@method} - Group:<#{miq_group.description}> Category:<#{tag_text.first.inspect}> Tag:<#{tag_text.last.inspect}>")}
        $evm.log("info","#{@method} - Group:<#{miq_group.description}> End Tags [miq_group.tags]")
        $evm.log("info","")
      end

      $evm.log("info","#{@method} - Group:<#{miq_group.description}> Begin Virtual Columns [miq_group.virtual_column_names]")
      miq_group.virtual_column_names.sort.each { |vcn| $evm.log("info", "#{@method} - Group:<#{miq_group.description}> Virtual Columns - #{vcn}: #{miq_group.send(vcn).inspect}")}
      $evm.log("info","#{@method} - Group:<#{miq_group.description}> End Virtual Columns [miq_group.virtual_column_names]")
      $evm.log("info","")
    end
  end
end

def get_tags_from_obj(obj, match_string)
  return obj.tags.select {
    |tag| tag.to_s.starts_with?("#{match_string}")
  }
end

$evm.log(:info, "Begin Automate Method")

# Refresh Available Cloud Tenant Tags
$evm.instantiate("/System/Event/Cloud_Tagging")

dump_user
dump_group
$evm.log(:info, "Done dumping root, user and group")

start_string = $evm.object["tenant_category_name"]
start_string = "cloud_tenants" if start_string.nil?


user_tags = get_tags_from_obj($evm.root['user'], start_string)
$evm.log(:info, "User Tenant-related Tags: #{user_tags.inspect}")

group_tags = get_tags_from_obj($evm.root['user'].current_group, start_string)
$evm.log(:info, "Group Tenant-related Tags: #{group_tags.inspect}")

group_tags = user_tags  if group_tags.nil? || group_tags.length <= 0
user_tags  = group_tags if user_tags.nil? || user_tags.length <= 0

$evm.log(:info, "Group Tenant-related Tags: #{group_tags.inspect}")

intersection_tags = nil
if group_tags.length > 0 && user_tags.length > 0
  intersection_tags = group_tags & user_tags
  $evm.log(:info, "Intersection of Group and User Tags (these are the tenants available to this user: #{intersection_tags.inspect}")
else
  $evm.log(:info, "User and Group are not tagged with tenants, allowing access to all tenants for this user")
end

openstack_hash = {}
openstack_hash[nil] = nil

list = $evm.vmdb(:cloud_tenant).all
for item in list
  $evm.log(:info, "Cloud Tenant: #{item.inspect}")
  unless $evm.root['dialog_mid'].blank?
    next unless item.ems_id.to_s == "#{$evm.root['dialog_mid']}"
  end
  ems = $evm.vmdb(:ems_openstack).find_by_id(item.ems_id)
  unless intersection_tags.nil?
    openstack_hash[item.id] = "#{item.name} in #{ems[:hostname]}" if intersection_tags.include?("#{start_string}/#{item.name}")
  else
    openstack_hash[item.id] = "#{item.name} in #{ems[:hostname]}"
  end
end

if openstack_hash.length <= 1
  $evm.log(:info, "User has no access to tenants")
  openstack_hash[nil] = "No Tenant Access, Contact Administrator"
end

$evm.object['values'] = openstack_hash
$evm.log(:info, "Dynamic drop down values: #{$evm.object['values']}")
