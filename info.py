from pathlib import Path
from os import path
from os.path import join
import requests
import socket
# import xmltodict
import re
from fritzconnection import FritzConnection
import pprint

home = Path.home()
fb_folder = path.dirname(__file__)

documents = path.join(home, 'documents')
# local_path = path.join('c:' + sep, 'git', 'etc')
hostname = socket.gethostname()
if hostname == 't--pc':
    documents = path.join(home, 'Dokumente')

ip = 'http://192.168.178.1'
with open(path.join(documents, 'irule'), 'r') as file_:
    p = file_.read()
if hostname=='t--pc':
    p = p[:-1]

fc = FritzConnection(password=p)


def main():
    pp = pprint.PrettyPrinter(indent=2)
    keys = ['WANIPConnection', 'GetInfo']
    keys = ['DeviceInfo', 'GetInfo']
    keys = ['WLANConfiguration', 'GetInfo', 'NewEnable']
    result = div()
    result = fbc(keys)
    # pp.pprint(result)
    # result = change_enable()
    # result = fb('wlanconfig1', 'getinfo')
    print('res', result)


def fbc(keys):
    state = fc.call_action(keys[0], keys[1])
    return state[keys[2]] if 0 <= 2 < len(keys) else state


def div():
    enable = True
    enable = False
    result = fc.call_action('WLANConfiguration', 'SetEnable', NewEnable=enable)
    return result


def fb(service, action):
    print('..fb started..')

    # service = 'deviceinfo'
    # action = 'getinfo'

    servicenew = 'deviceinfo' if service == 'deviceinfo' else 'wlanconfiguration'

    xml_ = join(fb_folder, action + '.xml')

    headers = {'content-type': 'text/xml',
               'soapaction': 'urn:dslforum-org:service:' + servicenew + ':1#' + action
               }

    with open(xml_, 'r') as f:
        xml = f.read()

    response = requests.post(
        ip + ':49000/upnp/control/' + service, data=xml, headers=headers)

    # xml = xmltodict.parse(response.content.lower(), dict_constructor=dict)
    xml =1
    env = xml['s:envelope']
    body = env['s:body']
    if action == 'setenable':
        inforesp = body['u:setenableresponse']
        return inforesp

    settings = {
        'wlanconfig1': 'newenable',
        'deviceinfo': 'newsoftwareversion'
    }
    inforesp = body['u:getinforesponse']

    return inforesp[settings[service]]


def change_enable():
    print('..change_en started..')
    xml_ = join(fb_folder, 'setenable.xml')

    with open(xml_, 'r') as file_:
        newen = '<NewEnable>'

        str_ = ''
        for line in file_:
            if match := re.match(newen + '([01])', line):
                value = match.group(1)
                value = 1 - int(value)
                str_ += re.sub(f'({newen})[01]',
                               f'\g<1>{str(value)}', line)
                continue
            str_ += line

    with open(xml_, 'w') as file_:
        file_.write(str_)
    xml = fb('wlanconfig1', 'setenable')
    print('wlanconfig1', xml)


if __name__ == '__main__':
    main()
