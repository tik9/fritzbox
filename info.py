from pathlib import Path
from os import path
from os.path import join
import requests
import xml.etree.ElementTree as ET
import xmltodict
import json

headers = {'content-type': 'text/xml'}

control = 'http://192.168.178.1:49000/upnp/control'
service = 'urn:dslforum-org:service'


home = Path.home()
fb_folder = path.dirname(__file__)

# action = 'setenable'


def main():
    change_enable(0)
    # print(xml_)
    # fb('wlanconfig1', 'setenable')
    fb('wlanconfig1', 'getinfo')
    # fb('deviceinfo', 'getinfo')
    test()

def fb(url, action):

    # url = "wlanconfig1"
    location = control + '/' + url
    if url == 'deviceinfo':
        url_ = url
    else:
        url_ = 'wlanconfiguration'
    uri = service + ':' + url_ + ':1#'

    # action = 'setenable'
    xml_ = join(fb_folder, action + '.xml')
    headers['soapaction'] = uri + action

    with open(xml_, 'r') as f:
        xml = f.read()

    response = requests.post(location, data=xml, headers=headers)
    if (url == 'wlanconfig1' and action == 'getinfo'):
        parseinfo(response)
        return
    print(response.content)

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
    #     print(elt.tag, elt.text)

    # print(tree,type(tree))
    # print(tree)
    # print(xmltodict.parse(response.content))
    # print(json.dumps(xmltodict.parse(response.content)))
    for elem in tree.iter():
         print(elem)

def change_enable(enable):

    str_ = ''
    action = 'setenable'
    xml_ = join(fb_folder, action + '.xml')
    with open(xml_, 'r') as file_:
        # print(file_.read())
        for line in file_:
            if 'NewEnable' in line:
                str_ += '<NewEnable>' + str(enable) + '</NewEnable>\n'
                continue
            str_ += line

        # print(str_)
    with open(xml_, 'w') as file_:
        file_.write(str_)


if __name__ == '__main__':
    main()
