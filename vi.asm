
_vi：     文件格式 elf32-i386


Disassembly of section .text:

00000000 <main>:
ushort *screen_buffer; //保存屏幕内容 

void create_new_file(int argc, char *argv[]);
void vim_gui();
int main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 10             	sub    $0x10,%esp
  12:	89 cb                	mov    %ecx,%ebx
  // 判断命令行输入是否正确
  
  if (argc != 2)
  14:	83 3b 02             	cmpl   $0x2,(%ebx)
  17:	74 48                	je     61 <main+0x61>
  {
  printf(1, "Pos:%d\n",getCuPos());
  19:	e8 5e 04 00 00       	call   47c <getCuPos>
  1e:	83 ec 04             	sub    $0x4,%esp
  21:	50                   	push   %eax
  22:	68 2c 09 00 00       	push   $0x92c
  27:	6a 01                	push   $0x1
  29:	e8 45 05 00 00       	call   573 <printf>
  2e:	83 c4 10             	add    $0x10,%esp
    if (argc == 1)
  31:	83 3b 01             	cmpl   $0x1,(%ebx)
  34:	75 14                	jne    4a <main+0x4a>
      printf(1, "[Error] Filename Unavailable.\n");
  36:	83 ec 08             	sub    $0x8,%esp
  39:	68 34 09 00 00       	push   $0x934
  3e:	6a 01                	push   $0x1
  40:	e8 2e 05 00 00       	call   573 <printf>
  45:	83 c4 10             	add    $0x10,%esp
  48:	eb 12                	jmp    5c <main+0x5c>
    else
      printf(1, "[Error] Only vi \"filename\".\n");
  4a:	83 ec 08             	sub    $0x8,%esp
  4d:	68 53 09 00 00       	push   $0x953
  52:	6a 01                	push   $0x1
  54:	e8 1a 05 00 00       	call   573 <printf>
  59:	83 c4 10             	add    $0x10,%esp
    exit();
  5c:	e8 7b 03 00 00       	call   3dc <exit>
  }
  int fd;
  // 测试文件是否存在
  if ((fd = open(argv[1], O_RDONLY)) < 0)
  61:	8b 43 04             	mov    0x4(%ebx),%eax
  64:	83 c0 04             	add    $0x4,%eax
  67:	8b 00                	mov    (%eax),%eax
  69:	83 ec 08             	sub    $0x8,%esp
  6c:	6a 00                	push   $0x0
  6e:	50                   	push   %eax
  6f:	e8 a8 03 00 00       	call   41c <open>
  74:	83 c4 10             	add    $0x10,%esp
  77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  7e:	79 10                	jns    90 <main+0x90>
  {
    create_new_file(argc, argv);
  80:	83 ec 08             	sub    $0x8,%esp
  83:	ff 73 04             	pushl  0x4(%ebx)
  86:	ff 33                	pushl  (%ebx)
  88:	e8 1f 00 00 00       	call   ac <create_new_file>
  8d:	83 c4 10             	add    $0x10,%esp
  }
  vim_gui();
  90:	e8 63 00 00 00       	call   f8 <vim_gui>
  printf(1, "Over.");
  95:	83 ec 08             	sub    $0x8,%esp
  98:	68 70 09 00 00       	push   $0x970
  9d:	6a 01                	push   $0x1
  9f:	e8 cf 04 00 00       	call   573 <printf>
  a4:	83 c4 10             	add    $0x10,%esp
  exit();
  a7:	e8 30 03 00 00       	call   3dc <exit>

000000ac <create_new_file>:
  // }
  // intoVi(argv[1]);  // 进入vi
}

void create_new_file(int argc, char *argv[])
{
  ac:	55                   	push   %ebp
  ad:	89 e5                	mov    %esp,%ebp
  af:	83 ec 18             	sub    $0x18,%esp
  int fd;
  fd = open(argv[1], O_CREATE | O_WRONLY);
  b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  b5:	83 c0 04             	add    $0x4,%eax
  b8:	8b 00                	mov    (%eax),%eax
  ba:	83 ec 08             	sub    $0x8,%esp
  bd:	68 01 02 00 00       	push   $0x201
  c2:	50                   	push   %eax
  c3:	e8 54 03 00 00       	call   41c <open>
  c8:	83 c4 10             	add    $0x10,%esp
  cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  char c[1];
  char *cf;
  cf = c;
  ce:	8d 45 ef             	lea    -0x11(%ebp),%eax
  d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  write(fd, cf, 1); // 写入'\0'
  d4:	83 ec 04             	sub    $0x4,%esp
  d7:	6a 01                	push   $0x1
  d9:	ff 75 f0             	pushl  -0x10(%ebp)
  dc:	ff 75 f4             	pushl  -0xc(%ebp)
  df:	e8 18 03 00 00       	call   3fc <write>
  e4:	83 c4 10             	add    $0x10,%esp
  close(fd);
  e7:	83 ec 0c             	sub    $0xc,%esp
  ea:	ff 75 f4             	pushl  -0xc(%ebp)
  ed:	e8 12 03 00 00       	call   404 <close>
  f2:	83 c4 10             	add    $0x10,%esp
}
  f5:	90                   	nop
  f6:	c9                   	leave  
  f7:	c3                   	ret    

