
VERSION = 0.9991B

#CC ?= gcc
CPPFLAGS += -DVERSION_STR=\"$(VERSION)\"
CFLAGS += -Wall -g

LD = $(CC)
LDFLAGS ?= -g
LDLIBS ?=

all: hypercom
OBJS =

## This is the maximum size (in bytes) the output (e.g. copy-paste)
## queue is allowed to grow to. Zero means unlimitted.
TTY_Q_SZ = 0
CPPFLAGS += -DTTY_Q_SZ=$(TTY_Q_SZ)

## Comment this out to disable high-baudrate support
CPPFLAGS += -DHIGH_BAUD

## Normally you should NOT enable both: UUCP-style and flock(2)
## locking.

## Comment this out to disable locking with flock
CPPFLAGS += -DUSE_FLOCK

## Comment these out to disable UUCP-style lockdirs
#UUCP_LOCK_DIR=/var/lock
#CPPFLAGS += -DUUCP_LOCK_DIR=\"$(UUCP_LOCK_DIR)\"

## Comment these out to disable "linenoise"-library support
HISTFILE = .hypercom_history
CPPFLAGS += -DHISTFILE=\"$(HISTFILE)\" \
	    -DLINENOISE
OBJS += linenoise-1.0/linenoise.o
linenoise-1.0/linenoise.o : linenoise-1.0/linenoise.c linenoise-1.0/linenoise.h

## Comment this in to enable (force) custom baudrate support
## even on systems not enabled by default.
#CPPFLAGS += -DUSE_CUSTOM_BAUD

## Comment this in to disable custom baudrate support
## on ALL systems (even on these enabled by default).
#CPPFLAGS += -DNO_CUSTOM_BAUD

## Comment this IN to remove help strings (saves ~ 4-6 Kb).
#CPPFLAGS += -DNO_HELP


OBJS += hypercom.o term.o fdio.o split.o custbaud.o termios2.o custbaud_bsd.o
hypercom : $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

hypercom.o : hypercom.c term.h fdio.h split.h custbaud.h colors.h
term.o : term.c term.h termios2.h custbaud_bsd.h custbaud.h
split.o : split.c split.h
fdio.o : fdio.c fdio.h
termios2.o : termios2.c termios2.h termbits2.h custbaud.h
custbaud_bsd.o : custbaud_bsd.c custbaud_bsd.h custbaud.h
custbaud.o : custbaud.c custbaud.h
.c.o :
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $@ -c $<


doc : hypercom.1.html hypercom.1 hypercom.1.pdf

hypercom.1 : hypercom.1.md
	sed 's/\*\*\[/\*\*/g;s/\]\*\*/\*\*/g' $? \
	| pandoc -s -t man \
	    -Vfooter="Picocom $(VERSION)" -Vdate="`date -I`" \
	    -Vadjusting='l' \
	    -Vhyphenate='' \
	    -o $@

hypercom.1.html : hypercom.1.md
	pandoc -s -t html \
	    --template ~/.pandoc/tmpl/manpage.html \
	    -c ~/.pandoc/css/normalize-noforms.css \
	    -c ~/.pandoc/css/manpage.css \
	    --self-contained \
	    -Vversion="v$(VERSION)" -Vdate="`date -I`" \
	    -o $@ $?

hypercom.1.pdf : hypercom.1
	groff -man -Tpdf $? > $@


clean:
	rm -f hypercom.o term.o fdio.o split.o
	rm -f linenoise-1.0/linenoise.o
	rm -f custbaud.o termios2.o custbaud_bsd.o
	rm -f *~
	rm -f \#*\#
	rm -f hypercom
	rm -f hypercom.1
	rm -f hypercom.1.html
	rm -f hypercom.1.pdf
	rm -f CHANGES

