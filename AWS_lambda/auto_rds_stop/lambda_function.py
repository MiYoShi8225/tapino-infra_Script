import boto3
import traceback

region = 'ap-northeast-1'


def lambda_handler(event, context):
    try:
        rds = boto3.client('rds', region_name=region)
        instances = rds.describe_db_instances()
        for instance in instances['DBInstances']:
            instance_name = instance['DBInstanceIdentifier']
            instance_status = instance['DBInstanceStatus']
            instance_stop_jud = False

            # tagをつけていない場合も考慮して
            if 'TagList' in instance:
                instance_tags = instance['TagList']
            else:
                print('Tags is non.')
                continue

            for instance_tag in instance_tags:
                if instance_tag['Key'] == 'Env' and instance_tag['Value'] == 'dev' and instance_status != 'stopped':
                    instance_stop_jud = True

            if instance_stop_jud:
                rds.stop_db_instance(DBInstanceIdentifier=instance_name)
                print('auto stop instance: {}'.format(instance_name))
            else:
                print('not stop instance: {}'.format(instance_name))

        return

    except Exception as e:
        traceback.print_exc()
