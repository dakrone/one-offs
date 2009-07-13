#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>

/*
 * The intent of this program is the measure the randomness of a file, using
 * the index of coincidence. Basically the file is shifted to the left by an
 * amount and compared to the original, the matching bytes are counted and
 * compared to the number of differring bytes, which produces a percentage.
 */

static void usage()
{
      printf("Usage:\n");
      printf("\n\tchkrand <blocksize> <shiftsize> <filename>\n\n");
      exit(0);
}

/*
 * Shift the source string (src) to the left by the shift size (ss), putting
 * the new string in the destination (dst). This is a cyclical shifting, so
 * the shifted out bytes are appended to the end.
 */
void shift_buffer(char *src, char *dst, unsigned int strlen, unsigned int ss)
{
      int i = 0;
      char *shift_buffer = malloc(ss * sizeof(char));

      for (i = 0; i < ((strlen - ss) - 1); i++) {
            /* Save the first <shiftsize> characters so we can append them */
            if (i < ss)
                  shift_buffer[i] = src[i];

            dst[i] = src[i + ss];
      }

      /* Append the shifted buffer (circular shift) */
      strncat(dst,shift_buffer,ss);

      return;
}

/*
 * Go through the strings n1 and n2, comparing their bytes, return the number
 * of bytes that matched in the string.
 */
unsigned int byte_match(char *n1, char *n2, unsigned int strlen)
{
      unsigned int m = 0;
      unsigned int i = 0;

      for (i = 0; i < strlen; i++) {
            if ((n1[i] ^ n2[i]) == 0)
                  m++;
      }

      return m;
}

int main(int argc, char **argv)
{
      unsigned int blocksize = 0;
      unsigned int shiftsize = 0;
      ssize_t len = 0;
      unsigned int matches = 0;
      unsigned int totalbytes = 0;
      float ioc = 0.0;
      FILE *infile = NULL;
      char *filename = NULL;
      char *b1 = NULL;
      char *b2 = NULL;

      if (argc < 4)
            usage();

      blocksize = atoi(argv[1]);
      shiftsize = atoi(argv[2]);
      filename  = argv[3];

      printf("Blocksize: %u\n",blocksize);
      printf("Shiftsize: %u\n",shiftsize);
      printf("Filename : %s\n",filename);

      b1 = malloc(blocksize * sizeof(char));
      b2 = malloc(blocksize * sizeof(char));
      if ((b1 == NULL) || (b2 == NULL)) {
            printf("Unable to allocate buffers");
            exit(-1);
      }

      infile = fopen(filename, "r");
      if (infile == NULL) {
            printf("Unable to open file '%s'\n",filename);
            exit(-1);
      }

      while ((len = read(fileno(infile),b1,blocksize)) > 0) {
            totalbytes += len;

            if (shiftsize >= len)
                  shiftsize = len - 1;

            shift_buffer(b1,b2,len,shiftsize);

            matches += byte_match(b1,b2,len);

            /* reset the buffers */
            memset(b1, 0, blocksize);
            memset(b2, 0, blocksize);
      }
      fclose(infile);

      printf("\n%u matches from %u total bytes.\n",matches,totalbytes);
      ioc = (float)matches / (float)totalbytes;
      printf("Index of Coincidence: %f (%.2f%%) -- lower means more random.\n\n",ioc,ioc*100);

      return 0;
}
