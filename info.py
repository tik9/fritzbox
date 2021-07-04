from pathlib import Path
from os import path
from os.path import join
import requests
import xmltodict
import re

headers = {'content-type': 'text/xml'}

home = Path.home()
fb_folder = path.dirname(__file__)


def main():
    seten = 'setenable'
    # change_enable(seten)
    xml = fb('wlanconfig1',seten )

    settings = {
        'wlanconfig1': 'newenable',
        'deviceinfo': 'newsoftwareversion'
    }
    sett = 'wlanconfig1'
    sett = 'deviceinfo'
    xml = fb(sett, 'getinfo')
    xml = parse_info(xml, settings[sett])
    print(xml)
    # test()


def fb(url, action):
    print('.. fb started ..')
    if url == 'deviceinfo':
        url_ = url
    else:
        url_ = 'wlanconfiguration'

    xml_ = join(fb_folder, action + '.xml')

    headers['soapaction'] = 'urn:dslforum-org:service:' + url_ + ':1#' + action

    with open(xml_, 'r') as f:
        xml = f.read()
    print('..', xml_, 'parsed..')
    response = requests.post('http://192.168.178.1:49000/upnp/control/' + url, data=xml, headers=headers)
    return response


def parse_info(response, key):
    print('..parse_info started..', key)

    # print(xmltodict.parse(response.content))
    xml = xmltodict.parse(response.content.lower(), dict_constructor=dict)
    env = xml['s:envelope']
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
