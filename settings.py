import sys
from pathlib import Path
from os import path
import socket
from fritzconnection import FritzConnection

hostname = socket.gethostname()

sysex=sys.executable

home = Path.home()
script_folder = path.dirname(__file__)

boxuser='fritz3220'

ip = 'http://192.168.178.1'

with open(path.join(script_folder, 'env'), 'r') as file_:
    boxpw = file_.read()
if hostname=='t--pc':
    boxpw = boxpw[:-1]

fc = FritzConnection(password=boxpw,user=boxuser)
