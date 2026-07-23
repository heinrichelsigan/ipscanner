%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "getopt.h"
#include <string.h> 
#define MAXLEN 1024

int toggle = 0, match_pattern = 0, mode = 0;
int i, j, idx, len;

char tmps[MAXLEN], reverse[MAXLEN], pattern[MAXLEN];

int getoggle(int match_flag, const char* match_string, const char* ylextext)
{
	if (strlen(match_string) > 0) { 
        	if (match_flag == 1) { 
			if (strstr(ylextext, match_string) == (char*)NULL) {
				return 0;
			}
		}
        	if (match_flag == -1)  {
			if (strstr(ylextext, match_string) != (char*)NULL) {
				// printf("flag %d %s NOT in %s\n", match_flag, match_string, yytext);
				return 0;
			}
		}
	}
	return 1;
}

%}
SEGA  [2][5][0-5]
SEGB  [2][0-4][0-9]
SEGC  [1][0-9]{2}
SEGD  [1-9][0-9]{0,1}
SEG   {SEGA}|{SEGB}|{SEGC}|{SEGD}
IP    {SEG}["."]{SEG}["."]{SEG}["."]{SEG}

SEGV6	[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]
SEGA6 	{SEGV6}[":"]
SEGI6	{SEGV6}{0,1}[":"]
IPV6	{SEGA6}{SEGI6}{SEGI6}{SEGI6}{SEGI6}{SEGV6}

HOSTDOMAINSEGMENT [0-9a-zA-Z_"\-"]+["."]
TOPLEVELDOMAIN [a-zA-Z]{2,7}
HOSTNAME {HOSTDOMAINSEGMENT}+{TOPLEVELDOMAIN}
USER [0-9A-Za-z_"\-""."]+

EMAIL1 {USER}"@"{HOSTNAME}
EMAIL2 {USER}"@"{IP}

URIPROTOCOL [a-zA-Z]{2,10}"://"
URISUFFIX [^ \t\n\r"@"","">""<""("")""{""}"]
URL1   {URIPROTOCOL}{HOSTNAME}{URISUFFIX}*
URL2   {URIPROTOCOL}{IP}{URISUFFIX}*

%%
<<EOF>> { 
	exit(1);
}

{EMAIL1} |
{EMAIL2} { 
        toggle = getoggle(match_pattern, pattern, yytext);
	if (toggle == 1 && strchr(yytext, '@') != (char *)NULL) 
	{ 
		switch((mode % 16)) 
		{
			case 0: strcpy(tmps, yytext); break;
 			case 1: strcpy(tmps, strchr(yytext, (int)'@')); break;
 			case 2: strcpy(tmps, &strchr(yytext, (int)'@')[1]); break;
     			case 4: 
	 			strcpy(tmps, &strchr(yytext, (int)'@')[1]);
 				len = strlen(tmps); 
 				for (j = 0, idx = 0; ((j < len) && (j < MAXLEN-1)); j++) 
 				{ 
					if (tmps[j] == '.') 
					{ 
						for (i = idx; i <= j; reverse[(len-j) + (i-idx)] = tmps[i++]); 
						idx = j + 1; 
					}
 				}
				for (i = idx; i <= j; reverse[(len-j) + (i-idx)] = (i < len) ? tmps[i] : '.', i++);
 				reverse[len + 1] = '\0';
 				strcpy(tmps, reverse);
 				break;
 			case 8: strcpy(tmps, &strrchr(yytext, (int)'.')[1]); break;
 			default: strcpy(tmps, yytext); break; 
		}
		(void) printf("%s\n", tmps);
	} 
}

{URL1} |
{URL2} {
        toggle = getoggle(match_pattern, pattern, yytext);
	if (toggle == 1) 
	switch((mode % 16)) 
	{
		case 0: strcpy(tmps, yytext); break; 
		case 1: strcpy(tmps, strchr(yytext, (int)'/')); break; 
		case 2: strcpy(tmps, &strrchr(yytext, (int)'/')[1]); break; 
		case 4: 
			strcpy(tmps, &strrchr(yytext, (int)'/')[1]); 
			len = strlen(tmps); 
			for (j = 0, idx = 0; ((j < len) && (j < MAXLEN-1)) ; j++)
     			{ 
				if (tmps[j] == '.') { 
					for (i = idx; i <= j; reverse[(len-j) + (i-idx)] = tmps[i++]); 
					idx = j + 1; 
				} 
			} 
			for (i = idx; i <= j; reverse[(len-j) + (i-idx)] = (i < len) ? tmps[i] : '.', i++); 
			reverse[len + 1] = '\0'; 
			strcpy(tmps, reverse); 
			break;
		case 8: strcpy(tmps, &strrchr(yytext, (int)'.')[1]); break; 
		default: strcpy(tmps, yytext); break; 
	} 
	(void) printf("%s\n", tmps); 
} 

