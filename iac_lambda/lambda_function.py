import boto3
import os
import json

def lambda_handler(event, context):
    """
    ppeks Health Check Lambda
    - Lê credenciais do SSM Parameter Store
    - Retorna status dos recursos do projeto
    - Exposição via Function URL (aplicação web)
    """
    ssm = boto3.client('ssm', region_name=os.environ.get('AWS_REGION', 'us-east-1'))
    results = {}

    # Lê username do banco (SSM já usado no projeto)
    try:
        param = ssm.get_parameter(
            Name=os.environ['SSM_PATH_DB_USERNAME'],
            WithDecryption=False
        )
        results['db_user_found'] = True
        results['db_user']       = param['Parameter']['Value']
    except Exception as e:
        results['db_user_found'] = False
        results['db_user_error'] = str(e)

    # Lê endpoint do RDS
    results['db_host']    = os.environ.get('DB_HOST', 'not-configured')
    results['project']    = os.environ.get('PROJECT_NAME', 'ppeks')
    results['status']     = 'ok'
    results['message']    = 'ppeks Lambda health check executado com sucesso'

    print(json.dumps(results))

    # Retorno compatível com Function URL (HTTP response)
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(results, indent=2)
    }
