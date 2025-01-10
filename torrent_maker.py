import os
from torf import Torrent, TorfError


def create_torrent(name):
    try:
        print('Torrent file is being created')
        t = Torrent(path=os.path.join(name),
                    trackers=['udp://tracker.openbittorrent.com:80/announce',
                              'udp://tracker.opentrackr.org:1337/announce'])
        
        t.generate(2048)
        t.write(os.path.join(name + '.torrent'))
    except TorfError as ex:
        print(f'[warn] {ex}\n')
        pass
    else:
        print('Torrent file created\n')
    print('All done')


create_torrent(input('folder name\n>>> '))
