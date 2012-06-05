/* greplog.c - searches the IRC chat logs across dates, channels, urls or text, etc
 */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

enum DateRangeType {
    LATEST,
    ALL_TIME,
    DATE_RANGE
};

static const char USAGE[] =
"usage: greplog [from-date to-date] options...\n"
"\n"
"options:\n"
"  -a       parse logs for all time (from- and to-date may be omitted)\n"
"  -c CHAN  only look at the given channel\n"
"  -h       print this help message and exit\n"
"  -l       grab the latest day or so of the log (from- and to-date may be omitted)\n"
"  -n LINES the maximum number of lines to return\n"
"  -q PCRE  a Perl-compatible regular expression to filter the logs by\n"
"  -u       limit output to lines with URLs only\n"
"  -v       be verbose (for help with debugging)\n"
"\n"
"from-date and to-date should be integers for the number seconds since the\n"
"unix epoch.\n";

// command line flags
static enum DateRangeType o_date_range = DATE_RANGE;
static time_t o_from = 0, o_to = 0;
static int o_just_urls = 0;
static int o_line_limit = -1;
static char *o_query = NULL;
static char *o_channel = NULL;
static int o_verbose = 0;

static const char OPTS[] = "ac:hln:q:uv";

static void usage(int e)
{
    puts(USAGE);
    exit(e);
}

static void parse_args(int argc, char **argv)
{
    int o;

    // scan options
    while ((o = getopt(argc, argv, OPTS)) > 0) {
        switch (o) {
        case 'a':
            o_date_range = ALL_TIME;
            break;
        case 'c':
            o_channel = optarg;
            break;
        case 'h':
            usage(0);
            break;
        case 'l':
            o_date_range = LATEST;
            break;
        case 'n':
            o_line_limit = atoi(optarg);
            break;
        case 'q':
            o_query = optarg;
            break;
        case 'u':
            o_just_urls = 1;
            break;
        case 'v':
            o_verbose = 1;
            break;
        case ':':
        case '?': // missing or unknown options
            usage(-1);
            break;
        default:
            printf("greplog: woops! forgot to code in command line option '%c'", (char)o);
            exit(-1);
            break;
        }
    }

    if (o_date_range == DATE_RANGE) {
        if (optind + 2 < argc) {
            puts("greplog: missing date range spec.");
            usage(-1);
        } else if (optind + 2 != argc) {
            goto bad_arg_count;
        }
        o_from = strtoll(argv[optind++], NULL, 10);
        o_to   = strtoll(argv[optind++], NULL, 10);
    }

    if (optind != argc) {
 bad_arg_count:
        puts("greplog: unrecognized command line arguments");
        usage(-1);
    }
}

int main(int argc, char **argv)
{
    parse_args(argc, argv);

    if (o_verbose) {
        switch (o_date_range) {
        case LATEST:
            printf("latest logs\n");
            break;
        case ALL_TIME:
            printf("logs for ALL TIME\n");
            break;
        case DATE_RANGE:
            printf("logs from %li to %li\n", (long)o_from, (long)o_to);
            break;
        }

        if (o_just_urls)
            puts("just urls");
        else
            puts("full text");

        printf("line limit: %i\n", o_line_limit);

        if (o_query)
            printf("query: '%s'\n", o_query);

        printf("channels: %s\n", o_channel ? o_channel : "*");
    }

    // XXX figure out which log files

    // XXX read the log lines

    // XXX parse timestamp

    // XXX filter by date range

    // XXX sort lines by timestamp

    // XXX format log lines and print them to stdout

    return 0;
}
