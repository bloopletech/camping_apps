#!/usr/bin/env rackup

#if (pid = fork)
#  Signal.trap('HUP', 'IGNORE')
#  Process.detach(pid)
#  exit
#end

STDIN.reopen "/dev/null"
STDOUT.reopen "/dev/null", "a"
STDERR.reopen "log/errors.log", "a"

require 'camping.ru'