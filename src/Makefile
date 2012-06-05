CC = gcc
CFLAGS = -g -Wall -std=c99 -D_POSIX_C_SOURCE=2
LFLAGS =

.SUFFIXES: .o .c

.c.o:
	$(CC) $(CFLAGS) -c $*.c -o $*.o

all: greplog

greplog: greplog.o
	$(CC) $(CFLAGS) -o $@ $^ $(LFLAGS)

clean:
	rm -f *.o *~

# deps:
