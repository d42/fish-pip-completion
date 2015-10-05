import os
import sys
import time
import sqlite3
from itertools import cycle

from pip.commands import SearchCommand

try:
    import xmlrpclib
except ImportError:
    import xmlrpc.client as xmlrpclib

PIP_SEARCH_DB_FILENAME = 'pip_search.db'
INDEX_CHECK_TIMEOUT = 10 * 60

SCHEMA = """
    CREATE TABLE IF NOT EXISTS indexes (
        id INTEGER PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        url TEXT NOT NULL UNIQUE
    );

    CREATE TABLE IF NOT EXISTS packages (
        index_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (index_id) REFERENCES indexes(id)
    );
"""


class VeryORM:
    def __init__(self, db_path, pip_index):
        self.db_path = db_path
        self.init_db()
        self.index = pip_index
        if pip_index not in self.indexes: self.create_index(pip_index) # noqa
        self.index_id = self.get_index_id(pip_index)

    def init_db(self):
        self.conn = sqlite3.connect(self.db_path)
        self.conn.row_factory = sqlite3.Row
        self.conn.executescript(SCHEMA)

    def create_index(self, index):
        q = "INSERT INTO indexes(timestamp, url) VALUES(?, ?)"
        with self.conn as con:
            return con.execute(q, [0, index]).lastrowid

    def set_packages(self, packages):

        ts = int(time.time())
        id = self.index_id
        with self.conn as con:  # very efficient :_D
            con.execute("DELETE FROM packages where index_id=?", [id])
            con.execute("VACUUM")

            rows = zip(cycle([id]), packages)
            self.set_timestamp(ts)

            q = "INSERT INTO packages (index_id, name) VALUES(?, ?)"
            con.executemany(q, rows)

    def set_timestamp(self, ts):
        q = " UPDATE indexes SET timestamp=? WHERE id=?"
        with self.conn as con:
            con.execute(q, (int(ts), self.index_id))

    def get_packages(self, query):
        q = "SELECT name FROM packages WHERE index_id=? AND name LIKE ?"
        result = self.conn.execute(q, [self.index_id, query + '%']).fetchall()
        return (pkg['name'] for pkg in result)

    def get_timestamp(self):
        q = "SELECT timestamp FROM indexes WHERE id=?"
        return self.conn.execute(q, (self.index_id,)).fetchone()['timestamp']

    def get_index_id(self, index):
        q = "SELECT id FROM indexes where url=?"
        result = self.conn.execute(q, [index]).fetchone()
        return result['id'] if result else None

    @property
    def indexes(self):
        def contains(_, index): return self.get_index_id(index) is not None # noqa
        return type("", (), {'__contains__': contains})()


class SearchCache:

    def __init__(self, index, db_path):
        self.client = xmlrpclib.ServerProxy(index)
        self.db = VeryORM(db_path, index)

    def search(self, name):
        last_update_ts = self.db.get_timestamp()
        now = int(time.time())
        timeout_gone = last_update_ts + INDEX_CHECK_TIMEOUT < now
        if timeout_gone:
            self.update()
        return self.db.get_packages(name)

    def get_changes_since(self, timestamp):
        changes = self.client.changelog(timestamp)
        return [(name, action) for (name, _, _, action) in changes
                if action in ('create', 'remove')]

    def update(self):
        last_ts = self.db.get_timestamp()
        if last_ts != 0 and not self.get_changes_since(last_ts):
            self.db.set_timestamp(time.time())
            return

        packages = self.client.list_packages()
        self.db.set_packages(packages)


def cached_search(query):
    sc = SearchCommand()
    options = sc.cmd_opts.defaults
    index = options['index']
    db_path = os.path.join(options['cache_dir'], PIP_SEARCH_DB_FILENAME)
    cache = SearchCache(index, db_path)
    return cache.search(query)


def main():
    query = sys.argv[1] if len(sys.argv) > 1 else ''
    pkgnames = cached_search(query)
    print('\n'.join(pkgnames))


if __name__ == "__main__":
    main()
