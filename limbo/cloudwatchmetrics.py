import boto3
import re

class CloudWatchMetrics(object):
    VALID = "[^:&][^&]*(&[^&]*=[^&]*)*"
    def __init__(self, config):
        cfg = config["cloudwatch"]
        if not re.match(VALID, cfg):
            e = ValueError("Bad CloudWatch configuration {0}.  Must match {1}."
                           .format(cfg, VALID))
            logger.error(str(e))
            raise e
        cfg = string.split(cfg, '&')
        self._namespace = cfg[0]
        self._dims = []
        for dim in cfg[1:]:
            nv = string.split(dim, '=')
            self._dims.append({ 'Name': nv[0], 'Value': nv[1] })
        self._client = boto3.client('cloudwatch')
        pass

    def events(self, count):
        self._client.put_metrics_data(
            Namespace = self._namespace,
            MetricData = [
                {
                    'MetricName': 'EventCount',
                    'Dimensions': self._dims,
                    'Value': 1,
                    'Unit': 'Count'
                }
            ]
        )
