from itertools import count

from fritzconnection import FritzConnection
from fritzconnection.core.exceptions import FritzServiceError


def main():
    numbers = [1, 2, 3]
    # (print(i) for i in numbers)
    # print(result)
    for service, status in get_compact_wlan_status():
        print(f'{service}: {status}')

def get_compact_wlan_status():
    keys = ('NewSSID', 'NewChannel', 'NewStatus')
    return [
        [service, {key[3:]: status[key] for key in keys}]
        for service, status in get_wlan_status()
    ]

def get_wlan_status():
    fc = FritzConnection()
    status = []
    action = 'GetInfo'
    for n in count(1):
        service = f'WLANConfiguration{n}'
        try:
            result = fc.call_action(service, action)
        except FritzServiceError:
            break
        # print(service,result)
        status.append((service, result))
    return status


if __name__ == '__main__':
    main()
