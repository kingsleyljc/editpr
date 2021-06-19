
_editor：     文件格式 elf32-i386


Disassembly of section .text:

00000000 <main>:
//标记是否更改过
int changed = 0;
int auto_show = 1;

int main(int argc, char *argv[])
{
       0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
       4:	83 e4 f0             	and    $0xfffffff0,%esp
       7:	ff 71 fc             	pushl  -0x4(%ecx)
       a:	55                   	push   %ebp
       b:	89 e5                	mov    %esp,%ebp
       d:	57                   	push   %edi
       e:	56                   	push   %esi
       f:	53                   	push   %ebx
      10:	51                   	push   %ecx
      11:	81 ec 38 06 00 00    	sub    $0x638,%esp
      17:	89 cb                	mov    %ecx,%ebx
	if (argc == 1)
      19:	83 3b 01             	cmpl   $0x1,(%ebx)
      1c:	75 17                	jne    35 <main+0x35>
	{
		printf(1, "please input the command as [editor file_name]\n");
      1e:	83 ec 08             	sub    $0x8,%esp
      21:	68 6c 1a 00 00       	push   $0x1a6c
      26:	6a 01                	push   $0x1
      28:	e8 89 16 00 00       	call   16b6 <printf>
      2d:	83 c4 10             	add    $0x10,%esp
		exit();
      30:	e8 ea 14 00 00       	call   151f <exit>
	}
	//存放文件内容
	
	char *text[MAX_LINE_NUMBER] = {};
      35:	8d 95 c4 fb ff ff    	lea    -0x43c(%ebp),%edx
      3b:	b8 00 00 00 00       	mov    $0x0,%eax
      40:	b9 00 01 00 00       	mov    $0x100,%ecx
      45:	89 d7                	mov    %edx,%edi
      47:	f3 ab                	rep stos %eax,%es:(%edi)
	text[0] = malloc(MAX_LINE_LENGTH);
      49:	83 ec 0c             	sub    $0xc,%esp
      4c:	68 00 01 00 00       	push   $0x100
      51:	e8 33 19 00 00       	call   1989 <malloc>
      56:	83 c4 10             	add    $0x10,%esp
      59:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
	memset(text[0], 0, MAX_LINE_LENGTH);
      5f:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
      65:	83 ec 04             	sub    $0x4,%esp
      68:	68 00 01 00 00       	push   $0x100
      6d:	6a 00                	push   $0x0
      6f:	50                   	push   %eax
      70:	e8 0f 13 00 00       	call   1384 <memset>
      75:	83 c4 10             	add    $0x10,%esp
	//存储当前最大的行号，从0开始。即若line_number == x，则从text[0]到text[x]可用
	int line_number = 0;
      78:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	//尝试打开文件
	int fd = open(argv[1], O_RDONLY);
      7f:	8b 43 04             	mov    0x4(%ebx),%eax
      82:	83 c0 04             	add    $0x4,%eax
      85:	8b 00                	mov    (%eax),%eax
      87:	83 ec 08             	sub    $0x8,%esp
      8a:	6a 00                	push   $0x0
      8c:	50                   	push   %eax
      8d:	e8 cd 14 00 00       	call   155f <open>
      92:	83 c4 10             	add    $0x10,%esp
      95:	89 45 cc             	mov    %eax,-0x34(%ebp)
	//如果文件存在，则打开并读取里面的内容
	if (fd != -1)
      98:	83 7d cc ff          	cmpl   $0xffffffff,-0x34(%ebp)
      9c:	0f 84 a4 01 00 00    	je     246 <main+0x246>
	{
		printf(1, "file exist\n");
      a2:	83 ec 08             	sub    $0x8,%esp
      a5:	68 9c 1a 00 00       	push   $0x1a9c
      aa:	6a 01                	push   $0x1
      ac:	e8 05 16 00 00       	call   16b6 <printf>
      b1:	83 c4 10             	add    $0x10,%esp
		char buf[BUF_SIZE] = {};
      b4:	8d 95 c4 f9 ff ff    	lea    -0x63c(%ebp),%edx
      ba:	b8 00 00 00 00       	mov    $0x0,%eax
      bf:	b9 40 00 00 00       	mov    $0x40,%ecx
      c4:	89 d7                	mov    %edx,%edi
      c6:	f3 ab                	rep stos %eax,%es:(%edi)
		int len = 0;
      c8:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
		while ((len = read(fd, buf, BUF_SIZE)) > 0)
      cf:	e9 00 01 00 00       	jmp    1d4 <main+0x1d4>
		{
			int i = 0;
      d4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			int next = 0;
      db:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
			int is_full = 0;
      e2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
			while (i < len)
      e9:	e9 d4 00 00 00       	jmp    1c2 <main+0x1c2>
			{
				//拷贝"\n"之前的内容
				for (i = next; i < len && buf[i] != '\n'; i++)
      ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
      f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
      f4:	eb 04                	jmp    fa <main+0xfa>
      f6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
      fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
      fd:	3b 45 c8             	cmp    -0x38(%ebp),%eax
     100:	7d 12                	jge    114 <main+0x114>
     102:	8d 95 c4 f9 ff ff    	lea    -0x63c(%ebp),%edx
     108:	8b 45 e0             	mov    -0x20(%ebp),%eax
     10b:	01 d0                	add    %edx,%eax
     10d:	0f b6 00             	movzbl (%eax),%eax
     110:	3c 0a                	cmp    $0xa,%al
     112:	75 e2                	jne    f6 <main+0xf6>
					;
				strcat_n(text[line_number], buf+next, i-next);
     114:	8b 45 e0             	mov    -0x20(%ebp),%eax
     117:	2b 45 dc             	sub    -0x24(%ebp),%eax
     11a:	89 c2                	mov    %eax,%edx
     11c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     11f:	8d 8d c4 f9 ff ff    	lea    -0x63c(%ebp),%ecx
     125:	01 c1                	add    %eax,%ecx
     127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     12a:	8b 84 85 c4 fb ff ff 	mov    -0x43c(%ebp,%eax,4),%eax
     131:	83 ec 04             	sub    $0x4,%esp
     134:	52                   	push   %edx
     135:	51                   	push   %ecx
     136:	50                   	push   %eax
     137:	e8 2c 06 00 00       	call   768 <strcat_n>
     13c:	83 c4 10             	add    $0x10,%esp
				//必要时新建一行
				if (i < len && buf[i] == '\n')
     13f:	8b 45 e0             	mov    -0x20(%ebp),%eax
     142:	3b 45 c8             	cmp    -0x38(%ebp),%eax
     145:	7d 61                	jge    1a8 <main+0x1a8>
     147:	8d 95 c4 f9 ff ff    	lea    -0x63c(%ebp),%edx
     14d:	8b 45 e0             	mov    -0x20(%ebp),%eax
     150:	01 d0                	add    %edx,%eax
     152:	0f b6 00             	movzbl (%eax),%eax
     155:	3c 0a                	cmp    $0xa,%al
     157:	75 4f                	jne    1a8 <main+0x1a8>
				{
					if (line_number >= MAX_LINE_NUMBER - 1)
     159:	81 7d e4 fe 00 00 00 	cmpl   $0xfe,-0x1c(%ebp)
     160:	7e 09                	jle    16b <main+0x16b>
						is_full = 1;
     162:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
     169:	eb 3d                	jmp    1a8 <main+0x1a8>
					else
					{
						line_number++;
     16b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
						text[line_number] = malloc(MAX_LINE_LENGTH);
     16f:	83 ec 0c             	sub    $0xc,%esp
     172:	68 00 01 00 00       	push   $0x100
     177:	e8 0d 18 00 00       	call   1989 <malloc>
     17c:	83 c4 10             	add    $0x10,%esp
     17f:	89 c2                	mov    %eax,%edx
     181:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     184:	89 94 85 c4 fb ff ff 	mov    %edx,-0x43c(%ebp,%eax,4)
						memset(text[line_number], 0, MAX_LINE_LENGTH);
     18b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     18e:	8b 84 85 c4 fb ff ff 	mov    -0x43c(%ebp,%eax,4),%eax
     195:	83 ec 04             	sub    $0x4,%esp
     198:	68 00 01 00 00       	push   $0x100
     19d:	6a 00                	push   $0x0
     19f:	50                   	push   %eax
     1a0:	e8 df 11 00 00       	call   1384 <memset>
     1a5:	83 c4 10             	add    $0x10,%esp
					}
				}
				if (is_full == 1 || i >= len - 1)
     1a8:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
     1ac:	74 20                	je     1ce <main+0x1ce>
     1ae:	8b 45 c8             	mov    -0x38(%ebp),%eax
     1b1:	83 e8 01             	sub    $0x1,%eax
     1b4:	3b 45 e0             	cmp    -0x20(%ebp),%eax
     1b7:	7e 15                	jle    1ce <main+0x1ce>
					break;
				else
					next = i + 1;
     1b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1bc:	83 c0 01             	add    $0x1,%eax
     1bf:	89 45 dc             	mov    %eax,-0x24(%ebp)
		while ((len = read(fd, buf, BUF_SIZE)) > 0)
		{
			int i = 0;
			int next = 0;
			int is_full = 0;
			while (i < len)
     1c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1c5:	3b 45 c8             	cmp    -0x38(%ebp),%eax
     1c8:	0f 8c 20 ff ff ff    	jl     ee <main+0xee>
				if (is_full == 1 || i >= len - 1)
					break;
				else
					next = i + 1;
			}
			if (is_full == 1)
     1ce:	83 7d d8 01          	cmpl   $0x1,-0x28(%ebp)
     1d2:	74 29                	je     1fd <main+0x1fd>
	if (fd != -1)
	{
		printf(1, "file exist\n");
		char buf[BUF_SIZE] = {};
		int len = 0;
		while ((len = read(fd, buf, BUF_SIZE)) > 0)
     1d4:	83 ec 04             	sub    $0x4,%esp
     1d7:	68 00 01 00 00       	push   $0x100
     1dc:	8d 85 c4 f9 ff ff    	lea    -0x63c(%ebp),%eax
     1e2:	50                   	push   %eax
     1e3:	ff 75 cc             	pushl  -0x34(%ebp)
     1e6:	e8 4c 13 00 00       	call   1537 <read>
     1eb:	83 c4 10             	add    $0x10,%esp
     1ee:	89 45 c8             	mov    %eax,-0x38(%ebp)
     1f1:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
     1f5:	0f 8f d9 fe ff ff    	jg     d4 <main+0xd4>
     1fb:	eb 01                	jmp    1fe <main+0x1fe>
					break;
				else
					next = i + 1;
			}
			if (is_full == 1)
				break;
     1fd:	90                   	nop
		}
		close(fd);
     1fe:	83 ec 0c             	sub    $0xc,%esp
     201:	ff 75 cc             	pushl  -0x34(%ebp)
     204:	e8 3e 13 00 00       	call   1547 <close>
     209:	83 c4 10             	add    $0x10,%esp
		printf(1,"File do not exist\n");
		exit();
	}
	
	//输出文件内容
	show_text(text);
     20c:	83 ec 0c             	sub    $0xc,%esp
     20f:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     215:	50                   	push   %eax
     216:	e8 cb 05 00 00       	call   7e6 <show_text>
     21b:	83 c4 10             	add    $0x10,%esp
	//输出帮助
	com_help(text);
     21e:	83 ec 0c             	sub    $0xc,%esp
     221:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     227:	50                   	push   %eax
     228:	e8 5f 0d 00 00       	call   f8c <com_help>
     22d:	83 c4 10             	add    $0x10,%esp
	
	//处理命令
	char input[MAX_LINE_LENGTH] = {};
     230:	8d 95 c4 fa ff ff    	lea    -0x53c(%ebp),%edx
     236:	b8 00 00 00 00       	mov    $0x0,%eax
     23b:	b9 40 00 00 00       	mov    $0x40,%ecx
     240:	89 d7                	mov    %edx,%edi
     242:	f3 ab                	rep stos %eax,%es:(%edi)
     244:	eb 17                	jmp    25d <main+0x25d>
			if (is_full == 1)
				break;
		}
		close(fd);
	} else{
		printf(1,"File do not exist\n");
     246:	83 ec 08             	sub    $0x8,%esp
     249:	68 a8 1a 00 00       	push   $0x1aa8
     24e:	6a 01                	push   $0x1
     250:	e8 61 14 00 00       	call   16b6 <printf>
     255:	83 c4 10             	add    $0x10,%esp
		exit();
     258:	e8 c2 12 00 00       	call   151f <exit>
	
	//处理命令
	char input[MAX_LINE_LENGTH] = {};
	while (1)
	{
		printf(1, "\nplease input command:\n");
     25d:	83 ec 08             	sub    $0x8,%esp
     260:	68 bb 1a 00 00       	push   $0x1abb
     265:	6a 01                	push   $0x1
     267:	e8 4a 14 00 00       	call   16b6 <printf>
     26c:	83 c4 10             	add    $0x10,%esp
		memset(input, 0, MAX_LINE_LENGTH);
     26f:	83 ec 04             	sub    $0x4,%esp
     272:	68 00 01 00 00       	push   $0x100
     277:	6a 00                	push   $0x0
     279:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     27f:	50                   	push   %eax
     280:	e8 ff 10 00 00       	call   1384 <memset>
     285:	83 c4 10             	add    $0x10,%esp
		gets(input, MAX_LINE_LENGTH);
     288:	83 ec 08             	sub    $0x8,%esp
     28b:	68 00 01 00 00       	push   $0x100
     290:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     296:	50                   	push   %eax
     297:	e8 35 11 00 00       	call   13d1 <gets>
     29c:	83 c4 10             	add    $0x10,%esp
		int len = strlen(input);
     29f:	83 ec 0c             	sub    $0xc,%esp
     2a2:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     2a8:	50                   	push   %eax
     2a9:	e8 af 10 00 00       	call   135d <strlen>
     2ae:	83 c4 10             	add    $0x10,%esp
     2b1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		input[len-1] = '\0';
     2b4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     2b7:	83 e8 01             	sub    $0x1,%eax
     2ba:	c6 84 05 c4 fa ff ff 	movb   $0x0,-0x53c(%ebp,%eax,1)
     2c1:	00 
		len --;
     2c2:	83 6d c4 01          	subl   $0x1,-0x3c(%ebp)
		//寻找命令中第一个空格
		int pos = MAX_LINE_LENGTH - 1;
     2c6:	c7 45 d4 ff 00 00 00 	movl   $0xff,-0x2c(%ebp)
		int j = 0;
     2cd:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		for (; j < 8; j++)
     2d4:	eb 21                	jmp    2f7 <main+0x2f7>
		{
			if (input[j] == ' ')
     2d6:	8d 95 c4 fa ff ff    	lea    -0x53c(%ebp),%edx
     2dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
     2df:	01 d0                	add    %edx,%eax
     2e1:	0f b6 00             	movzbl (%eax),%eax
     2e4:	3c 20                	cmp    $0x20,%al
     2e6:	75 0b                	jne    2f3 <main+0x2f3>
			{
				pos = j + 1;
     2e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
     2eb:	83 c0 01             	add    $0x1,%eax
     2ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				break;
     2f1:	eb 0a                	jmp    2fd <main+0x2fd>
		input[len-1] = '\0';
		len --;
		//寻找命令中第一个空格
		int pos = MAX_LINE_LENGTH - 1;
		int j = 0;
		for (; j < 8; j++)
     2f3:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
     2f7:	83 7d d0 07          	cmpl   $0x7,-0x30(%ebp)
     2fb:	7e d9                	jle    2d6 <main+0x2d6>
				pos = j + 1;
				break;
			}
		}
		//ins
		if (input[0] == 'i' && input[1] == 'n' && input[2] == 's')
     2fd:	0f b6 85 c4 fa ff ff 	movzbl -0x53c(%ebp),%eax
     304:	3c 69                	cmp    $0x69,%al
     306:	0f 85 0e 01 00 00    	jne    41a <main+0x41a>
     30c:	0f b6 85 c5 fa ff ff 	movzbl -0x53b(%ebp),%eax
     313:	3c 6e                	cmp    $0x6e,%al
     315:	0f 85 ff 00 00 00    	jne    41a <main+0x41a>
     31b:	0f b6 85 c6 fa ff ff 	movzbl -0x53a(%ebp),%eax
     322:	3c 73                	cmp    $0x73,%al
     324:	0f 85 f0 00 00 00    	jne    41a <main+0x41a>
		{
			if (input[3] == '-'&&stringtonumber(&input[4])>=0)
     32a:	0f b6 85 c7 fa ff ff 	movzbl -0x539(%ebp),%eax
     331:	3c 2d                	cmp    $0x2d,%al
     333:	75 65                	jne    39a <main+0x39a>
     335:	83 ec 0c             	sub    $0xc,%esp
     338:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     33e:	83 c0 04             	add    $0x4,%eax
     341:	50                   	push   %eax
     342:	e8 e0 05 00 00       	call   927 <stringtonumber>
     347:	83 c4 10             	add    $0x10,%esp
     34a:	85 c0                	test   %eax,%eax
     34c:	78 4c                	js     39a <main+0x39a>
			{
				com_ins(text, stringtonumber(&input[4]), &input[pos]);
     34e:	8d 95 c4 fa ff ff    	lea    -0x53c(%ebp),%edx
     354:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     357:	8d 34 02             	lea    (%edx,%eax,1),%esi
     35a:	83 ec 0c             	sub    $0xc,%esp
     35d:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     363:	83 c0 04             	add    $0x4,%eax
     366:	50                   	push   %eax
     367:	e8 bb 05 00 00       	call   927 <stringtonumber>
     36c:	83 c4 10             	add    $0x10,%esp
     36f:	83 ec 04             	sub    $0x4,%esp
     372:	56                   	push   %esi
     373:	50                   	push   %eax
     374:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     37a:	50                   	push   %eax
     37b:	e8 3a 06 00 00       	call   9ba <com_ins>
     380:	83 c4 10             	add    $0x10,%esp
                                 //插入操作需要更新行号
				line_number = get_line_number(text);
     383:	83 ec 0c             	sub    $0xc,%esp
     386:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     38c:	50                   	push   %eax
     38d:	e8 54 05 00 00       	call   8e6 <get_line_number>
     392:	83 c4 10             	add    $0x10,%esp
     395:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     398:	eb 7b                	jmp    415 <main+0x415>
			}
			else if(input[3] == ' '||input[3] == '\0')
     39a:	0f b6 85 c7 fa ff ff 	movzbl -0x539(%ebp),%eax
     3a1:	3c 20                	cmp    $0x20,%al
     3a3:	74 0b                	je     3b0 <main+0x3b0>
     3a5:	0f b6 85 c7 fa ff ff 	movzbl -0x539(%ebp),%eax
     3ac:	84 c0                	test   %al,%al
     3ae:	75 3c                	jne    3ec <main+0x3ec>
			{
				com_ins(text, line_number+1, &input[pos]);
     3b0:	8d 95 c4 fa ff ff    	lea    -0x53c(%ebp),%edx
     3b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     3b9:	01 c2                	add    %eax,%edx
     3bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     3be:	83 c0 01             	add    $0x1,%eax
     3c1:	83 ec 04             	sub    $0x4,%esp
     3c4:	52                   	push   %edx
     3c5:	50                   	push   %eax
     3c6:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     3cc:	50                   	push   %eax
     3cd:	e8 e8 05 00 00       	call   9ba <com_ins>
     3d2:	83 c4 10             	add    $0x10,%esp
                                line_number = get_line_number(text);
     3d5:	83 ec 0c             	sub    $0xc,%esp
     3d8:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     3de:	50                   	push   %eax
     3df:	e8 02 05 00 00       	call   8e6 <get_line_number>
     3e4:	83 c4 10             	add    $0x10,%esp
     3e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     3ea:	eb 29                	jmp    415 <main+0x415>
			}
			else
			{
				printf(1, "invalid command.\n");
     3ec:	83 ec 08             	sub    $0x8,%esp
     3ef:	68 d3 1a 00 00       	push   $0x1ad3
     3f4:	6a 01                	push   $0x1
     3f6:	e8 bb 12 00 00       	call   16b6 <printf>
     3fb:	83 c4 10             	add    $0x10,%esp
				com_help(text);
     3fe:	83 ec 0c             	sub    $0xc,%esp
     401:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     407:	50                   	push   %eax
     408:	e8 7f 0b 00 00       	call   f8c <com_help>
     40d:	83 c4 10             	add    $0x10,%esp
			}
		}
		//ins
		if (input[0] == 'i' && input[1] == 'n' && input[2] == 's')
		{
			if (input[3] == '-'&&stringtonumber(&input[4])>=0)
     410:	e9 4e 03 00 00       	jmp    763 <main+0x763>
     415:	e9 49 03 00 00       	jmp    763 <main+0x763>
				printf(1, "invalid command.\n");
				com_help(text);
			}
		}
		//mod
		else if (input[0] == 'm' && input[1] == 'o' && input[2] == 'd')
     41a:	0f b6 85 c4 fa ff ff 	movzbl -0x53c(%ebp),%eax
     421:	3c 6d                	cmp    $0x6d,%al
     423:	0f 85 e4 00 00 00    	jne    50d <main+0x50d>
     429:	0f b6 85 c5 fa ff ff 	movzbl -0x53b(%ebp),%eax
     430:	3c 6f                	cmp    $0x6f,%al
     432:	0f 85 d5 00 00 00    	jne    50d <main+0x50d>
     438:	0f b6 85 c6 fa ff ff 	movzbl -0x53a(%ebp),%eax
     43f:	3c 64                	cmp    $0x64,%al
     441:	0f 85 c6 00 00 00    	jne    50d <main+0x50d>
		{
			if (input[3] == '-'&&stringtonumber(&input[4])>=0)
     447:	0f b6 85 c7 fa ff ff 	movzbl -0x539(%ebp),%eax
     44e:	3c 2d                	cmp    $0x2d,%al
     450:	75 50                	jne    4a2 <main+0x4a2>
     452:	83 ec 0c             	sub    $0xc,%esp
     455:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     45b:	83 c0 04             	add    $0x4,%eax
     45e:	50                   	push   %eax
     45f:	e8 c3 04 00 00       	call   927 <stringtonumber>
     464:	83 c4 10             	add    $0x10,%esp
     467:	85 c0                	test   %eax,%eax
     469:	78 37                	js     4a2 <main+0x4a2>
				com_mod(text, atoi(&input[4]), &input[pos]);
     46b:	8d 95 c4 fa ff ff    	lea    -0x53c(%ebp),%edx
     471:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     474:	8d 34 02             	lea    (%edx,%eax,1),%esi
     477:	83 ec 0c             	sub    $0xc,%esp
     47a:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     480:	83 c0 04             	add    $0x4,%eax
     483:	50                   	push   %eax
     484:	e8 04 10 00 00       	call   148d <atoi>
     489:	83 c4 10             	add    $0x10,%esp
     48c:	83 ec 04             	sub    $0x4,%esp
     48f:	56                   	push   %esi
     490:	50                   	push   %eax
     491:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     497:	50                   	push   %eax
     498:	e8 86 08 00 00       	call   d23 <com_mod>
     49d:	83 c4 10             	add    $0x10,%esp
     4a0:	eb 66                	jmp    508 <main+0x508>
			else if(input[3] == ' '||input[3] == '\0')
     4a2:	0f b6 85 c7 fa ff ff 	movzbl -0x539(%ebp),%eax
     4a9:	3c 20                	cmp    $0x20,%al
     4ab:	74 0b                	je     4b8 <main+0x4b8>
     4ad:	0f b6 85 c7 fa ff ff 	movzbl -0x539(%ebp),%eax
     4b4:	84 c0                	test   %al,%al
     4b6:	75 27                	jne    4df <main+0x4df>
				com_mod(text, line_number + 1, &input[pos]);
     4b8:	8d 95 c4 fa ff ff    	lea    -0x53c(%ebp),%edx
     4be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     4c1:	01 c2                	add    %eax,%edx
     4c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     4c6:	83 c0 01             	add    $0x1,%eax
     4c9:	83 ec 04             	sub    $0x4,%esp
     4cc:	52                   	push   %edx
     4cd:	50                   	push   %eax
     4ce:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     4d4:	50                   	push   %eax
     4d5:	e8 49 08 00 00       	call   d23 <com_mod>
     4da:	83 c4 10             	add    $0x10,%esp
     4dd:	eb 29                	jmp    508 <main+0x508>
			else
			{
				printf(1, "invalid command.\n");
     4df:	83 ec 08             	sub    $0x8,%esp
     4e2:	68 d3 1a 00 00       	push   $0x1ad3
     4e7:	6a 01                	push   $0x1
     4e9:	e8 c8 11 00 00       	call   16b6 <printf>
     4ee:	83 c4 10             	add    $0x10,%esp
				com_help(text);
     4f1:	83 ec 0c             	sub    $0xc,%esp
     4f4:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     4fa:	50                   	push   %eax
     4fb:	e8 8c 0a 00 00       	call   f8c <com_help>
     500:	83 c4 10             	add    $0x10,%esp
			}
		}
		//mod
		else if (input[0] == 'm' && input[1] == 'o' && input[2] == 'd')
		{
			if (input[3] == '-'&&stringtonumber(&input[4])>=0)
     503:	e9 5b 02 00 00       	jmp    763 <main+0x763>
     508:	e9 56 02 00 00       	jmp    763 <main+0x763>
				printf(1, "invalid command.\n");
				com_help(text);
			}
		}
		//del
		else if (input[0] == 'd' && input[1] == 'e' && input[2] == 'l')
     50d:	0f b6 85 c4 fa ff ff 	movzbl -0x53c(%ebp),%eax
     514:	3c 64                	cmp    $0x64,%al
     516:	0f 85 eb 00 00 00    	jne    607 <main+0x607>
     51c:	0f b6 85 c5 fa ff ff 	movzbl -0x53b(%ebp),%eax
     523:	3c 65                	cmp    $0x65,%al
     525:	0f 85 dc 00 00 00    	jne    607 <main+0x607>
     52b:	0f b6 85 c6 fa ff ff 	movzbl -0x53a(%ebp),%eax
     532:	3c 6c                	cmp    $0x6c,%al
     534:	0f 85 cd 00 00 00    	jne    607 <main+0x607>
		{
			if (input[3] == '-'&&stringtonumber(&input[4])>=0)
     53a:	0f b6 85 c7 fa ff ff 	movzbl -0x539(%ebp),%eax
     541:	3c 2d                	cmp    $0x2d,%al
     543:	75 5b                	jne    5a0 <main+0x5a0>
     545:	83 ec 0c             	sub    $0xc,%esp
     548:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     54e:	83 c0 04             	add    $0x4,%eax
     551:	50                   	push   %eax
     552:	e8 d0 03 00 00       	call   927 <stringtonumber>
     557:	83 c4 10             	add    $0x10,%esp
     55a:	85 c0                	test   %eax,%eax
     55c:	78 42                	js     5a0 <main+0x5a0>
			{
				com_del(text, atoi(&input[4]));
     55e:	83 ec 0c             	sub    $0xc,%esp
     561:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     567:	83 c0 04             	add    $0x4,%eax
     56a:	50                   	push   %eax
     56b:	e8 1d 0f 00 00       	call   148d <atoi>
     570:	83 c4 10             	add    $0x10,%esp
     573:	83 ec 08             	sub    $0x8,%esp
     576:	50                   	push   %eax
     577:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     57d:	50                   	push   %eax
     57e:	e8 ce 08 00 00       	call   e51 <com_del>
     583:	83 c4 10             	add    $0x10,%esp
                                //删除操作需要更新行号
				line_number = get_line_number(text);
     586:	83 ec 0c             	sub    $0xc,%esp
     589:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     58f:	50                   	push   %eax
     590:	e8 51 03 00 00       	call   8e6 <get_line_number>
     595:	83 c4 10             	add    $0x10,%esp
     598:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			}
		}
		//del
		else if (input[0] == 'd' && input[1] == 'e' && input[2] == 'l')
		{
			if (input[3] == '-'&&stringtonumber(&input[4])>=0)
     59b:	e9 c3 01 00 00       	jmp    763 <main+0x763>
			{
				com_del(text, atoi(&input[4]));
                                //删除操作需要更新行号
				line_number = get_line_number(text);
			}	
			else if(input[3]=='\0')
     5a0:	0f b6 85 c7 fa ff ff 	movzbl -0x539(%ebp),%eax
     5a7:	84 c0                	test   %al,%al
     5a9:	75 33                	jne    5de <main+0x5de>
			{
				com_del(text, line_number + 1);
     5ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     5ae:	83 c0 01             	add    $0x1,%eax
     5b1:	83 ec 08             	sub    $0x8,%esp
     5b4:	50                   	push   %eax
     5b5:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     5bb:	50                   	push   %eax
     5bc:	e8 90 08 00 00       	call   e51 <com_del>
     5c1:	83 c4 10             	add    $0x10,%esp
				line_number = get_line_number(text);
     5c4:	83 ec 0c             	sub    $0xc,%esp
     5c7:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     5cd:	50                   	push   %eax
     5ce:	e8 13 03 00 00       	call   8e6 <get_line_number>
     5d3:	83 c4 10             	add    $0x10,%esp
     5d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			}
		}
		//del
		else if (input[0] == 'd' && input[1] == 'e' && input[2] == 'l')
		{
			if (input[3] == '-'&&stringtonumber(&input[4])>=0)
     5d9:	e9 85 01 00 00       	jmp    763 <main+0x763>
				com_del(text, line_number + 1);
				line_number = get_line_number(text);
			}
			else
			{
				printf(1, "invalid command.\n");
     5de:	83 ec 08             	sub    $0x8,%esp
     5e1:	68 d3 1a 00 00       	push   $0x1ad3
     5e6:	6a 01                	push   $0x1
     5e8:	e8 c9 10 00 00       	call   16b6 <printf>
     5ed:	83 c4 10             	add    $0x10,%esp
				com_help(text);
     5f0:	83 ec 0c             	sub    $0xc,%esp
     5f3:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     5f9:	50                   	push   %eax
     5fa:	e8 8d 09 00 00       	call   f8c <com_help>
     5ff:	83 c4 10             	add    $0x10,%esp
			}
		}
		//del
		else if (input[0] == 'd' && input[1] == 'e' && input[2] == 'l')
		{
			if (input[3] == '-'&&stringtonumber(&input[4])>=0)
     602:	e9 5c 01 00 00       	jmp    763 <main+0x763>
				printf(1, "invalid command.\n");
				com_help(text);
			}
			
		}
		else if (strcmp(input, "show") == 0)
     607:	83 ec 08             	sub    $0x8,%esp
     60a:	68 e5 1a 00 00       	push   $0x1ae5
     60f:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     615:	50                   	push   %eax
     616:	e8 03 0d 00 00       	call   131e <strcmp>
     61b:	83 c4 10             	add    $0x10,%esp
     61e:	85 c0                	test   %eax,%eax
     620:	75 21                	jne    643 <main+0x643>
		{
			auto_show = 1;
     622:	c7 05 74 21 00 00 01 	movl   $0x1,0x2174
     629:	00 00 00 
			printf(1, "enable show current contents after text changed.\n");
     62c:	83 ec 08             	sub    $0x8,%esp
     62f:	68 ec 1a 00 00       	push   $0x1aec
     634:	6a 01                	push   $0x1
     636:	e8 7b 10 00 00       	call   16b6 <printf>
     63b:	83 c4 10             	add    $0x10,%esp
     63e:	e9 1a fc ff ff       	jmp    25d <main+0x25d>
		}
		else if (strcmp(input, "hide") == 0)
     643:	83 ec 08             	sub    $0x8,%esp
     646:	68 1e 1b 00 00       	push   $0x1b1e
     64b:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     651:	50                   	push   %eax
     652:	e8 c7 0c 00 00       	call   131e <strcmp>
     657:	83 c4 10             	add    $0x10,%esp
     65a:	85 c0                	test   %eax,%eax
     65c:	75 21                	jne    67f <main+0x67f>
		{
			auto_show = 0;
     65e:	c7 05 74 21 00 00 00 	movl   $0x0,0x2174
     665:	00 00 00 
			printf(1, "disable show current contents after text changed.\n");
     668:	83 ec 08             	sub    $0x8,%esp
     66b:	68 24 1b 00 00       	push   $0x1b24
     670:	6a 01                	push   $0x1
     672:	e8 3f 10 00 00       	call   16b6 <printf>
     677:	83 c4 10             	add    $0x10,%esp
     67a:	e9 de fb ff ff       	jmp    25d <main+0x25d>
		}
		else if (strcmp(input, "help") == 0)
     67f:	83 ec 08             	sub    $0x8,%esp
     682:	68 57 1b 00 00       	push   $0x1b57
     687:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     68d:	50                   	push   %eax
     68e:	e8 8b 0c 00 00       	call   131e <strcmp>
     693:	83 c4 10             	add    $0x10,%esp
     696:	85 c0                	test   %eax,%eax
     698:	75 17                	jne    6b1 <main+0x6b1>
			com_help(text);
     69a:	83 ec 0c             	sub    $0xc,%esp
     69d:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     6a3:	50                   	push   %eax
     6a4:	e8 e3 08 00 00       	call   f8c <com_help>
     6a9:	83 c4 10             	add    $0x10,%esp
     6ac:	e9 ac fb ff ff       	jmp    25d <main+0x25d>
		else if (strcmp(input, "save") == 0 || strcmp(input, "CTRL+S\n") == 0)
     6b1:	83 ec 08             	sub    $0x8,%esp
     6b4:	68 5c 1b 00 00       	push   $0x1b5c
     6b9:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     6bf:	50                   	push   %eax
     6c0:	e8 59 0c 00 00       	call   131e <strcmp>
     6c5:	83 c4 10             	add    $0x10,%esp
     6c8:	85 c0                	test   %eax,%eax
     6ca:	74 1b                	je     6e7 <main+0x6e7>
     6cc:	83 ec 08             	sub    $0x8,%esp
     6cf:	68 61 1b 00 00       	push   $0x1b61
     6d4:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     6da:	50                   	push   %eax
     6db:	e8 3e 0c 00 00       	call   131e <strcmp>
     6e0:	83 c4 10             	add    $0x10,%esp
     6e3:	85 c0                	test   %eax,%eax
     6e5:	75 1d                	jne    704 <main+0x704>
			com_save(text, argv[1]);
     6e7:	8b 43 04             	mov    0x4(%ebx),%eax
     6ea:	83 c0 04             	add    $0x4,%eax
     6ed:	8b 00                	mov    (%eax),%eax
     6ef:	83 ec 08             	sub    $0x8,%esp
     6f2:	50                   	push   %eax
     6f3:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     6f9:	50                   	push   %eax
     6fa:	e8 6e 09 00 00       	call   106d <com_save>
     6ff:	83 c4 10             	add    $0x10,%esp
     702:	eb 5f                	jmp    763 <main+0x763>
		else if (strcmp(input, "exit") == 0)
     704:	83 ec 08             	sub    $0x8,%esp
     707:	68 69 1b 00 00       	push   $0x1b69
     70c:	8d 85 c4 fa ff ff    	lea    -0x53c(%ebp),%eax
     712:	50                   	push   %eax
     713:	e8 06 0c 00 00       	call   131e <strcmp>
     718:	83 c4 10             	add    $0x10,%esp
     71b:	85 c0                	test   %eax,%eax
     71d:	75 20                	jne    73f <main+0x73f>
			com_exit(text, argv[1]);
     71f:	8b 43 04             	mov    0x4(%ebx),%eax
     722:	83 c0 04             	add    $0x4,%eax
     725:	8b 00                	mov    (%eax),%eax
     727:	83 ec 08             	sub    $0x8,%esp
     72a:	50                   	push   %eax
     72b:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     731:	50                   	push   %eax
     732:	e8 63 0a 00 00       	call   119a <com_exit>
     737:	83 c4 10             	add    $0x10,%esp
     73a:	e9 1e fb ff ff       	jmp    25d <main+0x25d>
		else
		{
			printf(1, "invalid command.\n");
     73f:	83 ec 08             	sub    $0x8,%esp
     742:	68 d3 1a 00 00       	push   $0x1ad3
     747:	6a 01                	push   $0x1
     749:	e8 68 0f 00 00       	call   16b6 <printf>
     74e:	83 c4 10             	add    $0x10,%esp
			com_help(text);
     751:	83 ec 0c             	sub    $0xc,%esp
     754:	8d 85 c4 fb ff ff    	lea    -0x43c(%ebp),%eax
     75a:	50                   	push   %eax
     75b:	e8 2c 08 00 00       	call   f8c <com_help>
     760:	83 c4 10             	add    $0x10,%esp
		}
	}
     763:	e9 f5 fa ff ff       	jmp    25d <main+0x25d>

