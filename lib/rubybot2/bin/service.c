/* Original code by Tony Arcieri, ported from his C Bot. */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <ctype.h>

#define CONNECT_TIMEOUT	10
#define MESSAGE_TIMEOUT 3
#define SOCKET_TIMEOUT 8
static const char *HELPTEXT = "usage: !service (<domain> | <ip>) [<port>]";

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

int resolve(uint32_t *addr, const char *name)
{
    struct hostent *h;

    if((h = gethostbyname(name)) == NULL)
        return -1;

    memcpy(addr, h->h_addr, h->h_length);
	endhostent();

    return 0;
}

static int svc_connect(char *hostname, int port)
{
	int fd, err, flags;
	struct sockaddr_in sin;
	struct timeval timeout;
	socklen_t errlen;
	fd_set fds;

	timeout.tv_sec = CONNECT_TIMEOUT;
	timeout.tv_usec = 0;

	sin.sin_family = AF_INET;
	sin.sin_port = htons(port);

	if((int)(sin.sin_addr.s_addr = inet_addr(hostname)) == -1) {
		if(resolve(&sin.sin_addr.s_addr, hostname) < 0) {
			reply("Couldn't resolve %s: Host name lookup failure", hostname);
			return -1;
		}
	}

	if((fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		reply("Couldn't create socket: %s", strerror(errno));
		return -1;
	}

	if((flags = fcntl(fd, F_GETFL)) < 0) {
		reply("Couldn't read socket flags: %s", strerror(errno));
		close(fd);

		return -1;
	}

	if(fcntl(fd, F_SETFL, flags | O_NONBLOCK) < 0) {
		reply("Couldn't set socket as non-blocking: %s", strerror(errno));
		close(fd);

		return -1;
	}

	connect(fd, (struct sockaddr *)&sin, sizeof(sin));

	FD_ZERO(&fds);
	FD_SET(fd, &fds);

	if(select(fd + 1, NULL, &fds, NULL, &timeout) < 1) {
		reply("Timeout connecting to %s:%d", hostname, port);
		close(fd);

		return -1;
	}

	errlen = sizeof(int);

	if(getsockopt(fd, SOL_SOCKET, SO_ERROR, (char *)&err, &errlen) < 0) {
		reply("Couldn't read SO_ERROR: %s", strerror(errno));
		close(fd);

		return -1;
	}

	if(err) {
		reply("Couldn't connect to %s:%d: %s", hostname, port, strerror(err));
		close(fd);

		return -1;
	}

	if(fcntl(fd, F_SETFL, flags) < 0) {
		reply("Couldn't set socket as blocking: %s", strerror(errno));
		close(fd);

		return -1;
	}

	return fd;
}

static void chop_crlf(char *buf)
{
	char *c;

	while((c = strpbrk(buf, "\r\n")) != NULL)
		*c = '\0';
}

static char *guess_version(char *ver)
{
	int i, l;
	char *begin, *t, p = 0, ip = 0, fa = 0, fc = 0;

	if((t = strstr(ver, "ready")) != NULL)
		*t = '\0';

	if((t = strstr(ver, "READY")) != NULL)
		*t = '\0';

	if((t = strstr(ver, "Ready")) != NULL)
		*t = '\0';

	l = strlen(ver);
	begin = ver;

	for(i = 0; i < l; i++) {
		switch(ver[i]) {
			case '(':
			case '[':
				/*if(ip) break;*/
				if(ip) {
					ver[i] = '\0';
					break;
				}

				if(fa && fc) {
					ver[i] = '\0';

					if((l = strlen(begin)) != 0) {
						if(isspace(begin[l - 1]))
							begin[l - 1] = '\0';
					}

					if(!strncasecmp(begin, "version", 7))
						begin += 7;

					if(*begin == ' ')
						begin++;

					return begin;
				}

				fa = 0;
				fc = 0;
				ip = 1;
				p = ver[i];
				begin = ver + i + 1;

				break;
			case ']':
			case ')':
				if(!ip)
					break;

				if(ver[i] == ')' && p != '(')
					break;
				else if(ver[i] == ']' && p != '[')
					break;

				ver[i] = '\0';

				if(fa && fc) {
					ver[i] = '\0';

					if((l = strlen(begin)) != 0) {
						if(isspace(begin[l - 1]))
							begin[l - 1] = '\0';
					}

					if(!strncasecmp(begin, "version", 7))
						begin += 7;

					if(*begin == ' ')
						begin++;

					return begin;
				}

				fa = 0;
				fc = 0;
				ip = 0;

				break;
			default:
				if(isalpha(ver[i])) 
					fa = 1;
				else if(isdigit(ver[i]))
					fc = 1;
		}
	}

	return begin;
}

static void svc_display_type(char *hostname, int port, char *type,
	char *version)
{
	if(version) 
		reply("%s:%d: %s running %s", hostname, port, type, version);
	else
		reply("%s:%d: %s", hostname, port, type);
}

static void svc_process_smtp_id(char *hostname, int port, char *buf)
{
	char *id, *t;

	id = strstr(buf, "SMTP ") + 5;
	if((t = strchr(id, ';')) != NULL)
		*t = '\0';

	svc_display_type(hostname, port, "SMTP server", guess_version(id));
}

static void svc_process_ssh_id(char *hostname, int port, char *buf)
{
	char *id, *v, *t;

	chop_crlf(buf);

	if((id = strchr(buf, '-')) == NULL)
		return;

	if((id = strchr(id + 1, '-')) == NULL)
		return;

	id++;

	if((t = strchr(id, ' ')) != NULL)
		*t = '\0';

	if((v = strchr(id, '_')) != NULL) 
		*v++ = '\0';
	else {
		v = id;
		id = "SSH";
	}

	reply("%s:%d: SSH server running %s %s", hostname, port, id, v);
}

static void svc_process_reply(int fd, char *hostname, int port)
{
	FILE *sock;
	char buf[512], *t;

	if((sock = fdopen(fd, "r")) == NULL) {
		reply("Couldn't buffer socket: %s", strerror(errno));
		close(fd);

		return;
	}

	fgets(buf, 512, sock);
	if(!strncmp(buf, "HTTP/", 5)) {
		while(strncmp(buf, "Server: ", 8)) {
			if(!fgets(buf, 512, sock)) {
				svc_display_type(hostname, port, "Non-RFC compliant HTTP server", NULL);
				return;
			}
		}

		chop_crlf(buf);
		svc_display_type(hostname, port, "HTTP server", buf + 8);
	}
	else if(!strncmp(buf, "200 ", 4)) 
		svc_display_type(hostname, port, "NNTP server", NULL);

	else if(!strncmp(buf, "220 ", 4) || !strncmp(buf, "220-", 4)) {
		chop_crlf(buf);
		if(strstr(buf, " ESMTP ")) 
			svc_process_smtp_id(hostname, port, buf);
		else if(!strstr(buf, "ESMTP")) 
			svc_display_type(hostname, port, "FTP server", guess_version(buf + 4));
		else {
			write(fd, "HELP\n", 5);
			fgets(buf, 512, sock);

			chop_crlf(buf);

			if((t = strchr(buf, ' ')) == NULL)
				t = buf;
			else
				t++;

			svc_display_type(hostname, port, "SMTP server", t);
		}
	}
	else if(!strncmp(buf, "SSH-", 4)) 
		svc_process_ssh_id(hostname, port, buf);

	else if(!strncmp(buf, "* OK ", 5)) {
		chop_crlf(buf);
		svc_display_type(hostname, port, "IMAP server", guess_version(buf + 5));
	}

	else if(!strncmp(buf, "+OK ", 4)) {
		chop_crlf(buf);
		svc_display_type(hostname, port, "POP server", guess_version(buf + 4));
	}

	else if(!strncmp(buf, "0 , 0 :", 7) || !strncmp(buf, "0, 0 :", 6) ||
	        !strncmp(buf, "0,0 :", 5) || !strncmp(buf, "0,0:", 4)) 
		svc_display_type(hostname, port, "IDENT server", NULL);

	else if(!strncmp(buf, "lpd ", 4) || strstr(buf, "lpd: ") != NULL) 
		svc_display_type(hostname, port, "LPD server", NULL);

	else if(!strncmp(buf, "HEAD / HTTP/1.0", 15)) 
		svc_display_type(hostname, port, "ECHO server", NULL);

	else if(strstr(buf, "NOTICE AUTH"))
		svc_display_type(hostname, port, "IRC server", NULL);

	else
		svc_display_type(hostname, port, "Active server of unknown type", NULL);

	fclose(sock);
}

static void svc_scan(char *hostname, int port)
{
	int fd;
	fd_set fds;
	struct timeval timeout;
	const char *http_request = "GET / HTTP/1.0\r\n\r\n";

	reply("Trying %s:%d...", hostname, port);

	if((fd = svc_connect(hostname, port)) < 0)
		return;

	timeout.tv_sec = MESSAGE_TIMEOUT;
	timeout.tv_usec = 0;

	FD_ZERO(&fds);
	FD_SET(fd, &fds);

	if(select(fd + 1, &fds, NULL, NULL, &timeout) == 1) {
		svc_process_reply(fd, hostname, port);
		return;
	}

	write(fd, http_request, strlen(http_request));

	timeout.tv_sec = SOCKET_TIMEOUT;
	timeout.tv_usec = 0;

	FD_ZERO(&fds);
	FD_SET(fd, &fds);

	if(select(fd + 1, &fds, NULL, NULL, &timeout) == 1) {
		svc_process_reply(fd, hostname, port);
		return;
	}

	reply("%s:%d: Active server of unknown type", hostname, port);
	close(fd);
}

static int svc_isnumber(char *s)
{
	int i, l = strlen(s);

	for(i = 0; i < l; i++) {
		if(i && isspace(s[i]))
			return 1;

		if(!isdigit(s[i]))
			return 0;
	}

	return 1;
}

void hook_handler(char *message)
{
	struct servent *s;
	int port = 80;
	char *t;

	if(!strchr(message, '.')) { 
		if(svc_isnumber(message)) {
			if(!(s = getservbyport(htons(atoi(message)), "tcp"))) {
				reply("No known service on port %s",
					message);
				return;
			}

			reply("Port %s: %s", message, s->s_name);
		} else {
			if(!(s = getservbyname(message, "tcp"))) {
				reply("No known service called '%s'",
					message);
				return;
			}

			reply("%s: port %d", message, ntohs(s->s_port));
		}

		return;
	}               

	if((t = strpbrk(message, ": ")) != NULL) {
		*t++ = '\0';

		if(!svc_isnumber(t)) {
			if(!(s = getservbyname(t, "tcp"))) {
				reply("Unknown service type: %s", t);
				return;
			}

			port = ntohs(s->s_port);
		} else 
			port = atoi(t);
	}

	svc_scan(message, port);
}

int main(int argc, char **argv)
{
    /* send back to channel if public request, otherwise back to sender */
    Dest = (argv[2][0] == '#') ? argv[2] : argv[1];

	if(argc < 4 || strlen(argv[3]) < 2) {
		reply(HELPTEXT);
		return 0;
	}

	hook_handler(argv[3]);

	return 0;
}
