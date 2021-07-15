from itertools import count

from pathlib import Path
from os import path
from os.path import join
import requests
import xmltodict
import re
from fritzconnection import FritzConnection
import pprint

home = Path.home()
fb_folder = path.dirname(__file__)

ip = 'http://192.168.178.1'
fc = FritzConnection(address=ip)


def main():
    pp = pprint.PrettyPrinter(indent=2)
    keys = ['WANIPConnection', 'GetExternalIPAddress', ]
    keys = ['WANIPConnection', 'GetInfo']
    keys = ['WLANConfiguration', 'GetInfo', 'NewEnable']
    keys = ['WLANConfiguration', 'GetInfo', ]
    keys = ['DeviceInfo', 'GetInfo']
    key = 'NewStatus'
    result = fbc(keys)
    # result = div()
    # pp.pprint(result)
    # result = div()
    print(result)

    # for n in count(1):
    # print(n)


def fbc(keys, outkey=''):

    state = fc.call_action(keys[0], keys[1])
    return state[keys[2]] if 0 <= 2 < len(keys) else state


def div():
    enable = True
    enable = False
    # fc.call_action('WLANConfiguration', 'SetEnable', NewEnable=enable)
    # return result


def fb(service, action):

    # service = 'wlanconfig1'
    # service = 'deviceinfo'

    # xml = fb(service, 'getinfo')
    # print(service, xml)    print('.. fb started ..', service, action)
    responsekey = 'setenableresponse'

    servicenew = 'deviceinfo' if service == 'deviceinfo' else 'wlanconfiguration'
    if action == 'getinfo':
        responsekey = 'getinforesponse'
        settings = {
            'wlanconfig1': 'newenable',
            'deviceinfo': 'newsoftwareversion'
        }
        info = settings[service]

    xml_ = join(fb_folder, action + '.xml')

    headers = {'content-type': 'text/xml',
               'soapaction': 'urn:dslforum-org:service:' + servicenew + ':1#' + action
               }

    with open(xml_, 'r') as f:
        xml = f.read()

    response = requests.post(
        ip + ':49000/upnp/control/' + service, data=xml, headers=headers)

    xml = xmltodict.parse(response.content.lower(), dict_constructor=dict)
    env = xml['s:envelope']
    body = env['s:body']
    inforesp = body['u:' + responsekey]
    if action == 'setenable':
        return inforesp
    return inforesp[info]


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
    print('change wlanconfig1', xml)


if __name__ == '__main__':
    main()
