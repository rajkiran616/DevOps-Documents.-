readonly KEY_NAME="devenvkey"
eeadonly INSTANCE_TYPE="t2-micro"
readonly AZ="us-east-1a"
readonly REGION="us-east-1"
readonly ROLE_NAME="dev-ec2-instance"
readonly vpcId="vpc-f603e291"
readonly subnetId="subnet-145d1f62"
readonly image_id="ami-2051294a"
readonly cidr="0.0.0.0/0"
readonly securityGroupId="sg-b16b60c9"


launch_instance(){
  #Create elastic IP
	aws ec2 allocate-address; 
  	local elastic_Id=`aws ec2 describe-addresses --output text --query "Addresses[].AllocationId | [0]"` ;
  #Creating an EC2 instance and storing its instance Id in a variable
  	instance_id=$(aws ec2 run-instances --image-id "$image_id" --count 1 --user-data "/home/vkiran/awscli/userdatascript.sh" --instance-type "t2.micro" --key-name "devenvkey" --subnet-id $subnetId --region "us-east-1" --output text --query "Instances[*].InstanceId") ;
  	echo -n "Waiting for instance to be in the running state..."
  	aws ec2 wait instance-running --instance-ids "$instance_id" ;
 	echo "Done..Instance $instance_id is created";
  #creating ebs volume
  	aws ec2 create-volume --size "8" --region "$REGION"  --availability-zone "$AZ" --volume-type "gp2"  ;
  #Storing the volume Id
  	aws ec2 associate-address --instance-id "$instance_id" --allocation-id "$elastic_Id" ;
  
  	volumeId=$(aws ec2 describe-volumes --output text --query "Volumes[].VolumeId | [1]") ;
  	aws ec2 wait volume-available --volume-ids $volumeId ;
  	aws ec2 attach-volume --volume-id "$volumeId" --instance-id "$instance_id" --device "/dev/sdf" ;
	aws route53 create-hosted-zone --name "rajkiran.server.com" --vpc "$vpcId" --caller-reference "2014-04-01-18:47" --hosted-zone-config Comment="command-line version";
	if [ -f "/home/vkiran/awscli/recordset.json" ]; then
		sed 's/^"Value":'.*'/"Value":$elastic_Id/g' /home/vkiran/awscli/recordset.json
	fi
	aws route53 change-resource-record-sets --hosted-zone-id "rajkiraserver" --change-batch "/home/vkiran/awscli/recordset.json"
}
launch_instance ;


stop_instance(){
		local instance_id=$1
		aws ec2 stop-instances --instance-ids $instance_id
		aws ec2 wait instance-stopped --instance-ids $instance_id
		echo " Instance $instance_id is stopped completely "
		}
stop_instance $instance_id;

restart_instance()
		{
  		local instance_id=$1
		aws ec2 start-instances --instance-ids $instance_id
		aws ec2 wait instance-running --instance-ids $instance_id	 
		}
restart_instance $instance_id;