00000768 <strcat_n>:
	exit();
}

//拼接src的前n个字符到dest
char* strcat_n(char* dest, char* src, int len)
{
     768:	55                   	push   %ebp
     769:	89 e5                	mov    %esp,%ebp
     76b:	83 ec 18             	sub    $0x18,%esp
	if (len <= 0)
     76e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     772:	7f 05                	jg     779 <strcat_n+0x11>
		return dest;
     774:	8b 45 08             	mov    0x8(%ebp),%eax
     777:	eb 6b                	jmp    7e4 <strcat_n+0x7c>
	int pos = strlen(dest);
     779:	83 ec 0c             	sub    $0xc,%esp
     77c:	ff 75 08             	pushl  0x8(%ebp)
     77f:	e8 d9 0b 00 00       	call   135d <strlen>
     784:	83 c4 10             	add    $0x10,%esp
     787:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (len + pos >= MAX_LINE_LENGTH)
     78a:	8b 55 10             	mov    0x10(%ebp),%edx
     78d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     790:	01 d0                	add    %edx,%eax
     792:	3d ff 00 00 00       	cmp    $0xff,%eax
     797:	7e 05                	jle    79e <strcat_n+0x36>
		return dest;
     799:	8b 45 08             	mov    0x8(%ebp),%eax
     79c:	eb 46                	jmp    7e4 <strcat_n+0x7c>
	int i = 0;
     79e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (; i < len; i++)
     7a5:	eb 20                	jmp    7c7 <strcat_n+0x5f>
		dest[i+pos] = src[i];
     7a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
     7aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
     7ad:	01 d0                	add    %edx,%eax
     7af:	89 c2                	mov    %eax,%edx
     7b1:	8b 45 08             	mov    0x8(%ebp),%eax
     7b4:	01 c2                	add    %eax,%edx
     7b6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     7b9:	8b 45 0c             	mov    0xc(%ebp),%eax
     7bc:	01 c8                	add    %ecx,%eax
     7be:	0f b6 00             	movzbl (%eax),%eax
     7c1:	88 02                	mov    %al,(%edx)
		return dest;
	int pos = strlen(dest);
	if (len + pos >= MAX_LINE_LENGTH)
		return dest;
	int i = 0;
	for (; i < len; i++)
     7c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     7c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7ca:	3b 45 10             	cmp    0x10(%ebp),%eax
     7cd:	7c d8                	jl     7a7 <strcat_n+0x3f>
		dest[i+pos] = src[i];
	dest[len+pos] = '\0';
     7cf:	8b 55 10             	mov    0x10(%ebp),%edx
     7d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
     7d5:	01 d0                	add    %edx,%eax
     7d7:	89 c2                	mov    %eax,%edx
     7d9:	8b 45 08             	mov    0x8(%ebp),%eax
     7dc:	01 d0                	add    %edx,%eax
     7de:	c6 00 00             	movb   $0x0,(%eax)
	return dest;
     7e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
     7e4:	c9                   	leave  
     7e5:	c3                   	ret    

000007e6 <show_text>:

void show_text(char *text[])
{
     7e6:	55                   	push   %ebp
     7e7:	89 e5                	mov    %esp,%ebp
     7e9:	57                   	push   %edi
     7ea:	56                   	push   %esi
     7eb:	53                   	push   %ebx
     7ec:	83 ec 1c             	sub    $0x1c,%esp
	printf(1, "****************************************\n");
     7ef:	83 ec 08             	sub    $0x8,%esp
     7f2:	68 70 1b 00 00       	push   $0x1b70
     7f7:	6a 01                	push   $0x1
     7f9:	e8 b8 0e 00 00       	call   16b6 <printf>
     7fe:	83 c4 10             	add    $0x10,%esp
	printf(1, "the contents of the file are:\n");
     801:	83 ec 08             	sub    $0x8,%esp
     804:	68 9c 1b 00 00       	push   $0x1b9c
     809:	6a 01                	push   $0x1
     80b:	e8 a6 0e 00 00       	call   16b6 <printf>
     810:	83 c4 10             	add    $0x10,%esp
	int j = 0;
     813:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (; text[j] != NULL; j++)
     81a:	e9 a5 00 00 00       	jmp    8c4 <show_text+0xde>
		printf(1, "%d%d%d:%s\n", (j+1)/100, ((j+1)%100)/10, (j+1)%10, text[j]);
     81f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     822:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     829:	8b 45 08             	mov    0x8(%ebp),%eax
     82c:	01 d0                	add    %edx,%eax
     82e:	8b 38                	mov    (%eax),%edi
     830:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     833:	8d 58 01             	lea    0x1(%eax),%ebx
     836:	ba 67 66 66 66       	mov    $0x66666667,%edx
     83b:	89 d8                	mov    %ebx,%eax
     83d:	f7 ea                	imul   %edx
     83f:	c1 fa 02             	sar    $0x2,%edx
     842:	89 d8                	mov    %ebx,%eax
     844:	c1 f8 1f             	sar    $0x1f,%eax
     847:	89 d1                	mov    %edx,%ecx
     849:	29 c1                	sub    %eax,%ecx
     84b:	89 c8                	mov    %ecx,%eax
     84d:	c1 e0 02             	shl    $0x2,%eax
     850:	01 c8                	add    %ecx,%eax
     852:	01 c0                	add    %eax,%eax
     854:	89 d9                	mov    %ebx,%ecx
     856:	29 c1                	sub    %eax,%ecx
     858:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     85b:	8d 70 01             	lea    0x1(%eax),%esi
     85e:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
     863:	89 f0                	mov    %esi,%eax
     865:	f7 ea                	imul   %edx
     867:	c1 fa 05             	sar    $0x5,%edx
     86a:	89 f0                	mov    %esi,%eax
     86c:	c1 f8 1f             	sar    $0x1f,%eax
     86f:	89 d3                	mov    %edx,%ebx
     871:	29 c3                	sub    %eax,%ebx
     873:	6b c3 64             	imul   $0x64,%ebx,%eax
     876:	29 c6                	sub    %eax,%esi
     878:	89 f3                	mov    %esi,%ebx
     87a:	ba 67 66 66 66       	mov    $0x66666667,%edx
     87f:	89 d8                	mov    %ebx,%eax
     881:	f7 ea                	imul   %edx
     883:	c1 fa 02             	sar    $0x2,%edx
     886:	89 d8                	mov    %ebx,%eax
     888:	c1 f8 1f             	sar    $0x1f,%eax
     88b:	89 d6                	mov    %edx,%esi
     88d:	29 c6                	sub    %eax,%esi
     88f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     892:	8d 58 01             	lea    0x1(%eax),%ebx
     895:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
     89a:	89 d8                	mov    %ebx,%eax
     89c:	f7 ea                	imul   %edx
     89e:	c1 fa 05             	sar    $0x5,%edx
     8a1:	89 d8                	mov    %ebx,%eax
     8a3:	c1 f8 1f             	sar    $0x1f,%eax
     8a6:	29 c2                	sub    %eax,%edx
     8a8:	89 d0                	mov    %edx,%eax
     8aa:	83 ec 08             	sub    $0x8,%esp
     8ad:	57                   	push   %edi
     8ae:	51                   	push   %ecx
     8af:	56                   	push   %esi
     8b0:	50                   	push   %eax
     8b1:	68 bb 1b 00 00       	push   $0x1bbb
     8b6:	6a 01                	push   $0x1
     8b8:	e8 f9 0d 00 00       	call   16b6 <printf>
     8bd:	83 c4 20             	add    $0x20,%esp
void show_text(char *text[])
{
	printf(1, "****************************************\n");
	printf(1, "the contents of the file are:\n");
	int j = 0;
	for (; text[j] != NULL; j++)
     8c0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
     8c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     8c7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     8ce:	8b 45 08             	mov    0x8(%ebp),%eax
     8d1:	01 d0                	add    %edx,%eax
     8d3:	8b 00                	mov    (%eax),%eax
     8d5:	85 c0                	test   %eax,%eax
     8d7:	0f 85 42 ff ff ff    	jne    81f <show_text+0x39>
		printf(1, "%d%d%d:%s\n", (j+1)/100, ((j+1)%100)/10, (j+1)%10, text[j]);
}
     8dd:	90                   	nop
     8de:	8d 65 f4             	lea    -0xc(%ebp),%esp
     8e1:	5b                   	pop    %ebx
     8e2:	5e                   	pop    %esi
     8e3:	5f                   	pop    %edi
     8e4:	5d                   	pop    %ebp
     8e5:	c3                   	ret    

000008e6 <get_line_number>:

//获取当前最大的行号，从0开始，即return x表示text[0]到text[x]可用
int get_line_number(char *text[])
{
     8e6:	55                   	push   %ebp
     8e7:	89 e5                	mov    %esp,%ebp
     8e9:	83 ec 10             	sub    $0x10,%esp
	int i = 0;
     8ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (; i < MAX_LINE_NUMBER; i++)
     8f3:	eb 21                	jmp    916 <get_line_number+0x30>
		if (text[i] == NULL)
     8f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
     8f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     8ff:	8b 45 08             	mov    0x8(%ebp),%eax
     902:	01 d0                	add    %edx,%eax
     904:	8b 00                	mov    (%eax),%eax
     906:	85 c0                	test   %eax,%eax
     908:	75 08                	jne    912 <get_line_number+0x2c>
			return i - 1;
     90a:	8b 45 fc             	mov    -0x4(%ebp),%eax
     90d:	83 e8 01             	sub    $0x1,%eax
     910:	eb 13                	jmp    925 <get_line_number+0x3f>

//获取当前最大的行号，从0开始，即return x表示text[0]到text[x]可用
int get_line_number(char *text[])
{
	int i = 0;
	for (; i < MAX_LINE_NUMBER; i++)
     912:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     916:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
     91d:	7e d6                	jle    8f5 <get_line_number+0xf>
		if (text[i] == NULL)
			return i - 1;
	return i - 1;
     91f:	8b 45 fc             	mov    -0x4(%ebp),%eax
     922:	83 e8 01             	sub    $0x1,%eax
}
     925:	c9                   	leave  
     926:	c3                   	ret    

00000927 <stringtonumber>:

int stringtonumber(char* src)
{
     927:	55                   	push   %ebp
     928:	89 e5                	mov    %esp,%ebp
     92a:	83 ec 18             	sub    $0x18,%esp
	int number = 0; 
     92d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int i=0;
     934:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int pos = strlen(src);
     93b:	83 ec 0c             	sub    $0xc,%esp
     93e:	ff 75 08             	pushl  0x8(%ebp)
     941:	e8 17 0a 00 00       	call   135d <strlen>
     946:	83 c4 10             	add    $0x10,%esp
     949:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for(;i<pos;i++)
     94c:	eb 5c                	jmp    9aa <stringtonumber+0x83>
	{
		if(src[i]==' ') break;
     94e:	8b 55 f0             	mov    -0x10(%ebp),%edx
     951:	8b 45 08             	mov    0x8(%ebp),%eax
     954:	01 d0                	add    %edx,%eax
     956:	0f b6 00             	movzbl (%eax),%eax
     959:	3c 20                	cmp    $0x20,%al
     95b:	74 57                	je     9b4 <stringtonumber+0x8d>
		if(src[i]>57||src[i]<48) return -1;
     95d:	8b 55 f0             	mov    -0x10(%ebp),%edx
     960:	8b 45 08             	mov    0x8(%ebp),%eax
     963:	01 d0                	add    %edx,%eax
     965:	0f b6 00             	movzbl (%eax),%eax
     968:	3c 39                	cmp    $0x39,%al
     96a:	7f 0f                	jg     97b <stringtonumber+0x54>
     96c:	8b 55 f0             	mov    -0x10(%ebp),%edx
     96f:	8b 45 08             	mov    0x8(%ebp),%eax
     972:	01 d0                	add    %edx,%eax
     974:	0f b6 00             	movzbl (%eax),%eax
     977:	3c 2f                	cmp    $0x2f,%al
     979:	7f 07                	jg     982 <stringtonumber+0x5b>
     97b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     980:	eb 36                	jmp    9b8 <stringtonumber+0x91>
		number=10*number+(src[i]-48);
     982:	8b 55 f4             	mov    -0xc(%ebp),%edx
     985:	89 d0                	mov    %edx,%eax
     987:	c1 e0 02             	shl    $0x2,%eax
     98a:	01 d0                	add    %edx,%eax
     98c:	01 c0                	add    %eax,%eax
     98e:	89 c1                	mov    %eax,%ecx
     990:	8b 55 f0             	mov    -0x10(%ebp),%edx
     993:	8b 45 08             	mov    0x8(%ebp),%eax
     996:	01 d0                	add    %edx,%eax
     998:	0f b6 00             	movzbl (%eax),%eax
     99b:	0f be c0             	movsbl %al,%eax
     99e:	83 e8 30             	sub    $0x30,%eax
     9a1:	01 c8                	add    %ecx,%eax
     9a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
int stringtonumber(char* src)
{
	int number = 0; 
	int i=0;
	int pos = strlen(src);
	for(;i<pos;i++)
     9a6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     9aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9ad:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     9b0:	7c 9c                	jl     94e <stringtonumber+0x27>
     9b2:	eb 01                	jmp    9b5 <stringtonumber+0x8e>
	{
		if(src[i]==' ') break;
     9b4:	90                   	nop
		if(src[i]>57||src[i]<48) return -1;
		number=10*number+(src[i]-48);
	}
	return number;
     9b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     9b8:	c9                   	leave  
     9b9:	c3                   	ret    

000009ba <com_ins>:

//插入命令，n为用户输入的行号，从1开始
//extra:输入命令时接着的信息，代表待插入的文本
void com_ins(char *text[], int n, char *extra)
{
     9ba:	55                   	push   %ebp
     9bb:	89 e5                	mov    %esp,%ebp
     9bd:	57                   	push   %edi
     9be:	53                   	push   %ebx
     9bf:	81 ec 10 01 00 00    	sub    $0x110,%esp
	if (n < 0 || n > get_line_number(text) + 1)
     9c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     9c9:	78 13                	js     9de <com_ins+0x24>
     9cb:	ff 75 08             	pushl  0x8(%ebp)
     9ce:	e8 13 ff ff ff       	call   8e6 <get_line_number>
     9d3:	83 c4 04             	add    $0x4,%esp
     9d6:	83 c0 01             	add    $0x1,%eax
     9d9:	3b 45 0c             	cmp    0xc(%ebp),%eax
     9dc:	7d 17                	jge    9f5 <com_ins+0x3b>
	{
		printf(1, "invalid line number\n");
     9de:	83 ec 08             	sub    $0x8,%esp
     9e1:	68 c6 1b 00 00       	push   $0x1bc6
     9e6:	6a 01                	push   $0x1
     9e8:	e8 c9 0c 00 00       	call   16b6 <printf>
     9ed:	83 c4 10             	add    $0x10,%esp
		return;
     9f0:	e9 27 03 00 00       	jmp    d1c <com_ins+0x362>
	}
	char input[MAX_LINE_LENGTH] = {};
     9f5:	8d 95 f4 fe ff ff    	lea    -0x10c(%ebp),%edx
     9fb:	b8 00 00 00 00       	mov    $0x0,%eax
     a00:	b9 40 00 00 00       	mov    $0x40,%ecx
     a05:	89 d7                	mov    %edx,%edi
     a07:	f3 ab                	rep stos %eax,%es:(%edi)
	if (*extra == '\0')
     a09:	8b 45 10             	mov    0x10(%ebp),%eax
     a0c:	0f b6 00             	movzbl (%eax),%eax
     a0f:	84 c0                	test   %al,%al
     a11:	75 48                	jne    a5b <com_ins+0xa1>
	{
		printf(1, "please input content:\n");
     a13:	83 ec 08             	sub    $0x8,%esp
     a16:	68 db 1b 00 00       	push   $0x1bdb
     a1b:	6a 01                	push   $0x1
     a1d:	e8 94 0c 00 00       	call   16b6 <printf>
     a22:	83 c4 10             	add    $0x10,%esp
		gets(input, MAX_LINE_LENGTH);
     a25:	83 ec 08             	sub    $0x8,%esp
     a28:	68 00 01 00 00       	push   $0x100
     a2d:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
     a33:	50                   	push   %eax
     a34:	e8 98 09 00 00       	call   13d1 <gets>
     a39:	83 c4 10             	add    $0x10,%esp
		input[strlen(input)-1] = '\0';
     a3c:	83 ec 0c             	sub    $0xc,%esp
     a3f:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
     a45:	50                   	push   %eax
     a46:	e8 12 09 00 00       	call   135d <strlen>
     a4b:	83 c4 10             	add    $0x10,%esp
     a4e:	83 e8 01             	sub    $0x1,%eax
     a51:	c6 84 05 f4 fe ff ff 	movb   $0x0,-0x10c(%ebp,%eax,1)
     a58:	00 
     a59:	eb 15                	jmp    a70 <com_ins+0xb6>
	}
	else
		strcpy(input, extra);
     a5b:	83 ec 08             	sub    $0x8,%esp
     a5e:	ff 75 10             	pushl  0x10(%ebp)
     a61:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
     a67:	50                   	push   %eax
     a68:	e8 81 08 00 00       	call   12ee <strcpy>
     a6d:	83 c4 10             	add    $0x10,%esp
	int i = MAX_LINE_NUMBER - 1;
     a70:	c7 45 f4 ff 00 00 00 	movl   $0xff,-0xc(%ebp)
	for (; i > n; i--)
     a77:	e9 5e 01 00 00       	jmp    bda <com_ins+0x220>
	{
		if (text[i-1] == NULL)
     a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a7f:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
     a84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     a8b:	8b 45 08             	mov    0x8(%ebp),%eax
     a8e:	01 d0                	add    %edx,%eax
     a90:	8b 00                	mov    (%eax),%eax
     a92:	85 c0                	test   %eax,%eax
     a94:	0f 84 3b 01 00 00    	je     bd5 <com_ins+0x21b>
			continue;
		else if (text[i] == NULL && text[i-1] != NULL)
     a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a9d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     aa4:	8b 45 08             	mov    0x8(%ebp),%eax
     aa7:	01 d0                	add    %edx,%eax
     aa9:	8b 00                	mov    (%eax),%eax
     aab:	85 c0                	test   %eax,%eax
     aad:	0f 85 99 00 00 00    	jne    b4c <com_ins+0x192>
     ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ab6:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
     abb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     ac2:	8b 45 08             	mov    0x8(%ebp),%eax
     ac5:	01 d0                	add    %edx,%eax
     ac7:	8b 00                	mov    (%eax),%eax
     ac9:	85 c0                	test   %eax,%eax
     acb:	74 7f                	je     b4c <com_ins+0x192>
		{
			text[i] = malloc(MAX_LINE_LENGTH);
     acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ad0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     ad7:	8b 45 08             	mov    0x8(%ebp),%eax
     ada:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
     add:	83 ec 0c             	sub    $0xc,%esp
     ae0:	68 00 01 00 00       	push   $0x100
     ae5:	e8 9f 0e 00 00       	call   1989 <malloc>
     aea:	83 c4 10             	add    $0x10,%esp
     aed:	89 03                	mov    %eax,(%ebx)
			memset(text[i], 0, MAX_LINE_LENGTH);
     aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
     af2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     af9:	8b 45 08             	mov    0x8(%ebp),%eax
     afc:	01 d0                	add    %edx,%eax
     afe:	8b 00                	mov    (%eax),%eax
     b00:	83 ec 04             	sub    $0x4,%esp
     b03:	68 00 01 00 00       	push   $0x100
     b08:	6a 00                	push   $0x0
     b0a:	50                   	push   %eax
     b0b:	e8 74 08 00 00       	call   1384 <memset>
     b10:	83 c4 10             	add    $0x10,%esp
			strcpy(text[i], text[i-1]);
     b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b16:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
     b1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     b22:	8b 45 08             	mov    0x8(%ebp),%eax
     b25:	01 d0                	add    %edx,%eax
     b27:	8b 10                	mov    (%eax),%edx
     b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b2c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
     b33:	8b 45 08             	mov    0x8(%ebp),%eax
     b36:	01 c8                	add    %ecx,%eax
     b38:	8b 00                	mov    (%eax),%eax
     b3a:	83 ec 08             	sub    $0x8,%esp
     b3d:	52                   	push   %edx
     b3e:	50                   	push   %eax
     b3f:	e8 aa 07 00 00       	call   12ee <strcpy>
     b44:	83 c4 10             	add    $0x10,%esp
     b47:	e9 8a 00 00 00       	jmp    bd6 <com_ins+0x21c>
		}
		else if (text[i] != NULL && text[i-1] != NULL)
     b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     b56:	8b 45 08             	mov    0x8(%ebp),%eax
     b59:	01 d0                	add    %edx,%eax
     b5b:	8b 00                	mov    (%eax),%eax
     b5d:	85 c0                	test   %eax,%eax
     b5f:	74 75                	je     bd6 <com_ins+0x21c>
     b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b64:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
     b69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     b70:	8b 45 08             	mov    0x8(%ebp),%eax
     b73:	01 d0                	add    %edx,%eax
     b75:	8b 00                	mov    (%eax),%eax
     b77:	85 c0                	test   %eax,%eax
     b79:	74 5b                	je     bd6 <com_ins+0x21c>
		{
			memset(text[i], 0, MAX_LINE_LENGTH);
     b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b7e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     b85:	8b 45 08             	mov    0x8(%ebp),%eax
     b88:	01 d0                	add    %edx,%eax
     b8a:	8b 00                	mov    (%eax),%eax
     b8c:	83 ec 04             	sub    $0x4,%esp
     b8f:	68 00 01 00 00       	push   $0x100
     b94:	6a 00                	push   $0x0
     b96:	50                   	push   %eax
     b97:	e8 e8 07 00 00       	call   1384 <memset>
     b9c:	83 c4 10             	add    $0x10,%esp
			strcpy(text[i], text[i-1]);
     b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ba2:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
     ba7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     bae:	8b 45 08             	mov    0x8(%ebp),%eax
     bb1:	01 d0                	add    %edx,%eax
     bb3:	8b 10                	mov    (%eax),%edx
     bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     bb8:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
     bbf:	8b 45 08             	mov    0x8(%ebp),%eax
     bc2:	01 c8                	add    %ecx,%eax
     bc4:	8b 00                	mov    (%eax),%eax
     bc6:	83 ec 08             	sub    $0x8,%esp
     bc9:	52                   	push   %edx
     bca:	50                   	push   %eax
     bcb:	e8 1e 07 00 00       	call   12ee <strcpy>
     bd0:	83 c4 10             	add    $0x10,%esp
     bd3:	eb 01                	jmp    bd6 <com_ins+0x21c>
		strcpy(input, extra);
	int i = MAX_LINE_NUMBER - 1;
	for (; i > n; i--)
	{
		if (text[i-1] == NULL)
			continue;
     bd5:	90                   	nop
		input[strlen(input)-1] = '\0';
	}
	else
		strcpy(input, extra);
	int i = MAX_LINE_NUMBER - 1;
	for (; i > n; i--)
     bd6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
     bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
     bdd:	3b 45 0c             	cmp    0xc(%ebp),%eax
     be0:	0f 8f 96 fe ff ff    	jg     a7c <com_ins+0xc2>
		{
			memset(text[i], 0, MAX_LINE_LENGTH);
			strcpy(text[i], text[i-1]);
		}
	}
	if (text[n] == NULL)
     be6:	8b 45 0c             	mov    0xc(%ebp),%eax
     be9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     bf0:	8b 45 08             	mov    0x8(%ebp),%eax
     bf3:	01 d0                	add    %edx,%eax
     bf5:	8b 00                	mov    (%eax),%eax
     bf7:	85 c0                	test   %eax,%eax
     bf9:	0f 85 b0 00 00 00    	jne    caf <com_ins+0x2f5>
	{
		text[n] = malloc(MAX_LINE_LENGTH);
     bff:	8b 45 0c             	mov    0xc(%ebp),%eax
     c02:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     c09:	8b 45 08             	mov    0x8(%ebp),%eax
     c0c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
     c0f:	83 ec 0c             	sub    $0xc,%esp
     c12:	68 00 01 00 00       	push   $0x100
     c17:	e8 6d 0d 00 00       	call   1989 <malloc>
     c1c:	83 c4 10             	add    $0x10,%esp
     c1f:	89 03                	mov    %eax,(%ebx)
		if (text[n-1][0] == '\0')
     c21:	8b 45 0c             	mov    0xc(%ebp),%eax
     c24:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
     c29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     c30:	8b 45 08             	mov    0x8(%ebp),%eax
     c33:	01 d0                	add    %edx,%eax
     c35:	8b 00                	mov    (%eax),%eax
     c37:	0f b6 00             	movzbl (%eax),%eax
     c3a:	84 c0                	test   %al,%al
     c3c:	75 71                	jne    caf <com_ins+0x2f5>
		{
			memset(text[n], 0, MAX_LINE_LENGTH);
     c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
     c41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     c48:	8b 45 08             	mov    0x8(%ebp),%eax
     c4b:	01 d0                	add    %edx,%eax
     c4d:	8b 00                	mov    (%eax),%eax
     c4f:	83 ec 04             	sub    $0x4,%esp
     c52:	68 00 01 00 00       	push   $0x100
     c57:	6a 00                	push   $0x0
     c59:	50                   	push   %eax
     c5a:	e8 25 07 00 00       	call   1384 <memset>
     c5f:	83 c4 10             	add    $0x10,%esp
			strcpy(text[n-1], input);
     c62:	8b 45 0c             	mov    0xc(%ebp),%eax
     c65:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
     c6a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     c71:	8b 45 08             	mov    0x8(%ebp),%eax
     c74:	01 d0                	add    %edx,%eax
     c76:	8b 00                	mov    (%eax),%eax
     c78:	83 ec 08             	sub    $0x8,%esp
     c7b:	8d 95 f4 fe ff ff    	lea    -0x10c(%ebp),%edx
     c81:	52                   	push   %edx
     c82:	50                   	push   %eax
     c83:	e8 66 06 00 00       	call   12ee <strcpy>
     c88:	83 c4 10             	add    $0x10,%esp
			changed = 1;
     c8b:	c7 05 8c 21 00 00 01 	movl   $0x1,0x218c
     c92:	00 00 00 
			if (auto_show == 1)
     c95:	a1 74 21 00 00       	mov    0x2174,%eax
     c9a:	83 f8 01             	cmp    $0x1,%eax
     c9d:	75 7c                	jne    d1b <com_ins+0x361>
				show_text(text);
     c9f:	83 ec 0c             	sub    $0xc,%esp
     ca2:	ff 75 08             	pushl  0x8(%ebp)
     ca5:	e8 3c fb ff ff       	call   7e6 <show_text>
     caa:	83 c4 10             	add    $0x10,%esp
			return;
     cad:	eb 6c                	jmp    d1b <com_ins+0x361>
		}
	}
	memset(text[n], 0, MAX_LINE_LENGTH);
     caf:	8b 45 0c             	mov    0xc(%ebp),%eax
     cb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     cb9:	8b 45 08             	mov    0x8(%ebp),%eax
     cbc:	01 d0                	add    %edx,%eax
     cbe:	8b 00                	mov    (%eax),%eax
     cc0:	83 ec 04             	sub    $0x4,%esp
     cc3:	68 00 01 00 00       	push   $0x100
     cc8:	6a 00                	push   $0x0
     cca:	50                   	push   %eax
     ccb:	e8 b4 06 00 00       	call   1384 <memset>
     cd0:	83 c4 10             	add    $0x10,%esp
	strcpy(text[n], input);
     cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
     cd6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     cdd:	8b 45 08             	mov    0x8(%ebp),%eax
     ce0:	01 d0                	add    %edx,%eax
     ce2:	8b 00                	mov    (%eax),%eax
     ce4:	83 ec 08             	sub    $0x8,%esp
     ce7:	8d 95 f4 fe ff ff    	lea    -0x10c(%ebp),%edx
     ced:	52                   	push   %edx
     cee:	50                   	push   %eax
     cef:	e8 fa 05 00 00       	call   12ee <strcpy>
     cf4:	83 c4 10             	add    $0x10,%esp
	changed = 1;
     cf7:	c7 05 8c 21 00 00 01 	movl   $0x1,0x218c
     cfe:	00 00 00 
	if (auto_show == 1)
     d01:	a1 74 21 00 00       	mov    0x2174,%eax
     d06:	83 f8 01             	cmp    $0x1,%eax
     d09:	75 11                	jne    d1c <com_ins+0x362>
		show_text(text);
     d0b:	83 ec 0c             	sub    $0xc,%esp
     d0e:	ff 75 08             	pushl  0x8(%ebp)
     d11:	e8 d0 fa ff ff       	call   7e6 <show_text>
     d16:	83 c4 10             	add    $0x10,%esp
     d19:	eb 01                	jmp    d1c <com_ins+0x362>
			memset(text[n], 0, MAX_LINE_LENGTH);
			strcpy(text[n-1], input);
			changed = 1;
			if (auto_show == 1)
				show_text(text);
			return;
     d1b:	90                   	nop
	memset(text[n], 0, MAX_LINE_LENGTH);
	strcpy(text[n], input);
	changed = 1;
	if (auto_show == 1)
		show_text(text);
}
     d1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
     d1f:	5b                   	pop    %ebx
     d20:	5f                   	pop    %edi
     d21:	5d                   	pop    %ebp
     d22:	c3                   	ret    

00000d23 <com_mod>:

//修改命令，n为用户输入的行号，从1开始
//extra:输入命令时接着的信息，代表待修改成的文本
void com_mod(char *text[], int n, char *extra)
{
     d23:	55                   	push   %ebp
     d24:	89 e5                	mov    %esp,%ebp
     d26:	57                   	push   %edi
     d27:	81 ec 04 01 00 00    	sub    $0x104,%esp
	if (n <= 0 || n > get_line_number(text) + 1)
     d2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     d31:	7e 13                	jle    d46 <com_mod+0x23>
     d33:	ff 75 08             	pushl  0x8(%ebp)
     d36:	e8 ab fb ff ff       	call   8e6 <get_line_number>
     d3b:	83 c4 04             	add    $0x4,%esp
     d3e:	83 c0 01             	add    $0x1,%eax
     d41:	3b 45 0c             	cmp    0xc(%ebp),%eax
     d44:	7d 17                	jge    d5d <com_mod+0x3a>
	{
		printf(1, "invalid line number\n");
     d46:	83 ec 08             	sub    $0x8,%esp
     d49:	68 c6 1b 00 00       	push   $0x1bc6
     d4e:	6a 01                	push   $0x1
     d50:	e8 61 09 00 00       	call   16b6 <printf>
     d55:	83 c4 10             	add    $0x10,%esp
     d58:	e9 ef 00 00 00       	jmp    e4c <com_mod+0x129>
		return;
	}
	char input[MAX_LINE_LENGTH] = {};
     d5d:	8d 95 f8 fe ff ff    	lea    -0x108(%ebp),%edx
     d63:	b8 00 00 00 00       	mov    $0x0,%eax
     d68:	b9 40 00 00 00       	mov    $0x40,%ecx
     d6d:	89 d7                	mov    %edx,%edi
     d6f:	f3 ab                	rep stos %eax,%es:(%edi)
	if (*extra == '\0')
     d71:	8b 45 10             	mov    0x10(%ebp),%eax
     d74:	0f b6 00             	movzbl (%eax),%eax
     d77:	84 c0                	test   %al,%al
     d79:	75 48                	jne    dc3 <com_mod+0xa0>
	{
		printf(1, "please input content:\n");
     d7b:	83 ec 08             	sub    $0x8,%esp
     d7e:	68 db 1b 00 00       	push   $0x1bdb
     d83:	6a 01                	push   $0x1
     d85:	e8 2c 09 00 00       	call   16b6 <printf>
     d8a:	83 c4 10             	add    $0x10,%esp
		gets(input, MAX_LINE_LENGTH);
     d8d:	83 ec 08             	sub    $0x8,%esp
     d90:	68 00 01 00 00       	push   $0x100
     d95:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
     d9b:	50                   	push   %eax
     d9c:	e8 30 06 00 00       	call   13d1 <gets>
     da1:	83 c4 10             	add    $0x10,%esp
		input[strlen(input)-1] = '\0';
     da4:	83 ec 0c             	sub    $0xc,%esp
     da7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
     dad:	50                   	push   %eax
     dae:	e8 aa 05 00 00       	call   135d <strlen>
     db3:	83 c4 10             	add    $0x10,%esp
     db6:	83 e8 01             	sub    $0x1,%eax
     db9:	c6 84 05 f8 fe ff ff 	movb   $0x0,-0x108(%ebp,%eax,1)
     dc0:	00 
     dc1:	eb 15                	jmp    dd8 <com_mod+0xb5>
	}
	else
		strcpy(input, extra);
     dc3:	83 ec 08             	sub    $0x8,%esp
     dc6:	ff 75 10             	pushl  0x10(%ebp)
     dc9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
     dcf:	50                   	push   %eax
     dd0:	e8 19 05 00 00       	call   12ee <strcpy>
     dd5:	83 c4 10             	add    $0x10,%esp
	memset(text[n-1], 0, MAX_LINE_LENGTH);
     dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
     ddb:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
     de0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     de7:	8b 45 08             	mov    0x8(%ebp),%eax
     dea:	01 d0                	add    %edx,%eax
     dec:	8b 00                	mov    (%eax),%eax
     dee:	83 ec 04             	sub    $0x4,%esp
     df1:	68 00 01 00 00       	push   $0x100
     df6:	6a 00                	push   $0x0
     df8:	50                   	push   %eax
     df9:	e8 86 05 00 00       	call   1384 <memset>
     dfe:	83 c4 10             	add    $0x10,%esp
	strcpy(text[n-1], input);
     e01:	8b 45 0c             	mov    0xc(%ebp),%eax
     e04:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
     e09:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     e10:	8b 45 08             	mov    0x8(%ebp),%eax
     e13:	01 d0                	add    %edx,%eax
     e15:	8b 00                	mov    (%eax),%eax
     e17:	83 ec 08             	sub    $0x8,%esp
     e1a:	8d 95 f8 fe ff ff    	lea    -0x108(%ebp),%edx
     e20:	52                   	push   %edx
     e21:	50                   	push   %eax
     e22:	e8 c7 04 00 00       	call   12ee <strcpy>
     e27:	83 c4 10             	add    $0x10,%esp
	changed = 1;
     e2a:	c7 05 8c 21 00 00 01 	movl   $0x1,0x218c
     e31:	00 00 00 
	if (auto_show == 1)
     e34:	a1 74 21 00 00       	mov    0x2174,%eax
     e39:	83 f8 01             	cmp    $0x1,%eax
     e3c:	75 0e                	jne    e4c <com_mod+0x129>
		show_text(text);
     e3e:	83 ec 0c             	sub    $0xc,%esp
     e41:	ff 75 08             	pushl  0x8(%ebp)
     e44:	e8 9d f9 ff ff       	call   7e6 <show_text>
     e49:	83 c4 10             	add    $0x10,%esp
}
     e4c:	8b 7d fc             	mov    -0x4(%ebp),%edi
     e4f:	c9                   	leave  
     e50:	c3                   	ret    

00000e51 <com_del>:

//删除命令，n为用户输入的行号，从1开始
void com_del(char *text[], int n)
{
     e51:	55                   	push   %ebp
     e52:	89 e5                	mov    %esp,%ebp
     e54:	83 ec 18             	sub    $0x18,%esp
	if (n <= 0 || n > get_line_number(text) + 1)
     e57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     e5b:	7e 13                	jle    e70 <com_del+0x1f>
     e5d:	ff 75 08             	pushl  0x8(%ebp)
     e60:	e8 81 fa ff ff       	call   8e6 <get_line_number>
     e65:	83 c4 04             	add    $0x4,%esp
     e68:	83 c0 01             	add    $0x1,%eax
     e6b:	3b 45 0c             	cmp    0xc(%ebp),%eax
     e6e:	7d 17                	jge    e87 <com_del+0x36>
	{
		printf(1, "invalid line number\n");
     e70:	83 ec 08             	sub    $0x8,%esp
     e73:	68 c6 1b 00 00       	push   $0x1bc6
     e78:	6a 01                	push   $0x1
     e7a:	e8 37 08 00 00       	call   16b6 <printf>
     e7f:	83 c4 10             	add    $0x10,%esp
		return;
     e82:	e9 03 01 00 00       	jmp    f8a <com_del+0x139>
	}
	memset(text[n-1], 0, MAX_LINE_LENGTH);
     e87:	8b 45 0c             	mov    0xc(%ebp),%eax
     e8a:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
     e8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     e96:	8b 45 08             	mov    0x8(%ebp),%eax
     e99:	01 d0                	add    %edx,%eax
     e9b:	8b 00                	mov    (%eax),%eax
     e9d:	83 ec 04             	sub    $0x4,%esp
     ea0:	68 00 01 00 00       	push   $0x100
     ea5:	6a 00                	push   $0x0
     ea7:	50                   	push   %eax
     ea8:	e8 d7 04 00 00       	call   1384 <memset>
     ead:	83 c4 10             	add    $0x10,%esp
	int i = n - 1;
     eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
     eb3:	83 e8 01             	sub    $0x1,%eax
     eb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (; text[i+1] != NULL; i++)
     eb9:	eb 5d                	jmp    f18 <com_del+0xc7>
	{
		strcpy(text[i], text[i+1]);
     ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ebe:	83 c0 01             	add    $0x1,%eax
     ec1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     ec8:	8b 45 08             	mov    0x8(%ebp),%eax
     ecb:	01 d0                	add    %edx,%eax
     ecd:	8b 10                	mov    (%eax),%edx
     ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ed2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
     ed9:	8b 45 08             	mov    0x8(%ebp),%eax
     edc:	01 c8                	add    %ecx,%eax
     ede:	8b 00                	mov    (%eax),%eax
     ee0:	83 ec 08             	sub    $0x8,%esp
     ee3:	52                   	push   %edx
     ee4:	50                   	push   %eax
     ee5:	e8 04 04 00 00       	call   12ee <strcpy>
     eea:	83 c4 10             	add    $0x10,%esp
		memset(text[i+1], 0, MAX_LINE_LENGTH);
     eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ef0:	83 c0 01             	add    $0x1,%eax
     ef3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     efa:	8b 45 08             	mov    0x8(%ebp),%eax
     efd:	01 d0                	add    %edx,%eax
     eff:	8b 00                	mov    (%eax),%eax
     f01:	83 ec 04             	sub    $0x4,%esp
     f04:	68 00 01 00 00       	push   $0x100
     f09:	6a 00                	push   $0x0
     f0b:	50                   	push   %eax
     f0c:	e8 73 04 00 00       	call   1384 <memset>
     f11:	83 c4 10             	add    $0x10,%esp
		printf(1, "invalid line number\n");
		return;
	}
	memset(text[n-1], 0, MAX_LINE_LENGTH);
	int i = n - 1;
	for (; text[i+1] != NULL; i++)
     f14:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f1b:	83 c0 01             	add    $0x1,%eax
     f1e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     f25:	8b 45 08             	mov    0x8(%ebp),%eax
     f28:	01 d0                	add    %edx,%eax
     f2a:	8b 00                	mov    (%eax),%eax
     f2c:	85 c0                	test   %eax,%eax
     f2e:	75 8b                	jne    ebb <com_del+0x6a>
	{
		strcpy(text[i], text[i+1]);
		memset(text[i+1], 0, MAX_LINE_LENGTH);
	}
	if (i != 0)
     f30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     f34:	74 32                	je     f68 <com_del+0x117>
	{
		free(text[i]);
     f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f39:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     f40:	8b 45 08             	mov    0x8(%ebp),%eax
     f43:	01 d0                	add    %edx,%eax
     f45:	8b 00                	mov    (%eax),%eax
     f47:	83 ec 0c             	sub    $0xc,%esp
     f4a:	50                   	push   %eax
     f4b:	e8 f7 08 00 00       	call   1847 <free>
     f50:	83 c4 10             	add    $0x10,%esp
		text[i] = 0;
     f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f56:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     f5d:	8b 45 08             	mov    0x8(%ebp),%eax
     f60:	01 d0                	add    %edx,%eax
     f62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	changed = 1;
     f68:	c7 05 8c 21 00 00 01 	movl   $0x1,0x218c
     f6f:	00 00 00 
	if (auto_show == 1)
     f72:	a1 74 21 00 00       	mov    0x2174,%eax
     f77:	83 f8 01             	cmp    $0x1,%eax
     f7a:	75 0e                	jne    f8a <com_del+0x139>
		show_text(text);
     f7c:	83 ec 0c             	sub    $0xc,%esp
     f7f:	ff 75 08             	pushl  0x8(%ebp)
     f82:	e8 5f f8 ff ff       	call   7e6 <show_text>
     f87:	83 c4 10             	add    $0x10,%esp
}
     f8a:	c9                   	leave  
     f8b:	c3                   	ret    

00000f8c <com_help>:

void com_help(char *text[])
{
     f8c:	55                   	push   %ebp
     f8d:	89 e5                	mov    %esp,%ebp
     f8f:	83 ec 08             	sub    $0x8,%esp
	printf(1, "****************************************\n");
     f92:	83 ec 08             	sub    $0x8,%esp
     f95:	68 70 1b 00 00       	push   $0x1b70
     f9a:	6a 01                	push   $0x1
     f9c:	e8 15 07 00 00       	call   16b6 <printf>
     fa1:	83 c4 10             	add    $0x10,%esp
	printf(1, "instructions for use:\n");
     fa4:	83 ec 08             	sub    $0x8,%esp
     fa7:	68 f2 1b 00 00       	push   $0x1bf2
     fac:	6a 01                	push   $0x1
     fae:	e8 03 07 00 00       	call   16b6 <printf>
     fb3:	83 c4 10             	add    $0x10,%esp
	printf(1, "ins-n, insert a line after line n\n");
     fb6:	83 ec 08             	sub    $0x8,%esp
     fb9:	68 0c 1c 00 00       	push   $0x1c0c
     fbe:	6a 01                	push   $0x1
     fc0:	e8 f1 06 00 00       	call   16b6 <printf>
     fc5:	83 c4 10             	add    $0x10,%esp
	printf(1, "mod-n, modify line n\n");
     fc8:	83 ec 08             	sub    $0x8,%esp
     fcb:	68 2f 1c 00 00       	push   $0x1c2f
     fd0:	6a 01                	push   $0x1
     fd2:	e8 df 06 00 00       	call   16b6 <printf>
     fd7:	83 c4 10             	add    $0x10,%esp
	printf(1, "del-n, delete line n\n");
     fda:	83 ec 08             	sub    $0x8,%esp
     fdd:	68 45 1c 00 00       	push   $0x1c45
     fe2:	6a 01                	push   $0x1
     fe4:	e8 cd 06 00 00       	call   16b6 <printf>
     fe9:	83 c4 10             	add    $0x10,%esp
	printf(1, "ins, insert a line after the last line\n");
     fec:	83 ec 08             	sub    $0x8,%esp
     fef:	68 5c 1c 00 00       	push   $0x1c5c
     ff4:	6a 01                	push   $0x1
     ff6:	e8 bb 06 00 00       	call   16b6 <printf>
     ffb:	83 c4 10             	add    $0x10,%esp
	printf(1, "mod, modify the last line\n");
     ffe:	83 ec 08             	sub    $0x8,%esp
    1001:	68 84 1c 00 00       	push   $0x1c84
    1006:	6a 01                	push   $0x1
    1008:	e8 a9 06 00 00       	call   16b6 <printf>
    100d:	83 c4 10             	add    $0x10,%esp
	printf(1, "del, delete the last line\n");
    1010:	83 ec 08             	sub    $0x8,%esp
    1013:	68 9f 1c 00 00       	push   $0x1c9f
    1018:	6a 01                	push   $0x1
    101a:	e8 97 06 00 00       	call   16b6 <printf>
    101f:	83 c4 10             	add    $0x10,%esp
	printf(1, "show, enable show current contents after executing a command.\n");
    1022:	83 ec 08             	sub    $0x8,%esp
    1025:	68 bc 1c 00 00       	push   $0x1cbc
    102a:	6a 01                	push   $0x1
    102c:	e8 85 06 00 00       	call   16b6 <printf>
    1031:	83 c4 10             	add    $0x10,%esp
	printf(1, "hide, disable show current contents after executing a command.\n");
    1034:	83 ec 08             	sub    $0x8,%esp
    1037:	68 fc 1c 00 00       	push   $0x1cfc
    103c:	6a 01                	push   $0x1
    103e:	e8 73 06 00 00       	call   16b6 <printf>
    1043:	83 c4 10             	add    $0x10,%esp
	printf(1, "save, save the file\n");
    1046:	83 ec 08             	sub    $0x8,%esp
    1049:	68 3c 1d 00 00       	push   $0x1d3c
    104e:	6a 01                	push   $0x1
    1050:	e8 61 06 00 00       	call   16b6 <printf>
    1055:	83 c4 10             	add    $0x10,%esp
	printf(1, "exit, exit editor\n");
    1058:	83 ec 08             	sub    $0x8,%esp
    105b:	68 51 1d 00 00       	push   $0x1d51
    1060:	6a 01                	push   $0x1
    1062:	e8 4f 06 00 00       	call   16b6 <printf>
    1067:	83 c4 10             	add    $0x10,%esp
}
    106a:	90                   	nop
    106b:	c9                   	leave  
    106c:	c3                   	ret    

0000106d <com_save>:

void com_save(char *text[], char *path)
{
    106d:	55                   	push   %ebp
    106e:	89 e5                	mov    %esp,%ebp
    1070:	83 ec 18             	sub    $0x18,%esp
	//删除旧有文件
	unlink(path);
    1073:	83 ec 0c             	sub    $0xc,%esp
    1076:	ff 75 0c             	pushl  0xc(%ebp)
    1079:	e8 f1 04 00 00       	call   156f <unlink>
    107e:	83 c4 10             	add    $0x10,%esp
	//新建文件并打开
	int fd = open(path, O_WRONLY|O_CREATE);
    1081:	83 ec 08             	sub    $0x8,%esp
    1084:	68 01 02 00 00       	push   $0x201
    1089:	ff 75 0c             	pushl  0xc(%ebp)
    108c:	e8 ce 04 00 00       	call   155f <open>
    1091:	83 c4 10             	add    $0x10,%esp
    1094:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (fd == -1)
    1097:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
    109b:	75 17                	jne    10b4 <com_save+0x47>
	{
		printf(1, "save failed, file can't open:\n");
    109d:	83 ec 08             	sub    $0x8,%esp
    10a0:	68 64 1d 00 00       	push   $0x1d64
    10a5:	6a 01                	push   $0x1
    10a7:	e8 0a 06 00 00       	call   16b6 <printf>
    10ac:	83 c4 10             	add    $0x10,%esp
		//setProgramStatus(SHELL);
		exit();
    10af:	e8 6b 04 00 00       	call   151f <exit>
	}
	if (text[0] == NULL)
    10b4:	8b 45 08             	mov    0x8(%ebp),%eax
    10b7:	8b 00                	mov    (%eax),%eax
    10b9:	85 c0                	test   %eax,%eax
    10bb:	75 13                	jne    10d0 <com_save+0x63>
	{
		close(fd);
    10bd:	83 ec 0c             	sub    $0xc,%esp
    10c0:	ff 75 f0             	pushl  -0x10(%ebp)
    10c3:	e8 7f 04 00 00       	call   1547 <close>
    10c8:	83 c4 10             	add    $0x10,%esp
		return;
    10cb:	e9 c8 00 00 00       	jmp    1198 <com_save+0x12b>
	}
	//写数据
	write(fd, text[0], strlen(text[0]));
    10d0:	8b 45 08             	mov    0x8(%ebp),%eax
    10d3:	8b 00                	mov    (%eax),%eax
    10d5:	83 ec 0c             	sub    $0xc,%esp
    10d8:	50                   	push   %eax
    10d9:	e8 7f 02 00 00       	call   135d <strlen>
    10de:	83 c4 10             	add    $0x10,%esp
    10e1:	89 c2                	mov    %eax,%edx
    10e3:	8b 45 08             	mov    0x8(%ebp),%eax
    10e6:	8b 00                	mov    (%eax),%eax
    10e8:	83 ec 04             	sub    $0x4,%esp
    10eb:	52                   	push   %edx
    10ec:	50                   	push   %eax
    10ed:	ff 75 f0             	pushl  -0x10(%ebp)
    10f0:	e8 4a 04 00 00       	call   153f <write>
    10f5:	83 c4 10             	add    $0x10,%esp
	int i = 1;
    10f8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	for (; text[i] != NULL; i++)
    10ff:	eb 57                	jmp    1158 <com_save+0xeb>
	{
		printf(fd, "\n");
    1101:	83 ec 08             	sub    $0x8,%esp
    1104:	68 83 1d 00 00       	push   $0x1d83
    1109:	ff 75 f0             	pushl  -0x10(%ebp)
    110c:	e8 a5 05 00 00       	call   16b6 <printf>
    1111:	83 c4 10             	add    $0x10,%esp
		write(fd, text[i], strlen(text[i]));
    1114:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1117:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    111e:	8b 45 08             	mov    0x8(%ebp),%eax
    1121:	01 d0                	add    %edx,%eax
    1123:	8b 00                	mov    (%eax),%eax
    1125:	83 ec 0c             	sub    $0xc,%esp
    1128:	50                   	push   %eax
    1129:	e8 2f 02 00 00       	call   135d <strlen>
    112e:	83 c4 10             	add    $0x10,%esp
    1131:	89 c1                	mov    %eax,%ecx
    1133:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1136:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    113d:	8b 45 08             	mov    0x8(%ebp),%eax
    1140:	01 d0                	add    %edx,%eax
    1142:	8b 00                	mov    (%eax),%eax
    1144:	83 ec 04             	sub    $0x4,%esp
    1147:	51                   	push   %ecx
    1148:	50                   	push   %eax
    1149:	ff 75 f0             	pushl  -0x10(%ebp)
    114c:	e8 ee 03 00 00       	call   153f <write>
    1151:	83 c4 10             	add    $0x10,%esp
		return;
	}
	//写数据
	write(fd, text[0], strlen(text[0]));
	int i = 1;
	for (; text[i] != NULL; i++)
    1154:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1158:	8b 45 f4             	mov    -0xc(%ebp),%eax
    115b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    1162:	8b 45 08             	mov    0x8(%ebp),%eax
    1165:	01 d0                	add    %edx,%eax
    1167:	8b 00                	mov    (%eax),%eax
    1169:	85 c0                	test   %eax,%eax
    116b:	75 94                	jne    1101 <com_save+0x94>
	{
		printf(fd, "\n");
		write(fd, text[i], strlen(text[i]));
	}
	close(fd);
    116d:	83 ec 0c             	sub    $0xc,%esp
    1170:	ff 75 f0             	pushl  -0x10(%ebp)
    1173:	e8 cf 03 00 00       	call   1547 <close>
    1178:	83 c4 10             	add    $0x10,%esp
	printf(1, "saved successfully\n");
    117b:	83 ec 08             	sub    $0x8,%esp
    117e:	68 85 1d 00 00       	push   $0x1d85
    1183:	6a 01                	push   $0x1
    1185:	e8 2c 05 00 00       	call   16b6 <printf>
    118a:	83 c4 10             	add    $0x10,%esp
	changed = 0;
    118d:	c7 05 8c 21 00 00 00 	movl   $0x0,0x218c
    1194:	00 00 00 
	return;
    1197:	90                   	nop
}
    1198:	c9                   	leave  
    1199:	c3                   	ret    

0000119a <com_exit>:

void com_exit(char *text[], char *path)
{
    119a:	55                   	push   %ebp
    119b:	89 e5                	mov    %esp,%ebp
    119d:	57                   	push   %edi
    119e:	81 ec 14 01 00 00    	sub    $0x114,%esp
	//询问是否保存
	while (changed == 1)
    11a4:	e9 b5 00 00 00       	jmp    125e <com_exit+0xc4>
	{
		printf(1, "save the file? y/n\n");
    11a9:	83 ec 08             	sub    $0x8,%esp
    11ac:	68 99 1d 00 00       	push   $0x1d99
    11b1:	6a 01                	push   $0x1
    11b3:	e8 fe 04 00 00       	call   16b6 <printf>
    11b8:	83 c4 10             	add    $0x10,%esp
		char input[MAX_LINE_LENGTH] = {};
    11bb:	8d 95 f4 fe ff ff    	lea    -0x10c(%ebp),%edx
    11c1:	b8 00 00 00 00       	mov    $0x0,%eax
    11c6:	b9 40 00 00 00       	mov    $0x40,%ecx
    11cb:	89 d7                	mov    %edx,%edi
    11cd:	f3 ab                	rep stos %eax,%es:(%edi)
		gets(input, MAX_LINE_LENGTH);
    11cf:	83 ec 08             	sub    $0x8,%esp
    11d2:	68 00 01 00 00       	push   $0x100
    11d7:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
    11dd:	50                   	push   %eax
    11de:	e8 ee 01 00 00       	call   13d1 <gets>
    11e3:	83 c4 10             	add    $0x10,%esp
		input[strlen(input)-1] = '\0';
    11e6:	83 ec 0c             	sub    $0xc,%esp
    11e9:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
    11ef:	50                   	push   %eax
    11f0:	e8 68 01 00 00       	call   135d <strlen>
    11f5:	83 c4 10             	add    $0x10,%esp
    11f8:	83 e8 01             	sub    $0x1,%eax
    11fb:	c6 84 05 f4 fe ff ff 	movb   $0x0,-0x10c(%ebp,%eax,1)
    1202:	00 
		if (strcmp(input, "y") == 0)
    1203:	83 ec 08             	sub    $0x8,%esp
    1206:	68 ad 1d 00 00       	push   $0x1dad
    120b:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
    1211:	50                   	push   %eax
    1212:	e8 07 01 00 00       	call   131e <strcmp>
    1217:	83 c4 10             	add    $0x10,%esp
    121a:	85 c0                	test   %eax,%eax
    121c:	75 13                	jne    1231 <com_exit+0x97>
			com_save(text, path);
    121e:	83 ec 08             	sub    $0x8,%esp
    1221:	ff 75 0c             	pushl  0xc(%ebp)
    1224:	ff 75 08             	pushl  0x8(%ebp)
    1227:	e8 41 fe ff ff       	call   106d <com_save>
    122c:	83 c4 10             	add    $0x10,%esp
    122f:	eb 2d                	jmp    125e <com_exit+0xc4>
		else if(strcmp(input, "n") == 0)
    1231:	83 ec 08             	sub    $0x8,%esp
    1234:	68 af 1d 00 00       	push   $0x1daf
    1239:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
    123f:	50                   	push   %eax
    1240:	e8 d9 00 00 00       	call   131e <strcmp>
    1245:	83 c4 10             	add    $0x10,%esp
    1248:	85 c0                	test   %eax,%eax
    124a:	74 22                	je     126e <com_exit+0xd4>
			break;
		else
		printf(2, "wrong answer?\n");
    124c:	83 ec 08             	sub    $0x8,%esp
    124f:	68 b1 1d 00 00       	push   $0x1db1
    1254:	6a 02                	push   $0x2
    1256:	e8 5b 04 00 00       	call   16b6 <printf>
    125b:	83 c4 10             	add    $0x10,%esp
}

void com_exit(char *text[], char *path)
{
	//询问是否保存
	while (changed == 1)
    125e:	a1 8c 21 00 00       	mov    0x218c,%eax
    1263:	83 f8 01             	cmp    $0x1,%eax
    1266:	0f 84 3d ff ff ff    	je     11a9 <com_exit+0xf>
    126c:	eb 01                	jmp    126f <com_exit+0xd5>
		gets(input, MAX_LINE_LENGTH);
		input[strlen(input)-1] = '\0';
		if (strcmp(input, "y") == 0)
			com_save(text, path);
		else if(strcmp(input, "n") == 0)
			break;
    126e:	90                   	nop
		else
		printf(2, "wrong answer?\n");
	}
	//释放内存
	int i = 0;
    126f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (; text[i] != NULL; i++)
    1276:	eb 36                	jmp    12ae <com_exit+0x114>
	{
		free(text[i]);
    1278:	8b 45 f4             	mov    -0xc(%ebp),%eax
    127b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    1282:	8b 45 08             	mov    0x8(%ebp),%eax
    1285:	01 d0                	add    %edx,%eax
    1287:	8b 00                	mov    (%eax),%eax
    1289:	83 ec 0c             	sub    $0xc,%esp
    128c:	50                   	push   %eax
    128d:	e8 b5 05 00 00       	call   1847 <free>
    1292:	83 c4 10             	add    $0x10,%esp
		text[i] = 0;
    1295:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1298:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    129f:	8b 45 08             	mov    0x8(%ebp),%eax
    12a2:	01 d0                	add    %edx,%eax
    12a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		else
		printf(2, "wrong answer?\n");
	}
	//释放内存
	int i = 0;
	for (; text[i] != NULL; i++)
    12aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    12ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12b1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    12b8:	8b 45 08             	mov    0x8(%ebp),%eax
    12bb:	01 d0                	add    %edx,%eax
    12bd:	8b 00                	mov    (%eax),%eax
    12bf:	85 c0                	test   %eax,%eax
    12c1:	75 b5                	jne    1278 <com_exit+0xde>
		free(text[i]);
		text[i] = 0;
	}
	//退出
	//setProgramStatus(SHELL);
	exit();
    12c3:	e8 57 02 00 00       	call   151f <exit>

000012c8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    12c8:	55                   	push   %ebp
    12c9:	89 e5                	mov    %esp,%ebp
    12cb:	57                   	push   %edi
    12cc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    12cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
    12d0:	8b 55 10             	mov    0x10(%ebp),%edx
    12d3:	8b 45 0c             	mov    0xc(%ebp),%eax
    12d6:	89 cb                	mov    %ecx,%ebx
    12d8:	89 df                	mov    %ebx,%edi
    12da:	89 d1                	mov    %edx,%ecx
    12dc:	fc                   	cld    
    12dd:	f3 aa                	rep stos %al,%es:(%edi)
    12df:	89 ca                	mov    %ecx,%edx
    12e1:	89 fb                	mov    %edi,%ebx
    12e3:	89 5d 08             	mov    %ebx,0x8(%ebp)
    12e6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    12e9:	90                   	nop
    12ea:	5b                   	pop    %ebx
    12eb:	5f                   	pop    %edi
    12ec:	5d                   	pop    %ebp
    12ed:	c3                   	ret    

000012ee <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    12ee:	55                   	push   %ebp
    12ef:	89 e5                	mov    %esp,%ebp
    12f1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    12f4:	8b 45 08             	mov    0x8(%ebp),%eax
    12f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    12fa:	90                   	nop
    12fb:	8b 45 08             	mov    0x8(%ebp),%eax
    12fe:	8d 50 01             	lea    0x1(%eax),%edx
    1301:	89 55 08             	mov    %edx,0x8(%ebp)
    1304:	8b 55 0c             	mov    0xc(%ebp),%edx
    1307:	8d 4a 01             	lea    0x1(%edx),%ecx
    130a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    130d:	0f b6 12             	movzbl (%edx),%edx
    1310:	88 10                	mov    %dl,(%eax)
    1312:	0f b6 00             	movzbl (%eax),%eax
    1315:	84 c0                	test   %al,%al
    1317:	75 e2                	jne    12fb <strcpy+0xd>
    ;
  return os;
    1319:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    131c:	c9                   	leave  
    131d:	c3                   	ret    

0000131e <strcmp>:

int
strcmp(const char *p, const char *q)
{
    131e:	55                   	push   %ebp
    131f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    1321:	eb 08                	jmp    132b <strcmp+0xd>
    p++, q++;
    1323:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1327:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    132b:	8b 45 08             	mov    0x8(%ebp),%eax
    132e:	0f b6 00             	movzbl (%eax),%eax
    1331:	84 c0                	test   %al,%al
    1333:	74 10                	je     1345 <strcmp+0x27>
    1335:	8b 45 08             	mov    0x8(%ebp),%eax
    1338:	0f b6 10             	movzbl (%eax),%edx
    133b:	8b 45 0c             	mov    0xc(%ebp),%eax
    133e:	0f b6 00             	movzbl (%eax),%eax
    1341:	38 c2                	cmp    %al,%dl
    1343:	74 de                	je     1323 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    1345:	8b 45 08             	mov    0x8(%ebp),%eax
    1348:	0f b6 00             	movzbl (%eax),%eax
    134b:	0f b6 d0             	movzbl %al,%edx
    134e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1351:	0f b6 00             	movzbl (%eax),%eax
    1354:	0f b6 c0             	movzbl %al,%eax
    1357:	29 c2                	sub    %eax,%edx
    1359:	89 d0                	mov    %edx,%eax
}
    135b:	5d                   	pop    %ebp
    135c:	c3                   	ret    

0000135d <strlen>:

uint
strlen(char *s)
{
    135d:	55                   	push   %ebp
    135e:	89 e5                	mov    %esp,%ebp
    1360:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1363:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    136a:	eb 04                	jmp    1370 <strlen+0x13>
    136c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1370:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1373:	8b 45 08             	mov    0x8(%ebp),%eax
    1376:	01 d0                	add    %edx,%eax
    1378:	0f b6 00             	movzbl (%eax),%eax
    137b:	84 c0                	test   %al,%al
    137d:	75 ed                	jne    136c <strlen+0xf>
    ;
  return n;
    137f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1382:	c9                   	leave  
    1383:	c3                   	ret    

00001384 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1384:	55                   	push   %ebp
    1385:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    1387:	8b 45 10             	mov    0x10(%ebp),%eax
    138a:	50                   	push   %eax
    138b:	ff 75 0c             	pushl  0xc(%ebp)
    138e:	ff 75 08             	pushl  0x8(%ebp)
    1391:	e8 32 ff ff ff       	call   12c8 <stosb>
    1396:	83 c4 0c             	add    $0xc,%esp
  return dst;
    1399:	8b 45 08             	mov    0x8(%ebp),%eax
}
    139c:	c9                   	leave  
    139d:	c3                   	ret    

0000139e <strchr>:

char*
strchr(const char *s, char c)
{
    139e:	55                   	push   %ebp
    139f:	89 e5                	mov    %esp,%ebp
    13a1:	83 ec 04             	sub    $0x4,%esp
    13a4:	8b 45 0c             	mov    0xc(%ebp),%eax
    13a7:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    13aa:	eb 14                	jmp    13c0 <strchr+0x22>
    if(*s == c)
    13ac:	8b 45 08             	mov    0x8(%ebp),%eax
    13af:	0f b6 00             	movzbl (%eax),%eax
    13b2:	3a 45 fc             	cmp    -0x4(%ebp),%al
    13b5:	75 05                	jne    13bc <strchr+0x1e>
      return (char*)s;
    13b7:	8b 45 08             	mov    0x8(%ebp),%eax
    13ba:	eb 13                	jmp    13cf <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    13bc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    13c0:	8b 45 08             	mov    0x8(%ebp),%eax
    13c3:	0f b6 00             	movzbl (%eax),%eax
    13c6:	84 c0                	test   %al,%al
    13c8:	75 e2                	jne    13ac <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    13ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
    13cf:	c9                   	leave  
    13d0:	c3                   	ret    

000013d1 <gets>:

char*
gets(char *buf, int max)
{
    13d1:	55                   	push   %ebp
    13d2:	89 e5                	mov    %esp,%ebp
    13d4:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    13d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    13de:	eb 42                	jmp    1422 <gets+0x51>
    cc = read(0, &c, 1);
    13e0:	83 ec 04             	sub    $0x4,%esp
    13e3:	6a 01                	push   $0x1
    13e5:	8d 45 ef             	lea    -0x11(%ebp),%eax
    13e8:	50                   	push   %eax
    13e9:	6a 00                	push   $0x0
    13eb:	e8 47 01 00 00       	call   1537 <read>
    13f0:	83 c4 10             	add    $0x10,%esp
    13f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    13f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    13fa:	7e 33                	jle    142f <gets+0x5e>
      break;
    buf[i++] = c;
    13fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13ff:	8d 50 01             	lea    0x1(%eax),%edx
    1402:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1405:	89 c2                	mov    %eax,%edx
    1407:	8b 45 08             	mov    0x8(%ebp),%eax
    140a:	01 c2                	add    %eax,%edx
    140c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1410:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1412:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1416:	3c 0a                	cmp    $0xa,%al
    1418:	74 16                	je     1430 <gets+0x5f>
    141a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    141e:	3c 0d                	cmp    $0xd,%al
    1420:	74 0e                	je     1430 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1422:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1425:	83 c0 01             	add    $0x1,%eax
    1428:	3b 45 0c             	cmp    0xc(%ebp),%eax
    142b:	7c b3                	jl     13e0 <gets+0xf>
    142d:	eb 01                	jmp    1430 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    142f:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1430:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1433:	8b 45 08             	mov    0x8(%ebp),%eax
    1436:	01 d0                	add    %edx,%eax
    1438:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    143b:	8b 45 08             	mov    0x8(%ebp),%eax
}
    143e:	c9                   	leave  
    143f:	c3                   	ret    

00001440 <stat>:

int
stat(char *n, struct stat *st)
{
    1440:	55                   	push   %ebp
    1441:	89 e5                	mov    %esp,%ebp
    1443:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    1446:	83 ec 08             	sub    $0x8,%esp
    1449:	6a 00                	push   $0x0
    144b:	ff 75 08             	pushl  0x8(%ebp)
    144e:	e8 0c 01 00 00       	call   155f <open>
    1453:	83 c4 10             	add    $0x10,%esp
    1456:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1459:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    145d:	79 07                	jns    1466 <stat+0x26>
    return -1;
    145f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1464:	eb 25                	jmp    148b <stat+0x4b>
  r = fstat(fd, st);
    1466:	83 ec 08             	sub    $0x8,%esp
    1469:	ff 75 0c             	pushl  0xc(%ebp)
    146c:	ff 75 f4             	pushl  -0xc(%ebp)
    146f:	e8 03 01 00 00       	call   1577 <fstat>
    1474:	83 c4 10             	add    $0x10,%esp
    1477:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    147a:	83 ec 0c             	sub    $0xc,%esp
    147d:	ff 75 f4             	pushl  -0xc(%ebp)
    1480:	e8 c2 00 00 00       	call   1547 <close>
    1485:	83 c4 10             	add    $0x10,%esp
  return r;
    1488:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    148b:	c9                   	leave  
    148c:	c3                   	ret    

0000148d <atoi>:

int
atoi(const char *s)
{
    148d:	55                   	push   %ebp
    148e:	89 e5                	mov    %esp,%ebp
    1490:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1493:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    149a:	eb 25                	jmp    14c1 <atoi+0x34>
    n = n*10 + *s++ - '0';
    149c:	8b 55 fc             	mov    -0x4(%ebp),%edx
    149f:	89 d0                	mov    %edx,%eax
    14a1:	c1 e0 02             	shl    $0x2,%eax
    14a4:	01 d0                	add    %edx,%eax
    14a6:	01 c0                	add    %eax,%eax
    14a8:	89 c1                	mov    %eax,%ecx
    14aa:	8b 45 08             	mov    0x8(%ebp),%eax
    14ad:	8d 50 01             	lea    0x1(%eax),%edx
    14b0:	89 55 08             	mov    %edx,0x8(%ebp)
    14b3:	0f b6 00             	movzbl (%eax),%eax
    14b6:	0f be c0             	movsbl %al,%eax
    14b9:	01 c8                	add    %ecx,%eax
    14bb:	83 e8 30             	sub    $0x30,%eax
    14be:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    14c1:	8b 45 08             	mov    0x8(%ebp),%eax
    14c4:	0f b6 00             	movzbl (%eax),%eax
    14c7:	3c 2f                	cmp    $0x2f,%al
    14c9:	7e 0a                	jle    14d5 <atoi+0x48>
    14cb:	8b 45 08             	mov    0x8(%ebp),%eax
    14ce:	0f b6 00             	movzbl (%eax),%eax
    14d1:	3c 39                	cmp    $0x39,%al
    14d3:	7e c7                	jle    149c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    14d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    14d8:	c9                   	leave  
    14d9:	c3                   	ret    

000014da <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    14da:	55                   	push   %ebp
    14db:	89 e5                	mov    %esp,%ebp
    14dd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    14e0:	8b 45 08             	mov    0x8(%ebp),%eax
    14e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    14e6:	8b 45 0c             	mov    0xc(%ebp),%eax
    14e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    14ec:	eb 17                	jmp    1505 <memmove+0x2b>
    *dst++ = *src++;
    14ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
    14f1:	8d 50 01             	lea    0x1(%eax),%edx
    14f4:	89 55 fc             	mov    %edx,-0x4(%ebp)
    14f7:	8b 55 f8             	mov    -0x8(%ebp),%edx
    14fa:	8d 4a 01             	lea    0x1(%edx),%ecx
    14fd:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1500:	0f b6 12             	movzbl (%edx),%edx
    1503:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1505:	8b 45 10             	mov    0x10(%ebp),%eax
    1508:	8d 50 ff             	lea    -0x1(%eax),%edx
    150b:	89 55 10             	mov    %edx,0x10(%ebp)
    150e:	85 c0                	test   %eax,%eax
    1510:	7f dc                	jg     14ee <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1512:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1515:	c9                   	leave  
    1516:	c3                   	ret    

00001517 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1517:	b8 01 00 00 00       	mov    $0x1,%eax
    151c:	cd 40                	int    $0x40
    151e:	c3                   	ret    

0000151f <exit>:
SYSCALL(exit)
    151f:	b8 02 00 00 00       	mov    $0x2,%eax
    1524:	cd 40                	int    $0x40
    1526:	c3                   	ret    

00001527 <wait>:
SYSCALL(wait)
    1527:	b8 03 00 00 00       	mov    $0x3,%eax
    152c:	cd 40                	int    $0x40
    152e:	c3                   	ret    

0000152f <pipe>:
SYSCALL(pipe)
    152f:	b8 04 00 00 00       	mov    $0x4,%eax
    1534:	cd 40                	int    $0x40
    1536:	c3                   	ret    

00001537 <read>:
SYSCALL(read)
    1537:	b8 05 00 00 00       	mov    $0x5,%eax
    153c:	cd 40                	int    $0x40
    153e:	c3                   	ret    

0000153f <write>:
SYSCALL(write)
    153f:	b8 10 00 00 00       	mov    $0x10,%eax
    1544:	cd 40                	int    $0x40
    1546:	c3                   	ret    

00001547 <close>:
SYSCALL(close)
    1547:	b8 15 00 00 00       	mov    $0x15,%eax
    154c:	cd 40                	int    $0x40
    154e:	c3                   	ret    

0000154f <kill>:
SYSCALL(kill)
    154f:	b8 06 00 00 00       	mov    $0x6,%eax
    1554:	cd 40                	int    $0x40
    1556:	c3                   	ret    

00001557 <exec>:
SYSCALL(exec)
    1557:	b8 07 00 00 00       	mov    $0x7,%eax
    155c:	cd 40                	int    $0x40
    155e:	c3                   	ret    

0000155f <open>:
SYSCALL(open)
    155f:	b8 0f 00 00 00       	mov    $0xf,%eax
    1564:	cd 40                	int    $0x40
    1566:	c3                   	ret    

00001567 <mknod>:
SYSCALL(mknod)
    1567:	b8 11 00 00 00       	mov    $0x11,%eax
    156c:	cd 40                	int    $0x40
    156e:	c3                   	ret    

0000156f <unlink>:
SYSCALL(unlink)
    156f:	b8 12 00 00 00       	mov    $0x12,%eax
    1574:	cd 40                	int    $0x40
    1576:	c3                   	ret    

00001577 <fstat>:
SYSCALL(fstat)
    1577:	b8 08 00 00 00       	mov    $0x8,%eax
    157c:	cd 40                	int    $0x40
    157e:	c3                   	ret    

0000157f <link>:
SYSCALL(link)
    157f:	b8 13 00 00 00       	mov    $0x13,%eax
    1584:	cd 40                	int    $0x40
    1586:	c3                   	ret    

00001587 <mkdir>:
SYSCALL(mkdir)
    1587:	b8 14 00 00 00       	mov    $0x14,%eax
    158c:	cd 40                	int    $0x40
    158e:	c3                   	ret    

0000158f <chdir>:
SYSCALL(chdir)
    158f:	b8 09 00 00 00       	mov    $0x9,%eax
    1594:	cd 40                	int    $0x40
    1596:	c3                   	ret    

00001597 <dup>:
SYSCALL(dup)
    1597:	b8 0a 00 00 00       	mov    $0xa,%eax
    159c:	cd 40                	int    $0x40
    159e:	c3                   	ret    

0000159f <getpid>:
SYSCALL(getpid)
    159f:	b8 0b 00 00 00       	mov    $0xb,%eax
    15a4:	cd 40                	int    $0x40
    15a6:	c3                   	ret    

000015a7 <sbrk>:
SYSCALL(sbrk)
    15a7:	b8 0c 00 00 00       	mov    $0xc,%eax
    15ac:	cd 40                	int    $0x40
    15ae:	c3                   	ret    

000015af <sleep>:
SYSCALL(sleep)
    15af:	b8 0d 00 00 00       	mov    $0xd,%eax
    15b4:	cd 40                	int    $0x40
    15b6:	c3                   	ret    

000015b7 <uptime>:
SYSCALL(uptime)
    15b7:	b8 0e 00 00 00       	mov    $0xe,%eax
    15bc:	cd 40                	int    $0x40
    15be:	c3                   	ret    

000015bf <getCuPos>:
SYSCALL(getCuPos)
    15bf:	b8 16 00 00 00       	mov    $0x16,%eax
    15c4:	cd 40                	int    $0x40
    15c6:	c3                   	ret    

000015c7 <setCuPos>:
SYSCALL(setCuPos)
    15c7:	b8 17 00 00 00       	mov    $0x17,%eax
    15cc:	cd 40                	int    $0x40
    15ce:	c3                   	ret    

000015cf <getSnapshot>:
SYSCALL(getSnapshot)
    15cf:	b8 18 00 00 00       	mov    $0x18,%eax
    15d4:	cd 40                	int    $0x40
    15d6:	c3                   	ret    

000015d7 <clearScreen>:
    15d7:	b8 19 00 00 00       	mov    $0x19,%eax
    15dc:	cd 40                	int    $0x40
    15de:	c3                   	ret    

000015df <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    15df:	55                   	push   %ebp
    15e0:	89 e5                	mov    %esp,%ebp
    15e2:	83 ec 18             	sub    $0x18,%esp
    15e5:	8b 45 0c             	mov    0xc(%ebp),%eax
    15e8:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    15eb:	83 ec 04             	sub    $0x4,%esp
    15ee:	6a 01                	push   $0x1
    15f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
    15f3:	50                   	push   %eax
    15f4:	ff 75 08             	pushl  0x8(%ebp)
    15f7:	e8 43 ff ff ff       	call   153f <write>
    15fc:	83 c4 10             	add    $0x10,%esp
}
    15ff:	90                   	nop
    1600:	c9                   	leave  
    1601:	c3                   	ret    

00001602 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1602:	55                   	push   %ebp
    1603:	89 e5                	mov    %esp,%ebp
    1605:	53                   	push   %ebx
    1606:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1609:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1610:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1614:	74 17                	je     162d <printint+0x2b>
    1616:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    161a:	79 11                	jns    162d <printint+0x2b>
    neg = 1;
    161c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1623:	8b 45 0c             	mov    0xc(%ebp),%eax
    1626:	f7 d8                	neg    %eax
    1628:	89 45 ec             	mov    %eax,-0x14(%ebp)
    162b:	eb 06                	jmp    1633 <printint+0x31>
  } else {
    x = xx;
    162d:	8b 45 0c             	mov    0xc(%ebp),%eax
    1630:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1633:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    163a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    163d:	8d 41 01             	lea    0x1(%ecx),%eax
    1640:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1643:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1646:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1649:	ba 00 00 00 00       	mov    $0x0,%edx
    164e:	f7 f3                	div    %ebx
    1650:	89 d0                	mov    %edx,%eax
    1652:	0f b6 80 78 21 00 00 	movzbl 0x2178(%eax),%eax
    1659:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    165d:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1660:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1663:	ba 00 00 00 00       	mov    $0x0,%edx
    1668:	f7 f3                	div    %ebx
    166a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    166d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1671:	75 c7                	jne    163a <printint+0x38>
  if(neg)
    1673:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1677:	74 2d                	je     16a6 <printint+0xa4>
    buf[i++] = '-';
    1679:	8b 45 f4             	mov    -0xc(%ebp),%eax
    167c:	8d 50 01             	lea    0x1(%eax),%edx
    167f:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1682:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1687:	eb 1d                	jmp    16a6 <printint+0xa4>
    putc(fd, buf[i]);
    1689:	8d 55 dc             	lea    -0x24(%ebp),%edx
    168c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    168f:	01 d0                	add    %edx,%eax
    1691:	0f b6 00             	movzbl (%eax),%eax
    1694:	0f be c0             	movsbl %al,%eax
    1697:	83 ec 08             	sub    $0x8,%esp
    169a:	50                   	push   %eax
    169b:	ff 75 08             	pushl  0x8(%ebp)
    169e:	e8 3c ff ff ff       	call   15df <putc>
    16a3:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    16a6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    16aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    16ae:	79 d9                	jns    1689 <printint+0x87>
    putc(fd, buf[i]);
}
    16b0:	90                   	nop
    16b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    16b4:	c9                   	leave  
    16b5:	c3                   	ret    

000016b6 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    16b6:	55                   	push   %ebp
    16b7:	89 e5                	mov    %esp,%ebp
    16b9:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    16bc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    16c3:	8d 45 0c             	lea    0xc(%ebp),%eax
    16c6:	83 c0 04             	add    $0x4,%eax
    16c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    16cc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    16d3:	e9 59 01 00 00       	jmp    1831 <printf+0x17b>
    c = fmt[i] & 0xff;
    16d8:	8b 55 0c             	mov    0xc(%ebp),%edx
    16db:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16de:	01 d0                	add    %edx,%eax
    16e0:	0f b6 00             	movzbl (%eax),%eax
    16e3:	0f be c0             	movsbl %al,%eax
    16e6:	25 ff 00 00 00       	and    $0xff,%eax
    16eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    16ee:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    16f2:	75 2c                	jne    1720 <printf+0x6a>
      if(c == '%'){
    16f4:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    16f8:	75 0c                	jne    1706 <printf+0x50>
        state = '%';
    16fa:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1701:	e9 27 01 00 00       	jmp    182d <printf+0x177>
      } else {
        putc(fd, c);
    1706:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1709:	0f be c0             	movsbl %al,%eax
    170c:	83 ec 08             	sub    $0x8,%esp
    170f:	50                   	push   %eax
    1710:	ff 75 08             	pushl  0x8(%ebp)
    1713:	e8 c7 fe ff ff       	call   15df <putc>
    1718:	83 c4 10             	add    $0x10,%esp
    171b:	e9 0d 01 00 00       	jmp    182d <printf+0x177>
      }
    } else if(state == '%'){
    1720:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1724:	0f 85 03 01 00 00    	jne    182d <printf+0x177>
      if(c == 'd'){
    172a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    172e:	75 1e                	jne    174e <printf+0x98>
        printint(fd, *ap, 10, 1);
    1730:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1733:	8b 00                	mov    (%eax),%eax
    1735:	6a 01                	push   $0x1
    1737:	6a 0a                	push   $0xa
    1739:	50                   	push   %eax
    173a:	ff 75 08             	pushl  0x8(%ebp)
    173d:	e8 c0 fe ff ff       	call   1602 <printint>
    1742:	83 c4 10             	add    $0x10,%esp
        ap++;
    1745:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1749:	e9 d8 00 00 00       	jmp    1826 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    174e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1752:	74 06                	je     175a <printf+0xa4>
    1754:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1758:	75 1e                	jne    1778 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    175a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    175d:	8b 00                	mov    (%eax),%eax
    175f:	6a 00                	push   $0x0
    1761:	6a 10                	push   $0x10
    1763:	50                   	push   %eax
    1764:	ff 75 08             	pushl  0x8(%ebp)
    1767:	e8 96 fe ff ff       	call   1602 <printint>
    176c:	83 c4 10             	add    $0x10,%esp
        ap++;
    176f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1773:	e9 ae 00 00 00       	jmp    1826 <printf+0x170>
      } else if(c == 's'){
    1778:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    177c:	75 43                	jne    17c1 <printf+0x10b>
        s = (char*)*ap;
    177e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1781:	8b 00                	mov    (%eax),%eax
    1783:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1786:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    178a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    178e:	75 25                	jne    17b5 <printf+0xff>
          s = "(null)";
    1790:	c7 45 f4 c0 1d 00 00 	movl   $0x1dc0,-0xc(%ebp)
        while(*s != 0){
    1797:	eb 1c                	jmp    17b5 <printf+0xff>
          putc(fd, *s);
    1799:	8b 45 f4             	mov    -0xc(%ebp),%eax
    179c:	0f b6 00             	movzbl (%eax),%eax
    179f:	0f be c0             	movsbl %al,%eax
    17a2:	83 ec 08             	sub    $0x8,%esp
    17a5:	50                   	push   %eax
    17a6:	ff 75 08             	pushl  0x8(%ebp)
    17a9:	e8 31 fe ff ff       	call   15df <putc>
    17ae:	83 c4 10             	add    $0x10,%esp
          s++;
    17b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    17b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b8:	0f b6 00             	movzbl (%eax),%eax
    17bb:	84 c0                	test   %al,%al
    17bd:	75 da                	jne    1799 <printf+0xe3>
    17bf:	eb 65                	jmp    1826 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    17c1:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    17c5:	75 1d                	jne    17e4 <printf+0x12e>
        putc(fd, *ap);
    17c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
    17ca:	8b 00                	mov    (%eax),%eax
    17cc:	0f be c0             	movsbl %al,%eax
    17cf:	83 ec 08             	sub    $0x8,%esp
    17d2:	50                   	push   %eax
    17d3:	ff 75 08             	pushl  0x8(%ebp)
    17d6:	e8 04 fe ff ff       	call   15df <putc>
    17db:	83 c4 10             	add    $0x10,%esp
        ap++;
    17de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    17e2:	eb 42                	jmp    1826 <printf+0x170>
      } else if(c == '%'){
    17e4:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    17e8:	75 17                	jne    1801 <printf+0x14b>
        putc(fd, c);
    17ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    17ed:	0f be c0             	movsbl %al,%eax
    17f0:	83 ec 08             	sub    $0x8,%esp
    17f3:	50                   	push   %eax
    17f4:	ff 75 08             	pushl  0x8(%ebp)
    17f7:	e8 e3 fd ff ff       	call   15df <putc>
    17fc:	83 c4 10             	add    $0x10,%esp
    17ff:	eb 25                	jmp    1826 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1801:	83 ec 08             	sub    $0x8,%esp
    1804:	6a 25                	push   $0x25
    1806:	ff 75 08             	pushl  0x8(%ebp)
    1809:	e8 d1 fd ff ff       	call   15df <putc>
    180e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    1811:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1814:	0f be c0             	movsbl %al,%eax
    1817:	83 ec 08             	sub    $0x8,%esp
    181a:	50                   	push   %eax
    181b:	ff 75 08             	pushl  0x8(%ebp)
    181e:	e8 bc fd ff ff       	call   15df <putc>
    1823:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    1826:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    182d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1831:	8b 55 0c             	mov    0xc(%ebp),%edx
    1834:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1837:	01 d0                	add    %edx,%eax
    1839:	0f b6 00             	movzbl (%eax),%eax
    183c:	84 c0                	test   %al,%al
    183e:	0f 85 94 fe ff ff    	jne    16d8 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1844:	90                   	nop
    1845:	c9                   	leave  
    1846:	c3                   	ret    

00001847 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1847:	55                   	push   %ebp
    1848:	89 e5                	mov    %esp,%ebp
    184a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    184d:	8b 45 08             	mov    0x8(%ebp),%eax
    1850:	83 e8 08             	sub    $0x8,%eax
    1853:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1856:	a1 98 21 00 00       	mov    0x2198,%eax
    185b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    185e:	eb 24                	jmp    1884 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1860:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1863:	8b 00                	mov    (%eax),%eax
    1865:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1868:	77 12                	ja     187c <free+0x35>
    186a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    186d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1870:	77 24                	ja     1896 <free+0x4f>
    1872:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1875:	8b 00                	mov    (%eax),%eax
    1877:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    187a:	77 1a                	ja     1896 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    187c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    187f:	8b 00                	mov    (%eax),%eax
    1881:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1884:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1887:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    188a:	76 d4                	jbe    1860 <free+0x19>
    188c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    188f:	8b 00                	mov    (%eax),%eax
    1891:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1894:	76 ca                	jbe    1860 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1896:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1899:	8b 40 04             	mov    0x4(%eax),%eax
    189c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    18a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    18a6:	01 c2                	add    %eax,%edx
    18a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    18ab:	8b 00                	mov    (%eax),%eax
    18ad:	39 c2                	cmp    %eax,%edx
    18af:	75 24                	jne    18d5 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    18b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    18b4:	8b 50 04             	mov    0x4(%eax),%edx
    18b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    18ba:	8b 00                	mov    (%eax),%eax
    18bc:	8b 40 04             	mov    0x4(%eax),%eax
    18bf:	01 c2                	add    %eax,%edx
    18c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    18c4:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    18c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    18ca:	8b 00                	mov    (%eax),%eax
    18cc:	8b 10                	mov    (%eax),%edx
    18ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
    18d1:	89 10                	mov    %edx,(%eax)
    18d3:	eb 0a                	jmp    18df <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    18d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    18d8:	8b 10                	mov    (%eax),%edx
    18da:	8b 45 f8             	mov    -0x8(%ebp),%eax
    18dd:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    18df:	8b 45 fc             	mov    -0x4(%ebp),%eax
    18e2:	8b 40 04             	mov    0x4(%eax),%eax
    18e5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    18ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
    18ef:	01 d0                	add    %edx,%eax
    18f1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    18f4:	75 20                	jne    1916 <free+0xcf>
    p->s.size += bp->s.size;
    18f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    18f9:	8b 50 04             	mov    0x4(%eax),%edx
    18fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    18ff:	8b 40 04             	mov    0x4(%eax),%eax
    1902:	01 c2                	add    %eax,%edx
    1904:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1907:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    190a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    190d:	8b 10                	mov    (%eax),%edx
    190f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1912:	89 10                	mov    %edx,(%eax)
    1914:	eb 08                	jmp    191e <free+0xd7>
  } else
    p->s.ptr = bp;
    1916:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1919:	8b 55 f8             	mov    -0x8(%ebp),%edx
    191c:	89 10                	mov    %edx,(%eax)
  freep = p;
    191e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1921:	a3 98 21 00 00       	mov    %eax,0x2198
}
    1926:	90                   	nop
    1927:	c9                   	leave  
    1928:	c3                   	ret    

00001929 <morecore>:

static Header*
morecore(uint nu)
{
    1929:	55                   	push   %ebp
    192a:	89 e5                	mov    %esp,%ebp
    192c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    192f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1936:	77 07                	ja     193f <morecore+0x16>
    nu = 4096;
    1938:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    193f:	8b 45 08             	mov    0x8(%ebp),%eax
    1942:	c1 e0 03             	shl    $0x3,%eax
    1945:	83 ec 0c             	sub    $0xc,%esp
    1948:	50                   	push   %eax
    1949:	e8 59 fc ff ff       	call   15a7 <sbrk>
    194e:	83 c4 10             	add    $0x10,%esp
    1951:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1954:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1958:	75 07                	jne    1961 <morecore+0x38>
    return 0;
    195a:	b8 00 00 00 00       	mov    $0x0,%eax
    195f:	eb 26                	jmp    1987 <morecore+0x5e>
  hp = (Header*)p;
    1961:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1964:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1967:	8b 45 f0             	mov    -0x10(%ebp),%eax
    196a:	8b 55 08             	mov    0x8(%ebp),%edx
    196d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1970:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1973:	83 c0 08             	add    $0x8,%eax
    1976:	83 ec 0c             	sub    $0xc,%esp
    1979:	50                   	push   %eax
    197a:	e8 c8 fe ff ff       	call   1847 <free>
    197f:	83 c4 10             	add    $0x10,%esp
  return freep;
    1982:	a1 98 21 00 00       	mov    0x2198,%eax
}
    1987:	c9                   	leave  
    1988:	c3                   	ret    

00001989 <malloc>:

void*
malloc(uint nbytes)
{
    1989:	55                   	push   %ebp
    198a:	89 e5                	mov    %esp,%ebp
    198c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    198f:	8b 45 08             	mov    0x8(%ebp),%eax
    1992:	83 c0 07             	add    $0x7,%eax
    1995:	c1 e8 03             	shr    $0x3,%eax
    1998:	83 c0 01             	add    $0x1,%eax
    199b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    199e:	a1 98 21 00 00       	mov    0x2198,%eax
    19a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    19a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    19aa:	75 23                	jne    19cf <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    19ac:	c7 45 f0 90 21 00 00 	movl   $0x2190,-0x10(%ebp)
    19b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    19b6:	a3 98 21 00 00       	mov    %eax,0x2198
    19bb:	a1 98 21 00 00       	mov    0x2198,%eax
    19c0:	a3 90 21 00 00       	mov    %eax,0x2190
    base.s.size = 0;
    19c5:	c7 05 94 21 00 00 00 	movl   $0x0,0x2194
    19cc:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    19cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
    19d2:	8b 00                	mov    (%eax),%eax
    19d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    19d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    19da:	8b 40 04             	mov    0x4(%eax),%eax
    19dd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    19e0:	72 4d                	jb     1a2f <malloc+0xa6>
      if(p->s.size == nunits)
    19e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    19e5:	8b 40 04             	mov    0x4(%eax),%eax
    19e8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    19eb:	75 0c                	jne    19f9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    19ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    19f0:	8b 10                	mov    (%eax),%edx
    19f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    19f5:	89 10                	mov    %edx,(%eax)
    19f7:	eb 26                	jmp    1a1f <malloc+0x96>
      else {
        p->s.size -= nunits;
    19f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    19fc:	8b 40 04             	mov    0x4(%eax),%eax
    19ff:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1a02:	89 c2                	mov    %eax,%edx
    1a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a07:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a0d:	8b 40 04             	mov    0x4(%eax),%eax
    1a10:	c1 e0 03             	shl    $0x3,%eax
    1a13:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a19:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1a1c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1a22:	a3 98 21 00 00       	mov    %eax,0x2198
      return (void*)(p + 1);
    1a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a2a:	83 c0 08             	add    $0x8,%eax
    1a2d:	eb 3b                	jmp    1a6a <malloc+0xe1>
    }
    if(p == freep)
    1a2f:	a1 98 21 00 00       	mov    0x2198,%eax
    1a34:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1a37:	75 1e                	jne    1a57 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    1a39:	83 ec 0c             	sub    $0xc,%esp
    1a3c:	ff 75 ec             	pushl  -0x14(%ebp)
    1a3f:	e8 e5 fe ff ff       	call   1929 <morecore>
    1a44:	83 c4 10             	add    $0x10,%esp
    1a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1a4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1a4e:	75 07                	jne    1a57 <malloc+0xce>
        return 0;
    1a50:	b8 00 00 00 00       	mov    $0x0,%eax
    1a55:	eb 13                	jmp    1a6a <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a60:	8b 00                	mov    (%eax),%eax
    1a62:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1a65:	e9 6d ff ff ff       	jmp    19d7 <malloc+0x4e>
}
    1a6a:	c9                   	leave  
    1a6b:	c3                   	ret    
