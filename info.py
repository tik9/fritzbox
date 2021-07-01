from pathlib import Path
from os import path
from os.path import join
from typing import Pattern
import requests
import xml.etree.ElementTree as ET
import xmltodict
import json
import re

headers = {'content-type': 'text/xml'}

control = 'http://192.168.178.1:49000/upnp/control'
service = 'urn:dslforum-org:service'

home = Path.home()
fb_folder = path.dirname(__file__)


def main():
    change_enable()
    # fb('wlanconfig1', 'setenable')
    # xml_ = fb('wlanconfig1', 'getinfo')
    # print(xml)
    # fb('deviceinfo', 'getinfo')
    # test()


def change_enable():

    xml_ = join(fb_folder, 'setenable.xml')

    with open(xml_, 'r') as file_:
        newen = '<NewEnable>'
        close_newen = '</NewEnable>'

        pattern = newen+'([01])'+close_newen
        str_ = ''
        for line in file_:
            print(line)
            if match := re.match(pattern, line):
                val = match.group(1)
                val = 1-int(val)
                pattern = '(' + newen+')[01]('+close_newen+')'
                str_ += re.sub(pattern,
                                '\g<1>'+str(val)+'\g<2>', line)
                continue
            str_ += line

        # print(str_)
    with open(xml_, 'w') as file_:
        file_.write(str_)


def fb(url, action):

    # url = "wlanconfig1"
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
    # print(location,xml_,headers)
    response = requests.post(location, data=xml, headers=headers)
    # if (url == 'wlanconfig1' and action == 'getinfo'):
    #     parseinfo(response)
    #     return
    return response.content


def test():
    print(json.dumps(xmltodict.parse("""
  <mydocument has="an attribute">
    <and>
      <many>elements</many>
      <many>more elements</many>
    </and>
    <plus a="complex">
      element as well
    </plus>
  </mydocument>
"""), indent=4))


def parseinfo(response):
    # for line in parse:
    #     print(line)
    # print(parse.content)
    tree = ET.fromstring(response.content)
    # for elt in e.iter():
    #     print(elt.tag, elt.helper_xml)

    # print(tree,type(tree))
    # print(tree)
    # print(xmltodict.parse(response.content))
    # print(json.dumps(xmltodict.parse(response.content)))
    for elem in tree.iter():
        print(elem)


if __name__ == '__main__':
    main()
