#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

ushort *screen_buffer; //保存屏幕内容 

void create_new_file(int argc, char *argv[]);
void vim_gui();
int main(int argc, char *argv[])
{
  // 判断命令行输入是否正确
  
  if (argc != 2)
  {
  printf(1, "Pos:%d\n",getCuPos());
    if (argc == 1)
      printf(1, "[Error] Filename Unavailable.\n");
    else
      printf(1, "[Error] Only vi \"filename\".\n");
    exit();
  }
  int fd;
  // 测试文件是否存在
  if ((fd = open(argv[1], O_RDONLY)) < 0)
  {
    create_new_file(argc, argv);
  }
  vim_gui();
  printf(1, "Over.");
  exit();
  // editing = 1;	// 0=exit, 1=one file
  // re_t pattern = re_compile(".c");     //　匹配.Ｃ文件
  // int match_length;
  // int match_idx = re_matchp(pattern, argv[1], &match_length);
  // if(match_idx != -1){
  // flagCfile = 1;
  // }
  // intoVi(argv[1]);  // 进入vi
}

void create_new_file(int argc, char *argv[])
{
  int fd;
  fd = open(argv[1], O_CREATE | O_WRONLY);
  char c[1];
  char *cf;
  cf = c;
  write(fd, cf, 1); // 写入'\0'
  close(fd);
}
void vim_gui(){
  int cursor_pos = getCuPos();
  int screen_size = cursor_pos * sizeof(screen_buffer[0]);
  screen_buffer = (ushort *) malloc(screen_size);
  
  printf(1, "fuckyou %d\n",getCuPos());
  getSnapshot(screen_buffer,cursor_pos);

  printf(1, "fuckme%d\n",getCuPos());
  clearScreen();
  printf(1, "fuckheyhey:%d\n",getCuPos());
  while (1)
  {
    
  }
  
  printf(1, "fuck3hey:%d\n",getCuPos());
  // exit();
}