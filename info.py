from pathlib import Path
from os import path
from os.path import join
import requests
import xmltodict
import re

home = Path.home()
fb_folder = path.dirname(__file__)


def main():
    change_enable()

    url = 'deviceinfo'
    url = 'wlanconfig1'

    # xml = fb(url,'setenable' )
    xml = fb(url, 'getinfo')
    print(xml)


def fb(url, action):
    print('.. fb started ..')

    settings = {
        'wlanconfig1': 'newenable',
        'deviceinfo': 'newsoftwareversion'
    }
    url_ = 'wlanconfiguration'
    if url == 'deviceinfo':
        url_ = url

    xml_ = join(fb_folder, action + '.xml')

    headers = {'content-type': 'text/xml',
               'soapaction': 'urn:dslforum-org:service:' + url_ + ':1#' + action
               }

    with open(xml_, 'r') as f:
        xml = f.read()

    response = requests.post(
        'http://192.168.178.1:49000/upnp/control/' + url, data=xml, headers=headers)
    # return response
    xml = xmltodict.parse(response.content.lower(), dict_constructor=dict)
    env = xml['s:envelope']
    body = env['s:body']
    inforesp = body['u:getinforesponse']
    # result = inforesp
    result = inforesp[settings[url]]
    return result


def change_enable():
    print('..change_en started..')
    xml_ = join(fb_folder, 'setenable.xml')

    with open(xml_, 'r') as file_:
        newen = '<NewEnable>'

        str_ = ''
        for line in file_:
            if match := re.match(newen+'([01])', line):
                value = match.group(1)
                print(value)
                value = 1-int(value)
                str_ += re.sub(f'({newen})[01]',
                               f'\g<1>{str(value)}', line)
                continue
            str_ += line

    with open(xml_, 'w') as file_:
        file_.write(str_)
    # return fb('wlanconfig1', 'getinfo')


if __name__ == '__main__':
    main()
