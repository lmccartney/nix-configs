#! shell.nix
with (import <nixpkgs> {});
{ pkgs ? import <nixpkgs> {} }:
let
  python-with-packages = pkgs.python37.withPackages (p: with p; [
    virtualenv
  ]);

  node-pkgs = import (builtins.fetchGit {
    name = "node-js-10";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixpkgs-unstable";
    rev = "860b56be91fb874d48e23a950815969a7b832fbc";
  }) {};
  node-js = node-pkgs.nodejs-10_x;

  databaseReloadSript = ''
    psql -h localhost -d postgres -c "\set AUTOCOMMIT on\n drop database if exists uptime_dev; drop database if exists uptime_tsdb;"
    psql -h localhost -d postgres -f dev_backup.dmp > /dev/null 2>&1
    psql -h localhost -d postgres -f dev_tsdb_backup.dmp > /dev/null 2>&1
    /home/lennon/.virtualenvs/uptime/bin/python manage.py shell < update_password.py
  '';

in 
mkShell {
  buildInputs = [
    python-with-packages
    aws
    node-js
    postgresql_11
    chromium
    curl
    rabbitmq-server
    redis
    go
    docker
    glibc
  ];

  shellHook = ''
    if [ ! -d .tmp/postgres/database ]; then
      mkdir -p .tmp/postgres/
      initdb -D .tmp/postgres/database
    fi

    if [ ! -f .tmp/postgres/.S.PGSQL.5432.lock ]; then
      pg_ctl -D .tmp/postgres/database -l .tmp/postgres/logfile -o \"--unix-socket_directories='$PWD'/.tmp/postgres\" start
      trap "pg_ctl -D .tmp/postgres/database -l .tmp/postgres/logfile -o \"--unix-socket_directories='$PWD'/.tmp/postgres\" stop" EXIT
    fi

    pycharm-professional > /dev/null 2>&1 &
  '';
}

