#define VGA_ADDRESS 0xB8000 /* VGA-Text Mode start address */

#define CONSOLE_WIDTH 80
#define CONSOLE_HEIGHT 25
#define CONSOLE_CHARS (CONSOLE_WIDTH * CONSOLE_HEIGHT)

#define MIX_COLOR(fg, bg) ((bg) << 4 | ((fg) & 0x0F))

typedef enum {
  COLOR_BLACK = 0,
  COLOR_GREEN = 2,
  COLOR_RED = 4,
  COLOR_YELLOW = 14,
  COLOR_WHITE = 15
} VGA_COLOR_T;

unsigned short *terminal_buffer; // volatile
unsigned int vga_index;
unsigned char color = MIX_COLOR(COLOR_WHITE, COLOR_BLACK);

void getCursor(unsigned short *x, unsigned short *y) {
  *y = vga_index / CONSOLE_WIDTH;
  *x = vga_index % CONSOLE_WIDTH;
}

char setCursor(unsigned short x, unsigned short y) {
  if(x >= CONSOLE_WIDTH) {
    y += x / CONSOLE_WIDTH;
    x = x % CONSOLE_WIDTH;
  }
  if(y >= CONSOLE_HEIGHT) {
    return 0;
  }

  vga_index = y * CONSOLE_WIDTH + x;

  return 1;
}

void setColor(VGA_COLOR_T fg, VGA_COLOR_T bg) {
  color = MIX_COLOR(fg, bg);
}

void kernel_clear(void) {
  int index = 0;
  while (index < CONSOLE_CHARS) {
    terminal_buffer[index] = (unsigned short) ' ' | (unsigned short) color << 8;
    index++;
  }
  vga_index = 0;
}

void kernel_scroll() {
  unsigned int i;
  for(i = 0; i < CONSOLE_CHARS - CONSOLE_WIDTH; i++) {
    terminal_buffer[i] = terminal_buffer[i + CONSOLE_WIDTH];
  }
  for(i = CONSOLE_CHARS - 1; i >= CONSOLE_CHARS - CONSOLE_WIDTH; i--) {
    terminal_buffer[i] = 0x0000 | color;
  }
}

void kernel_putchar(char c) {
  terminal_buffer[vga_index] = (unsigned short) c | (unsigned short) color << 8;
  vga_index++;
}

void kernel_print(char *str) {
  int index = 0;
  while(str[index]) {
    char c = (char) str[index];

    if(c == '\n') {
      unsigned short x = 0, y = 0;
      getCursor(&x, &y);
      x = 0;
      y = y + 1;
      if(y >= CONSOLE_HEIGHT) {
	kernel_scroll();
	y = y - 1;
      }
      setCursor(x, y);
    } else {
      kernel_putchar(c);
    }

    index++;
  }
}

void main(void) {
  terminal_buffer = (unsigned short *) VGA_ADDRESS;
  vga_index = 0;

  setColor(COLOR_WHITE, COLOR_BLACK);

  kernel_clear();

  kernel_print("Test 0\n");
  kernel_print("Test 1\n");
  kernel_print("Test 2\n");
  kernel_print("Test 3\n");
  kernel_print("Test 4\n");
  kernel_print("Test 5\n");
  kernel_print("Test 6\n");
  kernel_print("Test 7\n");
  kernel_print("Test 8\n");
  kernel_print("Test 9\n");
  kernel_print("Test A\n");
  kernel_print("Test B\n");
  kernel_print("Test C\n");
  kernel_print("Test D\n");
  kernel_print("Test E\n");
  kernel_print("Test F\n");
  kernel_print("Test G\n");
  kernel_print("Test H\n");
  kernel_print("Test I\n");
  kernel_print("Test J\n");
  kernel_print("Test K\n");
  kernel_print("Test L\n");
  kernel_print("Test M\n");
  kernel_print("Test N\n");
  kernel_print("Test O\n");
  kernel_print("Test P\n");
  kernel_print("Test Q\n");
  kernel_print("Test R\n");
  kernel_print("Test S\n");
  kernel_print("Test T\n");
  
}
