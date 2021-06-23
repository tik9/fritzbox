from pathlib import Path
from os import path
from os.path import join
import requests

home = Path.home()
fb_folder = path.dirname(__file__)

action = 'getinfo'
# action='setenable'

xml = join(fb_folder, action+'.xml')
# print(xml)
enable = 0

url = 'http://192.168.178.1:49000/upnp/control/deviceinfo'
headers = {'content-type': 'text/xml',
           'soapaction': 'urn:dslforum-org:service:DeviceInfo:1#' + action}
body = """<?xml?>
         </SOAP-ENV:Envelope>"""

response = requests.post(url, data=xml, headers=headers)
print(response.content)


def main():
    change_enable()


def info():

    print('')

# $result=Invoke-WebRequest -Headers @{'soapaction' = 'urn:dslforum-org:service:DeviceInfo:1#getinfo' } -Method post `
    # -InFile $fb/$action.xml -Uri http://192.168.178.1:49000/upnp/control/deviceinfo -ContentType text/xml


def change_enable():
    str_ = ''
    with open(xml, 'r') as file_:
        # print(file_.read())
        for line in file_:
            if 'NewEnable' in line:
                str_ += '<NewEnable>' + str(enable) + '</NewEnable>\n'
                continue
            str_ += line

        print(str_)
    # with open(xml, 'w') as file_:file_.write(str_)


if __name__ == '__main__':
    main()
