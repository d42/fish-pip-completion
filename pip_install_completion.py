import os
import sys
import time
import sqlite3
from itertools import cycle
from collections import defaultdict
import six.moves.xmlrpc_client as xmlrpclib
import logging

from pip.commands import SearchCommand


logger = logging.Logger('pip', level=logging.NOTSET)

PIP_SEARCH_DB_FILENAME = '{pip_dir}/pip_search.db'
INDEX_CHECK_TIMEOUT = 10 * 60

SCHEMA = """
    CREATE TABLE indexes (
        id INTEGER PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        url TEXT NOT NULL UNIQUE
    );

    CREATE TABLE packages (
        index_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (index_id) REFERENCES indexes(id),
        PRIMARY KEY (index_id, name)
    );
"""


class VeryORM:
    def __init__(self, db_path, pip_index):
        logger.debug("new db {0}, {1}".format(db_path, pip_index))
        self.db_path = db_path
        self.init_db()
        self.index = pip_index
        if pip_index not in self.indexes:
            self.create_index(pip_index)

        self.index_id = self.get_index_id(pip_index)
        logger.debug("index id: {}".format(self.index_id))

    def init_db(self):
        self.conn = sqlite3.connect(self.db_path)
        self.conn.row_factory = sqlite3.Row
        try:
            self.conn.executescript(SCHEMA)
            created = True
        except sqlite3.OperationalError as exc:
            if 'table indexes already exists' in exc.args:
                created = False
            else:
                raise
        return created

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

    def add_package(self, package):
        if self.has_package(package):
            sys.stderr.write("%s is already there\n" % package)
            return

        id = self.index_id
        q = 'INSERT INTO packages (index_id, name) VALUES(?, ?)'
        self.conn.execute(q, [id, package])

    def add_packages(self, package_names):
        q = 'INSERT OR IGNORE INTO packages (index_id, name) VALUES(?, ?)'
        id = self.index_id
        self.conn.executemany(q, zip(cycle([id]), package_names))

    def rem_package(self, package):
        if not self.has_package(package):
            sys.stderr.write("%s not found ,_, \n" % package)
            return
        id = self.index_id
        q = 'DELETE FROM packages WHERE index_id=? AND name=?'
        self.conn.execute(q, [id, package])

    def has_package(self, package):
        id = self.index_id
        q = 'SELECT name FROM packages WHERE index_id=? AND name=?'
        result = self.conn.execute(q, [id, package]).fetchone()
        return bool(result)

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

    def get_index_urls(self):
        q = 'SELECT url FROM indexes'
        result = self.conn.execute(q).fetchall()
        return [idx['url'] for idx in result]

    @property
    def indexes(self):
        return self.get_index_urls()


class SearchCache:

    def __init__(self, db_path, index=None):
        defaults = SearchCommand().parse_args([])[0]
        self.index = index or defaults.index
        self.db_path = db_path.format(pip_dir=defaults.cache_dir)

        self.client = xmlrpclib.ServerProxy(self.index)
        self.db = VeryORM(self.db_path, self.index)

    def search(self, name):
        logger.info("searching for {}".format(name))
        if self.database_stale:
            self.update()
        return self.db.get_packages(name)

    @property
    def database_stale(self):
        last_update_ts = self.db.get_timestamp()
        now = int(time.time())
        return last_update_ts + INDEX_CHECK_TIMEOUT < now

    def get_changes_since(self, timestamp):
        changes_dict = defaultdict(set)
        changes = self.client.changelog(timestamp)
        create_remove = [(name, action) for (name, _, _, action) in changes
                         if action in ('create', 'remove')]
        for name, action in create_remove:
            changes_dict[action].add(name)
        return changes_dict

    def update(self):
        logger.info("updating!")
        last_ts = self.db.get_timestamp()
        if last_ts == 0:  # not initialized
            self._fetch_all()
        else:
            self._fetch_since(last_ts)

        self.db.set_timestamp(time.time())

    def _fetch_since(self, ts):
        changes = self.get_changes_since(ts)
        self.db.add_packages(changes.get('create', []))

    def _fetch_all(self):
        logger.info("not initialized yet")
        packages = self.client.list_packages()
        self.db.set_packages(packages)


def main():
    cache = SearchCache(PIP_SEARCH_DB_FILENAME)
    query = sys.argv[1] if len(sys.argv) > 1 else ''
    print('\n'.join(cache.search(query)))


if __name__ == "__main__":
    main()
