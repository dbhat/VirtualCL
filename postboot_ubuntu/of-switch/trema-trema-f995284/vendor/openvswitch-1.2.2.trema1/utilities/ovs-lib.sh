# This is a shell function library sourced by some Open vSwitch scripts.
# It is not intended to be invoked on its own.

# Copyright (C) 2009, 2010, 2011 Nicira Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## ----------------- ##
## configure options ##
## ----------------- ##

# All of these should be substituted by the Makefile at build time.
logdir=${OVS_LOGDIR-'/opt/trema-trema-f995284/objects/openvswitch/var/log/openvswitch'}                 # /var/log/openvswitch
rundir=${OVS_RUNDIR-'/opt/trema-trema-f995284/tmp/sock'}                 # /var/run/openvswitch
sysconfdir=${OVS_SYSCONFDIR-'/opt/trema-trema-f995284/objects/openvswitch/etc'}     # /etc
etcdir=$sysconfdir/openvswitch                  # /etc/openvswitch
datadir=${OVS_PKGDATADIR-'/opt/trema-trema-f995284/objects/openvswitch/share/openvswitch'}        # /usr/share/openvswitch
bindir=${OVS_BINDIR-'/opt/trema-trema-f995284/objects/openvswitch/bin'}                 # /usr/bin
sbindir=${OVS_SBINDIR-'/opt/trema-trema-f995284/objects/openvswitch/sbin'}              # /usr/sbin

VERSION='1.2.2.trema1'
case 0 in
    [1-9]*) BUILDNR='+build0' ;;
    *) BUILDNR= ;;
esac

LC_ALL=C; export LC_ALL

## ------------- ##
## LSB functions ##
## ------------- ##

# Use the system's own implementations if it has any.
if test -e /etc/init.d/functions; then
    . /etc/init.d/functions
elif test -e /etc/rc.d/init.d/functions; then
    . /etc/rc.d/init.d/functions
elif test -e /lib/lsb/init-functions; then
    . /lib/lsb/init-functions
fi

# Implement missing functions (e.g. OpenSUSE lacks 'action').
if type log_success_msg >/dev/null 2>&1; then :; else
    log_success_msg () {
        printf '%s.\n' "$*"
    }
fi
if type log_failure_msg >/dev/null 2>&1; then :; else
    log_failure_msg () {
        printf '%s ... failed!\n' "$*"
    }
fi
if type log_warning_msg >/dev/null 2>&1; then :; else
    log_warning_msg () {
        printf '%s ... (warning).\n' "$*"
    }
fi
if type action >/dev/null 2>&1; then :; else
    action () {
       STRING=$1
       shift
       "$@"
       rc=$?
       if test $rc = 0; then
            log_success_msg "$STRING"
       else
            log_failure_msg "$STRING"
       fi
       return $rc
    }
fi

## ------- ##
## Daemons ##
## ------- ##

pid_exists () {
    # This is better than "kill -0" because it doesn't require permission to
    # send a signal (so daemon_status in particular works as non-root).
    test -d /proc/"$1"
}

start_daemon () {
    priority=$1
    shift
    daemon=$1

    # drop core files in a sensible place
    test -d "$DAEMON_CWD" || install -d -m 755 -o root -g root "$DAEMON_CWD"
    set "$@" --no-chdir
    cd "$DAEMON_CWD"

    # log file
    test -d "$logdir" || install -d -m 755 -o root -g root "$logdir"
    set "$@" --log-file="$logdir/$daemon.log"

    # pidfile and monitoring
    test -d "$rundir" || install -d -m 755 -o root -g root "$rundir"
    set "$@" --pidfile="$rundir/$daemon.pid"
    set "$@" --detach --monitor

    # priority
    if test X"$priority" != X; then
        set nice -n "$priority" "$@"
    fi

    action "Starting $daemon" "$@"
}

DAEMON_CWD=/
stop_daemon () {
    if test -e "$rundir/$1.pid"; then
        if pid=`cat "$rundir/$1.pid"`; then
            for action in TERM .1 .25 .65 1 1 1 1 KILL 1 1 1 1 FAIL; do
                case $action in
                    TERM)
                        action "Killing $1 ($pid)" kill $pid
                        ;;
                    KILL)
                        action "Killing $1 ($pid) with SIGKILL" kill -9 $pid
                        ;;
                    FAIL)
                        log_failure_msg "Killing $1 ($pid) failed"
                        return 1
                        ;;
                    *)
                        if pid_exists $pid >/dev/null 2>&1; then
                            sleep $action
                        else
                            return 0
                        fi
                        ;;
                esac
            done
        fi
    fi
    log_success_msg "$1 is not running"
}

daemon_status () {
    pidfile=$rundir/$1.pid
    if test -e "$pidfile"; then
        if pid=`cat "$pidfile"`; then
            if pid_exists "$pid"; then
                echo "$1 is running with pid $pid"
                return 0
            else
                echo "Pidfile for $1 ($pidfile) is stale"
            fi
        else
            echo "Pidfile for $1 ($pidfile) exists but cannot be read"
        fi
    else
        echo "$1 is not running"
    fi
    return 1
}

daemon_is_running () {
    pidfile=$rundir/$1.pid
    test -e "$pidfile" && pid=`cat "$pidfile"` && pid_exists "$pid"
} >/dev/null 2>&1
