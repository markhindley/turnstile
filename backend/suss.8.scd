suss(8) "Turnstile Backend" "Simple User Session Service Usage Guide"

# NAME

suss - Simple User Session Service; a simple turnstile backend.

# SYNOPSIS

Implements the _turnstiled(8)_ backend API:

	*suss* *run* _fifo_ _srvdir_ _confdir_++
*suss* *ready* _string_++
*suss* *stop* _runpid_

# DESCRIPTION

*suss* is a _turnstiled(8)_ backend for starting user session services
by executing scripts and binaries found in any _$USER_SESSION_PATH_
directories (e.g. _$HOME/.user_session.d:/etc/user_session.d_). These
are run when a user first logs in to a host, and then stopped when the
user's last login ends.

Longer running services should be run as asynchronous background
processes whilst retaining the current session ID. The service startup
scripts (or binaries) must return directly after carrying out fast
setup actions and/or spawning background services

Upon the user's final logout, *suss* ensures that all services with
the same session ID are terminated by means of the successive signals
TERM and KILL.

If several executables with the same filename are found in
_$USER_SESSION_PATH_, only the first is used. A user could employ this
to override a service installed system-wide.

## Restarting Services

The *suss* backend also handles signals HUP and TERM itself by
terminating all running services (of its session ID) before exiting.
_turnstiled(8)_ will then restart the *suss* service manager anew for
a new start of the user session services.

Note that service control startup filenames consist entirely of ASCII
uppercase and lowercase letters, digits, underscore, full-stop
(period), hyphen (minus) or plus. Filenames with other characters are
silently ignored, as are any sub directories (regardless of their
names) and all non-executable files.

One may therefore, for instance, disable a service by making it
non-executable. If then *suss* is sent a HUP signal, it will terminate
all currently running services, including the ones just disabled, and
subsequently restart only those that are still enabled.

# EXAMPLES

The following are examples of session service startup scripts for
running a long term service, "myservice".

## Simple Non-Repeating Session Action

This example illustrates a control script for a simple non-repeating
"myservice" service.

	#!/bin/sh++
myaction &++
true

Note that if the "myservice service is indeed simple and known to
terminate quickly in all circumstances, then it might not need a
service control script at all, but could be installed either directly
or with a symbolic link in the _$HOME/user_session.d/_ directory.

## Simple, Uncontrolled Repetition

This example illustrates a simple, uncontrolled repetition of a
"myservice", which merely re-runs the service repeatedly, should it
exit:

	#!/bin/sh++
while true ; do myservice ; done &++
true

## Daemon Based Repetition

This example illustrates using _daemon(1)_ for a more controlled
repetition of the "myservice" service, where the service is re-run
repeatedly under _daemon(1)_ control, should it exit:

	#!/bin/sh++
daemon -f -r -- myservice &++
true

## Propagating Environment Variables

If the user service script needs to set variables in the user's environment,
add this fragment to _$HOME/.profile_:

	\[ -r "$XDG_RUNTIME_DIR/profile" \] && . "$XDG_RUNTIME_DIR/profile

and append the export to _$XDG_RUNTIME_DIR/profile_ in the user service script:

	#!/bin/sh++
SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/openssh_agent++
ssh-agent -D -a $SSH_AUTH_SOCK &++
echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> $XDG_RUNTIME_DIR/profile

# CONFIGURATION

*suss* uses a configuration file named *suss.conf* in the
_turnstiled(8)_ backend configuration directory. This file is a
POSIX sh fragment that gets sourced into *suss* on demand.

Currently the only configuration is for _$USER_SESSION_PATH_ which
nominates the (colon separated) directories  for user session
service start programs.

# CONTRIBUTORS

Mark Hindley <mark@hindley.org.uk>++
Ralph Ronnquist <rrq@rrq.au>
