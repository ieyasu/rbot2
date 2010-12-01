/* Original code by Tony Arcieri, ported from his C Bot. */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <string.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static const char *HELPTEXT = "usage: !version <program>";

static char *Dest;

static void reply(const char *format, ...)
{
	va_list ap;

	printf("PRIVMSG %s :", Dest);
	va_start(ap, format);
	vprintf(format, ap);
	va_end(ap);
	puts("");
}

typedef struct _Buffer {
	uint8_t *bptr, *dptr;
	size_t bsize, dsize;
} *Buffer;

#define AGBUF_SIZE	512

typedef struct _SB {
	int fd, nlc;
	char *hostname;
	int port;
	Buffer b;

	struct timeval *tv;
} *SB;


/* Buffer */

static void buffer_flush(Buffer b);

static Buffer buffer_create()
{
	Buffer b;

	b = malloc(sizeof(struct _Buffer));
	b->bptr = b->dptr = NULL;
	b->bsize = b->dsize = 0;

	return b;
}

static void buffer_destroy(Buffer b)
{
	buffer_flush(b);
	free(b);
}

static ssize_t buffer_prepend(Buffer b, void *buffer, size_t nbytes)
{
	uint8_t *t;

	t = (uint8_t *)malloc(nbytes + b->dsize);
	memcpy(t, buffer, nbytes);
	memcpy(t + nbytes, b->dptr, b->dsize);
	free(b->bptr);

	b->bptr = b->dptr = t;
	b->dsize += nbytes;
	b->bsize = b->dsize;

	return nbytes;
}

static ssize_t buffer_get(Buffer b, void *buffer, size_t nbytes)
{
    int ret;
        
    if(b->dsize == 0)
        return 0;

    if(nbytes >= b->dsize) {
        memcpy(buffer, b->dptr, b->dsize);
		ret = b->dsize;
        free(b->bptr);
        b->bptr = b->dptr = NULL;
        b->bsize = b->dsize = 0;

        return ret;
    }

    memcpy(buffer, b->dptr, nbytes);
    b->dptr += nbytes;
    b->dsize -= nbytes;

    return nbytes;
}

static size_t buffer_size(Buffer b)
{
	return b->dsize;
}

static void buffer_flush(Buffer b)
{
	if(b->bptr != NULL) {
		free(b->bptr);
		b->bptr = NULL;
	}

	b->dptr = NULL;
	b->bsize = b->dsize = 0;
}


/* Socket Buffer */

static int resolve(uint32_t *addr, const char *name);
static void sb_destroy(SB s);
static int sb_connect(SB s);

static SB sb_create(char *hostname, int port)
{
	SB ret = (SB)malloc(sizeof(struct _SB));

	ret->b = buffer_create();
	ret->fd = -1;
	ret->nlc = 0;

	ret->hostname = strdup(hostname);
	ret->port = port;

	ret->tv = NULL;

	if(sb_connect(ret) < 0) {
		sb_destroy(ret);
		return NULL;
	}

	return ret;
}

static void sb_destroy(SB s)
{
	buffer_destroy(s->b);
	free(s->hostname);
	close(s->fd);

	if(s->tv != NULL)
		free(s->tv);

	free(s);
}