{IP} {
        toggle = getoggle(match_pattern, pattern, yytext);
	if ((toggle == 1) && (mode == 0 || mode == 16 || mode >= 32)) {
		(void) printf("%s\n", yytext); 
	}
}

{IPV6} {
        toggle = getoggle(match_pattern, pattern, yytext);
	if ((toggle == 1) && (mode == 0 || mode == 16 || mode >= 64)) {
		(void) printf("%s\n", yytext); 
	}
}

^[\n;] { ; }

[\r\n]+ { ; }

. { ; }

%%
void yyerror() { exit(1); }


void usage(const char *cmd) 
{
	(void) printf("Usage: %s [-f file] [-a ] [ -r ] [ -u ]\n", cmd);
	(void) printf("\t simple email address and uri lexer reads from stdin \n"); 
	(void) printf("\t -a, --noat    \t print only hostname of email address (all chars left of \'@\') \n"); 
	(void) printf("\t -u, --nouser  \t print email without username \n"); 
	(void) printf("\t -t, --top     \t prints domain toplevel only, when using option -a | -u \n"); 
	(void) printf("\t -m, --match {optarg} \t matching {optarg]\n"); 
	(void) printf("\t -n, --nomatch {optarg} \t no matching {optarg]\n"); 
	(void) printf("\t -r, --reverse \t reverse the hostdomain / ip address segments\n"); 
	(void) printf("\t -4, --ipv4 \t prints lonley ipv4 address too.\n"); 
	(void) printf("\t -6, --ipv6 \t prints lonley ipv6 address too.\n"); 

	exit(0);
}


int main(int argc, char** argv)
{
	static int verbose_flag = 0;
	int c;

 	while(1) 
	{ 
		static struct option long_options[] = 
		{ 
			{"help", 	no_argument, 		0, 	'h'}, 
			{"noat", 	no_argument, 		0, 	'a'}, 
			{"nouser", 	no_argument, 		0, 	'u'}, 
			{"top", 	no_argument, 		0, 	't'}, 
			{"match", 	required_argument, 	0, 	'm'}, 
			{"nomatch", 	required_argument, 	0, 	'n'}, 
			{"reverse",	no_argument, 		0, 	'r'},
			{"verbose",	no_argument, 		0,	'v'}, 
			{"ipv4",	no_argument, 		0,	'4'}, 
			{"ipv6",	no_argument, 		0,	'6'}, 
			{0,         	0,        		0, 	0} 
		};

		int option_index = 0; 
		c = getopt_long(argc, argv, ("hautnrm:"), long_options, &option_index);

		if (c == -1) 
			break;

		switch (c) // Handle options 
		{ 
			case 0: // If this option set a flag, do nothing else now. 
				 if (long_options[option_index].flag != 0) 
						break; 
					printf ("option %s", long_options[option_index].name); 
					if (optarg) 
						printf (" with arg %s", optarg); 
					printf ("\n"); 
					break; 
			case 'v': verbose_flag = 1; break;
			case ('u'): mode = 1; break; 
			case ('a'): mode = 2; break; 
			case ('r'): mode = 4; break; 
			case ('h'): usage(argv[0]); break; 
			case ('t'): mode = 8; break; 
			case ('n'): 
				if (optarg) {
					printf (" with arg %s", optarg); 
					strcpy(pattern, optarg);	
					match_pattern = -1;
					mode += 16; 
				}
				break;
			case ('m'): 
				if (optarg) {
					printf (" with arg %s", optarg); 
                                        strcpy(pattern, optarg);        
                                        match_pattern = 1;
                                        mode += 16; 
                                }
                                break;
			// case 4:
			case '4': 	mode += 32; break;
			// case 6:
			case '6':		mode += 64; break; 
			case '?': break; // getopt_long already printed an error message. 
			default: abort(); 
		} 
	}

	if (verbose_flag > 0) 
	{
		if (mode == 0)
			printf("%s \twith no options\n", argv[0]);
		else 
		{
			printf("%s ", argv[0]);
			if ((mode%2) == 1) 
				printf("\t--nouser");
			if ((mode%4) >= 2)
				printf("\t--noat");
			if ((mode%8) >= 4)
				printf("\t--reverse");
			if ((mode%16) >= 8)
				printf("\t--top");
			if ((mode%32) >= 16) {
				if (match_pattern == 1)
					printf("\t--match %s", pattern);
				if (match_pattern == -1)
					printf("\t--nomatch %s", pattern);
			}
			if ((mode%64) >= 32)
       	 			printf("\t--ipv4");
			if ((mode%128) >= 64)
        			printf("\t--ipv6");
			printf("\n");
		}
	}

	(void) fflush(stdout); 
	yyin = stdin; 
	yylex(); 

	exit(0);
}
