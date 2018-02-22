import uuid
import os
from mbed_cloud.certificates import CertificatesAPI
import json

sdk_config={'host':os.environ.get('API_GW'), 'api_key':os.environ.get('API_KEY')}
print (sdk_config)
certificatesApi = CertificatesAPI(sdk_config)

print("Creating new developer certificate...")
certificate_name=uuid.uuid1().hex
certificate = certificatesApi.add_developer_certificate(certificate_name)
print("Successfully created developer certificate with id: %r" % certificate.id)

with open('device_certificate.c', 'w') as the_file:
    the_file.write(certificate.header_file)
