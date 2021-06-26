import boto3
import traceback

region = 'ap-northeast-1'


def lambda_handler(event, context):
    try:
        instance_ids = []
        ec2 = boto3.client('ec2', region_name=region)
        instances = ec2.describe_instances()

        for instance in instances['Reservations']:
            instance = instance['Instances'][0]
            instance_id = instance['InstanceId']
            instance_status = instance['State']['Name']
            instance_stop_jud = False

            # tagをつけていない場合も考慮して
            if 'Tags' in instance:
                instance_tags = instance['Tags']
            else:
                print('Tags is non.')
                continue

            print('id:{} \n tags:{} \n status:{}'.format(
                instance_id, instance_tags, instance_status))

            for instance_tag in instance_tags:
                if instance_tag['Key'] == 'Env' and instance_tag['Value'] == 'dev' and instance_status != 'stopped':
                    instance_stop_jud = True

            if instance_stop_jud:
                instance_ids.append(instance_id)
                print('auto stop instance: {}'.format(instance_id))
            else:
                print('not stop instance: {}'.format(instance_id))

        # instance_idsに値があればstop処理を実行する。if文
        if instance_ids:
            ec2.stop_instances(InstanceIds=instance_ids)

        return

    except Exception as e:
        traceback.print_exc()
