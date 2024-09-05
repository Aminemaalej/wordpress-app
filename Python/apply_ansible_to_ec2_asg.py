import boto3
import subprocess
import sys

available_regions = ['eu-west-1', 'ap-southeast-1', 'us-east-1']

print("Select the AWS region:")
for idx, region in enumerate(available_regions, 1):
    print(f"{idx}. {region}")

# Get the user's region choice
while True:
    try:
        region_choice = int(input("Enter the number corresponding to your region (1-3): "))
        if 1 <= region_choice <= len(available_regions):
            region_name = available_regions[region_choice - 1]
            break
        else:
            print("Invalid selection. Please enter a number between 1 and 3.")
    except ValueError:
        print("Invalid input. Please enter a valid number.")

ec2_client = boto3.client('ec2', region_name=region_name)
asg_client = boto3.client('autoscaling', region_name=region_name)
ssm_client = boto3.client('ssm', region_name=region_name)

asg_name = 'wordpress-asg'
playbook_file = 'Ansible/playbook.yml'

# Fetch EC2 instance IDs from Auto Scaling Group
def get_instance_ids_from_asg(asg_name):
    try:
        response = asg_client.describe_auto_scaling_groups(AutoScalingGroupNames=[asg_name])
        instance_ids = [instance['InstanceId'] for instance in response['AutoScalingGroups'][0]['Instances']]
        if instance_ids:
            print(f"EC2 instances in Auto Scaling Group '{asg_name}': {instance_ids}")
            return instance_ids
        else:
            print(f"No instances found in Auto Scaling Group '{asg_name}'")
            return []
    except Exception as e:
        print(f"Error fetching instances from ASG: {e}")
        sys.exit(1)

# Check if EC2 instance is managed by SSM
def check_instance_managed(instance_id):
    try:
        response = ssm_client.describe_instance_information(
            Filters=[{'Key': 'InstanceIds', 'Values': [instance_id]}]
        )
        if response['InstanceInformationList']:
            print(f"EC2 instance {instance_id} is managed by SSM.")
            return True
        else:
            print(f"EC2 instance {instance_id} is NOT managed by SSM.")
            return False
    except Exception as e:
        print(f"Error checking instance SSM status: {e}")
        return False

# Run Ansible Playbook
def run_ansible_playbook():
    try:
        print(f"Running Ansible playbook: {playbook_file}")
        subprocess.run(['ansible-playbook', '-i', 'inventory', playbook_file], check=True)
        print("Ansible playbook applied successfully!")
    except subprocess.CalledProcessError as e:
        print(f"Error applying Ansible playbook: {e}")
        sys.exit(1)


if __name__ == "__main__":
    instance_ids = get_instance_ids_from_asg(asg_name)

    if not instance_ids:
        print(f"No EC2 instances found in ASG '{asg_name}'. Exiting.")
        sys.exit(1)

    for instance_id in instance_ids:
        if check_instance_managed(instance_id):
            # Run Ansible playbook
            run_ansible_playbook()
        else:
            print(f"Instance {instance_id} is not managed by SSM. Skipping.")