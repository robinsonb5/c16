#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Utility to parse a file of hex values, break into chunks of (by default) 4 bytes
   then scan for repeated chunks.  If the source data contains more than one set of data
   the sets will be appended side-by-side before scanning.  (A max of 4 sets supported.)
   The output is a table of tuples, where the first byte is a pointer to a "row",
   and subsequent bytes (one for each set of data) contains a byte from a unique row
   within the original data.
   The idea is to do a 2-stage lookup: use the original table's index to read the row pointer
   then use that pointer to read the actual data.  The extreme repetition in the SID tables is
   thus restricted to the list of pointers, and not the actual row data.
*/

#define MAXROWS 2048
#define COLS 4
int ROWS=512;

int lookup[MAXROWS];
int indirect[MAXROWS];
int hist[MAXROWS];
unsigned char pattern[MAXROWS][COLS*4];

char *lineptr=0;
size_t linelen=0;


int calchist(int sets)
{
	int row,col,set;
	int rowcount=0;
	int sixteencount=0;
	for(row=0;row<ROWS;++row)
		hist[row]=indirect[row]=0;

	int targetrow=0;

	for(row=0;row<ROWS;++row)
	{
		if(!hist[row]) /* Don't bother comparing rows which have already been matched */
		{
			int row2;
			for(row2=row+1;row2<ROWS;++row2)
			{
				int match=1;
				for(col=0;col<COLS;++col)
				{
					for(set=0;set<sets;++set)
					{
						if(pattern[row][col+set*COLS]!=pattern[row2][col+set*COLS])
							match=0;
					}
				}
				if(match)
				{
					++hist[row];  /* Increase the count for this row */
					--hist[row2];	/* Mark the matched row so we don't consider it later. */
					indirect[row2]=targetrow;
				}
			}
			indirect[row]=targetrow;
			lookup[targetrow]=row;
			++targetrow;
		}
	}
	for(row=0;row<ROWS;++row)
	{
		if(hist[row]>=0)
			++rowcount;
	}
	printf("%d rows of interest\n",rowcount);
	for(row=0;row<rowcount;++row)
	{
		int sixteen=1;
		for(col=0;col<COLS;++col)
		{
			for(set=0;set<sets;++set)
			{
				int t=pattern[lookup[row]][col+set*COLS];
				if((t&0xe0)!=0 && (t&0xe0)!=0xe0)
					sixteen=0;
			}
		}
		if(sixteen)
			++sixteencount;
	}
	printf("%d of which can be expressed in 16 bits\n",sixteencount);
	return(rowcount);
}


void outputtables(int rowsofinterest,int sets)
{
	int row;
	int col;
	int set;
	int i,j;
	char *prefix="16'h";

	if(sets>1)
		prefix="32'h";

	col=0;
	for(i=0;i<rowsofinterest;++i)
	{
		int targetrow=lookup[i];
		for(j=0;j<COLS;++j)
		{
			int idx=i*COLS+j;
			if(idx<ROWS)
				idx=indirect[(i*COLS+j)];
			else
				idx=0;

			if(!col)
				printf("\t");
			printf("%s%02x",prefix,idx);
			for(set=0;set<sets;++set)
			{
				printf("%02x",pattern[targetrow][set*COLS+j]);
			}
			printf(", ");
			++col;
			if(col==4)
			{
				printf("\n");
				col=0;
			}
		}
	}
	printf("\n");
	if((rowsofinterest*COLS)<ROWS)
	{
		col=0;
		for(i=rowsofinterest*COLS;i<ROWS;++i)
		{
			int idx=indirect[i];
			if(!col)
				printf("\t");
			printf("%s%02x",prefix,idx);
			for(idx=0;idx<sets;++idx)
			{
				printf("00");
			}
			printf(", ");
			++col;
			if(col==4)
			{
				printf("\n");
				col=0;
			}
		}
	}
}


int main(int argc,char **argv)
{
	int i,l;
	int row,col,set;
	char *tok;
	char *ep=0;
	int rowsofinterest;

	i=getline(&lineptr,&linelen,stdin);
	if(i<0)
		return(10);
	l=strtoul(lineptr,&ep,16);
	if(lineptr!=ep)
		ROWS=l*2;

	row=0;
	col=0;
	set=0;
	tok=0;
	do
	{
		if(!tok)
		{
			i=getline(&lineptr,&linelen,stdin);
			if(i<0)
				break;
			tok=strtok(lineptr,"\t,\n");
		}
		if(tok)
		{
			l=strtoul(tok,&ep,16);
			if(ep!=tok)
			{
//				printf("%d, %d -> %d\n",row,col,l);
				pattern[row][col+set*COLS]=l&255;
			}
			else
				printf("(invalid)\n");
			tok=strtok(0,"\t,\n");
			++col;
			if(col>=COLS)
			{
				col=0;
				++row;
				if(row>=ROWS)
				{
					row=0;
					++set;
				}
			}
		}
	} while(i>0);

	rowsofinterest=calchist(set);
//	outputtables(rowsofinterest,set);

	return(0);
}

