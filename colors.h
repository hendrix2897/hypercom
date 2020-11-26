#include <stdio.h>
void font_next_red() {
  printf("\033[1;31m");
}

void font_next_yellow(){
  printf("\033[1;33m");
}

void font_next_cyan(){
  printf ("\033[1;36m");
}
void font_next_reset() {
  printf("\033[0m");
  printf("\033[K");
}