static int sb_connect(SB s)
{
	struct sockaddr_in sin;

	if(s->fd != 1)
		close(s->fd);

	sin.sin_family = AF_INET;
	sin.sin_port = htons(s->port);

	if((int)(sin.sin_addr.s_addr = inet_addr(s->hostname)) == -1) {
		if(resolve(&sin.sin_addr.s_addr, s->hostname) < 0) {
			perror("gethostbyname");

			return -1;
		}
	}

	if((s->fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		perror("socket");

		return -1;
	}

	if(connect(s->fd, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
		perror("connect");

		return -1;
	}

	return 0;
}

static int fnl(char *buf, int len)
{
	int r = 0;

	while(len--) if(*buf++ == '\n')
		r++;

	return r;
}

static ssize_t sb_read_raw(SB s, void *buf, size_t nbytes)
{
	ssize_t r, t;
	fd_set fds;
	uint8_t *bptr = buf;

	if((t = buffer_size(s->b)) > 0) {
		if(t >= (ssize_t)nbytes) {
			r = buffer_get(s->b, bptr, nbytes);
			s->nlc -= fnl((char *)bptr, nbytes);

			return r;
		}

		buffer_get(s->b, bptr, t);
		s->nlc -= fnl((char *)bptr, t);

		bptr += t;
		nbytes -= t;

		return t;
	}

	
	if(s->tv != NULL) {
		FD_ZERO(&fds);
		FD_SET(s->fd, &fds);

		if(!select(s->fd + 1, &fds, NULL, NULL, s->tv)) {
			if(t > 0)
				return t;

			return -1;
		}
	}

	if((r = read(s->fd, bptr, nbytes)) >= 0) {
		return r + t;
	}

	return -1;
}

static ssize_t sb_read_line(SB s, char *buf, size_t nbytes)
{
	int i;
	ssize_t r, t = 0;

	while(nbytes > 0) {
		if((r = sb_read_raw(s, buf, nbytes)) < 0)
			return -1;

		if(r == 0)
			return 0;

		for(i = 0; i < r; i++) {
			if(buf[i] == '\n') { 
				if(r - i > 1) {
					s->nlc += fnl(buf + i + 1, r - i - 1);
					buffer_prepend(s->b, buf + i + 1, r - i - 1);
					r = i + 1;
				}


				buf[i + 1] = '\0';

				return t + r;
			}
		}

		t += r;
		buf += r;
		nbytes -= r;
	}

	return t;
}

static ssize_t sb_write(SB s, void *buf, size_t nbytes)
{
	return write(s->fd, buf, nbytes);
}

static ssize_t sb_write_line(SB s, char *buf)
{
	return sb_write(s, buf, strlen(buf));
}


/* PUBLIC INTERFACE */

static void *sconnect(char *hostname, int port)
{
	return (void *)sb_create(hostname, port);
}

static char *sread(void *socket)
{
	char buf[1024];

	if(sb_read_line((SB)socket, buf, 1024) < 1)
		return NULL;

	return strdup(buf);
}

static int swrite(void *socket, char *str)
{
	if(sb_write_line((SB)socket, str) > 0)
		return 0;

	return -1;
}

static int resolve(uint32_t *addr, const char *name)
{
    struct hostent *h;

    if((h = gethostbyname(name)) == NULL)
        return -1;

    memcpy(addr, h->h_addr, h->h_length);
	endhostent();

    return 0;
}

static void *version_connect(char *program, char *extra)
{
	void *ret;
	char *buf;

	if((ret = sconnect("freshmeat.net", 80)) == NULL)
		return NULL;

	asprintf(&buf, "GET /projects/%s/%s HTTP/1.0\r\n", program, extra);
	swrite(ret, buf);
	swrite(ret, "Host: freshmeat.net:80\r\n\r\n");
	free(buf);

	return ret;
}

static void *version_http_connect(char *program)
{
	void *ret;
	char *str, *t;

	if((ret = version_connect(program, "")) == NULL)
		return NULL;

	if((str = sread(ret)) == NULL)
		return NULL;

	if((t = strchr(str, ' ')) == NULL)
		return NULL;

	t++;

	if(*t == '2')
		return ret;

	if(*t != '3')
		return NULL;

	while((str = sread(ret)) != NULL) {
		if(strncmp(str, "Location: ", 10))
			continue;

		if((str = strchr(str, '?')) == NULL)
			continue;

		if((t = strpbrk(str, "\r\n")) != NULL)
			*t = '\0';

		if((ret = version_connect(program, str)) == NULL)
			return NULL;

		if((str = sread(ret)) == NULL)
			return NULL;

		if((t = strchr(str, ' ')) == NULL)
			return NULL;

		t++;

		if(*t != '2')
			return NULL;

		return ret;
	}

	return NULL;
}

void version_info(char *program)
{
	char *str, *title = NULL, *ret = NULL, *t;
	void *c;

	if((c = version_http_connect(program)) == NULL) {
		reply("Error: Couldn't connect to remote server");
		return;
	}

	while((str = sread(c)) != NULL) {
		if(!title && !strncmp(str, "&nbsp;<b>", 9)) {
			if((str = strrchr(str, '\"')) == NULL)
				continue;

			if(str[1] != '>')
				continue;

			title = str + 2;
			if((t = strchr(title, '<')) != NULL)
				*t = '\0';
		}

		if(strstr(str, "/branches/")) {
			if((str = strchr(str, '>')) == NULL)
				continue;

			str++;

			if((t = strchr(str, '<')) != NULL) 
				*t = '\0';

			if(strcmp(str, "Default")) {
				if(!ret)
					asprintf(&ret, "%s: ", str);
				else
					asprintf(&ret, "%s, %s: ", ret, str);
			} else {
				if(!ret) 
					ret = "";
			}
		}

		if(strstr(str, "/releases/")) {
			if(ret == NULL)
				continue;

			if((str = strchr(str, '>')) == NULL)
				continue;

			str++;

			if((t = strchr(str, '<')) != NULL) 
				*t = '\0';

			asprintf(&ret, "%s%s", ret, str);
		}
	}

	if(title && ret)
		reply("%s - %s", title, ret);
	else
		reply("No version information available for: %s", program);
}

int main(int argc, char **argv)
{
    /* send back to channel if public request, otherwise back to sender */
    Dest = (argv[2][0] == '#') ? argv[2] : argv[1];

	if(argc < 4 || strlen(argv[3]) < 2) {
		reply(HELPTEXT);
		return 0;
	}

	version_info(argv[3]);

	return 0;
}