000000f8 <vim_gui>:
void vim_gui(){
  f8:	55                   	push   %ebp
  f9:	89 e5                	mov    %esp,%ebp
  fb:	83 ec 18             	sub    $0x18,%esp
  int cursor_pos = getCuPos();
  fe:	e8 79 03 00 00       	call   47c <getCuPos>
 103:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int screen_size = cursor_pos * sizeof(screen_buffer[0]);
 106:	8b 45 f4             	mov    -0xc(%ebp),%eax
 109:	01 c0                	add    %eax,%eax
 10b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  screen_buffer = (ushort *) malloc(screen_size);
 10e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 111:	83 ec 0c             	sub    $0xc,%esp
 114:	50                   	push   %eax
 115:	e8 2c 07 00 00       	call   846 <malloc>
 11a:	83 c4 10             	add    $0x10,%esp
 11d:	a3 4c 0c 00 00       	mov    %eax,0xc4c
  
  printf(1, "fuckyou %d\n",getCuPos());
 122:	e8 55 03 00 00       	call   47c <getCuPos>
 127:	83 ec 04             	sub    $0x4,%esp
 12a:	50                   	push   %eax
 12b:	68 76 09 00 00       	push   $0x976
 130:	6a 01                	push   $0x1
 132:	e8 3c 04 00 00       	call   573 <printf>
 137:	83 c4 10             	add    $0x10,%esp
  getSnapshot(screen_buffer,cursor_pos);
 13a:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 13f:	83 ec 08             	sub    $0x8,%esp
 142:	ff 75 f4             	pushl  -0xc(%ebp)
 145:	50                   	push   %eax
 146:	e8 41 03 00 00       	call   48c <getSnapshot>
 14b:	83 c4 10             	add    $0x10,%esp

  printf(1, "fuckme%d\n",getCuPos());
 14e:	e8 29 03 00 00       	call   47c <getCuPos>
 153:	83 ec 04             	sub    $0x4,%esp
 156:	50                   	push   %eax
 157:	68 82 09 00 00       	push   $0x982
 15c:	6a 01                	push   $0x1
 15e:	e8 10 04 00 00       	call   573 <printf>
 163:	83 c4 10             	add    $0x10,%esp
  clearScreen();
 166:	e8 29 03 00 00       	call   494 <clearScreen>
  printf(1, "fuckheyhey:%d\n",getCuPos());
 16b:	e8 0c 03 00 00       	call   47c <getCuPos>
 170:	83 ec 04             	sub    $0x4,%esp
 173:	50                   	push   %eax
 174:	68 8c 09 00 00       	push   $0x98c
 179:	6a 01                	push   $0x1
 17b:	e8 f3 03 00 00       	call   573 <printf>
 180:	83 c4 10             	add    $0x10,%esp
  while (1)
  {
    
  }
 183:	eb fe                	jmp    183 <vim_gui+0x8b>

00000185 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
 188:	57                   	push   %edi
 189:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 18a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 18d:	8b 55 10             	mov    0x10(%ebp),%edx
 190:	8b 45 0c             	mov    0xc(%ebp),%eax
 193:	89 cb                	mov    %ecx,%ebx
 195:	89 df                	mov    %ebx,%edi
 197:	89 d1                	mov    %edx,%ecx
 199:	fc                   	cld    
 19a:	f3 aa                	rep stos %al,%es:(%edi)
 19c:	89 ca                	mov    %ecx,%edx
 19e:	89 fb                	mov    %edi,%ebx
 1a0:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1a3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1a6:	90                   	nop
 1a7:	5b                   	pop    %ebx
 1a8:	5f                   	pop    %edi
 1a9:	5d                   	pop    %ebp
 1aa:	c3                   	ret    

000001ab <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1ab:	55                   	push   %ebp
 1ac:	89 e5                	mov    %esp,%ebp
 1ae:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1b1:	8b 45 08             	mov    0x8(%ebp),%eax
 1b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1b7:	90                   	nop
 1b8:	8b 45 08             	mov    0x8(%ebp),%eax
 1bb:	8d 50 01             	lea    0x1(%eax),%edx
 1be:	89 55 08             	mov    %edx,0x8(%ebp)
 1c1:	8b 55 0c             	mov    0xc(%ebp),%edx
 1c4:	8d 4a 01             	lea    0x1(%edx),%ecx
 1c7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1ca:	0f b6 12             	movzbl (%edx),%edx
 1cd:	88 10                	mov    %dl,(%eax)
 1cf:	0f b6 00             	movzbl (%eax),%eax
 1d2:	84 c0                	test   %al,%al
 1d4:	75 e2                	jne    1b8 <strcpy+0xd>
    ;
  return os;
 1d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d9:	c9                   	leave  
 1da:	c3                   	ret    

000001db <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1db:	55                   	push   %ebp
 1dc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1de:	eb 08                	jmp    1e8 <strcmp+0xd>
    p++, q++;
 1e0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1e4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1e8:	8b 45 08             	mov    0x8(%ebp),%eax
 1eb:	0f b6 00             	movzbl (%eax),%eax
 1ee:	84 c0                	test   %al,%al
 1f0:	74 10                	je     202 <strcmp+0x27>
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	0f b6 10             	movzbl (%eax),%edx
 1f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fb:	0f b6 00             	movzbl (%eax),%eax
 1fe:	38 c2                	cmp    %al,%dl
 200:	74 de                	je     1e0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 202:	8b 45 08             	mov    0x8(%ebp),%eax
 205:	0f b6 00             	movzbl (%eax),%eax
 208:	0f b6 d0             	movzbl %al,%edx
 20b:	8b 45 0c             	mov    0xc(%ebp),%eax
 20e:	0f b6 00             	movzbl (%eax),%eax
 211:	0f b6 c0             	movzbl %al,%eax
 214:	29 c2                	sub    %eax,%edx
 216:	89 d0                	mov    %edx,%eax
}
 218:	5d                   	pop    %ebp
 219:	c3                   	ret    

