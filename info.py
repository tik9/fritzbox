from pathlib import Path
from os import path
from os.path import join
import requests
import xmltodict
import re

headers = {'content-type': 'text/xml'}

control = 'http://192.168.178.1:49000/upnp/control'
service = 'urn:dslforum-org:service'

home = Path.home()
fb_folder = path.dirname(__file__)


def main():
    change_enable()
    # xml_ = fb('wlanconfig1', 'setenable')
    # xml_ = fb('deviceinfo', 'getinfo')
    xml_ = fb('wlanconfig1', 'getinfo')
    print(xml_)
    # test()


def fb(url, action):
    print('.. fb started ..')
    location = control + '/' + url
    if url == 'deviceinfo':
        url_ = url
    else:
        url_ = 'wlanconfiguration'
    uri = service + ':' + url_ + ':1#'

    xml_ = join(fb_folder, action + '.xml')

    headers['soapaction'] = uri + action

    with open(xml_, 'r') as f:
        xml = f.read()
    print('..', xml_, 'parsed..')
    response = requests.post(location, data=xml, headers=headers)
    if (url == 'wlanconfig1' and action == 'getinfo'):
        return parseinfo(response, 'newenable')
    elif (url == 'deviceinfo' and action == 'getinfo'):
        return parseinfo(response, 'newsoftwareversion')


def parseinfo(response, key):
    print('..parse_info started..', key)

    # print(xmltodict.parse(response.content))
    xmld = xmltodict.parse(response.content.lower(), dict_constructor=dict)
    env = xmld['s:envelope']
    body = env['s:body']
    inforesp = body['u:getinforesponse']
    # result = inforesp['newenable']
    # result = inforesp
    result = inforesp[key]
    return result


def change_enable():
    print('..change_en started..')
    xml_ = join(fb_folder, 'setenable.xml')

    with open(xml_, 'r') as file_:
        newen = '<NewEnable>'
        close_newen = '</NewEnable>'

        str_ = ''
        for line in file_:
            if match := re.match(newen+'([01])', line):
                value = match.group(1)
                value = 1-int(value)
                str_ += re.sub(f'({newen})[01]',
                               f'\g<1>{str(value)}', line)
                continue
            str_ += line

        # print(str_)
    with open(xml_, 'w') as file_:
        file_.write(str_)
    # return fb('wlanconfig1', 'getinfo')

if __name__ == '__main__':
    main()
