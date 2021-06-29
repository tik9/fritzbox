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

# action = 'setenable'


def main():
    change_enable()
    # print(xml_)
    # fb('wlanconfig1', 'setenable')
    # fb('wlanconfig1', 'getinfo')
    # fb('deviceinfo', 'getinfo')
    # test()


def change_enable():

    str_ = ''
    action = 'setenable'
    xml_ = join(fb_folder, action + '.xml')

    newen = '<NewEnable>'
    close_newen = '</NewEnable>'
    pattern = newen+'([01])'+close_newen
    
    with open(xml_, 'r') as file_:
        # print(file_.read())
        for line in file_:
            if match := re.match(pattern, line):
                # str_ += '<NewEnable>' + str(enable) + '</NewEnable>\n'
                val = match.group(1)
                print('val before', val)
                val = 1-val
                print(pattern, val)
                # re.sub('('+newen+')[01]('+close_newen+')', '\1'+val+'\2', line)
                continue
            str_ += line

        # print(str_)
    # with open(xml_, 'w') as file_:
        # file_.write(str_)


def change_enable2():
    s = "Ex St"
    text = '<NewEnable>1</NewEnable>'
    pattern = '<NewEnable>(.*)</NewEnable>'
    if match := re.match(pattern, text, re.IGNORECASE):
        title = match.group(1)
    print(title)

    # if re.match('<NewEnable>.</NewEnable>', '<NewEnable>1</NewEnable>'):
    # replaced = re.sub('[01]', 'a', s)
    # print('Yes')
    # print(replaced )


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


if __name__ == '__main__':
    main()