0000021a <strlen>:

uint
strlen(char *s)
{
 21a:	55                   	push   %ebp
 21b:	89 e5                	mov    %esp,%ebp
 21d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 220:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 227:	eb 04                	jmp    22d <strlen+0x13>
 229:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 22d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 230:	8b 45 08             	mov    0x8(%ebp),%eax
 233:	01 d0                	add    %edx,%eax
 235:	0f b6 00             	movzbl (%eax),%eax
 238:	84 c0                	test   %al,%al
 23a:	75 ed                	jne    229 <strlen+0xf>
    ;
  return n;
 23c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 23f:	c9                   	leave  
 240:	c3                   	ret    

00000241 <memset>:

void*
memset(void *dst, int c, uint n)
{
 241:	55                   	push   %ebp
 242:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 244:	8b 45 10             	mov    0x10(%ebp),%eax
 247:	50                   	push   %eax
 248:	ff 75 0c             	pushl  0xc(%ebp)
 24b:	ff 75 08             	pushl  0x8(%ebp)
 24e:	e8 32 ff ff ff       	call   185 <stosb>
 253:	83 c4 0c             	add    $0xc,%esp
  return dst;
 256:	8b 45 08             	mov    0x8(%ebp),%eax
}
 259:	c9                   	leave  
 25a:	c3                   	ret    

0000025b <strchr>:

char*
strchr(const char *s, char c)
{
 25b:	55                   	push   %ebp
 25c:	89 e5                	mov    %esp,%ebp
 25e:	83 ec 04             	sub    $0x4,%esp
 261:	8b 45 0c             	mov    0xc(%ebp),%eax
 264:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 267:	eb 14                	jmp    27d <strchr+0x22>
    if(*s == c)
 269:	8b 45 08             	mov    0x8(%ebp),%eax
 26c:	0f b6 00             	movzbl (%eax),%eax
 26f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 272:	75 05                	jne    279 <strchr+0x1e>
      return (char*)s;
 274:	8b 45 08             	mov    0x8(%ebp),%eax
 277:	eb 13                	jmp    28c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 279:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	0f b6 00             	movzbl (%eax),%eax
 283:	84 c0                	test   %al,%al
 285:	75 e2                	jne    269 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 287:	b8 00 00 00 00       	mov    $0x0,%eax
}
 28c:	c9                   	leave  
 28d:	c3                   	ret    

0000028e <gets>:

char*
gets(char *buf, int max)
{
 28e:	55                   	push   %ebp
 28f:	89 e5                	mov    %esp,%ebp
 291:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 294:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 29b:	eb 42                	jmp    2df <gets+0x51>
    cc = read(0, &c, 1);
 29d:	83 ec 04             	sub    $0x4,%esp
 2a0:	6a 01                	push   $0x1
 2a2:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2a5:	50                   	push   %eax
 2a6:	6a 00                	push   $0x0
 2a8:	e8 47 01 00 00       	call   3f4 <read>
 2ad:	83 c4 10             	add    $0x10,%esp
 2b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2b7:	7e 33                	jle    2ec <gets+0x5e>
      break;
    buf[i++] = c;
 2b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2bc:	8d 50 01             	lea    0x1(%eax),%edx
 2bf:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2c2:	89 c2                	mov    %eax,%edx
 2c4:	8b 45 08             	mov    0x8(%ebp),%eax
 2c7:	01 c2                	add    %eax,%edx
 2c9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2cd:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2cf:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2d3:	3c 0a                	cmp    $0xa,%al
 2d5:	74 16                	je     2ed <gets+0x5f>
 2d7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2db:	3c 0d                	cmp    $0xd,%al
 2dd:	74 0e                	je     2ed <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e2:	83 c0 01             	add    $0x1,%eax
 2e5:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2e8:	7c b3                	jl     29d <gets+0xf>
 2ea:	eb 01                	jmp    2ed <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 2ec:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2f0:	8b 45 08             	mov    0x8(%ebp),%eax
 2f3:	01 d0                	add    %edx,%eax
 2f5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2fb:	c9                   	leave  
 2fc:	c3                   	ret    

000002fd <stat>:

int
stat(char *n, struct stat *st)
{
 2fd:	55                   	push   %ebp
 2fe:	89 e5                	mov    %esp,%ebp
 300:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 303:	83 ec 08             	sub    $0x8,%esp
 306:	6a 00                	push   $0x0
 308:	ff 75 08             	pushl  0x8(%ebp)
 30b:	e8 0c 01 00 00       	call   41c <open>
 310:	83 c4 10             	add    $0x10,%esp
 313:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 316:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 31a:	79 07                	jns    323 <stat+0x26>
    return -1;
 31c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 321:	eb 25                	jmp    348 <stat+0x4b>
  r = fstat(fd, st);
 323:	83 ec 08             	sub    $0x8,%esp
 326:	ff 75 0c             	pushl  0xc(%ebp)
 329:	ff 75 f4             	pushl  -0xc(%ebp)
 32c:	e8 03 01 00 00       	call   434 <fstat>
 331:	83 c4 10             	add    $0x10,%esp
 334:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 337:	83 ec 0c             	sub    $0xc,%esp
 33a:	ff 75 f4             	pushl  -0xc(%ebp)
 33d:	e8 c2 00 00 00       	call   404 <close>
 342:	83 c4 10             	add    $0x10,%esp
  return r;
 345:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 348:	c9                   	leave  
 349:	c3                   	ret    

0000034a <atoi>:

int
atoi(const char *s)
{
 34a:	55                   	push   %ebp
 34b:	89 e5                	mov    %esp,%ebp
 34d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 350:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 357:	eb 25                	jmp    37e <atoi+0x34>
    n = n*10 + *s++ - '0';
 359:	8b 55 fc             	mov    -0x4(%ebp),%edx
 35c:	89 d0                	mov    %edx,%eax
 35e:	c1 e0 02             	shl    $0x2,%eax
 361:	01 d0                	add    %edx,%eax
 363:	01 c0                	add    %eax,%eax
 365:	89 c1                	mov    %eax,%ecx
 367:	8b 45 08             	mov    0x8(%ebp),%eax
 36a:	8d 50 01             	lea    0x1(%eax),%edx
 36d:	89 55 08             	mov    %edx,0x8(%ebp)
 370:	0f b6 00             	movzbl (%eax),%eax
 373:	0f be c0             	movsbl %al,%eax
 376:	01 c8                	add    %ecx,%eax
 378:	83 e8 30             	sub    $0x30,%eax
 37b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 37e:	8b 45 08             	mov    0x8(%ebp),%eax
 381:	0f b6 00             	movzbl (%eax),%eax
 384:	3c 2f                	cmp    $0x2f,%al
 386:	7e 0a                	jle    392 <atoi+0x48>
 388:	8b 45 08             	mov    0x8(%ebp),%eax
 38b:	0f b6 00             	movzbl (%eax),%eax
 38e:	3c 39                	cmp    $0x39,%al
 390:	7e c7                	jle    359 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 392:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 395:	c9                   	leave  
 396:	c3                   	ret    

00000397 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 397:	55                   	push   %ebp
 398:	89 e5                	mov    %esp,%ebp
 39a:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 39d:	8b 45 08             	mov    0x8(%ebp),%eax
 3a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3a3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3a9:	eb 17                	jmp    3c2 <memmove+0x2b>
    *dst++ = *src++;
 3ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ae:	8d 50 01             	lea    0x1(%eax),%edx
 3b1:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3b4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3b7:	8d 4a 01             	lea    0x1(%edx),%ecx
 3ba:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3bd:	0f b6 12             	movzbl (%edx),%edx
 3c0:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3c2:	8b 45 10             	mov    0x10(%ebp),%eax
 3c5:	8d 50 ff             	lea    -0x1(%eax),%edx
 3c8:	89 55 10             	mov    %edx,0x10(%ebp)
 3cb:	85 c0                	test   %eax,%eax
 3cd:	7f dc                	jg     3ab <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3d2:	c9                   	leave  
 3d3:	c3                   	ret    

000003d4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3d4:	b8 01 00 00 00       	mov    $0x1,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <exit>:
SYSCALL(exit)
 3dc:	b8 02 00 00 00       	mov    $0x2,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <wait>:
SYSCALL(wait)
 3e4:	b8 03 00 00 00       	mov    $0x3,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <pipe>:
SYSCALL(pipe)
 3ec:	b8 04 00 00 00       	mov    $0x4,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <read>:
SYSCALL(read)
 3f4:	b8 05 00 00 00       	mov    $0x5,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <write>:
SYSCALL(write)
 3fc:	b8 10 00 00 00       	mov    $0x10,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <close>:
SYSCALL(close)
 404:	b8 15 00 00 00       	mov    $0x15,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <kill>:
SYSCALL(kill)
 40c:	b8 06 00 00 00       	mov    $0x6,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <exec>:
SYSCALL(exec)
 414:	b8 07 00 00 00       	mov    $0x7,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <open>:
SYSCALL(open)
 41c:	b8 0f 00 00 00       	mov    $0xf,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <mknod>:
SYSCALL(mknod)
 424:	b8 11 00 00 00       	mov    $0x11,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <unlink>:
SYSCALL(unlink)
 42c:	b8 12 00 00 00       	mov    $0x12,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <fstat>:
SYSCALL(fstat)
 434:	b8 08 00 00 00       	mov    $0x8,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <link>:
SYSCALL(link)
 43c:	b8 13 00 00 00       	mov    $0x13,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <mkdir>:
SYSCALL(mkdir)
 444:	b8 14 00 00 00       	mov    $0x14,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <chdir>:
SYSCALL(chdir)
 44c:	b8 09 00 00 00       	mov    $0x9,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <dup>:
SYSCALL(dup)
 454:	b8 0a 00 00 00       	mov    $0xa,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <getpid>:
SYSCALL(getpid)
 45c:	b8 0b 00 00 00       	mov    $0xb,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <sbrk>:
SYSCALL(sbrk)
 464:	b8 0c 00 00 00       	mov    $0xc,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <sleep>:
SYSCALL(sleep)
 46c:	b8 0d 00 00 00       	mov    $0xd,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <uptime>:
SYSCALL(uptime)
 474:	b8 0e 00 00 00       	mov    $0xe,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <getCuPos>:
SYSCALL(getCuPos)
 47c:	b8 16 00 00 00       	mov    $0x16,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <setCuPos>:
SYSCALL(setCuPos)
 484:	b8 17 00 00 00       	mov    $0x17,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <getSnapshot>:
SYSCALL(getSnapshot)
 48c:	b8 18 00 00 00       	mov    $0x18,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <clearScreen>:
 494:	b8 19 00 00 00       	mov    $0x19,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 49c:	55                   	push   %ebp
 49d:	89 e5                	mov    %esp,%ebp
 49f:	83 ec 18             	sub    $0x18,%esp
 4a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4a8:	83 ec 04             	sub    $0x4,%esp
 4ab:	6a 01                	push   $0x1
 4ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4b0:	50                   	push   %eax
 4b1:	ff 75 08             	pushl  0x8(%ebp)
 4b4:	e8 43 ff ff ff       	call   3fc <write>
 4b9:	83 c4 10             	add    $0x10,%esp
}
 4bc:	90                   	nop
 4bd:	c9                   	leave  
 4be:	c3                   	ret    

000004bf <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4bf:	55                   	push   %ebp
 4c0:	89 e5                	mov    %esp,%ebp
 4c2:	53                   	push   %ebx
 4c3:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4cd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4d1:	74 17                	je     4ea <printint+0x2b>
 4d3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4d7:	79 11                	jns    4ea <printint+0x2b>
    neg = 1;
 4d9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4e0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e3:	f7 d8                	neg    %eax
 4e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e8:	eb 06                	jmp    4f0 <printint+0x31>
  } else {
    x = xx;
 4ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4f7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4fa:	8d 41 01             	lea    0x1(%ecx),%eax
 4fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
 500:	8b 5d 10             	mov    0x10(%ebp),%ebx
 503:	8b 45 ec             	mov    -0x14(%ebp),%eax
 506:	ba 00 00 00 00       	mov    $0x0,%edx
 50b:	f7 f3                	div    %ebx
 50d:	89 d0                	mov    %edx,%eax
 50f:	0f b6 80 2c 0c 00 00 	movzbl 0xc2c(%eax),%eax
 516:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 51a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 51d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 520:	ba 00 00 00 00       	mov    $0x0,%edx
 525:	f7 f3                	div    %ebx
 527:	89 45 ec             	mov    %eax,-0x14(%ebp)
 52a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 52e:	75 c7                	jne    4f7 <printint+0x38>
  if(neg)
 530:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 534:	74 2d                	je     563 <printint+0xa4>
    buf[i++] = '-';
 536:	8b 45 f4             	mov    -0xc(%ebp),%eax
 539:	8d 50 01             	lea    0x1(%eax),%edx
 53c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 53f:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 544:	eb 1d                	jmp    563 <printint+0xa4>
    putc(fd, buf[i]);
 546:	8d 55 dc             	lea    -0x24(%ebp),%edx
 549:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54c:	01 d0                	add    %edx,%eax
 54e:	0f b6 00             	movzbl (%eax),%eax
 551:	0f be c0             	movsbl %al,%eax
 554:	83 ec 08             	sub    $0x8,%esp
 557:	50                   	push   %eax
 558:	ff 75 08             	pushl  0x8(%ebp)
 55b:	e8 3c ff ff ff       	call   49c <putc>
 560:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 563:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 567:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 56b:	79 d9                	jns    546 <printint+0x87>
    putc(fd, buf[i]);
}
 56d:	90                   	nop
 56e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 571:	c9                   	leave  
 572:	c3                   	ret    

00000573 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 573:	55                   	push   %ebp
 574:	89 e5                	mov    %esp,%ebp
 576:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 579:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 580:	8d 45 0c             	lea    0xc(%ebp),%eax
 583:	83 c0 04             	add    $0x4,%eax
 586:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 589:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 590:	e9 59 01 00 00       	jmp    6ee <printf+0x17b>
    c = fmt[i] & 0xff;
 595:	8b 55 0c             	mov    0xc(%ebp),%edx
 598:	8b 45 f0             	mov    -0x10(%ebp),%eax
 59b:	01 d0                	add    %edx,%eax
 59d:	0f b6 00             	movzbl (%eax),%eax
 5a0:	0f be c0             	movsbl %al,%eax
 5a3:	25 ff 00 00 00       	and    $0xff,%eax
 5a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5af:	75 2c                	jne    5dd <printf+0x6a>
      if(c == '%'){
 5b1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5b5:	75 0c                	jne    5c3 <printf+0x50>
        state = '%';
 5b7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5be:	e9 27 01 00 00       	jmp    6ea <printf+0x177>
      } else {
        putc(fd, c);
 5c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c6:	0f be c0             	movsbl %al,%eax
 5c9:	83 ec 08             	sub    $0x8,%esp
 5cc:	50                   	push   %eax
 5cd:	ff 75 08             	pushl  0x8(%ebp)
 5d0:	e8 c7 fe ff ff       	call   49c <putc>
 5d5:	83 c4 10             	add    $0x10,%esp
 5d8:	e9 0d 01 00 00       	jmp    6ea <printf+0x177>
      }
    } else if(state == '%'){
 5dd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5e1:	0f 85 03 01 00 00    	jne    6ea <printf+0x177>
      if(c == 'd'){
 5e7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5eb:	75 1e                	jne    60b <printf+0x98>
        printint(fd, *ap, 10, 1);
 5ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f0:	8b 00                	mov    (%eax),%eax
 5f2:	6a 01                	push   $0x1
 5f4:	6a 0a                	push   $0xa
 5f6:	50                   	push   %eax
 5f7:	ff 75 08             	pushl  0x8(%ebp)
 5fa:	e8 c0 fe ff ff       	call   4bf <printint>
 5ff:	83 c4 10             	add    $0x10,%esp
        ap++;
 602:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 606:	e9 d8 00 00 00       	jmp    6e3 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 60b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 60f:	74 06                	je     617 <printf+0xa4>
 611:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 615:	75 1e                	jne    635 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 617:	8b 45 e8             	mov    -0x18(%ebp),%eax
 61a:	8b 00                	mov    (%eax),%eax
 61c:	6a 00                	push   $0x0
 61e:	6a 10                	push   $0x10
 620:	50                   	push   %eax
 621:	ff 75 08             	pushl  0x8(%ebp)
 624:	e8 96 fe ff ff       	call   4bf <printint>
 629:	83 c4 10             	add    $0x10,%esp
        ap++;
 62c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 630:	e9 ae 00 00 00       	jmp    6e3 <printf+0x170>
      } else if(c == 's'){
 635:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 639:	75 43                	jne    67e <printf+0x10b>
        s = (char*)*ap;
 63b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 63e:	8b 00                	mov    (%eax),%eax
 640:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 643:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 647:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 64b:	75 25                	jne    672 <printf+0xff>
          s = "(null)";
 64d:	c7 45 f4 9b 09 00 00 	movl   $0x99b,-0xc(%ebp)
        while(*s != 0){
 654:	eb 1c                	jmp    672 <printf+0xff>
          putc(fd, *s);
 656:	8b 45 f4             	mov    -0xc(%ebp),%eax
 659:	0f b6 00             	movzbl (%eax),%eax
 65c:	0f be c0             	movsbl %al,%eax
 65f:	83 ec 08             	sub    $0x8,%esp
 662:	50                   	push   %eax
 663:	ff 75 08             	pushl  0x8(%ebp)
 666:	e8 31 fe ff ff       	call   49c <putc>
 66b:	83 c4 10             	add    $0x10,%esp
          s++;
 66e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 672:	8b 45 f4             	mov    -0xc(%ebp),%eax
 675:	0f b6 00             	movzbl (%eax),%eax
 678:	84 c0                	test   %al,%al
 67a:	75 da                	jne    656 <printf+0xe3>
 67c:	eb 65                	jmp    6e3 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 67e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 682:	75 1d                	jne    6a1 <printf+0x12e>
        putc(fd, *ap);
 684:	8b 45 e8             	mov    -0x18(%ebp),%eax
 687:	8b 00                	mov    (%eax),%eax
 689:	0f be c0             	movsbl %al,%eax
 68c:	83 ec 08             	sub    $0x8,%esp
 68f:	50                   	push   %eax
 690:	ff 75 08             	pushl  0x8(%ebp)
 693:	e8 04 fe ff ff       	call   49c <putc>
 698:	83 c4 10             	add    $0x10,%esp
        ap++;
 69b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 69f:	eb 42                	jmp    6e3 <printf+0x170>
      } else if(c == '%'){
 6a1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6a5:	75 17                	jne    6be <printf+0x14b>
        putc(fd, c);
 6a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6aa:	0f be c0             	movsbl %al,%eax
 6ad:	83 ec 08             	sub    $0x8,%esp
 6b0:	50                   	push   %eax
 6b1:	ff 75 08             	pushl  0x8(%ebp)
 6b4:	e8 e3 fd ff ff       	call   49c <putc>
 6b9:	83 c4 10             	add    $0x10,%esp
 6bc:	eb 25                	jmp    6e3 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6be:	83 ec 08             	sub    $0x8,%esp
 6c1:	6a 25                	push   $0x25
 6c3:	ff 75 08             	pushl  0x8(%ebp)
 6c6:	e8 d1 fd ff ff       	call   49c <putc>
 6cb:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6d1:	0f be c0             	movsbl %al,%eax
 6d4:	83 ec 08             	sub    $0x8,%esp
 6d7:	50                   	push   %eax
 6d8:	ff 75 08             	pushl  0x8(%ebp)
 6db:	e8 bc fd ff ff       	call   49c <putc>
 6e0:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6ea:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6ee:	8b 55 0c             	mov    0xc(%ebp),%edx
 6f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f4:	01 d0                	add    %edx,%eax
 6f6:	0f b6 00             	movzbl (%eax),%eax
 6f9:	84 c0                	test   %al,%al
 6fb:	0f 85 94 fe ff ff    	jne    595 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 701:	90                   	nop
 702:	c9                   	leave  
 703:	c3                   	ret    

00000704 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 704:	55                   	push   %ebp
 705:	89 e5                	mov    %esp,%ebp
 707:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 70a:	8b 45 08             	mov    0x8(%ebp),%eax
 70d:	83 e8 08             	sub    $0x8,%eax
 710:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 713:	a1 48 0c 00 00       	mov    0xc48,%eax
 718:	89 45 fc             	mov    %eax,-0x4(%ebp)
 71b:	eb 24                	jmp    741 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 71d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 720:	8b 00                	mov    (%eax),%eax
 722:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 725:	77 12                	ja     739 <free+0x35>
 727:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 72d:	77 24                	ja     753 <free+0x4f>
 72f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 732:	8b 00                	mov    (%eax),%eax
 734:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 737:	77 1a                	ja     753 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 739:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73c:	8b 00                	mov    (%eax),%eax
 73e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 741:	8b 45 f8             	mov    -0x8(%ebp),%eax
 744:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 747:	76 d4                	jbe    71d <free+0x19>
 749:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74c:	8b 00                	mov    (%eax),%eax
 74e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 751:	76 ca                	jbe    71d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 753:	8b 45 f8             	mov    -0x8(%ebp),%eax
 756:	8b 40 04             	mov    0x4(%eax),%eax
 759:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 760:	8b 45 f8             	mov    -0x8(%ebp),%eax
 763:	01 c2                	add    %eax,%edx
 765:	8b 45 fc             	mov    -0x4(%ebp),%eax
 768:	8b 00                	mov    (%eax),%eax
 76a:	39 c2                	cmp    %eax,%edx
 76c:	75 24                	jne    792 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 76e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 771:	8b 50 04             	mov    0x4(%eax),%edx
 774:	8b 45 fc             	mov    -0x4(%ebp),%eax
 777:	8b 00                	mov    (%eax),%eax
 779:	8b 40 04             	mov    0x4(%eax),%eax
 77c:	01 c2                	add    %eax,%edx
 77e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 781:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 784:	8b 45 fc             	mov    -0x4(%ebp),%eax
 787:	8b 00                	mov    (%eax),%eax
 789:	8b 10                	mov    (%eax),%edx
 78b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78e:	89 10                	mov    %edx,(%eax)
 790:	eb 0a                	jmp    79c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 792:	8b 45 fc             	mov    -0x4(%ebp),%eax
 795:	8b 10                	mov    (%eax),%edx
 797:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 79c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79f:	8b 40 04             	mov    0x4(%eax),%eax
 7a2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ac:	01 d0                	add    %edx,%eax
 7ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7b1:	75 20                	jne    7d3 <free+0xcf>
    p->s.size += bp->s.size;
 7b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b6:	8b 50 04             	mov    0x4(%eax),%edx
 7b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bc:	8b 40 04             	mov    0x4(%eax),%eax
 7bf:	01 c2                	add    %eax,%edx
 7c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ca:	8b 10                	mov    (%eax),%edx
 7cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cf:	89 10                	mov    %edx,(%eax)
 7d1:	eb 08                	jmp    7db <free+0xd7>
  } else
    p->s.ptr = bp;
 7d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7d9:	89 10                	mov    %edx,(%eax)
  freep = p;
 7db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7de:	a3 48 0c 00 00       	mov    %eax,0xc48
}
 7e3:	90                   	nop
 7e4:	c9                   	leave  
 7e5:	c3                   	ret    

000007e6 <morecore>:

static Header*
morecore(uint nu)
{
 7e6:	55                   	push   %ebp
 7e7:	89 e5                	mov    %esp,%ebp
 7e9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7ec:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7f3:	77 07                	ja     7fc <morecore+0x16>
    nu = 4096;
 7f5:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7fc:	8b 45 08             	mov    0x8(%ebp),%eax
 7ff:	c1 e0 03             	shl    $0x3,%eax
 802:	83 ec 0c             	sub    $0xc,%esp
 805:	50                   	push   %eax
 806:	e8 59 fc ff ff       	call   464 <sbrk>
 80b:	83 c4 10             	add    $0x10,%esp
 80e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 811:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 815:	75 07                	jne    81e <morecore+0x38>
    return 0;
 817:	b8 00 00 00 00       	mov    $0x0,%eax
 81c:	eb 26                	jmp    844 <morecore+0x5e>
  hp = (Header*)p;
 81e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 821:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 824:	8b 45 f0             	mov    -0x10(%ebp),%eax
 827:	8b 55 08             	mov    0x8(%ebp),%edx
 82a:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 82d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 830:	83 c0 08             	add    $0x8,%eax
 833:	83 ec 0c             	sub    $0xc,%esp
 836:	50                   	push   %eax
 837:	e8 c8 fe ff ff       	call   704 <free>
 83c:	83 c4 10             	add    $0x10,%esp
  return freep;
 83f:	a1 48 0c 00 00       	mov    0xc48,%eax
}
 844:	c9                   	leave  
 845:	c3                   	ret    

00000846 <malloc>:

void*
malloc(uint nbytes)
{
 846:	55                   	push   %ebp
 847:	89 e5                	mov    %esp,%ebp
 849:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 84c:	8b 45 08             	mov    0x8(%ebp),%eax
 84f:	83 c0 07             	add    $0x7,%eax
 852:	c1 e8 03             	shr    $0x3,%eax
 855:	83 c0 01             	add    $0x1,%eax
 858:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 85b:	a1 48 0c 00 00       	mov    0xc48,%eax
 860:	89 45 f0             	mov    %eax,-0x10(%ebp)
 863:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 867:	75 23                	jne    88c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 869:	c7 45 f0 40 0c 00 00 	movl   $0xc40,-0x10(%ebp)
 870:	8b 45 f0             	mov    -0x10(%ebp),%eax
 873:	a3 48 0c 00 00       	mov    %eax,0xc48
 878:	a1 48 0c 00 00       	mov    0xc48,%eax
 87d:	a3 40 0c 00 00       	mov    %eax,0xc40
    base.s.size = 0;
 882:	c7 05 44 0c 00 00 00 	movl   $0x0,0xc44
 889:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88f:	8b 00                	mov    (%eax),%eax
 891:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 894:	8b 45 f4             	mov    -0xc(%ebp),%eax
 897:	8b 40 04             	mov    0x4(%eax),%eax
 89a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 89d:	72 4d                	jb     8ec <malloc+0xa6>
      if(p->s.size == nunits)
 89f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a2:	8b 40 04             	mov    0x4(%eax),%eax
 8a5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8a8:	75 0c                	jne    8b6 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ad:	8b 10                	mov    (%eax),%edx
 8af:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b2:	89 10                	mov    %edx,(%eax)
 8b4:	eb 26                	jmp    8dc <malloc+0x96>
      else {
        p->s.size -= nunits;
 8b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b9:	8b 40 04             	mov    0x4(%eax),%eax
 8bc:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8bf:	89 c2                	mov    %eax,%edx
 8c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c4:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ca:	8b 40 04             	mov    0x4(%eax),%eax
 8cd:	c1 e0 03             	shl    $0x3,%eax
 8d0:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8d9:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8df:	a3 48 0c 00 00       	mov    %eax,0xc48
      return (void*)(p + 1);
 8e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e7:	83 c0 08             	add    $0x8,%eax
 8ea:	eb 3b                	jmp    927 <malloc+0xe1>
    }
    if(p == freep)
 8ec:	a1 48 0c 00 00       	mov    0xc48,%eax
 8f1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8f4:	75 1e                	jne    914 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8f6:	83 ec 0c             	sub    $0xc,%esp
 8f9:	ff 75 ec             	pushl  -0x14(%ebp)
 8fc:	e8 e5 fe ff ff       	call   7e6 <morecore>
 901:	83 c4 10             	add    $0x10,%esp
 904:	89 45 f4             	mov    %eax,-0xc(%ebp)
 907:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 90b:	75 07                	jne    914 <malloc+0xce>
        return 0;
 90d:	b8 00 00 00 00       	mov    $0x0,%eax
 912:	eb 13                	jmp    927 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 914:	8b 45 f4             	mov    -0xc(%ebp),%eax
 917:	89 45 f0             	mov    %eax,-0x10(%ebp)
 91a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91d:	8b 00                	mov    (%eax),%eax
 91f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 922:	e9 6d ff ff ff       	jmp    894 <malloc+0x4e>
}
 927:	c9                   	leave  
 928:	c3                   	ret    
