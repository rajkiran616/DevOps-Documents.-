require 'aws-sdk'

region = 'us-east-1'
key_name = 'devenv'
availability_zone = 'us-east-1a'

Aws.config({
  :access_key_id => '',
  :secret_access_key => ''
});

Aws.config.update({region: 'us-west-1'});

Aws::EC2::Client.new(region: region);

image_id = 'ami-08111162'
security_groups = 'devsg'
instance_type = 't2.micro'
placement = { availability_zone: 'us-east-1a' }
block_device_mappings = [{ device_name: '/dev/sda1', ebs: { volume_size: 8, volume_type: 'gp2'} }]
ec2.run_instances image_id: image_id, key_name: key_name, security_groups: security_groups, min_count: 1, max_count: 1, instance_type: instance_type, placement: placement, block_device_mappings: block_device_mappings



