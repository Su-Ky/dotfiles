#!/usr/bin/env python2
# FileName: $XDG_HOME_CONFIG/offlineimap/offlineimap.py
# vim:fenc=utf-8:nu:ai:si:et:ts=4:sw=4:ft=python:
from subprocess import check_output as check, CalledProcessError as e, Popen 
from subprocess import STDOUT
from shlex import split
from os import environ as env
from sys import stderr

def get_pass(s):
    ret = ""
    lst = { 'personal': 'personal', 
            'work': 'work' }
    my_env = env.copy()

    fileName = my_env["HOME"] + "/." + lst[str(s)]+".asc"

    cmd = ("gpg2", "--homedir", my_env["HOME"]+"/.gnupg",
            "-r", "example@gmail.com",
            "--pinentry-mode", "loopback", "-dq",
            fileName)

    try:
        ret = check(cmd).strip("\n")
    except e:
        stderr.write("ERROR: offlineimap.py: get_pass: "+str(e))
    return ret
