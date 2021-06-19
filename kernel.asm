
kernel：     文件格式 elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 c6 10 80       	mov    $0x8010c670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 9c 36 10 80       	mov    $0x8010369c,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 80 83 10 80       	push   $0x80108380
80100042:	68 80 c6 10 80       	push   $0x8010c680
80100047:	e8 64 4d 00 00       	call   80104db0 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 b0 db 10 80 a4 	movl   $0x8010dba4,0x8010dbb0
80100056:	db 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 b4 db 10 80 a4 	movl   $0x8010dba4,0x8010dbb4
80100060:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 c6 10 80 	movl   $0x8010c6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 b4 db 10 80    	mov    0x8010dbb4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c a4 db 10 80 	movl   $0x8010dba4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 b4 db 10 80       	mov    %eax,0x8010dbb4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 a4 db 10 80       	mov    $0x8010dba4,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 80 c6 10 80       	push   $0x8010c680
801000c1:	e8 0c 4d 00 00       	call   80104dd2 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->sector == sector){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 80 c6 10 80       	push   $0x8010c680
8010010c:	e8 28 4d 00 00       	call   80104e39 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 c6 10 80       	push   $0x8010c680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 ad 49 00 00       	call   80104ad9 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 b0 db 10 80       	mov    0x8010dbb0,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 80 c6 10 80       	push   $0x8010c680
80100188:	e8 ac 4c 00 00       	call   80104e39 <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 87 83 10 80       	push   $0x80108387
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, sector);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 90 28 00 00       	call   80102a77 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 98 83 10 80       	push   $0x80108398
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 4f 28 00 00       	call   80102a77 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 9f 83 10 80       	push   $0x8010839f
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 c6 10 80       	push   $0x8010c680
80100255:	e8 78 4b 00 00       	call   80104dd2 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 b4 db 10 80    	mov    0x8010dbb4,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c a4 db 10 80 	movl   $0x8010dba4,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 b4 db 10 80       	mov    %eax,0x8010dbb4

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 06 49 00 00       	call   80104bc4 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 c6 10 80       	push   $0x8010c680
801002c9:	e8 6b 4b 00 00       	call   80104e39 <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 c3 03 00 00       	call   80100776 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 b5 10 80       	push   $0x8010b5e0
801003e2:	e8 eb 49 00 00       	call   80104dd2 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 a6 83 10 80       	push   $0x801083a6
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 55 03 00 00       	call   80100776 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec af 83 10 80 	movl   $0x801083af,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 8e 02 00 00       	call   80100776 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 71 02 00 00       	call   80100776 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 62 02 00 00       	call   80100776 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 54 02 00 00       	call   80100776 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 e0 b5 10 80       	push   $0x8010b5e0
8010055b:	e8 d9 48 00 00       	call   80104e39 <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 b6 83 10 80       	push   $0x801083b6
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 c5 83 10 80       	push   $0x801083c5
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 c4 48 00 00       	call   80104e8b <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 c7 83 10 80       	push   $0x801083c7
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory
//光标
static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)
  
  if((pos/80) >= 24){  // Scroll up.
801006b8:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006bf:	7e 4c                	jle    8010070d <cgaputc+0x10c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006c1:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006cc:	a1 00 90 10 80       	mov    0x80109000,%eax
801006d1:	83 ec 04             	sub    $0x4,%esp
801006d4:	68 60 0e 00 00       	push   $0xe60
801006d9:	52                   	push   %edx
801006da:	50                   	push   %eax
801006db:	e8 14 4a 00 00       	call   801050f4 <memmove>
801006e0:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006e3:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e7:	b8 80 07 00 00       	mov    $0x780,%eax
801006ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ef:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006f2:	a1 00 90 10 80       	mov    0x80109000,%eax
801006f7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fa:	01 c9                	add    %ecx,%ecx
801006fc:	01 c8                	add    %ecx,%eax
801006fe:	83 ec 04             	sub    $0x4,%esp
80100701:	52                   	push   %edx
80100702:	6a 00                	push   $0x0
80100704:	50                   	push   %eax
80100705:	e8 2b 49 00 00       	call   80105035 <memset>
8010070a:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
8010070d:	83 ec 08             	sub    $0x8,%esp
80100710:	6a 0e                	push   $0xe
80100712:	68 d4 03 00 00       	push   $0x3d4
80100717:	e8 d5 fb ff ff       	call   801002f1 <outb>
8010071c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100722:	c1 f8 08             	sar    $0x8,%eax
80100725:	0f b6 c0             	movzbl %al,%eax
80100728:	83 ec 08             	sub    $0x8,%esp
8010072b:	50                   	push   %eax
8010072c:	68 d5 03 00 00       	push   $0x3d5
80100731:	e8 bb fb ff ff       	call   801002f1 <outb>
80100736:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100739:	83 ec 08             	sub    $0x8,%esp
8010073c:	6a 0f                	push   $0xf
8010073e:	68 d4 03 00 00       	push   $0x3d4
80100743:	e8 a9 fb ff ff       	call   801002f1 <outb>
80100748:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010074e:	0f b6 c0             	movzbl %al,%eax
80100751:	83 ec 08             	sub    $0x8,%esp
80100754:	50                   	push   %eax
80100755:	68 d5 03 00 00       	push   $0x3d5
8010075a:	e8 92 fb ff ff       	call   801002f1 <outb>
8010075f:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100762:	a1 00 90 10 80       	mov    0x80109000,%eax
80100767:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010076a:	01 d2                	add    %edx,%edx
8010076c:	01 d0                	add    %edx,%eax
8010076e:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100773:	90                   	nop
80100774:	c9                   	leave  
80100775:	c3                   	ret    

80100776 <consputc>:

void
consputc(int c)
{
80100776:	55                   	push   %ebp
80100777:	89 e5                	mov    %esp,%ebp
80100779:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010077c:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80100781:	85 c0                	test   %eax,%eax
80100783:	74 07                	je     8010078c <consputc+0x16>
    cli();
80100785:	e8 86 fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
8010078a:	eb fe                	jmp    8010078a <consputc+0x14>
  }

  if(c == BACKSPACE){
8010078c:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100793:	75 29                	jne    801007be <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100795:	83 ec 0c             	sub    $0xc,%esp
80100798:	6a 08                	push   $0x8
8010079a:	e8 7a 62 00 00       	call   80106a19 <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 6d 62 00 00       	call   80106a19 <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 60 62 00 00       	call   80106a19 <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 50 62 00 00       	call   80106a19 <uartputc>
801007c9:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007cc:	83 ec 0c             	sub    $0xc,%esp
801007cf:	ff 75 08             	pushl  0x8(%ebp)
801007d2:	e8 2a fe ff ff       	call   80100601 <cgaputc>
801007d7:	83 c4 10             	add    $0x10,%esp
}
801007da:	90                   	nop
801007db:	c9                   	leave  
801007dc:	c3                   	ret    

801007dd <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007dd:	55                   	push   %ebp
801007de:	89 e5                	mov    %esp,%ebp
801007e0:	83 ec 18             	sub    $0x18,%esp
  int c;

  acquire(&input.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 c0 dd 10 80       	push   $0x8010ddc0
801007eb:	e8 e2 45 00 00       	call   80104dd2 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 42 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    switch(c){
801007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007fb:	83 f8 10             	cmp    $0x10,%eax
801007fe:	74 1e                	je     8010081e <consoleintr+0x41>
80100800:	83 f8 10             	cmp    $0x10,%eax
80100803:	7f 0a                	jg     8010080f <consoleintr+0x32>
80100805:	83 f8 08             	cmp    $0x8,%eax
80100808:	74 69                	je     80100873 <consoleintr+0x96>
8010080a:	e9 99 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
8010080f:	83 f8 15             	cmp    $0x15,%eax
80100812:	74 31                	je     80100845 <consoleintr+0x68>
80100814:	83 f8 7f             	cmp    $0x7f,%eax
80100817:	74 5a                	je     80100873 <consoleintr+0x96>
80100819:	e9 8a 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
    case C('P'):  // Process listing.
      procdump();
8010081e:	e8 5c 44 00 00       	call   80104c7f <procdump>
      break;
80100823:	e9 12 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100828:	a1 7c de 10 80       	mov    0x8010de7c,%eax
8010082d:	83 e8 01             	sub    $0x1,%eax
80100830:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(BACKSPACE);
80100835:	83 ec 0c             	sub    $0xc,%esp
80100838:	68 00 01 00 00       	push   $0x100
8010083d:	e8 34 ff ff ff       	call   80100776 <consputc>
80100842:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100845:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
8010084b:	a1 78 de 10 80       	mov    0x8010de78,%eax
80100850:	39 c2                	cmp    %eax,%edx
80100852:	0f 84 e2 00 00 00    	je     8010093a <consoleintr+0x15d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100858:	a1 7c de 10 80       	mov    0x8010de7c,%eax
8010085d:	83 e8 01             	sub    $0x1,%eax
80100860:	83 e0 7f             	and    $0x7f,%eax
80100863:	0f b6 80 f4 dd 10 80 	movzbl -0x7fef220c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	3c 0a                	cmp    $0xa,%al
8010086c:	75 ba                	jne    80100828 <consoleintr+0x4b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010086e:	e9 c7 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100873:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
80100879:	a1 78 de 10 80       	mov    0x8010de78,%eax
8010087e:	39 c2                	cmp    %eax,%edx
80100880:	0f 84 b4 00 00 00    	je     8010093a <consoleintr+0x15d>
        input.e--;
80100886:	a1 7c de 10 80       	mov    0x8010de7c,%eax
8010088b:	83 e8 01             	sub    $0x1,%eax
8010088e:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(BACKSPACE);
80100893:	83 ec 0c             	sub    $0xc,%esp
80100896:	68 00 01 00 00       	push   $0x100
8010089b:	e8 d6 fe ff ff       	call   80100776 <consputc>
801008a0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008a3:	e9 92 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801008ac:	0f 84 87 00 00 00    	je     80100939 <consoleintr+0x15c>
801008b2:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
801008b8:	a1 74 de 10 80       	mov    0x8010de74,%eax
801008bd:	29 c2                	sub    %eax,%edx
801008bf:	89 d0                	mov    %edx,%eax
801008c1:	83 f8 7f             	cmp    $0x7f,%eax
801008c4:	77 73                	ja     80100939 <consoleintr+0x15c>
        c = (c == '\r') ? '\n' : c;
801008c6:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008ca:	74 05                	je     801008d1 <consoleintr+0xf4>
801008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008cf:	eb 05                	jmp    801008d6 <consoleintr+0xf9>
801008d1:	b8 0a 00 00 00       	mov    $0xa,%eax
801008d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008d9:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801008de:	8d 50 01             	lea    0x1(%eax),%edx
801008e1:	89 15 7c de 10 80    	mov    %edx,0x8010de7c
801008e7:	83 e0 7f             	and    $0x7f,%eax
801008ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008ed:	88 90 f4 dd 10 80    	mov    %dl,-0x7fef220c(%eax)
        consputc(c);
801008f3:	83 ec 0c             	sub    $0xc,%esp
801008f6:	ff 75 f4             	pushl  -0xc(%ebp)
801008f9:	e8 78 fe ff ff       	call   80100776 <consputc>
801008fe:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100901:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80100905:	74 18                	je     8010091f <consoleintr+0x142>
80100907:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010090b:	74 12                	je     8010091f <consoleintr+0x142>
8010090d:	a1 7c de 10 80       	mov    0x8010de7c,%eax
80100912:	8b 15 74 de 10 80    	mov    0x8010de74,%edx
80100918:	83 ea 80             	sub    $0xffffff80,%edx
8010091b:	39 d0                	cmp    %edx,%eax
8010091d:	75 1a                	jne    80100939 <consoleintr+0x15c>
          input.w = input.e;
8010091f:	a1 7c de 10 80       	mov    0x8010de7c,%eax
80100924:	a3 78 de 10 80       	mov    %eax,0x8010de78
          wakeup(&input.r);
80100929:	83 ec 0c             	sub    $0xc,%esp
8010092c:	68 74 de 10 80       	push   $0x8010de74
80100931:	e8 8e 42 00 00       	call   80104bc4 <wakeup>
80100936:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100939:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
8010093a:	8b 45 08             	mov    0x8(%ebp),%eax
8010093d:	ff d0                	call   *%eax
8010093f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100942:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100946:	0f 89 ac fe ff ff    	jns    801007f8 <consoleintr+0x1b>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010094c:	83 ec 0c             	sub    $0xc,%esp
8010094f:	68 c0 dd 10 80       	push   $0x8010ddc0
80100954:	e8 e0 44 00 00       	call   80104e39 <release>
80100959:	83 c4 10             	add    $0x10,%esp
}
8010095c:	90                   	nop
8010095d:	c9                   	leave  
8010095e:	c3                   	ret    

8010095f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010095f:	55                   	push   %ebp
80100960:	89 e5                	mov    %esp,%ebp
80100962:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100965:	83 ec 0c             	sub    $0xc,%esp
80100968:	ff 75 08             	pushl  0x8(%ebp)
8010096b:	e8 fe 12 00 00       	call   80101c6e <iunlock>
80100970:	83 c4 10             	add    $0x10,%esp
  target = n;
80100973:	8b 45 10             	mov    0x10(%ebp),%eax
80100976:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 c0 dd 10 80       	push   $0x8010ddc0
80100981:	e8 4c 44 00 00       	call   80104dd2 <acquire>
80100986:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100989:	e9 ac 00 00 00       	jmp    80100a3a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
8010098e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100994:	8b 40 24             	mov    0x24(%eax),%eax
80100997:	85 c0                	test   %eax,%eax
80100999:	74 28                	je     801009c3 <consoleread+0x64>
        release(&input.lock);
8010099b:	83 ec 0c             	sub    $0xc,%esp
8010099e:	68 c0 dd 10 80       	push   $0x8010ddc0
801009a3:	e8 91 44 00 00       	call   80104e39 <release>
801009a8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009ab:	83 ec 0c             	sub    $0xc,%esp
801009ae:	ff 75 08             	pushl  0x8(%ebp)
801009b1:	e8 60 11 00 00       	call   80101b16 <ilock>
801009b6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009be:	e9 ab 00 00 00       	jmp    80100a6e <consoleread+0x10f>
      }
      sleep(&input.r, &input.lock);
801009c3:	83 ec 08             	sub    $0x8,%esp
801009c6:	68 c0 dd 10 80       	push   $0x8010ddc0
801009cb:	68 74 de 10 80       	push   $0x8010de74
801009d0:	e8 04 41 00 00       	call   80104ad9 <sleep>
801009d5:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009d8:	8b 15 74 de 10 80    	mov    0x8010de74,%edx
801009de:	a1 78 de 10 80       	mov    0x8010de78,%eax
801009e3:	39 c2                	cmp    %eax,%edx
801009e5:	74 a7                	je     8010098e <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009e7:	a1 74 de 10 80       	mov    0x8010de74,%eax
801009ec:	8d 50 01             	lea    0x1(%eax),%edx
801009ef:	89 15 74 de 10 80    	mov    %edx,0x8010de74
801009f5:	83 e0 7f             	and    $0x7f,%eax
801009f8:	0f b6 80 f4 dd 10 80 	movzbl -0x7fef220c(%eax),%eax
801009ff:	0f be c0             	movsbl %al,%eax
80100a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a05:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a09:	75 17                	jne    80100a22 <consoleread+0xc3>
      if(n < target){
80100a0b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a0e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a11:	73 2f                	jae    80100a42 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a13:	a1 74 de 10 80       	mov    0x8010de74,%eax
80100a18:	83 e8 01             	sub    $0x1,%eax
80100a1b:	a3 74 de 10 80       	mov    %eax,0x8010de74
      }
      break;
80100a20:	eb 20                	jmp    80100a42 <consoleread+0xe3>
    }
    *dst++ = c;
80100a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a25:	8d 50 01             	lea    0x1(%eax),%edx
80100a28:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a2e:	88 10                	mov    %dl,(%eax)
    --n;
80100a30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a34:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a38:	74 0b                	je     80100a45 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a3e:	7f 98                	jg     801009d8 <consoleread+0x79>
80100a40:	eb 04                	jmp    80100a46 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a42:	90                   	nop
80100a43:	eb 01                	jmp    80100a46 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a45:	90                   	nop
  }
  release(&input.lock);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	68 c0 dd 10 80       	push   $0x8010ddc0
80100a4e:	e8 e6 43 00 00       	call   80104e39 <release>
80100a53:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a56:	83 ec 0c             	sub    $0xc,%esp
80100a59:	ff 75 08             	pushl  0x8(%ebp)
80100a5c:	e8 b5 10 00 00       	call   80101b16 <ilock>
80100a61:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a64:	8b 45 10             	mov    0x10(%ebp),%eax
80100a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a6a:	29 c2                	sub    %eax,%edx
80100a6c:	89 d0                	mov    %edx,%eax
}
80100a6e:	c9                   	leave  
80100a6f:	c3                   	ret    

80100a70 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a70:	55                   	push   %ebp
80100a71:	89 e5                	mov    %esp,%ebp
80100a73:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	pushl  0x8(%ebp)
80100a7c:	e8 ed 11 00 00       	call   80101c6e <iunlock>
80100a81:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a84:	83 ec 0c             	sub    $0xc,%esp
80100a87:	68 e0 b5 10 80       	push   $0x8010b5e0
80100a8c:	e8 41 43 00 00       	call   80104dd2 <acquire>
80100a91:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a9b:	eb 21                	jmp    80100abe <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aa3:	01 d0                	add    %edx,%eax
80100aa5:	0f b6 00             	movzbl (%eax),%eax
80100aa8:	0f be c0             	movsbl %al,%eax
80100aab:	0f b6 c0             	movzbl %al,%eax
80100aae:	83 ec 0c             	sub    $0xc,%esp
80100ab1:	50                   	push   %eax
80100ab2:	e8 bf fc ff ff       	call   80100776 <consputc>
80100ab7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ac1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ac4:	7c d7                	jl     80100a9d <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	68 e0 b5 10 80       	push   $0x8010b5e0
80100ace:	e8 66 43 00 00       	call   80104e39 <release>
80100ad3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad6:	83 ec 0c             	sub    $0xc,%esp
80100ad9:	ff 75 08             	pushl  0x8(%ebp)
80100adc:	e8 35 10 00 00       	call   80101b16 <ilock>
80100ae1:	83 c4 10             	add    $0x10,%esp

  return n;
80100ae4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ae7:	c9                   	leave  
80100ae8:	c3                   	ret    

80100ae9 <consoleinit>:

void
consoleinit(void)
{
80100ae9:	55                   	push   %ebp
80100aea:	89 e5                	mov    %esp,%ebp
80100aec:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100aef:	83 ec 08             	sub    $0x8,%esp
80100af2:	68 cb 83 10 80       	push   $0x801083cb
80100af7:	68 e0 b5 10 80       	push   $0x8010b5e0
80100afc:	e8 af 42 00 00       	call   80104db0 <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 d3 83 10 80       	push   $0x801083d3
80100b0c:	68 c0 dd 10 80       	push   $0x8010ddc0
80100b11:	e8 9a 42 00 00       	call   80104db0 <initlock>
80100b16:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b19:	c7 05 2c e8 10 80 70 	movl   $0x80100a70,0x8010e82c
80100b20:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b23:	c7 05 28 e8 10 80 5f 	movl   $0x8010095f,0x8010e828
80100b2a:	09 10 80 
  cons.locking = 1;
80100b2d:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100b34:	00 00 00 

  picenable(IRQ_KBD);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	6a 01                	push   $0x1
80100b3c:	e8 fc 31 00 00       	call   80103d3d <picenable>
80100b41:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b44:	83 ec 08             	sub    $0x8,%esp
80100b47:	6a 00                	push   $0x0
80100b49:	6a 01                	push   $0x1
80100b4b:	e8 f4 20 00 00       	call   80102c44 <ioapicenable>
80100b50:	83 c4 10             	add    $0x10,%esp
}
80100b53:	90                   	nop
80100b54:	c9                   	leave  
80100b55:	c3                   	ret    

80100b56 <getCuPos>:

//获取光标位置
int getCuPos(){
80100b56:	55                   	push   %ebp
80100b57:	89 e5                	mov    %esp,%ebp
80100b59:	83 ec 10             	sub    $0x10,%esp
    int pos;
    // Cursor position: col + 80*row.
    outb(CRTPORT, 14);
80100b5c:	6a 0e                	push   $0xe
80100b5e:	68 d4 03 00 00       	push   $0x3d4
80100b63:	e8 89 f7 ff ff       	call   801002f1 <outb>
80100b68:	83 c4 08             	add    $0x8,%esp
    pos = inb(CRTPORT+1) << 8;
80100b6b:	68 d5 03 00 00       	push   $0x3d5
80100b70:	e8 5f f7 ff ff       	call   801002d4 <inb>
80100b75:	83 c4 04             	add    $0x4,%esp
80100b78:	0f b6 c0             	movzbl %al,%eax
80100b7b:	c1 e0 08             	shl    $0x8,%eax
80100b7e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    outb(CRTPORT, 15);
80100b81:	6a 0f                	push   $0xf
80100b83:	68 d4 03 00 00       	push   $0x3d4
80100b88:	e8 64 f7 ff ff       	call   801002f1 <outb>
80100b8d:	83 c4 08             	add    $0x8,%esp
    pos |= inb(CRTPORT+1);
80100b90:	68 d5 03 00 00       	push   $0x3d5
80100b95:	e8 3a f7 ff ff       	call   801002d4 <inb>
80100b9a:	83 c4 04             	add    $0x4,%esp
80100b9d:	0f b6 c0             	movzbl %al,%eax
80100ba0:	09 45 fc             	or     %eax,-0x4(%ebp)
    return pos;
80100ba3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80100ba6:	c9                   	leave  
80100ba7:	c3                   	ret    

80100ba8 <setCuPos>:

void setCuPos(int row,int col){
80100ba8:	55                   	push   %ebp
80100ba9:	89 e5                	mov    %esp,%ebp
80100bab:	83 ec 10             	sub    $0x10,%esp
  int pos = row * 80 + col;
80100bae:	8b 55 08             	mov    0x8(%ebp),%edx
80100bb1:	89 d0                	mov    %edx,%eax
80100bb3:	c1 e0 02             	shl    $0x2,%eax
80100bb6:	01 d0                	add    %edx,%eax
80100bb8:	c1 e0 04             	shl    $0x4,%eax
80100bbb:	89 c2                	mov    %eax,%edx
80100bbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80100bc0:	01 d0                	add    %edx,%eax
80100bc2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  outb(CRTPORT, 14);
80100bc5:	6a 0e                	push   $0xe
80100bc7:	68 d4 03 00 00       	push   $0x3d4
80100bcc:	e8 20 f7 ff ff       	call   801002f1 <outb>
80100bd1:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT+1, pos>>8);
80100bd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100bd7:	c1 f8 08             	sar    $0x8,%eax
80100bda:	0f b6 c0             	movzbl %al,%eax
80100bdd:	50                   	push   %eax
80100bde:	68 d5 03 00 00       	push   $0x3d5
80100be3:	e8 09 f7 ff ff       	call   801002f1 <outb>
80100be8:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT, 15);
80100beb:	6a 0f                	push   $0xf
80100bed:	68 d4 03 00 00       	push   $0x3d4
80100bf2:	e8 fa f6 ff ff       	call   801002f1 <outb>
80100bf7:	83 c4 08             	add    $0x8,%esp
  outb(CRTPORT+1, pos);
80100bfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100bfd:	0f b6 c0             	movzbl %al,%eax
80100c00:	50                   	push   %eax
80100c01:	68 d5 03 00 00       	push   $0x3d5
80100c06:	e8 e6 f6 ff ff       	call   801002f1 <outb>
80100c0b:	83 c4 08             	add    $0x8,%esp
  crt[pos] = ' ' | 0x0700;
80100c0e:	a1 00 90 10 80       	mov    0x80109000,%eax
80100c13:	8b 55 fc             	mov    -0x4(%ebp),%edx
80100c16:	01 d2                	add    %edx,%edx
80100c18:	01 d0                	add    %edx,%eax
80100c1a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100c1f:	90                   	nop
80100c20:	c9                   	leave  
80100c21:	c3                   	ret    

80100c22 <getSnapshot>:

void getSnapshot(ushort *screen_buffer, int pos){ 
80100c22:	55                   	push   %ebp
80100c23:	89 e5                	mov    %esp,%ebp
80100c25:	83 ec 18             	sub    $0x18,%esp
  int size = pos*sizeof(crt[0]);
80100c28:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c2b:	01 c0                	add    %eax,%eax
80100c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("hellostart\n");
80100c30:	83 ec 0c             	sub    $0xc,%esp
80100c33:	68 d9 83 10 80       	push   $0x801083d9
80100c38:	e8 89 f7 ff ff       	call   801003c6 <cprintf>
80100c3d:	83 c4 10             	add    $0x10,%esp
  memmove(screen_buffer,crt,size);
80100c40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100c43:	a1 00 90 10 80       	mov    0x80109000,%eax
80100c48:	83 ec 04             	sub    $0x4,%esp
80100c4b:	52                   	push   %edx
80100c4c:	50                   	push   %eax
80100c4d:	ff 75 08             	pushl  0x8(%ebp)
80100c50:	e8 9f 44 00 00       	call   801050f4 <memmove>
80100c55:	83 c4 10             	add    $0x10,%esp
  cprintf("helloworld\n");
80100c58:	83 ec 0c             	sub    $0xc,%esp
80100c5b:	68 e5 83 10 80       	push   $0x801083e5
80100c60:	e8 61 f7 ff ff       	call   801003c6 <cprintf>
80100c65:	83 c4 10             	add    $0x10,%esp
}
80100c68:	90                   	nop
80100c69:	c9                   	leave  
80100c6a:	c3                   	ret    

80100c6b <clearScreen>:

void clearScreen(){
80100c6b:	55                   	push   %ebp
80100c6c:	89 e5                	mov    %esp,%ebp
80100c6e:	83 ec 18             	sub    $0x18,%esp
  // memset(crt,0,80*25*sizeof(crt[0]));
  int pos = 0;
80100c71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  memset(crt, 0, sizeof(crt[0]) * (25 * 80));
80100c78:	a1 00 90 10 80       	mov    0x80109000,%eax
80100c7d:	83 ec 04             	sub    $0x4,%esp
80100c80:	68 a0 0f 00 00       	push   $0xfa0
80100c85:	6a 00                	push   $0x0
80100c87:	50                   	push   %eax
80100c88:	e8 a8 43 00 00       	call   80105035 <memset>
80100c8d:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 14);
80100c90:	83 ec 08             	sub    $0x8,%esp
80100c93:	6a 0e                	push   $0xe
80100c95:	68 d4 03 00 00       	push   $0x3d4
80100c9a:	e8 52 f6 ff ff       	call   801002f1 <outb>
80100c9f:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
80100ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ca5:	c1 f8 08             	sar    $0x8,%eax
80100ca8:	0f b6 c0             	movzbl %al,%eax
80100cab:	83 ec 08             	sub    $0x8,%esp
80100cae:	50                   	push   %eax
80100caf:	68 d5 03 00 00       	push   $0x3d5
80100cb4:	e8 38 f6 ff ff       	call   801002f1 <outb>
80100cb9:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100cbc:	83 ec 08             	sub    $0x8,%esp
80100cbf:	6a 0f                	push   $0xf
80100cc1:	68 d4 03 00 00       	push   $0x3d4
80100cc6:	e8 26 f6 ff ff       	call   801002f1 <outb>
80100ccb:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100cd1:	0f b6 c0             	movzbl %al,%eax
80100cd4:	83 ec 08             	sub    $0x8,%esp
80100cd7:	50                   	push   %eax
80100cd8:	68 d5 03 00 00       	push   $0x3d5
80100cdd:	e8 0f f6 ff ff       	call   801002f1 <outb>
80100ce2:	83 c4 10             	add    $0x10,%esp
  crt[pos] = (' ') | 0x0700;  //显示光标
80100ce5:	a1 00 90 10 80       	mov    0x80109000,%eax
80100cea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ced:	01 d2                	add    %edx,%edx
80100cef:	01 d0                	add    %edx,%eax
80100cf1:	66 c7 00 20 07       	movw   $0x720,(%eax)
  while (1)
  {
    /* code */
  }
80100cf6:	eb fe                	jmp    80100cf6 <clearScreen+0x8b>

80100cf8 <setSnapshot>:
  
}
void setSnapshot(ushort *screen_buffer, int pos){ 
80100cf8:	55                   	push   %ebp
80100cf9:	89 e5                	mov    %esp,%ebp
80100cfb:	53                   	push   %ebx
80100cfc:	83 ec 14             	sub    $0x14,%esp
  clearScreen();
80100cff:	e8 67 ff ff ff       	call   80100c6b <clearScreen>
  int size = pos*sizeof(crt[0]);
80100d04:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d07:	01 c0                	add    %eax,%eax
80100d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(crt,screen_buffer,size);
80100d0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d0f:	a1 00 90 10 80       	mov    0x80109000,%eax
80100d14:	83 ec 04             	sub    $0x4,%esp
80100d17:	52                   	push   %edx
80100d18:	ff 75 08             	pushl  0x8(%ebp)
80100d1b:	50                   	push   %eax
80100d1c:	e8 d3 43 00 00       	call   801050f4 <memmove>
80100d21:	83 c4 10             	add    $0x10,%esp
  setCuPos(pos/80,pos%80);
80100d24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100d27:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100d2c:	89 d8                	mov    %ebx,%eax
80100d2e:	f7 ea                	imul   %edx
80100d30:	c1 fa 05             	sar    $0x5,%edx
80100d33:	89 d8                	mov    %ebx,%eax
80100d35:	c1 f8 1f             	sar    $0x1f,%eax
80100d38:	89 d1                	mov    %edx,%ecx
80100d3a:	29 c1                	sub    %eax,%ecx
80100d3c:	89 c8                	mov    %ecx,%eax
80100d3e:	c1 e0 02             	shl    $0x2,%eax
80100d41:	01 c8                	add    %ecx,%eax
80100d43:	c1 e0 04             	shl    $0x4,%eax
80100d46:	29 c3                	sub    %eax,%ebx
80100d48:	89 d9                	mov    %ebx,%ecx
80100d4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100d4d:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100d52:	89 d8                	mov    %ebx,%eax
80100d54:	f7 ea                	imul   %edx
80100d56:	c1 fa 05             	sar    $0x5,%edx
80100d59:	89 d8                	mov    %ebx,%eax
80100d5b:	c1 f8 1f             	sar    $0x1f,%eax
80100d5e:	29 c2                	sub    %eax,%edx
80100d60:	89 d0                	mov    %edx,%eax
80100d62:	83 ec 08             	sub    $0x8,%esp
80100d65:	51                   	push   %ecx
80100d66:	50                   	push   %eax
80100d67:	e8 3c fe ff ff       	call   80100ba8 <setCuPos>
80100d6c:	83 c4 10             	add    $0x10,%esp
80100d6f:	90                   	nop
80100d70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d73:	c9                   	leave  
80100d74:	c3                   	ret    

80100d75 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100d75:	55                   	push   %ebp
80100d76:	89 e5                	mov    %esp,%ebp
80100d78:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100d7e:	83 ec 0c             	sub    $0xc,%esp
80100d81:	ff 75 08             	pushl  0x8(%ebp)
80100d84:	e8 45 19 00 00       	call   801026ce <namei>
80100d89:	83 c4 10             	add    $0x10,%esp
80100d8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100d8f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100d93:	75 0a                	jne    80100d9f <exec+0x2a>
    return -1;
80100d95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100d9a:	e9 c4 03 00 00       	jmp    80101163 <exec+0x3ee>
  ilock(ip);
80100d9f:	83 ec 0c             	sub    $0xc,%esp
80100da2:	ff 75 d8             	pushl  -0x28(%ebp)
80100da5:	e8 6c 0d 00 00       	call   80101b16 <ilock>
80100daa:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100dad:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100db4:	6a 34                	push   $0x34
80100db6:	6a 00                	push   $0x0
80100db8:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100dbe:	50                   	push   %eax
80100dbf:	ff 75 d8             	pushl  -0x28(%ebp)
80100dc2:	e8 b7 12 00 00       	call   8010207e <readi>
80100dc7:	83 c4 10             	add    $0x10,%esp
80100dca:	83 f8 33             	cmp    $0x33,%eax
80100dcd:	0f 86 44 03 00 00    	jbe    80101117 <exec+0x3a2>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100dd3:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100dd9:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100dde:	0f 85 36 03 00 00    	jne    8010111a <exec+0x3a5>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100de4:	e8 85 6d 00 00       	call   80107b6e <setupkvm>
80100de9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100dec:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100df0:	0f 84 27 03 00 00    	je     8010111d <exec+0x3a8>
    goto bad;

  // Load program into memory.
  sz = 0;
80100df6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100dfd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100e04:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100e0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e0d:	e9 ab 00 00 00       	jmp    80100ebd <exec+0x148>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100e12:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e15:	6a 20                	push   $0x20
80100e17:	50                   	push   %eax
80100e18:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100e1e:	50                   	push   %eax
80100e1f:	ff 75 d8             	pushl  -0x28(%ebp)
80100e22:	e8 57 12 00 00       	call   8010207e <readi>
80100e27:	83 c4 10             	add    $0x10,%esp
80100e2a:	83 f8 20             	cmp    $0x20,%eax
80100e2d:	0f 85 ed 02 00 00    	jne    80101120 <exec+0x3ab>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100e33:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100e39:	83 f8 01             	cmp    $0x1,%eax
80100e3c:	75 71                	jne    80100eaf <exec+0x13a>
      continue;
    if(ph.memsz < ph.filesz)
80100e3e:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100e44:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100e4a:	39 c2                	cmp    %eax,%edx
80100e4c:	0f 82 d1 02 00 00    	jb     80101123 <exec+0x3ae>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100e52:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100e58:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100e5e:	01 d0                	add    %edx,%eax
80100e60:	83 ec 04             	sub    $0x4,%esp
80100e63:	50                   	push   %eax
80100e64:	ff 75 e0             	pushl  -0x20(%ebp)
80100e67:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e6a:	e8 a6 70 00 00       	call   80107f15 <allocuvm>
80100e6f:	83 c4 10             	add    $0x10,%esp
80100e72:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e75:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e79:	0f 84 a7 02 00 00    	je     80101126 <exec+0x3b1>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100e7f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100e85:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100e8b:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100e91:	83 ec 0c             	sub    $0xc,%esp
80100e94:	52                   	push   %edx
80100e95:	50                   	push   %eax
80100e96:	ff 75 d8             	pushl  -0x28(%ebp)
80100e99:	51                   	push   %ecx
80100e9a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e9d:	e8 9c 6f 00 00       	call   80107e3e <loaduvm>
80100ea2:	83 c4 20             	add    $0x20,%esp
80100ea5:	85 c0                	test   %eax,%eax
80100ea7:	0f 88 7c 02 00 00    	js     80101129 <exec+0x3b4>
80100ead:	eb 01                	jmp    80100eb0 <exec+0x13b>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100eaf:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100eb0:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100eb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100eb7:	83 c0 20             	add    $0x20,%eax
80100eba:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ebd:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100ec4:	0f b7 c0             	movzwl %ax,%eax
80100ec7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100eca:	0f 8f 42 ff ff ff    	jg     80100e12 <exec+0x9d>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100ed0:	83 ec 0c             	sub    $0xc,%esp
80100ed3:	ff 75 d8             	pushl  -0x28(%ebp)
80100ed6:	e8 f5 0e 00 00       	call   80101dd0 <iunlockput>
80100edb:	83 c4 10             	add    $0x10,%esp
  ip = 0;
80100ede:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100ee5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ee8:	05 ff 0f 00 00       	add    $0xfff,%eax
80100eed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ef2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ef5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ef8:	05 00 20 00 00       	add    $0x2000,%eax
80100efd:	83 ec 04             	sub    $0x4,%esp
80100f00:	50                   	push   %eax
80100f01:	ff 75 e0             	pushl  -0x20(%ebp)
80100f04:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f07:	e8 09 70 00 00       	call   80107f15 <allocuvm>
80100f0c:	83 c4 10             	add    $0x10,%esp
80100f0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f12:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f16:	0f 84 10 02 00 00    	je     8010112c <exec+0x3b7>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100f1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f1f:	2d 00 20 00 00       	sub    $0x2000,%eax
80100f24:	83 ec 08             	sub    $0x8,%esp
80100f27:	50                   	push   %eax
80100f28:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f2b:	e8 0b 72 00 00       	call   8010813b <clearpteu>
80100f30:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100f33:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f36:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f39:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100f40:	e9 96 00 00 00       	jmp    80100fdb <exec+0x266>
    if(argc >= MAXARG)
80100f45:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100f49:	0f 87 e0 01 00 00    	ja     8010112f <exec+0x3ba>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100f4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f52:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f59:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f5c:	01 d0                	add    %edx,%eax
80100f5e:	8b 00                	mov    (%eax),%eax
80100f60:	83 ec 0c             	sub    $0xc,%esp
80100f63:	50                   	push   %eax
80100f64:	e8 19 43 00 00       	call   80105282 <strlen>
80100f69:	83 c4 10             	add    $0x10,%esp
80100f6c:	89 c2                	mov    %eax,%edx
80100f6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f71:	29 d0                	sub    %edx,%eax
80100f73:	83 e8 01             	sub    $0x1,%eax
80100f76:	83 e0 fc             	and    $0xfffffffc,%eax
80100f79:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100f7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f7f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f86:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f89:	01 d0                	add    %edx,%eax
80100f8b:	8b 00                	mov    (%eax),%eax
80100f8d:	83 ec 0c             	sub    $0xc,%esp
80100f90:	50                   	push   %eax
80100f91:	e8 ec 42 00 00       	call   80105282 <strlen>
80100f96:	83 c4 10             	add    $0x10,%esp
80100f99:	83 c0 01             	add    $0x1,%eax
80100f9c:	89 c1                	mov    %eax,%ecx
80100f9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fa1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100fa8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100fab:	01 d0                	add    %edx,%eax
80100fad:	8b 00                	mov    (%eax),%eax
80100faf:	51                   	push   %ecx
80100fb0:	50                   	push   %eax
80100fb1:	ff 75 dc             	pushl  -0x24(%ebp)
80100fb4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fb7:	e8 23 73 00 00       	call   801082df <copyout>
80100fbc:	83 c4 10             	add    $0x10,%esp
80100fbf:	85 c0                	test   %eax,%eax
80100fc1:	0f 88 6b 01 00 00    	js     80101132 <exec+0x3bd>
      goto bad;
    ustack[3+argc] = sp;
80100fc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fca:	8d 50 03             	lea    0x3(%eax),%edx
80100fcd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100fd0:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100fd7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100fdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fde:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100fe8:	01 d0                	add    %edx,%eax
80100fea:	8b 00                	mov    (%eax),%eax
80100fec:	85 c0                	test   %eax,%eax
80100fee:	0f 85 51 ff ff ff    	jne    80100f45 <exec+0x1d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100ff4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ff7:	83 c0 03             	add    $0x3,%eax
80100ffa:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80101001:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80101005:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
8010100c:	ff ff ff 
  ustack[1] = argc;
8010100f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101012:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101018:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010101b:	83 c0 01             	add    $0x1,%eax
8010101e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101025:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101028:	29 d0                	sub    %edx,%eax
8010102a:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80101030:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101033:	83 c0 04             	add    $0x4,%eax
80101036:	c1 e0 02             	shl    $0x2,%eax
80101039:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
8010103c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010103f:	83 c0 04             	add    $0x4,%eax
80101042:	c1 e0 02             	shl    $0x2,%eax
80101045:	50                   	push   %eax
80101046:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
8010104c:	50                   	push   %eax
8010104d:	ff 75 dc             	pushl  -0x24(%ebp)
80101050:	ff 75 d4             	pushl  -0x2c(%ebp)
80101053:	e8 87 72 00 00       	call   801082df <copyout>
80101058:	83 c4 10             	add    $0x10,%esp
8010105b:	85 c0                	test   %eax,%eax
8010105d:	0f 88 d2 00 00 00    	js     80101135 <exec+0x3c0>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101063:	8b 45 08             	mov    0x8(%ebp),%eax
80101066:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010106f:	eb 17                	jmp    80101088 <exec+0x313>
    if(*s == '/')
80101071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101074:	0f b6 00             	movzbl (%eax),%eax
80101077:	3c 2f                	cmp    $0x2f,%al
80101079:	75 09                	jne    80101084 <exec+0x30f>
      last = s+1;
8010107b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010107e:	83 c0 01             	add    $0x1,%eax
80101081:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101084:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010108b:	0f b6 00             	movzbl (%eax),%eax
8010108e:	84 c0                	test   %al,%al
80101090:	75 df                	jne    80101071 <exec+0x2fc>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80101092:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101098:	83 c0 6c             	add    $0x6c,%eax
8010109b:	83 ec 04             	sub    $0x4,%esp
8010109e:	6a 10                	push   $0x10
801010a0:	ff 75 f0             	pushl  -0x10(%ebp)
801010a3:	50                   	push   %eax
801010a4:	e8 8f 41 00 00       	call   80105238 <safestrcpy>
801010a9:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
801010ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010b2:	8b 40 04             	mov    0x4(%eax),%eax
801010b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
801010b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801010c1:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801010c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
801010cd:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801010cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010d5:	8b 40 18             	mov    0x18(%eax),%eax
801010d8:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
801010de:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801010e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010e7:	8b 40 18             	mov    0x18(%eax),%eax
801010ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
801010ed:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
801010f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010f6:	83 ec 0c             	sub    $0xc,%esp
801010f9:	50                   	push   %eax
801010fa:	e8 56 6b 00 00       	call   80107c55 <switchuvm>
801010ff:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80101102:	83 ec 0c             	sub    $0xc,%esp
80101105:	ff 75 d0             	pushl  -0x30(%ebp)
80101108:	e8 8e 6f 00 00       	call   8010809b <freevm>
8010110d:	83 c4 10             	add    $0x10,%esp
  return 0;
80101110:	b8 00 00 00 00       	mov    $0x0,%eax
80101115:	eb 4c                	jmp    80101163 <exec+0x3ee>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80101117:	90                   	nop
80101118:	eb 1c                	jmp    80101136 <exec+0x3c1>
  if(elf.magic != ELF_MAGIC)
    goto bad;
8010111a:	90                   	nop
8010111b:	eb 19                	jmp    80101136 <exec+0x3c1>

  if((pgdir = setupkvm()) == 0)
    goto bad;
8010111d:	90                   	nop
8010111e:	eb 16                	jmp    80101136 <exec+0x3c1>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101120:	90                   	nop
80101121:	eb 13                	jmp    80101136 <exec+0x3c1>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80101123:	90                   	nop
80101124:	eb 10                	jmp    80101136 <exec+0x3c1>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80101126:	90                   	nop
80101127:	eb 0d                	jmp    80101136 <exec+0x3c1>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80101129:	90                   	nop
8010112a:	eb 0a                	jmp    80101136 <exec+0x3c1>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
8010112c:	90                   	nop
8010112d:	eb 07                	jmp    80101136 <exec+0x3c1>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
8010112f:	90                   	nop
80101130:	eb 04                	jmp    80101136 <exec+0x3c1>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101132:	90                   	nop
80101133:	eb 01                	jmp    80101136 <exec+0x3c1>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80101135:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80101136:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010113a:	74 0e                	je     8010114a <exec+0x3d5>
    freevm(pgdir);
8010113c:	83 ec 0c             	sub    $0xc,%esp
8010113f:	ff 75 d4             	pushl  -0x2c(%ebp)
80101142:	e8 54 6f 00 00       	call   8010809b <freevm>
80101147:	83 c4 10             	add    $0x10,%esp
  if(ip)
8010114a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010114e:	74 0e                	je     8010115e <exec+0x3e9>
    iunlockput(ip);
80101150:	83 ec 0c             	sub    $0xc,%esp
80101153:	ff 75 d8             	pushl  -0x28(%ebp)
80101156:	e8 75 0c 00 00       	call   80101dd0 <iunlockput>
8010115b:	83 c4 10             	add    $0x10,%esp
  return -1;
8010115e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101163:	c9                   	leave  
80101164:	c3                   	ret    

80101165 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101165:	55                   	push   %ebp
80101166:	89 e5                	mov    %esp,%ebp
80101168:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010116b:	83 ec 08             	sub    $0x8,%esp
8010116e:	68 f1 83 10 80       	push   $0x801083f1
80101173:	68 80 de 10 80       	push   $0x8010de80
80101178:	e8 33 3c 00 00       	call   80104db0 <initlock>
8010117d:	83 c4 10             	add    $0x10,%esp
}
80101180:	90                   	nop
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101189:	83 ec 0c             	sub    $0xc,%esp
8010118c:	68 80 de 10 80       	push   $0x8010de80
80101191:	e8 3c 3c 00 00       	call   80104dd2 <acquire>
80101196:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101199:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
801011a0:	eb 2d                	jmp    801011cf <filealloc+0x4c>
    if(f->ref == 0){
801011a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011a5:	8b 40 04             	mov    0x4(%eax),%eax
801011a8:	85 c0                	test   %eax,%eax
801011aa:	75 1f                	jne    801011cb <filealloc+0x48>
      f->ref = 1;
801011ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011af:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801011b6:	83 ec 0c             	sub    $0xc,%esp
801011b9:	68 80 de 10 80       	push   $0x8010de80
801011be:	e8 76 3c 00 00       	call   80104e39 <release>
801011c3:	83 c4 10             	add    $0x10,%esp
      return f;
801011c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011c9:	eb 23                	jmp    801011ee <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801011cb:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801011cf:	b8 14 e8 10 80       	mov    $0x8010e814,%eax
801011d4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801011d7:	72 c9                	jb     801011a2 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801011d9:	83 ec 0c             	sub    $0xc,%esp
801011dc:	68 80 de 10 80       	push   $0x8010de80
801011e1:	e8 53 3c 00 00       	call   80104e39 <release>
801011e6:	83 c4 10             	add    $0x10,%esp
  return 0;
801011e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801011ee:	c9                   	leave  
801011ef:	c3                   	ret    

801011f0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801011f0:	55                   	push   %ebp
801011f1:	89 e5                	mov    %esp,%ebp
801011f3:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801011f6:	83 ec 0c             	sub    $0xc,%esp
801011f9:	68 80 de 10 80       	push   $0x8010de80
801011fe:	e8 cf 3b 00 00       	call   80104dd2 <acquire>
80101203:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101206:	8b 45 08             	mov    0x8(%ebp),%eax
80101209:	8b 40 04             	mov    0x4(%eax),%eax
8010120c:	85 c0                	test   %eax,%eax
8010120e:	7f 0d                	jg     8010121d <filedup+0x2d>
    panic("filedup");
80101210:	83 ec 0c             	sub    $0xc,%esp
80101213:	68 f8 83 10 80       	push   $0x801083f8
80101218:	e8 49 f3 ff ff       	call   80100566 <panic>
  f->ref++;
8010121d:	8b 45 08             	mov    0x8(%ebp),%eax
80101220:	8b 40 04             	mov    0x4(%eax),%eax
80101223:	8d 50 01             	lea    0x1(%eax),%edx
80101226:	8b 45 08             	mov    0x8(%ebp),%eax
80101229:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010122c:	83 ec 0c             	sub    $0xc,%esp
8010122f:	68 80 de 10 80       	push   $0x8010de80
80101234:	e8 00 3c 00 00       	call   80104e39 <release>
80101239:	83 c4 10             	add    $0x10,%esp
  return f;
8010123c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010123f:	c9                   	leave  
80101240:	c3                   	ret    

80101241 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101241:	55                   	push   %ebp
80101242:	89 e5                	mov    %esp,%ebp
80101244:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101247:	83 ec 0c             	sub    $0xc,%esp
8010124a:	68 80 de 10 80       	push   $0x8010de80
8010124f:	e8 7e 3b 00 00       	call   80104dd2 <acquire>
80101254:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101257:	8b 45 08             	mov    0x8(%ebp),%eax
8010125a:	8b 40 04             	mov    0x4(%eax),%eax
8010125d:	85 c0                	test   %eax,%eax
8010125f:	7f 0d                	jg     8010126e <fileclose+0x2d>
    panic("fileclose");
80101261:	83 ec 0c             	sub    $0xc,%esp
80101264:	68 00 84 10 80       	push   $0x80108400
80101269:	e8 f8 f2 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010126e:	8b 45 08             	mov    0x8(%ebp),%eax
80101271:	8b 40 04             	mov    0x4(%eax),%eax
80101274:	8d 50 ff             	lea    -0x1(%eax),%edx
80101277:	8b 45 08             	mov    0x8(%ebp),%eax
8010127a:	89 50 04             	mov    %edx,0x4(%eax)
8010127d:	8b 45 08             	mov    0x8(%ebp),%eax
80101280:	8b 40 04             	mov    0x4(%eax),%eax
80101283:	85 c0                	test   %eax,%eax
80101285:	7e 15                	jle    8010129c <fileclose+0x5b>
    release(&ftable.lock);
80101287:	83 ec 0c             	sub    $0xc,%esp
8010128a:	68 80 de 10 80       	push   $0x8010de80
8010128f:	e8 a5 3b 00 00       	call   80104e39 <release>
80101294:	83 c4 10             	add    $0x10,%esp
80101297:	e9 8b 00 00 00       	jmp    80101327 <fileclose+0xe6>
    return;
  }
  ff = *f;
8010129c:	8b 45 08             	mov    0x8(%ebp),%eax
8010129f:	8b 10                	mov    (%eax),%edx
801012a1:	89 55 e0             	mov    %edx,-0x20(%ebp)
801012a4:	8b 50 04             	mov    0x4(%eax),%edx
801012a7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801012aa:	8b 50 08             	mov    0x8(%eax),%edx
801012ad:	89 55 e8             	mov    %edx,-0x18(%ebp)
801012b0:	8b 50 0c             	mov    0xc(%eax),%edx
801012b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
801012b6:	8b 50 10             	mov    0x10(%eax),%edx
801012b9:	89 55 f0             	mov    %edx,-0x10(%ebp)
801012bc:	8b 40 14             	mov    0x14(%eax),%eax
801012bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801012cc:	8b 45 08             	mov    0x8(%ebp),%eax
801012cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801012d5:	83 ec 0c             	sub    $0xc,%esp
801012d8:	68 80 de 10 80       	push   $0x8010de80
801012dd:	e8 57 3b 00 00       	call   80104e39 <release>
801012e2:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801012e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801012e8:	83 f8 01             	cmp    $0x1,%eax
801012eb:	75 19                	jne    80101306 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801012ed:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801012f1:	0f be d0             	movsbl %al,%edx
801012f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012f7:	83 ec 08             	sub    $0x8,%esp
801012fa:	52                   	push   %edx
801012fb:	50                   	push   %eax
801012fc:	e8 a5 2c 00 00       	call   80103fa6 <pipeclose>
80101301:	83 c4 10             	add    $0x10,%esp
80101304:	eb 21                	jmp    80101327 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101306:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101309:	83 f8 02             	cmp    $0x2,%eax
8010130c:	75 19                	jne    80101327 <fileclose+0xe6>
    begin_trans();
8010130e:	e8 87 21 00 00       	call   8010349a <begin_trans>
    iput(ff.ip);
80101313:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101316:	83 ec 0c             	sub    $0xc,%esp
80101319:	50                   	push   %eax
8010131a:	e8 c1 09 00 00       	call   80101ce0 <iput>
8010131f:	83 c4 10             	add    $0x10,%esp
    commit_trans();
80101322:	e8 c6 21 00 00       	call   801034ed <commit_trans>
  }
}
80101327:	c9                   	leave  
80101328:	c3                   	ret    

80101329 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101329:	55                   	push   %ebp
8010132a:	89 e5                	mov    %esp,%ebp
8010132c:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010132f:	8b 45 08             	mov    0x8(%ebp),%eax
80101332:	8b 00                	mov    (%eax),%eax
80101334:	83 f8 02             	cmp    $0x2,%eax
80101337:	75 40                	jne    80101379 <filestat+0x50>
    ilock(f->ip);
80101339:	8b 45 08             	mov    0x8(%ebp),%eax
8010133c:	8b 40 10             	mov    0x10(%eax),%eax
8010133f:	83 ec 0c             	sub    $0xc,%esp
80101342:	50                   	push   %eax
80101343:	e8 ce 07 00 00       	call   80101b16 <ilock>
80101348:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010134b:	8b 45 08             	mov    0x8(%ebp),%eax
8010134e:	8b 40 10             	mov    0x10(%eax),%eax
80101351:	83 ec 08             	sub    $0x8,%esp
80101354:	ff 75 0c             	pushl  0xc(%ebp)
80101357:	50                   	push   %eax
80101358:	e8 db 0c 00 00       	call   80102038 <stati>
8010135d:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101360:	8b 45 08             	mov    0x8(%ebp),%eax
80101363:	8b 40 10             	mov    0x10(%eax),%eax
80101366:	83 ec 0c             	sub    $0xc,%esp
80101369:	50                   	push   %eax
8010136a:	e8 ff 08 00 00       	call   80101c6e <iunlock>
8010136f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101372:	b8 00 00 00 00       	mov    $0x0,%eax
80101377:	eb 05                	jmp    8010137e <filestat+0x55>
  }
  return -1;
80101379:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010137e:	c9                   	leave  
8010137f:	c3                   	ret    

80101380 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101380:	55                   	push   %ebp
80101381:	89 e5                	mov    %esp,%ebp
80101383:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101386:	8b 45 08             	mov    0x8(%ebp),%eax
80101389:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010138d:	84 c0                	test   %al,%al
8010138f:	75 0a                	jne    8010139b <fileread+0x1b>
    return -1;
80101391:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101396:	e9 9b 00 00 00       	jmp    80101436 <fileread+0xb6>
  if(f->type == FD_PIPE)
8010139b:	8b 45 08             	mov    0x8(%ebp),%eax
8010139e:	8b 00                	mov    (%eax),%eax
801013a0:	83 f8 01             	cmp    $0x1,%eax
801013a3:	75 1a                	jne    801013bf <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801013a5:	8b 45 08             	mov    0x8(%ebp),%eax
801013a8:	8b 40 0c             	mov    0xc(%eax),%eax
801013ab:	83 ec 04             	sub    $0x4,%esp
801013ae:	ff 75 10             	pushl  0x10(%ebp)
801013b1:	ff 75 0c             	pushl  0xc(%ebp)
801013b4:	50                   	push   %eax
801013b5:	e8 94 2d 00 00       	call   8010414e <piperead>
801013ba:	83 c4 10             	add    $0x10,%esp
801013bd:	eb 77                	jmp    80101436 <fileread+0xb6>
  if(f->type == FD_INODE){
801013bf:	8b 45 08             	mov    0x8(%ebp),%eax
801013c2:	8b 00                	mov    (%eax),%eax
801013c4:	83 f8 02             	cmp    $0x2,%eax
801013c7:	75 60                	jne    80101429 <fileread+0xa9>
    ilock(f->ip);
801013c9:	8b 45 08             	mov    0x8(%ebp),%eax
801013cc:	8b 40 10             	mov    0x10(%eax),%eax
801013cf:	83 ec 0c             	sub    $0xc,%esp
801013d2:	50                   	push   %eax
801013d3:	e8 3e 07 00 00       	call   80101b16 <ilock>
801013d8:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801013db:	8b 4d 10             	mov    0x10(%ebp),%ecx
801013de:	8b 45 08             	mov    0x8(%ebp),%eax
801013e1:	8b 50 14             	mov    0x14(%eax),%edx
801013e4:	8b 45 08             	mov    0x8(%ebp),%eax
801013e7:	8b 40 10             	mov    0x10(%eax),%eax
801013ea:	51                   	push   %ecx
801013eb:	52                   	push   %edx
801013ec:	ff 75 0c             	pushl  0xc(%ebp)
801013ef:	50                   	push   %eax
801013f0:	e8 89 0c 00 00       	call   8010207e <readi>
801013f5:	83 c4 10             	add    $0x10,%esp
801013f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801013fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801013ff:	7e 11                	jle    80101412 <fileread+0x92>
      f->off += r;
80101401:	8b 45 08             	mov    0x8(%ebp),%eax
80101404:	8b 50 14             	mov    0x14(%eax),%edx
80101407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010140a:	01 c2                	add    %eax,%edx
8010140c:	8b 45 08             	mov    0x8(%ebp),%eax
8010140f:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101412:	8b 45 08             	mov    0x8(%ebp),%eax
80101415:	8b 40 10             	mov    0x10(%eax),%eax
80101418:	83 ec 0c             	sub    $0xc,%esp
8010141b:	50                   	push   %eax
8010141c:	e8 4d 08 00 00       	call   80101c6e <iunlock>
80101421:	83 c4 10             	add    $0x10,%esp
    return r;
80101424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101427:	eb 0d                	jmp    80101436 <fileread+0xb6>
  }
  panic("fileread");
80101429:	83 ec 0c             	sub    $0xc,%esp
8010142c:	68 0a 84 10 80       	push   $0x8010840a
80101431:	e8 30 f1 ff ff       	call   80100566 <panic>
}
80101436:	c9                   	leave  
80101437:	c3                   	ret    

80101438 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101438:	55                   	push   %ebp
80101439:	89 e5                	mov    %esp,%ebp
8010143b:	53                   	push   %ebx
8010143c:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010143f:	8b 45 08             	mov    0x8(%ebp),%eax
80101442:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101446:	84 c0                	test   %al,%al
80101448:	75 0a                	jne    80101454 <filewrite+0x1c>
    return -1;
8010144a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010144f:	e9 1b 01 00 00       	jmp    8010156f <filewrite+0x137>
  if(f->type == FD_PIPE)
80101454:	8b 45 08             	mov    0x8(%ebp),%eax
80101457:	8b 00                	mov    (%eax),%eax
80101459:	83 f8 01             	cmp    $0x1,%eax
8010145c:	75 1d                	jne    8010147b <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010145e:	8b 45 08             	mov    0x8(%ebp),%eax
80101461:	8b 40 0c             	mov    0xc(%eax),%eax
80101464:	83 ec 04             	sub    $0x4,%esp
80101467:	ff 75 10             	pushl  0x10(%ebp)
8010146a:	ff 75 0c             	pushl  0xc(%ebp)
8010146d:	50                   	push   %eax
8010146e:	e8 dd 2b 00 00       	call   80104050 <pipewrite>
80101473:	83 c4 10             	add    $0x10,%esp
80101476:	e9 f4 00 00 00       	jmp    8010156f <filewrite+0x137>
  if(f->type == FD_INODE){
8010147b:	8b 45 08             	mov    0x8(%ebp),%eax
8010147e:	8b 00                	mov    (%eax),%eax
80101480:	83 f8 02             	cmp    $0x2,%eax
80101483:	0f 85 d9 00 00 00    	jne    80101562 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101489:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101490:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101497:	e9 a3 00 00 00       	jmp    8010153f <filewrite+0x107>
      int n1 = n - i;
8010149c:	8b 45 10             	mov    0x10(%ebp),%eax
8010149f:	2b 45 f4             	sub    -0xc(%ebp),%eax
801014a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801014a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801014ab:	7e 06                	jle    801014b3 <filewrite+0x7b>
        n1 = max;
801014ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014b0:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
801014b3:	e8 e2 1f 00 00       	call   8010349a <begin_trans>
      ilock(f->ip);
801014b8:	8b 45 08             	mov    0x8(%ebp),%eax
801014bb:	8b 40 10             	mov    0x10(%eax),%eax
801014be:	83 ec 0c             	sub    $0xc,%esp
801014c1:	50                   	push   %eax
801014c2:	e8 4f 06 00 00       	call   80101b16 <ilock>
801014c7:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801014ca:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801014cd:	8b 45 08             	mov    0x8(%ebp),%eax
801014d0:	8b 50 14             	mov    0x14(%eax),%edx
801014d3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801014d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801014d9:	01 c3                	add    %eax,%ebx
801014db:	8b 45 08             	mov    0x8(%ebp),%eax
801014de:	8b 40 10             	mov    0x10(%eax),%eax
801014e1:	51                   	push   %ecx
801014e2:	52                   	push   %edx
801014e3:	53                   	push   %ebx
801014e4:	50                   	push   %eax
801014e5:	e8 eb 0c 00 00       	call   801021d5 <writei>
801014ea:	83 c4 10             	add    $0x10,%esp
801014ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
801014f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801014f4:	7e 11                	jle    80101507 <filewrite+0xcf>
        f->off += r;
801014f6:	8b 45 08             	mov    0x8(%ebp),%eax
801014f9:	8b 50 14             	mov    0x14(%eax),%edx
801014fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014ff:	01 c2                	add    %eax,%edx
80101501:	8b 45 08             	mov    0x8(%ebp),%eax
80101504:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101507:	8b 45 08             	mov    0x8(%ebp),%eax
8010150a:	8b 40 10             	mov    0x10(%eax),%eax
8010150d:	83 ec 0c             	sub    $0xc,%esp
80101510:	50                   	push   %eax
80101511:	e8 58 07 00 00       	call   80101c6e <iunlock>
80101516:	83 c4 10             	add    $0x10,%esp
      commit_trans();
80101519:	e8 cf 1f 00 00       	call   801034ed <commit_trans>

      if(r < 0)
8010151e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101522:	78 29                	js     8010154d <filewrite+0x115>
        break;
      if(r != n1)
80101524:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101527:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010152a:	74 0d                	je     80101539 <filewrite+0x101>
        panic("short filewrite");
8010152c:	83 ec 0c             	sub    $0xc,%esp
8010152f:	68 13 84 10 80       	push   $0x80108413
80101534:	e8 2d f0 ff ff       	call   80100566 <panic>
      i += r;
80101539:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010153c:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	3b 45 10             	cmp    0x10(%ebp),%eax
80101545:	0f 8c 51 ff ff ff    	jl     8010149c <filewrite+0x64>
8010154b:	eb 01                	jmp    8010154e <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
8010154d:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010154e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101551:	3b 45 10             	cmp    0x10(%ebp),%eax
80101554:	75 05                	jne    8010155b <filewrite+0x123>
80101556:	8b 45 10             	mov    0x10(%ebp),%eax
80101559:	eb 14                	jmp    8010156f <filewrite+0x137>
8010155b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101560:	eb 0d                	jmp    8010156f <filewrite+0x137>
  }
  panic("filewrite");
80101562:	83 ec 0c             	sub    $0xc,%esp
80101565:	68 23 84 10 80       	push   $0x80108423
8010156a:	e8 f7 ef ff ff       	call   80100566 <panic>
}
8010156f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101572:	c9                   	leave  
80101573:	c3                   	ret    

80101574 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101574:	55                   	push   %ebp
80101575:	89 e5                	mov    %esp,%ebp
80101577:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010157a:	8b 45 08             	mov    0x8(%ebp),%eax
8010157d:	83 ec 08             	sub    $0x8,%esp
80101580:	6a 01                	push   $0x1
80101582:	50                   	push   %eax
80101583:	e8 2e ec ff ff       	call   801001b6 <bread>
80101588:	83 c4 10             	add    $0x10,%esp
8010158b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	83 c0 18             	add    $0x18,%eax
80101594:	83 ec 04             	sub    $0x4,%esp
80101597:	6a 10                	push   $0x10
80101599:	50                   	push   %eax
8010159a:	ff 75 0c             	pushl  0xc(%ebp)
8010159d:	e8 52 3b 00 00       	call   801050f4 <memmove>
801015a2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801015a5:	83 ec 0c             	sub    $0xc,%esp
801015a8:	ff 75 f4             	pushl  -0xc(%ebp)
801015ab:	e8 7e ec ff ff       	call   8010022e <brelse>
801015b0:	83 c4 10             	add    $0x10,%esp
}
801015b3:	90                   	nop
801015b4:	c9                   	leave  
801015b5:	c3                   	ret    

801015b6 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801015b6:	55                   	push   %ebp
801015b7:	89 e5                	mov    %esp,%ebp
801015b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801015bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801015bf:	8b 45 08             	mov    0x8(%ebp),%eax
801015c2:	83 ec 08             	sub    $0x8,%esp
801015c5:	52                   	push   %edx
801015c6:	50                   	push   %eax
801015c7:	e8 ea eb ff ff       	call   801001b6 <bread>
801015cc:	83 c4 10             	add    $0x10,%esp
801015cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015d5:	83 c0 18             	add    $0x18,%eax
801015d8:	83 ec 04             	sub    $0x4,%esp
801015db:	68 00 02 00 00       	push   $0x200
801015e0:	6a 00                	push   $0x0
801015e2:	50                   	push   %eax
801015e3:	e8 4d 3a 00 00       	call   80105035 <memset>
801015e8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801015eb:	83 ec 0c             	sub    $0xc,%esp
801015ee:	ff 75 f4             	pushl  -0xc(%ebp)
801015f1:	e8 5c 1f 00 00       	call   80103552 <log_write>
801015f6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801015f9:	83 ec 0c             	sub    $0xc,%esp
801015fc:	ff 75 f4             	pushl  -0xc(%ebp)
801015ff:	e8 2a ec ff ff       	call   8010022e <brelse>
80101604:	83 c4 10             	add    $0x10,%esp
}
80101607:	90                   	nop
80101608:	c9                   	leave  
80101609:	c3                   	ret    

8010160a <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010160a:	55                   	push   %ebp
8010160b:	89 e5                	mov    %esp,%ebp
8010160d:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101610:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101617:	8b 45 08             	mov    0x8(%ebp),%eax
8010161a:	83 ec 08             	sub    $0x8,%esp
8010161d:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101620:	52                   	push   %edx
80101621:	50                   	push   %eax
80101622:	e8 4d ff ff ff       	call   80101574 <readsb>
80101627:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010162a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101631:	e9 15 01 00 00       	jmp    8010174b <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101639:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010163f:	85 c0                	test   %eax,%eax
80101641:	0f 48 c2             	cmovs  %edx,%eax
80101644:	c1 f8 0c             	sar    $0xc,%eax
80101647:	89 c2                	mov    %eax,%edx
80101649:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010164c:	c1 e8 03             	shr    $0x3,%eax
8010164f:	01 d0                	add    %edx,%eax
80101651:	83 c0 03             	add    $0x3,%eax
80101654:	83 ec 08             	sub    $0x8,%esp
80101657:	50                   	push   %eax
80101658:	ff 75 08             	pushl  0x8(%ebp)
8010165b:	e8 56 eb ff ff       	call   801001b6 <bread>
80101660:	83 c4 10             	add    $0x10,%esp
80101663:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101666:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010166d:	e9 a6 00 00 00       	jmp    80101718 <balloc+0x10e>
      m = 1 << (bi % 8);
80101672:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101675:	99                   	cltd   
80101676:	c1 ea 1d             	shr    $0x1d,%edx
80101679:	01 d0                	add    %edx,%eax
8010167b:	83 e0 07             	and    $0x7,%eax
8010167e:	29 d0                	sub    %edx,%eax
80101680:	ba 01 00 00 00       	mov    $0x1,%edx
80101685:	89 c1                	mov    %eax,%ecx
80101687:	d3 e2                	shl    %cl,%edx
80101689:	89 d0                	mov    %edx,%eax
8010168b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010168e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101691:	8d 50 07             	lea    0x7(%eax),%edx
80101694:	85 c0                	test   %eax,%eax
80101696:	0f 48 c2             	cmovs  %edx,%eax
80101699:	c1 f8 03             	sar    $0x3,%eax
8010169c:	89 c2                	mov    %eax,%edx
8010169e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016a1:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801016a6:	0f b6 c0             	movzbl %al,%eax
801016a9:	23 45 e8             	and    -0x18(%ebp),%eax
801016ac:	85 c0                	test   %eax,%eax
801016ae:	75 64                	jne    80101714 <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
801016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016b3:	8d 50 07             	lea    0x7(%eax),%edx
801016b6:	85 c0                	test   %eax,%eax
801016b8:	0f 48 c2             	cmovs  %edx,%eax
801016bb:	c1 f8 03             	sar    $0x3,%eax
801016be:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016c1:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801016c6:	89 d1                	mov    %edx,%ecx
801016c8:	8b 55 e8             	mov    -0x18(%ebp),%edx
801016cb:	09 ca                	or     %ecx,%edx
801016cd:	89 d1                	mov    %edx,%ecx
801016cf:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016d2:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801016d6:	83 ec 0c             	sub    $0xc,%esp
801016d9:	ff 75 ec             	pushl  -0x14(%ebp)
801016dc:	e8 71 1e 00 00       	call   80103552 <log_write>
801016e1:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801016e4:	83 ec 0c             	sub    $0xc,%esp
801016e7:	ff 75 ec             	pushl  -0x14(%ebp)
801016ea:	e8 3f eb ff ff       	call   8010022e <brelse>
801016ef:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801016f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f8:	01 c2                	add    %eax,%edx
801016fa:	8b 45 08             	mov    0x8(%ebp),%eax
801016fd:	83 ec 08             	sub    $0x8,%esp
80101700:	52                   	push   %edx
80101701:	50                   	push   %eax
80101702:	e8 af fe ff ff       	call   801015b6 <bzero>
80101707:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010170a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101710:	01 d0                	add    %edx,%eax
80101712:	eb 52                	jmp    80101766 <balloc+0x15c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101714:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101718:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010171f:	7f 15                	jg     80101736 <balloc+0x12c>
80101721:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101724:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101727:	01 d0                	add    %edx,%eax
80101729:	89 c2                	mov    %eax,%edx
8010172b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010172e:	39 c2                	cmp    %eax,%edx
80101730:	0f 82 3c ff ff ff    	jb     80101672 <balloc+0x68>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101736:	83 ec 0c             	sub    $0xc,%esp
80101739:	ff 75 ec             	pushl  -0x14(%ebp)
8010173c:	e8 ed ea ff ff       	call   8010022e <brelse>
80101741:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101744:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010174b:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010174e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101751:	39 c2                	cmp    %eax,%edx
80101753:	0f 87 dd fe ff ff    	ja     80101636 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101759:	83 ec 0c             	sub    $0xc,%esp
8010175c:	68 2d 84 10 80       	push   $0x8010842d
80101761:	e8 00 ee ff ff       	call   80100566 <panic>
}
80101766:	c9                   	leave  
80101767:	c3                   	ret    

80101768 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101768:	55                   	push   %ebp
80101769:	89 e5                	mov    %esp,%ebp
8010176b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
8010176e:	83 ec 08             	sub    $0x8,%esp
80101771:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101774:	50                   	push   %eax
80101775:	ff 75 08             	pushl  0x8(%ebp)
80101778:	e8 f7 fd ff ff       	call   80101574 <readsb>
8010177d:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101780:	8b 45 0c             	mov    0xc(%ebp),%eax
80101783:	c1 e8 0c             	shr    $0xc,%eax
80101786:	89 c2                	mov    %eax,%edx
80101788:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010178b:	c1 e8 03             	shr    $0x3,%eax
8010178e:	01 d0                	add    %edx,%eax
80101790:	8d 50 03             	lea    0x3(%eax),%edx
80101793:	8b 45 08             	mov    0x8(%ebp),%eax
80101796:	83 ec 08             	sub    $0x8,%esp
80101799:	52                   	push   %edx
8010179a:	50                   	push   %eax
8010179b:	e8 16 ea ff ff       	call   801001b6 <bread>
801017a0:	83 c4 10             	add    $0x10,%esp
801017a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801017a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801017a9:	25 ff 0f 00 00       	and    $0xfff,%eax
801017ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801017b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017b4:	99                   	cltd   
801017b5:	c1 ea 1d             	shr    $0x1d,%edx
801017b8:	01 d0                	add    %edx,%eax
801017ba:	83 e0 07             	and    $0x7,%eax
801017bd:	29 d0                	sub    %edx,%eax
801017bf:	ba 01 00 00 00       	mov    $0x1,%edx
801017c4:	89 c1                	mov    %eax,%ecx
801017c6:	d3 e2                	shl    %cl,%edx
801017c8:	89 d0                	mov    %edx,%eax
801017ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801017cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d0:	8d 50 07             	lea    0x7(%eax),%edx
801017d3:	85 c0                	test   %eax,%eax
801017d5:	0f 48 c2             	cmovs  %edx,%eax
801017d8:	c1 f8 03             	sar    $0x3,%eax
801017db:	89 c2                	mov    %eax,%edx
801017dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e0:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801017e5:	0f b6 c0             	movzbl %al,%eax
801017e8:	23 45 ec             	and    -0x14(%ebp),%eax
801017eb:	85 c0                	test   %eax,%eax
801017ed:	75 0d                	jne    801017fc <bfree+0x94>
    panic("freeing free block");
801017ef:	83 ec 0c             	sub    $0xc,%esp
801017f2:	68 43 84 10 80       	push   $0x80108443
801017f7:	e8 6a ed ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801017fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ff:	8d 50 07             	lea    0x7(%eax),%edx
80101802:	85 c0                	test   %eax,%eax
80101804:	0f 48 c2             	cmovs  %edx,%eax
80101807:	c1 f8 03             	sar    $0x3,%eax
8010180a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010180d:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101812:	89 d1                	mov    %edx,%ecx
80101814:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101817:	f7 d2                	not    %edx
80101819:	21 ca                	and    %ecx,%edx
8010181b:	89 d1                	mov    %edx,%ecx
8010181d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101820:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101824:	83 ec 0c             	sub    $0xc,%esp
80101827:	ff 75 f4             	pushl  -0xc(%ebp)
8010182a:	e8 23 1d 00 00       	call   80103552 <log_write>
8010182f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101832:	83 ec 0c             	sub    $0xc,%esp
80101835:	ff 75 f4             	pushl  -0xc(%ebp)
80101838:	e8 f1 e9 ff ff       	call   8010022e <brelse>
8010183d:	83 c4 10             	add    $0x10,%esp
}
80101840:	90                   	nop
80101841:	c9                   	leave  
80101842:	c3                   	ret    

80101843 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101843:	55                   	push   %ebp
80101844:	89 e5                	mov    %esp,%ebp
80101846:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
80101849:	83 ec 08             	sub    $0x8,%esp
8010184c:	68 56 84 10 80       	push   $0x80108456
80101851:	68 80 e8 10 80       	push   $0x8010e880
80101856:	e8 55 35 00 00       	call   80104db0 <initlock>
8010185b:	83 c4 10             	add    $0x10,%esp
}
8010185e:	90                   	nop
8010185f:	c9                   	leave  
80101860:	c3                   	ret    

80101861 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101861:	55                   	push   %ebp
80101862:	89 e5                	mov    %esp,%ebp
80101864:	83 ec 38             	sub    $0x38,%esp
80101867:	8b 45 0c             	mov    0xc(%ebp),%eax
8010186a:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
8010186e:	8b 45 08             	mov    0x8(%ebp),%eax
80101871:	83 ec 08             	sub    $0x8,%esp
80101874:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101877:	52                   	push   %edx
80101878:	50                   	push   %eax
80101879:	e8 f6 fc ff ff       	call   80101574 <readsb>
8010187e:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
80101881:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101888:	e9 98 00 00 00       	jmp    80101925 <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
8010188d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101890:	c1 e8 03             	shr    $0x3,%eax
80101893:	83 c0 02             	add    $0x2,%eax
80101896:	83 ec 08             	sub    $0x8,%esp
80101899:	50                   	push   %eax
8010189a:	ff 75 08             	pushl  0x8(%ebp)
8010189d:	e8 14 e9 ff ff       	call   801001b6 <bread>
801018a2:	83 c4 10             	add    $0x10,%esp
801018a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ab:	8d 50 18             	lea    0x18(%eax),%edx
801018ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b1:	83 e0 07             	and    $0x7,%eax
801018b4:	c1 e0 06             	shl    $0x6,%eax
801018b7:	01 d0                	add    %edx,%eax
801018b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018bf:	0f b7 00             	movzwl (%eax),%eax
801018c2:	66 85 c0             	test   %ax,%ax
801018c5:	75 4c                	jne    80101913 <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
801018c7:	83 ec 04             	sub    $0x4,%esp
801018ca:	6a 40                	push   $0x40
801018cc:	6a 00                	push   $0x0
801018ce:	ff 75 ec             	pushl  -0x14(%ebp)
801018d1:	e8 5f 37 00 00       	call   80105035 <memset>
801018d6:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801018d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018dc:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801018e0:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801018e3:	83 ec 0c             	sub    $0xc,%esp
801018e6:	ff 75 f0             	pushl  -0x10(%ebp)
801018e9:	e8 64 1c 00 00       	call   80103552 <log_write>
801018ee:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018f1:	83 ec 0c             	sub    $0xc,%esp
801018f4:	ff 75 f0             	pushl  -0x10(%ebp)
801018f7:	e8 32 e9 ff ff       	call   8010022e <brelse>
801018fc:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101902:	83 ec 08             	sub    $0x8,%esp
80101905:	50                   	push   %eax
80101906:	ff 75 08             	pushl  0x8(%ebp)
80101909:	e8 ef 00 00 00       	call   801019fd <iget>
8010190e:	83 c4 10             	add    $0x10,%esp
80101911:	eb 2d                	jmp    80101940 <ialloc+0xdf>
    }
    brelse(bp);
80101913:	83 ec 0c             	sub    $0xc,%esp
80101916:	ff 75 f0             	pushl  -0x10(%ebp)
80101919:	e8 10 e9 ff ff       	call   8010022e <brelse>
8010191e:	83 c4 10             	add    $0x10,%esp
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101921:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101925:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192b:	39 c2                	cmp    %eax,%edx
8010192d:	0f 87 5a ff ff ff    	ja     8010188d <ialloc+0x2c>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101933:	83 ec 0c             	sub    $0xc,%esp
80101936:	68 5d 84 10 80       	push   $0x8010845d
8010193b:	e8 26 ec ff ff       	call   80100566 <panic>
}
80101940:	c9                   	leave  
80101941:	c3                   	ret    

80101942 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101942:	55                   	push   %ebp
80101943:	89 e5                	mov    %esp,%ebp
80101945:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101948:	8b 45 08             	mov    0x8(%ebp),%eax
8010194b:	8b 40 04             	mov    0x4(%eax),%eax
8010194e:	c1 e8 03             	shr    $0x3,%eax
80101951:	8d 50 02             	lea    0x2(%eax),%edx
80101954:	8b 45 08             	mov    0x8(%ebp),%eax
80101957:	8b 00                	mov    (%eax),%eax
80101959:	83 ec 08             	sub    $0x8,%esp
8010195c:	52                   	push   %edx
8010195d:	50                   	push   %eax
8010195e:	e8 53 e8 ff ff       	call   801001b6 <bread>
80101963:	83 c4 10             	add    $0x10,%esp
80101966:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196c:	8d 50 18             	lea    0x18(%eax),%edx
8010196f:	8b 45 08             	mov    0x8(%ebp),%eax
80101972:	8b 40 04             	mov    0x4(%eax),%eax
80101975:	83 e0 07             	and    $0x7,%eax
80101978:	c1 e0 06             	shl    $0x6,%eax
8010197b:	01 d0                	add    %edx,%eax
8010197d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101980:	8b 45 08             	mov    0x8(%ebp),%eax
80101983:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101987:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198a:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010198d:	8b 45 08             	mov    0x8(%ebp),%eax
80101990:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101994:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101997:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010199b:	8b 45 08             	mov    0x8(%ebp),%eax
8010199e:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801019a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a5:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019a9:	8b 45 08             	mov    0x8(%ebp),%eax
801019ac:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801019b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b3:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801019b7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ba:	8b 50 18             	mov    0x18(%eax),%edx
801019bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c0:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019c3:	8b 45 08             	mov    0x8(%ebp),%eax
801019c6:	8d 50 1c             	lea    0x1c(%eax),%edx
801019c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cc:	83 c0 0c             	add    $0xc,%eax
801019cf:	83 ec 04             	sub    $0x4,%esp
801019d2:	6a 34                	push   $0x34
801019d4:	52                   	push   %edx
801019d5:	50                   	push   %eax
801019d6:	e8 19 37 00 00       	call   801050f4 <memmove>
801019db:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019de:	83 ec 0c             	sub    $0xc,%esp
801019e1:	ff 75 f4             	pushl  -0xc(%ebp)
801019e4:	e8 69 1b 00 00       	call   80103552 <log_write>
801019e9:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019ec:	83 ec 0c             	sub    $0xc,%esp
801019ef:	ff 75 f4             	pushl  -0xc(%ebp)
801019f2:	e8 37 e8 ff ff       	call   8010022e <brelse>
801019f7:	83 c4 10             	add    $0x10,%esp
}
801019fa:	90                   	nop
801019fb:	c9                   	leave  
801019fc:	c3                   	ret    

801019fd <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019fd:	55                   	push   %ebp
801019fe:	89 e5                	mov    %esp,%ebp
80101a00:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a03:	83 ec 0c             	sub    $0xc,%esp
80101a06:	68 80 e8 10 80       	push   $0x8010e880
80101a0b:	e8 c2 33 00 00       	call   80104dd2 <acquire>
80101a10:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a1a:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101a21:	eb 5d                	jmp    80101a80 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a26:	8b 40 08             	mov    0x8(%eax),%eax
80101a29:	85 c0                	test   %eax,%eax
80101a2b:	7e 39                	jle    80101a66 <iget+0x69>
80101a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a30:	8b 00                	mov    (%eax),%eax
80101a32:	3b 45 08             	cmp    0x8(%ebp),%eax
80101a35:	75 2f                	jne    80101a66 <iget+0x69>
80101a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3a:	8b 40 04             	mov    0x4(%eax),%eax
80101a3d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101a40:	75 24                	jne    80101a66 <iget+0x69>
      ip->ref++;
80101a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a45:	8b 40 08             	mov    0x8(%eax),%eax
80101a48:	8d 50 01             	lea    0x1(%eax),%edx
80101a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4e:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a51:	83 ec 0c             	sub    $0xc,%esp
80101a54:	68 80 e8 10 80       	push   $0x8010e880
80101a59:	e8 db 33 00 00       	call   80104e39 <release>
80101a5e:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a64:	eb 74                	jmp    80101ada <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a6a:	75 10                	jne    80101a7c <iget+0x7f>
80101a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6f:	8b 40 08             	mov    0x8(%eax),%eax
80101a72:	85 c0                	test   %eax,%eax
80101a74:	75 06                	jne    80101a7c <iget+0x7f>
      empty = ip;
80101a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a79:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a7c:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101a80:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
80101a87:	72 9a                	jb     80101a23 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a89:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a8d:	75 0d                	jne    80101a9c <iget+0x9f>
    panic("iget: no inodes");
80101a8f:	83 ec 0c             	sub    $0xc,%esp
80101a92:	68 6f 84 10 80       	push   $0x8010846f
80101a97:	e8 ca ea ff ff       	call   80100566 <panic>

  ip = empty;
80101a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa5:	8b 55 08             	mov    0x8(%ebp),%edx
80101aa8:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aad:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ab0:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101ac7:	83 ec 0c             	sub    $0xc,%esp
80101aca:	68 80 e8 10 80       	push   $0x8010e880
80101acf:	e8 65 33 00 00       	call   80104e39 <release>
80101ad4:	83 c4 10             	add    $0x10,%esp

  return ip;
80101ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101ada:	c9                   	leave  
80101adb:	c3                   	ret    

80101adc <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101adc:	55                   	push   %ebp
80101add:	89 e5                	mov    %esp,%ebp
80101adf:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ae2:	83 ec 0c             	sub    $0xc,%esp
80101ae5:	68 80 e8 10 80       	push   $0x8010e880
80101aea:	e8 e3 32 00 00       	call   80104dd2 <acquire>
80101aef:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101af2:	8b 45 08             	mov    0x8(%ebp),%eax
80101af5:	8b 40 08             	mov    0x8(%eax),%eax
80101af8:	8d 50 01             	lea    0x1(%eax),%edx
80101afb:	8b 45 08             	mov    0x8(%ebp),%eax
80101afe:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b01:	83 ec 0c             	sub    $0xc,%esp
80101b04:	68 80 e8 10 80       	push   $0x8010e880
80101b09:	e8 2b 33 00 00       	call   80104e39 <release>
80101b0e:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b14:	c9                   	leave  
80101b15:	c3                   	ret    

80101b16 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b16:	55                   	push   %ebp
80101b17:	89 e5                	mov    %esp,%ebp
80101b19:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b1c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b20:	74 0a                	je     80101b2c <ilock+0x16>
80101b22:	8b 45 08             	mov    0x8(%ebp),%eax
80101b25:	8b 40 08             	mov    0x8(%eax),%eax
80101b28:	85 c0                	test   %eax,%eax
80101b2a:	7f 0d                	jg     80101b39 <ilock+0x23>
    panic("ilock");
80101b2c:	83 ec 0c             	sub    $0xc,%esp
80101b2f:	68 7f 84 10 80       	push   $0x8010847f
80101b34:	e8 2d ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101b39:	83 ec 0c             	sub    $0xc,%esp
80101b3c:	68 80 e8 10 80       	push   $0x8010e880
80101b41:	e8 8c 32 00 00       	call   80104dd2 <acquire>
80101b46:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101b49:	eb 13                	jmp    80101b5e <ilock+0x48>
    sleep(ip, &icache.lock);
80101b4b:	83 ec 08             	sub    $0x8,%esp
80101b4e:	68 80 e8 10 80       	push   $0x8010e880
80101b53:	ff 75 08             	pushl  0x8(%ebp)
80101b56:	e8 7e 2f 00 00       	call   80104ad9 <sleep>
80101b5b:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b61:	8b 40 0c             	mov    0xc(%eax),%eax
80101b64:	83 e0 01             	and    $0x1,%eax
80101b67:	85 c0                	test   %eax,%eax
80101b69:	75 e0                	jne    80101b4b <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	8b 40 0c             	mov    0xc(%eax),%eax
80101b71:	83 c8 01             	or     $0x1,%eax
80101b74:	89 c2                	mov    %eax,%edx
80101b76:	8b 45 08             	mov    0x8(%ebp),%eax
80101b79:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101b7c:	83 ec 0c             	sub    $0xc,%esp
80101b7f:	68 80 e8 10 80       	push   $0x8010e880
80101b84:	e8 b0 32 00 00       	call   80104e39 <release>
80101b89:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8f:	8b 40 0c             	mov    0xc(%eax),%eax
80101b92:	83 e0 02             	and    $0x2,%eax
80101b95:	85 c0                	test   %eax,%eax
80101b97:	0f 85 ce 00 00 00    	jne    80101c6b <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba0:	8b 40 04             	mov    0x4(%eax),%eax
80101ba3:	c1 e8 03             	shr    $0x3,%eax
80101ba6:	8d 50 02             	lea    0x2(%eax),%edx
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	8b 00                	mov    (%eax),%eax
80101bae:	83 ec 08             	sub    $0x8,%esp
80101bb1:	52                   	push   %edx
80101bb2:	50                   	push   %eax
80101bb3:	e8 fe e5 ff ff       	call   801001b6 <bread>
80101bb8:	83 c4 10             	add    $0x10,%esp
80101bbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc1:	8d 50 18             	lea    0x18(%eax),%edx
80101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc7:	8b 40 04             	mov    0x4(%eax),%eax
80101bca:	83 e0 07             	and    $0x7,%eax
80101bcd:	c1 e0 06             	shl    $0x6,%eax
80101bd0:	01 d0                	add    %edx,%eax
80101bd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd8:	0f b7 10             	movzwl (%eax),%edx
80101bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bde:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be5:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101be9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bec:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf3:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfa:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c01:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c05:	8b 45 08             	mov    0x8(%ebp),%eax
80101c08:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c0f:	8b 50 08             	mov    0x8(%eax),%edx
80101c12:	8b 45 08             	mov    0x8(%ebp),%eax
80101c15:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c1b:	8d 50 0c             	lea    0xc(%eax),%edx
80101c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c21:	83 c0 1c             	add    $0x1c,%eax
80101c24:	83 ec 04             	sub    $0x4,%esp
80101c27:	6a 34                	push   $0x34
80101c29:	52                   	push   %edx
80101c2a:	50                   	push   %eax
80101c2b:	e8 c4 34 00 00       	call   801050f4 <memmove>
80101c30:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c33:	83 ec 0c             	sub    $0xc,%esp
80101c36:	ff 75 f4             	pushl  -0xc(%ebp)
80101c39:	e8 f0 e5 ff ff       	call   8010022e <brelse>
80101c3e:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101c41:	8b 45 08             	mov    0x8(%ebp),%eax
80101c44:	8b 40 0c             	mov    0xc(%eax),%eax
80101c47:	83 c8 02             	or     $0x2,%eax
80101c4a:	89 c2                	mov    %eax,%edx
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101c52:	8b 45 08             	mov    0x8(%ebp),%eax
80101c55:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101c59:	66 85 c0             	test   %ax,%ax
80101c5c:	75 0d                	jne    80101c6b <ilock+0x155>
      panic("ilock: no type");
80101c5e:	83 ec 0c             	sub    $0xc,%esp
80101c61:	68 85 84 10 80       	push   $0x80108485
80101c66:	e8 fb e8 ff ff       	call   80100566 <panic>
  }
}
80101c6b:	90                   	nop
80101c6c:	c9                   	leave  
80101c6d:	c3                   	ret    

80101c6e <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c6e:	55                   	push   %ebp
80101c6f:	89 e5                	mov    %esp,%ebp
80101c71:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101c74:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c78:	74 17                	je     80101c91 <iunlock+0x23>
80101c7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7d:	8b 40 0c             	mov    0xc(%eax),%eax
80101c80:	83 e0 01             	and    $0x1,%eax
80101c83:	85 c0                	test   %eax,%eax
80101c85:	74 0a                	je     80101c91 <iunlock+0x23>
80101c87:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8a:	8b 40 08             	mov    0x8(%eax),%eax
80101c8d:	85 c0                	test   %eax,%eax
80101c8f:	7f 0d                	jg     80101c9e <iunlock+0x30>
    panic("iunlock");
80101c91:	83 ec 0c             	sub    $0xc,%esp
80101c94:	68 94 84 10 80       	push   $0x80108494
80101c99:	e8 c8 e8 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101c9e:	83 ec 0c             	sub    $0xc,%esp
80101ca1:	68 80 e8 10 80       	push   $0x8010e880
80101ca6:	e8 27 31 00 00       	call   80104dd2 <acquire>
80101cab:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 40 0c             	mov    0xc(%eax),%eax
80101cb4:	83 e0 fe             	and    $0xfffffffe,%eax
80101cb7:	89 c2                	mov    %eax,%edx
80101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbc:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101cbf:	83 ec 0c             	sub    $0xc,%esp
80101cc2:	ff 75 08             	pushl  0x8(%ebp)
80101cc5:	e8 fa 2e 00 00       	call   80104bc4 <wakeup>
80101cca:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101ccd:	83 ec 0c             	sub    $0xc,%esp
80101cd0:	68 80 e8 10 80       	push   $0x8010e880
80101cd5:	e8 5f 31 00 00       	call   80104e39 <release>
80101cda:	83 c4 10             	add    $0x10,%esp
}
80101cdd:	90                   	nop
80101cde:	c9                   	leave  
80101cdf:	c3                   	ret    

80101ce0 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101ce0:	55                   	push   %ebp
80101ce1:	89 e5                	mov    %esp,%ebp
80101ce3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ce6:	83 ec 0c             	sub    $0xc,%esp
80101ce9:	68 80 e8 10 80       	push   $0x8010e880
80101cee:	e8 df 30 00 00       	call   80104dd2 <acquire>
80101cf3:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	8b 40 08             	mov    0x8(%eax),%eax
80101cfc:	83 f8 01             	cmp    $0x1,%eax
80101cff:	0f 85 a9 00 00 00    	jne    80101dae <iput+0xce>
80101d05:	8b 45 08             	mov    0x8(%ebp),%eax
80101d08:	8b 40 0c             	mov    0xc(%eax),%eax
80101d0b:	83 e0 02             	and    $0x2,%eax
80101d0e:	85 c0                	test   %eax,%eax
80101d10:	0f 84 98 00 00 00    	je     80101dae <iput+0xce>
80101d16:	8b 45 08             	mov    0x8(%ebp),%eax
80101d19:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101d1d:	66 85 c0             	test   %ax,%ax
80101d20:	0f 85 88 00 00 00    	jne    80101dae <iput+0xce>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	8b 40 0c             	mov    0xc(%eax),%eax
80101d2c:	83 e0 01             	and    $0x1,%eax
80101d2f:	85 c0                	test   %eax,%eax
80101d31:	74 0d                	je     80101d40 <iput+0x60>
      panic("iput busy");
80101d33:	83 ec 0c             	sub    $0xc,%esp
80101d36:	68 9c 84 10 80       	push   $0x8010849c
80101d3b:	e8 26 e8 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101d40:	8b 45 08             	mov    0x8(%ebp),%eax
80101d43:	8b 40 0c             	mov    0xc(%eax),%eax
80101d46:	83 c8 01             	or     $0x1,%eax
80101d49:	89 c2                	mov    %eax,%edx
80101d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4e:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 80 e8 10 80       	push   $0x8010e880
80101d59:	e8 db 30 00 00       	call   80104e39 <release>
80101d5e:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101d61:	83 ec 0c             	sub    $0xc,%esp
80101d64:	ff 75 08             	pushl  0x8(%ebp)
80101d67:	e8 a8 01 00 00       	call   80101f14 <itrunc>
80101d6c:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d72:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101d78:	83 ec 0c             	sub    $0xc,%esp
80101d7b:	ff 75 08             	pushl  0x8(%ebp)
80101d7e:	e8 bf fb ff ff       	call   80101942 <iupdate>
80101d83:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101d86:	83 ec 0c             	sub    $0xc,%esp
80101d89:	68 80 e8 10 80       	push   $0x8010e880
80101d8e:	e8 3f 30 00 00       	call   80104dd2 <acquire>
80101d93:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101d96:	8b 45 08             	mov    0x8(%ebp),%eax
80101d99:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101da0:	83 ec 0c             	sub    $0xc,%esp
80101da3:	ff 75 08             	pushl  0x8(%ebp)
80101da6:	e8 19 2e 00 00       	call   80104bc4 <wakeup>
80101dab:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101dae:	8b 45 08             	mov    0x8(%ebp),%eax
80101db1:	8b 40 08             	mov    0x8(%eax),%eax
80101db4:	8d 50 ff             	lea    -0x1(%eax),%edx
80101db7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dba:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101dbd:	83 ec 0c             	sub    $0xc,%esp
80101dc0:	68 80 e8 10 80       	push   $0x8010e880
80101dc5:	e8 6f 30 00 00       	call   80104e39 <release>
80101dca:	83 c4 10             	add    $0x10,%esp
}
80101dcd:	90                   	nop
80101dce:	c9                   	leave  
80101dcf:	c3                   	ret    

80101dd0 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101dd0:	55                   	push   %ebp
80101dd1:	89 e5                	mov    %esp,%ebp
80101dd3:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101dd6:	83 ec 0c             	sub    $0xc,%esp
80101dd9:	ff 75 08             	pushl  0x8(%ebp)
80101ddc:	e8 8d fe ff ff       	call   80101c6e <iunlock>
80101de1:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101de4:	83 ec 0c             	sub    $0xc,%esp
80101de7:	ff 75 08             	pushl  0x8(%ebp)
80101dea:	e8 f1 fe ff ff       	call   80101ce0 <iput>
80101def:	83 c4 10             	add    $0x10,%esp
}
80101df2:	90                   	nop
80101df3:	c9                   	leave  
80101df4:	c3                   	ret    

80101df5 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101df5:	55                   	push   %ebp
80101df6:	89 e5                	mov    %esp,%ebp
80101df8:	53                   	push   %ebx
80101df9:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101dfc:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101e00:	77 42                	ja     80101e44 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101e02:	8b 45 08             	mov    0x8(%ebp),%eax
80101e05:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e08:	83 c2 04             	add    $0x4,%edx
80101e0b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e16:	75 24                	jne    80101e3c <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e18:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1b:	8b 00                	mov    (%eax),%eax
80101e1d:	83 ec 0c             	sub    $0xc,%esp
80101e20:	50                   	push   %eax
80101e21:	e8 e4 f7 ff ff       	call   8010160a <balloc>
80101e26:	83 c4 10             	add    $0x10,%esp
80101e29:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e32:	8d 4a 04             	lea    0x4(%edx),%ecx
80101e35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e38:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e3f:	e9 cb 00 00 00       	jmp    80101f0f <bmap+0x11a>
  }
  bn -= NDIRECT;
80101e44:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e48:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e4c:	0f 87 b0 00 00 00    	ja     80101f02 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e52:	8b 45 08             	mov    0x8(%ebp),%eax
80101e55:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e5b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e5f:	75 1d                	jne    80101e7e <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e61:	8b 45 08             	mov    0x8(%ebp),%eax
80101e64:	8b 00                	mov    (%eax),%eax
80101e66:	83 ec 0c             	sub    $0xc,%esp
80101e69:	50                   	push   %eax
80101e6a:	e8 9b f7 ff ff       	call   8010160a <balloc>
80101e6f:	83 c4 10             	add    $0x10,%esp
80101e72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e7b:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e81:	8b 00                	mov    (%eax),%eax
80101e83:	83 ec 08             	sub    $0x8,%esp
80101e86:	ff 75 f4             	pushl  -0xc(%ebp)
80101e89:	50                   	push   %eax
80101e8a:	e8 27 e3 ff ff       	call   801001b6 <bread>
80101e8f:	83 c4 10             	add    $0x10,%esp
80101e92:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e98:	83 c0 18             	add    $0x18,%eax
80101e9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ea8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eab:	01 d0                	add    %edx,%eax
80101ead:	8b 00                	mov    (%eax),%eax
80101eaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101eb2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101eb6:	75 37                	jne    80101eef <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecb:	8b 00                	mov    (%eax),%eax
80101ecd:	83 ec 0c             	sub    $0xc,%esp
80101ed0:	50                   	push   %eax
80101ed1:	e8 34 f7 ff ff       	call   8010160a <balloc>
80101ed6:	83 c4 10             	add    $0x10,%esp
80101ed9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101edf:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ee1:	83 ec 0c             	sub    $0xc,%esp
80101ee4:	ff 75 f0             	pushl  -0x10(%ebp)
80101ee7:	e8 66 16 00 00       	call   80103552 <log_write>
80101eec:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101eef:	83 ec 0c             	sub    $0xc,%esp
80101ef2:	ff 75 f0             	pushl  -0x10(%ebp)
80101ef5:	e8 34 e3 ff ff       	call   8010022e <brelse>
80101efa:	83 c4 10             	add    $0x10,%esp
    return addr;
80101efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f00:	eb 0d                	jmp    80101f0f <bmap+0x11a>
  }

  panic("bmap: out of range");
80101f02:	83 ec 0c             	sub    $0xc,%esp
80101f05:	68 a6 84 10 80       	push   $0x801084a6
80101f0a:	e8 57 e6 ff ff       	call   80100566 <panic>
}
80101f0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f12:	c9                   	leave  
80101f13:	c3                   	ret    

80101f14 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f14:	55                   	push   %ebp
80101f15:	89 e5                	mov    %esp,%ebp
80101f17:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f21:	eb 45                	jmp    80101f68 <itrunc+0x54>
    if(ip->addrs[i]){
80101f23:	8b 45 08             	mov    0x8(%ebp),%eax
80101f26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f29:	83 c2 04             	add    $0x4,%edx
80101f2c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f30:	85 c0                	test   %eax,%eax
80101f32:	74 30                	je     80101f64 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101f34:	8b 45 08             	mov    0x8(%ebp),%eax
80101f37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f3a:	83 c2 04             	add    $0x4,%edx
80101f3d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f41:	8b 55 08             	mov    0x8(%ebp),%edx
80101f44:	8b 12                	mov    (%edx),%edx
80101f46:	83 ec 08             	sub    $0x8,%esp
80101f49:	50                   	push   %eax
80101f4a:	52                   	push   %edx
80101f4b:	e8 18 f8 ff ff       	call   80101768 <bfree>
80101f50:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101f53:	8b 45 08             	mov    0x8(%ebp),%eax
80101f56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f59:	83 c2 04             	add    $0x4,%edx
80101f5c:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f63:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f68:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f6c:	7e b5                	jle    80101f23 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f71:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f74:	85 c0                	test   %eax,%eax
80101f76:	0f 84 a1 00 00 00    	je     8010201d <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7f:	8b 50 4c             	mov    0x4c(%eax),%edx
80101f82:	8b 45 08             	mov    0x8(%ebp),%eax
80101f85:	8b 00                	mov    (%eax),%eax
80101f87:	83 ec 08             	sub    $0x8,%esp
80101f8a:	52                   	push   %edx
80101f8b:	50                   	push   %eax
80101f8c:	e8 25 e2 ff ff       	call   801001b6 <bread>
80101f91:	83 c4 10             	add    $0x10,%esp
80101f94:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f9a:	83 c0 18             	add    $0x18,%eax
80101f9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101fa0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101fa7:	eb 3c                	jmp    80101fe5 <itrunc+0xd1>
      if(a[j])
80101fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fb3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fb6:	01 d0                	add    %edx,%eax
80101fb8:	8b 00                	mov    (%eax),%eax
80101fba:	85 c0                	test   %eax,%eax
80101fbc:	74 23                	je     80101fe1 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101fbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fcb:	01 d0                	add    %edx,%eax
80101fcd:	8b 00                	mov    (%eax),%eax
80101fcf:	8b 55 08             	mov    0x8(%ebp),%edx
80101fd2:	8b 12                	mov    (%edx),%edx
80101fd4:	83 ec 08             	sub    $0x8,%esp
80101fd7:	50                   	push   %eax
80101fd8:	52                   	push   %edx
80101fd9:	e8 8a f7 ff ff       	call   80101768 <bfree>
80101fde:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101fe1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe8:	83 f8 7f             	cmp    $0x7f,%eax
80101feb:	76 bc                	jbe    80101fa9 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101fed:	83 ec 0c             	sub    $0xc,%esp
80101ff0:	ff 75 ec             	pushl  -0x14(%ebp)
80101ff3:	e8 36 e2 ff ff       	call   8010022e <brelse>
80101ff8:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffe:	8b 40 4c             	mov    0x4c(%eax),%eax
80102001:	8b 55 08             	mov    0x8(%ebp),%edx
80102004:	8b 12                	mov    (%edx),%edx
80102006:	83 ec 08             	sub    $0x8,%esp
80102009:	50                   	push   %eax
8010200a:	52                   	push   %edx
8010200b:	e8 58 f7 ff ff       	call   80101768 <bfree>
80102010:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80102013:	8b 45 08             	mov    0x8(%ebp),%eax
80102016:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
8010201d:	8b 45 08             	mov    0x8(%ebp),%eax
80102020:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80102027:	83 ec 0c             	sub    $0xc,%esp
8010202a:	ff 75 08             	pushl  0x8(%ebp)
8010202d:	e8 10 f9 ff ff       	call   80101942 <iupdate>
80102032:	83 c4 10             	add    $0x10,%esp
}
80102035:	90                   	nop
80102036:	c9                   	leave  
80102037:	c3                   	ret    

80102038 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102038:	55                   	push   %ebp
80102039:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	8b 00                	mov    (%eax),%eax
80102040:	89 c2                	mov    %eax,%edx
80102042:	8b 45 0c             	mov    0xc(%ebp),%eax
80102045:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102048:	8b 45 08             	mov    0x8(%ebp),%eax
8010204b:	8b 50 04             	mov    0x4(%eax),%edx
8010204e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102051:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102054:	8b 45 08             	mov    0x8(%ebp),%eax
80102057:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010205b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010205e:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102068:	8b 45 0c             	mov    0xc(%ebp),%eax
8010206b:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010206f:	8b 45 08             	mov    0x8(%ebp),%eax
80102072:	8b 50 18             	mov    0x18(%eax),%edx
80102075:	8b 45 0c             	mov    0xc(%ebp),%eax
80102078:	89 50 10             	mov    %edx,0x10(%eax)
}
8010207b:	90                   	nop
8010207c:	5d                   	pop    %ebp
8010207d:	c3                   	ret    

8010207e <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010207e:	55                   	push   %ebp
8010207f:	89 e5                	mov    %esp,%ebp
80102081:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102084:	8b 45 08             	mov    0x8(%ebp),%eax
80102087:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010208b:	66 83 f8 03          	cmp    $0x3,%ax
8010208f:	75 5c                	jne    801020ed <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102091:	8b 45 08             	mov    0x8(%ebp),%eax
80102094:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102098:	66 85 c0             	test   %ax,%ax
8010209b:	78 20                	js     801020bd <readi+0x3f>
8010209d:	8b 45 08             	mov    0x8(%ebp),%eax
801020a0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020a4:	66 83 f8 09          	cmp    $0x9,%ax
801020a8:	7f 13                	jg     801020bd <readi+0x3f>
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020b1:	98                   	cwtl   
801020b2:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
801020b9:	85 c0                	test   %eax,%eax
801020bb:	75 0a                	jne    801020c7 <readi+0x49>
      return -1;
801020bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020c2:	e9 0c 01 00 00       	jmp    801021d3 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
801020c7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ca:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020ce:	98                   	cwtl   
801020cf:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
801020d6:	8b 55 14             	mov    0x14(%ebp),%edx
801020d9:	83 ec 04             	sub    $0x4,%esp
801020dc:	52                   	push   %edx
801020dd:	ff 75 0c             	pushl  0xc(%ebp)
801020e0:	ff 75 08             	pushl  0x8(%ebp)
801020e3:	ff d0                	call   *%eax
801020e5:	83 c4 10             	add    $0x10,%esp
801020e8:	e9 e6 00 00 00       	jmp    801021d3 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
801020ed:	8b 45 08             	mov    0x8(%ebp),%eax
801020f0:	8b 40 18             	mov    0x18(%eax),%eax
801020f3:	3b 45 10             	cmp    0x10(%ebp),%eax
801020f6:	72 0d                	jb     80102105 <readi+0x87>
801020f8:	8b 55 10             	mov    0x10(%ebp),%edx
801020fb:	8b 45 14             	mov    0x14(%ebp),%eax
801020fe:	01 d0                	add    %edx,%eax
80102100:	3b 45 10             	cmp    0x10(%ebp),%eax
80102103:	73 0a                	jae    8010210f <readi+0x91>
    return -1;
80102105:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010210a:	e9 c4 00 00 00       	jmp    801021d3 <readi+0x155>
  if(off + n > ip->size)
8010210f:	8b 55 10             	mov    0x10(%ebp),%edx
80102112:	8b 45 14             	mov    0x14(%ebp),%eax
80102115:	01 c2                	add    %eax,%edx
80102117:	8b 45 08             	mov    0x8(%ebp),%eax
8010211a:	8b 40 18             	mov    0x18(%eax),%eax
8010211d:	39 c2                	cmp    %eax,%edx
8010211f:	76 0c                	jbe    8010212d <readi+0xaf>
    n = ip->size - off;
80102121:	8b 45 08             	mov    0x8(%ebp),%eax
80102124:	8b 40 18             	mov    0x18(%eax),%eax
80102127:	2b 45 10             	sub    0x10(%ebp),%eax
8010212a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010212d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102134:	e9 8b 00 00 00       	jmp    801021c4 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102139:	8b 45 10             	mov    0x10(%ebp),%eax
8010213c:	c1 e8 09             	shr    $0x9,%eax
8010213f:	83 ec 08             	sub    $0x8,%esp
80102142:	50                   	push   %eax
80102143:	ff 75 08             	pushl  0x8(%ebp)
80102146:	e8 aa fc ff ff       	call   80101df5 <bmap>
8010214b:	83 c4 10             	add    $0x10,%esp
8010214e:	89 c2                	mov    %eax,%edx
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	8b 00                	mov    (%eax),%eax
80102155:	83 ec 08             	sub    $0x8,%esp
80102158:	52                   	push   %edx
80102159:	50                   	push   %eax
8010215a:	e8 57 e0 ff ff       	call   801001b6 <bread>
8010215f:	83 c4 10             	add    $0x10,%esp
80102162:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102165:	8b 45 10             	mov    0x10(%ebp),%eax
80102168:	25 ff 01 00 00       	and    $0x1ff,%eax
8010216d:	ba 00 02 00 00       	mov    $0x200,%edx
80102172:	29 c2                	sub    %eax,%edx
80102174:	8b 45 14             	mov    0x14(%ebp),%eax
80102177:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010217a:	39 c2                	cmp    %eax,%edx
8010217c:	0f 46 c2             	cmovbe %edx,%eax
8010217f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102182:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102185:	8d 50 18             	lea    0x18(%eax),%edx
80102188:	8b 45 10             	mov    0x10(%ebp),%eax
8010218b:	25 ff 01 00 00       	and    $0x1ff,%eax
80102190:	01 d0                	add    %edx,%eax
80102192:	83 ec 04             	sub    $0x4,%esp
80102195:	ff 75 ec             	pushl  -0x14(%ebp)
80102198:	50                   	push   %eax
80102199:	ff 75 0c             	pushl  0xc(%ebp)
8010219c:	e8 53 2f 00 00       	call   801050f4 <memmove>
801021a1:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021a4:	83 ec 0c             	sub    $0xc,%esp
801021a7:	ff 75 f0             	pushl  -0x10(%ebp)
801021aa:	e8 7f e0 ff ff       	call   8010022e <brelse>
801021af:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021b5:	01 45 f4             	add    %eax,-0xc(%ebp)
801021b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021bb:	01 45 10             	add    %eax,0x10(%ebp)
801021be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021c1:	01 45 0c             	add    %eax,0xc(%ebp)
801021c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021c7:	3b 45 14             	cmp    0x14(%ebp),%eax
801021ca:	0f 82 69 ff ff ff    	jb     80102139 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801021d0:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021d3:	c9                   	leave  
801021d4:	c3                   	ret    

801021d5 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021d5:	55                   	push   %ebp
801021d6:	89 e5                	mov    %esp,%ebp
801021d8:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021db:	8b 45 08             	mov    0x8(%ebp),%eax
801021de:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021e2:	66 83 f8 03          	cmp    $0x3,%ax
801021e6:	75 5c                	jne    80102244 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021e8:	8b 45 08             	mov    0x8(%ebp),%eax
801021eb:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021ef:	66 85 c0             	test   %ax,%ax
801021f2:	78 20                	js     80102214 <writei+0x3f>
801021f4:	8b 45 08             	mov    0x8(%ebp),%eax
801021f7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021fb:	66 83 f8 09          	cmp    $0x9,%ax
801021ff:	7f 13                	jg     80102214 <writei+0x3f>
80102201:	8b 45 08             	mov    0x8(%ebp),%eax
80102204:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102208:	98                   	cwtl   
80102209:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80102210:	85 c0                	test   %eax,%eax
80102212:	75 0a                	jne    8010221e <writei+0x49>
      return -1;
80102214:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102219:	e9 3d 01 00 00       	jmp    8010235b <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010221e:	8b 45 08             	mov    0x8(%ebp),%eax
80102221:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102225:	98                   	cwtl   
80102226:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
8010222d:	8b 55 14             	mov    0x14(%ebp),%edx
80102230:	83 ec 04             	sub    $0x4,%esp
80102233:	52                   	push   %edx
80102234:	ff 75 0c             	pushl  0xc(%ebp)
80102237:	ff 75 08             	pushl  0x8(%ebp)
8010223a:	ff d0                	call   *%eax
8010223c:	83 c4 10             	add    $0x10,%esp
8010223f:	e9 17 01 00 00       	jmp    8010235b <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102244:	8b 45 08             	mov    0x8(%ebp),%eax
80102247:	8b 40 18             	mov    0x18(%eax),%eax
8010224a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010224d:	72 0d                	jb     8010225c <writei+0x87>
8010224f:	8b 55 10             	mov    0x10(%ebp),%edx
80102252:	8b 45 14             	mov    0x14(%ebp),%eax
80102255:	01 d0                	add    %edx,%eax
80102257:	3b 45 10             	cmp    0x10(%ebp),%eax
8010225a:	73 0a                	jae    80102266 <writei+0x91>
    return -1;
8010225c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102261:	e9 f5 00 00 00       	jmp    8010235b <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102266:	8b 55 10             	mov    0x10(%ebp),%edx
80102269:	8b 45 14             	mov    0x14(%ebp),%eax
8010226c:	01 d0                	add    %edx,%eax
8010226e:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102273:	76 0a                	jbe    8010227f <writei+0xaa>
    return -1;
80102275:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010227a:	e9 dc 00 00 00       	jmp    8010235b <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010227f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102286:	e9 99 00 00 00       	jmp    80102324 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010228b:	8b 45 10             	mov    0x10(%ebp),%eax
8010228e:	c1 e8 09             	shr    $0x9,%eax
80102291:	83 ec 08             	sub    $0x8,%esp
80102294:	50                   	push   %eax
80102295:	ff 75 08             	pushl  0x8(%ebp)
80102298:	e8 58 fb ff ff       	call   80101df5 <bmap>
8010229d:	83 c4 10             	add    $0x10,%esp
801022a0:	89 c2                	mov    %eax,%edx
801022a2:	8b 45 08             	mov    0x8(%ebp),%eax
801022a5:	8b 00                	mov    (%eax),%eax
801022a7:	83 ec 08             	sub    $0x8,%esp
801022aa:	52                   	push   %edx
801022ab:	50                   	push   %eax
801022ac:	e8 05 df ff ff       	call   801001b6 <bread>
801022b1:	83 c4 10             	add    $0x10,%esp
801022b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022b7:	8b 45 10             	mov    0x10(%ebp),%eax
801022ba:	25 ff 01 00 00       	and    $0x1ff,%eax
801022bf:	ba 00 02 00 00       	mov    $0x200,%edx
801022c4:	29 c2                	sub    %eax,%edx
801022c6:	8b 45 14             	mov    0x14(%ebp),%eax
801022c9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801022cc:	39 c2                	cmp    %eax,%edx
801022ce:	0f 46 c2             	cmovbe %edx,%eax
801022d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022d7:	8d 50 18             	lea    0x18(%eax),%edx
801022da:	8b 45 10             	mov    0x10(%ebp),%eax
801022dd:	25 ff 01 00 00       	and    $0x1ff,%eax
801022e2:	01 d0                	add    %edx,%eax
801022e4:	83 ec 04             	sub    $0x4,%esp
801022e7:	ff 75 ec             	pushl  -0x14(%ebp)
801022ea:	ff 75 0c             	pushl  0xc(%ebp)
801022ed:	50                   	push   %eax
801022ee:	e8 01 2e 00 00       	call   801050f4 <memmove>
801022f3:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801022f6:	83 ec 0c             	sub    $0xc,%esp
801022f9:	ff 75 f0             	pushl  -0x10(%ebp)
801022fc:	e8 51 12 00 00       	call   80103552 <log_write>
80102301:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102304:	83 ec 0c             	sub    $0xc,%esp
80102307:	ff 75 f0             	pushl  -0x10(%ebp)
8010230a:	e8 1f df ff ff       	call   8010022e <brelse>
8010230f:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102312:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102315:	01 45 f4             	add    %eax,-0xc(%ebp)
80102318:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010231b:	01 45 10             	add    %eax,0x10(%ebp)
8010231e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102321:	01 45 0c             	add    %eax,0xc(%ebp)
80102324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102327:	3b 45 14             	cmp    0x14(%ebp),%eax
8010232a:	0f 82 5b ff ff ff    	jb     8010228b <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102330:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102334:	74 22                	je     80102358 <writei+0x183>
80102336:	8b 45 08             	mov    0x8(%ebp),%eax
80102339:	8b 40 18             	mov    0x18(%eax),%eax
8010233c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010233f:	73 17                	jae    80102358 <writei+0x183>
    ip->size = off;
80102341:	8b 45 08             	mov    0x8(%ebp),%eax
80102344:	8b 55 10             	mov    0x10(%ebp),%edx
80102347:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	ff 75 08             	pushl  0x8(%ebp)
80102350:	e8 ed f5 ff ff       	call   80101942 <iupdate>
80102355:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102358:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010235b:	c9                   	leave  
8010235c:	c3                   	ret    

8010235d <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010235d:	55                   	push   %ebp
8010235e:	89 e5                	mov    %esp,%ebp
80102360:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102363:	83 ec 04             	sub    $0x4,%esp
80102366:	6a 0e                	push   $0xe
80102368:	ff 75 0c             	pushl  0xc(%ebp)
8010236b:	ff 75 08             	pushl  0x8(%ebp)
8010236e:	e8 17 2e 00 00       	call   8010518a <strncmp>
80102373:	83 c4 10             	add    $0x10,%esp
}
80102376:	c9                   	leave  
80102377:	c3                   	ret    

80102378 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102378:	55                   	push   %ebp
80102379:	89 e5                	mov    %esp,%ebp
8010237b:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010237e:	8b 45 08             	mov    0x8(%ebp),%eax
80102381:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102385:	66 83 f8 01          	cmp    $0x1,%ax
80102389:	74 0d                	je     80102398 <dirlookup+0x20>
    panic("dirlookup not DIR");
8010238b:	83 ec 0c             	sub    $0xc,%esp
8010238e:	68 b9 84 10 80       	push   $0x801084b9
80102393:	e8 ce e1 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102398:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010239f:	eb 7b                	jmp    8010241c <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023a1:	6a 10                	push   $0x10
801023a3:	ff 75 f4             	pushl  -0xc(%ebp)
801023a6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023a9:	50                   	push   %eax
801023aa:	ff 75 08             	pushl  0x8(%ebp)
801023ad:	e8 cc fc ff ff       	call   8010207e <readi>
801023b2:	83 c4 10             	add    $0x10,%esp
801023b5:	83 f8 10             	cmp    $0x10,%eax
801023b8:	74 0d                	je     801023c7 <dirlookup+0x4f>
      panic("dirlink read");
801023ba:	83 ec 0c             	sub    $0xc,%esp
801023bd:	68 cb 84 10 80       	push   $0x801084cb
801023c2:	e8 9f e1 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801023c7:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023cb:	66 85 c0             	test   %ax,%ax
801023ce:	74 47                	je     80102417 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801023d0:	83 ec 08             	sub    $0x8,%esp
801023d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023d6:	83 c0 02             	add    $0x2,%eax
801023d9:	50                   	push   %eax
801023da:	ff 75 0c             	pushl  0xc(%ebp)
801023dd:	e8 7b ff ff ff       	call   8010235d <namecmp>
801023e2:	83 c4 10             	add    $0x10,%esp
801023e5:	85 c0                	test   %eax,%eax
801023e7:	75 2f                	jne    80102418 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801023e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023ed:	74 08                	je     801023f7 <dirlookup+0x7f>
        *poff = off;
801023ef:	8b 45 10             	mov    0x10(%ebp),%eax
801023f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023f5:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023f7:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023fb:	0f b7 c0             	movzwl %ax,%eax
801023fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102401:	8b 45 08             	mov    0x8(%ebp),%eax
80102404:	8b 00                	mov    (%eax),%eax
80102406:	83 ec 08             	sub    $0x8,%esp
80102409:	ff 75 f0             	pushl  -0x10(%ebp)
8010240c:	50                   	push   %eax
8010240d:	e8 eb f5 ff ff       	call   801019fd <iget>
80102412:	83 c4 10             	add    $0x10,%esp
80102415:	eb 19                	jmp    80102430 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102417:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102418:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010241c:	8b 45 08             	mov    0x8(%ebp),%eax
8010241f:	8b 40 18             	mov    0x18(%eax),%eax
80102422:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102425:	0f 87 76 ff ff ff    	ja     801023a1 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010242b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102430:	c9                   	leave  
80102431:	c3                   	ret    

80102432 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102432:	55                   	push   %ebp
80102433:	89 e5                	mov    %esp,%ebp
80102435:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102438:	83 ec 04             	sub    $0x4,%esp
8010243b:	6a 00                	push   $0x0
8010243d:	ff 75 0c             	pushl  0xc(%ebp)
80102440:	ff 75 08             	pushl  0x8(%ebp)
80102443:	e8 30 ff ff ff       	call   80102378 <dirlookup>
80102448:	83 c4 10             	add    $0x10,%esp
8010244b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010244e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102452:	74 18                	je     8010246c <dirlink+0x3a>
    iput(ip);
80102454:	83 ec 0c             	sub    $0xc,%esp
80102457:	ff 75 f0             	pushl  -0x10(%ebp)
8010245a:	e8 81 f8 ff ff       	call   80101ce0 <iput>
8010245f:	83 c4 10             	add    $0x10,%esp
    return -1;
80102462:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102467:	e9 9c 00 00 00       	jmp    80102508 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010246c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102473:	eb 39                	jmp    801024ae <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102478:	6a 10                	push   $0x10
8010247a:	50                   	push   %eax
8010247b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010247e:	50                   	push   %eax
8010247f:	ff 75 08             	pushl  0x8(%ebp)
80102482:	e8 f7 fb ff ff       	call   8010207e <readi>
80102487:	83 c4 10             	add    $0x10,%esp
8010248a:	83 f8 10             	cmp    $0x10,%eax
8010248d:	74 0d                	je     8010249c <dirlink+0x6a>
      panic("dirlink read");
8010248f:	83 ec 0c             	sub    $0xc,%esp
80102492:	68 cb 84 10 80       	push   $0x801084cb
80102497:	e8 ca e0 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
8010249c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024a0:	66 85 c0             	test   %ax,%ax
801024a3:	74 18                	je     801024bd <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a8:	83 c0 10             	add    $0x10,%eax
801024ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024ae:	8b 45 08             	mov    0x8(%ebp),%eax
801024b1:	8b 50 18             	mov    0x18(%eax),%edx
801024b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b7:	39 c2                	cmp    %eax,%edx
801024b9:	77 ba                	ja     80102475 <dirlink+0x43>
801024bb:	eb 01                	jmp    801024be <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801024bd:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801024be:	83 ec 04             	sub    $0x4,%esp
801024c1:	6a 0e                	push   $0xe
801024c3:	ff 75 0c             	pushl  0xc(%ebp)
801024c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024c9:	83 c0 02             	add    $0x2,%eax
801024cc:	50                   	push   %eax
801024cd:	e8 0e 2d 00 00       	call   801051e0 <strncpy>
801024d2:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801024d5:	8b 45 10             	mov    0x10(%ebp),%eax
801024d8:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024df:	6a 10                	push   $0x10
801024e1:	50                   	push   %eax
801024e2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024e5:	50                   	push   %eax
801024e6:	ff 75 08             	pushl  0x8(%ebp)
801024e9:	e8 e7 fc ff ff       	call   801021d5 <writei>
801024ee:	83 c4 10             	add    $0x10,%esp
801024f1:	83 f8 10             	cmp    $0x10,%eax
801024f4:	74 0d                	je     80102503 <dirlink+0xd1>
    panic("dirlink");
801024f6:	83 ec 0c             	sub    $0xc,%esp
801024f9:	68 d8 84 10 80       	push   $0x801084d8
801024fe:	e8 63 e0 ff ff       	call   80100566 <panic>
  
  return 0;
80102503:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102508:	c9                   	leave  
80102509:	c3                   	ret    

8010250a <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010250a:	55                   	push   %ebp
8010250b:	89 e5                	mov    %esp,%ebp
8010250d:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102510:	eb 04                	jmp    80102516 <skipelem+0xc>
    path++;
80102512:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102516:	8b 45 08             	mov    0x8(%ebp),%eax
80102519:	0f b6 00             	movzbl (%eax),%eax
8010251c:	3c 2f                	cmp    $0x2f,%al
8010251e:	74 f2                	je     80102512 <skipelem+0x8>
    path++;
  if(*path == 0)
80102520:	8b 45 08             	mov    0x8(%ebp),%eax
80102523:	0f b6 00             	movzbl (%eax),%eax
80102526:	84 c0                	test   %al,%al
80102528:	75 07                	jne    80102531 <skipelem+0x27>
    return 0;
8010252a:	b8 00 00 00 00       	mov    $0x0,%eax
8010252f:	eb 7b                	jmp    801025ac <skipelem+0xa2>
  s = path;
80102531:	8b 45 08             	mov    0x8(%ebp),%eax
80102534:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102537:	eb 04                	jmp    8010253d <skipelem+0x33>
    path++;
80102539:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010253d:	8b 45 08             	mov    0x8(%ebp),%eax
80102540:	0f b6 00             	movzbl (%eax),%eax
80102543:	3c 2f                	cmp    $0x2f,%al
80102545:	74 0a                	je     80102551 <skipelem+0x47>
80102547:	8b 45 08             	mov    0x8(%ebp),%eax
8010254a:	0f b6 00             	movzbl (%eax),%eax
8010254d:	84 c0                	test   %al,%al
8010254f:	75 e8                	jne    80102539 <skipelem+0x2f>
    path++;
  len = path - s;
80102551:	8b 55 08             	mov    0x8(%ebp),%edx
80102554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102557:	29 c2                	sub    %eax,%edx
80102559:	89 d0                	mov    %edx,%eax
8010255b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010255e:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102562:	7e 15                	jle    80102579 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102564:	83 ec 04             	sub    $0x4,%esp
80102567:	6a 0e                	push   $0xe
80102569:	ff 75 f4             	pushl  -0xc(%ebp)
8010256c:	ff 75 0c             	pushl  0xc(%ebp)
8010256f:	e8 80 2b 00 00       	call   801050f4 <memmove>
80102574:	83 c4 10             	add    $0x10,%esp
80102577:	eb 26                	jmp    8010259f <skipelem+0x95>
  else {
    memmove(name, s, len);
80102579:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010257c:	83 ec 04             	sub    $0x4,%esp
8010257f:	50                   	push   %eax
80102580:	ff 75 f4             	pushl  -0xc(%ebp)
80102583:	ff 75 0c             	pushl  0xc(%ebp)
80102586:	e8 69 2b 00 00       	call   801050f4 <memmove>
8010258b:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010258e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102591:	8b 45 0c             	mov    0xc(%ebp),%eax
80102594:	01 d0                	add    %edx,%eax
80102596:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102599:	eb 04                	jmp    8010259f <skipelem+0x95>
    path++;
8010259b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010259f:	8b 45 08             	mov    0x8(%ebp),%eax
801025a2:	0f b6 00             	movzbl (%eax),%eax
801025a5:	3c 2f                	cmp    $0x2f,%al
801025a7:	74 f2                	je     8010259b <skipelem+0x91>
    path++;
  return path;
801025a9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025ac:	c9                   	leave  
801025ad:	c3                   	ret    

801025ae <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025ae:	55                   	push   %ebp
801025af:	89 e5                	mov    %esp,%ebp
801025b1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025b4:	8b 45 08             	mov    0x8(%ebp),%eax
801025b7:	0f b6 00             	movzbl (%eax),%eax
801025ba:	3c 2f                	cmp    $0x2f,%al
801025bc:	75 17                	jne    801025d5 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801025be:	83 ec 08             	sub    $0x8,%esp
801025c1:	6a 01                	push   $0x1
801025c3:	6a 01                	push   $0x1
801025c5:	e8 33 f4 ff ff       	call   801019fd <iget>
801025ca:	83 c4 10             	add    $0x10,%esp
801025cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801025d0:	e9 bb 00 00 00       	jmp    80102690 <namex+0xe2>
  else
    ip = idup(proc->cwd);
801025d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801025db:	8b 40 68             	mov    0x68(%eax),%eax
801025de:	83 ec 0c             	sub    $0xc,%esp
801025e1:	50                   	push   %eax
801025e2:	e8 f5 f4 ff ff       	call   80101adc <idup>
801025e7:	83 c4 10             	add    $0x10,%esp
801025ea:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801025ed:	e9 9e 00 00 00       	jmp    80102690 <namex+0xe2>
    ilock(ip);
801025f2:	83 ec 0c             	sub    $0xc,%esp
801025f5:	ff 75 f4             	pushl  -0xc(%ebp)
801025f8:	e8 19 f5 ff ff       	call   80101b16 <ilock>
801025fd:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102603:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102607:	66 83 f8 01          	cmp    $0x1,%ax
8010260b:	74 18                	je     80102625 <namex+0x77>
      iunlockput(ip);
8010260d:	83 ec 0c             	sub    $0xc,%esp
80102610:	ff 75 f4             	pushl  -0xc(%ebp)
80102613:	e8 b8 f7 ff ff       	call   80101dd0 <iunlockput>
80102618:	83 c4 10             	add    $0x10,%esp
      return 0;
8010261b:	b8 00 00 00 00       	mov    $0x0,%eax
80102620:	e9 a7 00 00 00       	jmp    801026cc <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102625:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102629:	74 20                	je     8010264b <namex+0x9d>
8010262b:	8b 45 08             	mov    0x8(%ebp),%eax
8010262e:	0f b6 00             	movzbl (%eax),%eax
80102631:	84 c0                	test   %al,%al
80102633:	75 16                	jne    8010264b <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102635:	83 ec 0c             	sub    $0xc,%esp
80102638:	ff 75 f4             	pushl  -0xc(%ebp)
8010263b:	e8 2e f6 ff ff       	call   80101c6e <iunlock>
80102640:	83 c4 10             	add    $0x10,%esp
      return ip;
80102643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102646:	e9 81 00 00 00       	jmp    801026cc <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010264b:	83 ec 04             	sub    $0x4,%esp
8010264e:	6a 00                	push   $0x0
80102650:	ff 75 10             	pushl  0x10(%ebp)
80102653:	ff 75 f4             	pushl  -0xc(%ebp)
80102656:	e8 1d fd ff ff       	call   80102378 <dirlookup>
8010265b:	83 c4 10             	add    $0x10,%esp
8010265e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102661:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102665:	75 15                	jne    8010267c <namex+0xce>
      iunlockput(ip);
80102667:	83 ec 0c             	sub    $0xc,%esp
8010266a:	ff 75 f4             	pushl  -0xc(%ebp)
8010266d:	e8 5e f7 ff ff       	call   80101dd0 <iunlockput>
80102672:	83 c4 10             	add    $0x10,%esp
      return 0;
80102675:	b8 00 00 00 00       	mov    $0x0,%eax
8010267a:	eb 50                	jmp    801026cc <namex+0x11e>
    }
    iunlockput(ip);
8010267c:	83 ec 0c             	sub    $0xc,%esp
8010267f:	ff 75 f4             	pushl  -0xc(%ebp)
80102682:	e8 49 f7 ff ff       	call   80101dd0 <iunlockput>
80102687:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010268a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010268d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102690:	83 ec 08             	sub    $0x8,%esp
80102693:	ff 75 10             	pushl  0x10(%ebp)
80102696:	ff 75 08             	pushl  0x8(%ebp)
80102699:	e8 6c fe ff ff       	call   8010250a <skipelem>
8010269e:	83 c4 10             	add    $0x10,%esp
801026a1:	89 45 08             	mov    %eax,0x8(%ebp)
801026a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026a8:	0f 85 44 ff ff ff    	jne    801025f2 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801026ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026b2:	74 15                	je     801026c9 <namex+0x11b>
    iput(ip);
801026b4:	83 ec 0c             	sub    $0xc,%esp
801026b7:	ff 75 f4             	pushl  -0xc(%ebp)
801026ba:	e8 21 f6 ff ff       	call   80101ce0 <iput>
801026bf:	83 c4 10             	add    $0x10,%esp
    return 0;
801026c2:	b8 00 00 00 00       	mov    $0x0,%eax
801026c7:	eb 03                	jmp    801026cc <namex+0x11e>
  }
  return ip;
801026c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026cc:	c9                   	leave  
801026cd:	c3                   	ret    

801026ce <namei>:

struct inode*
namei(char *path)
{
801026ce:	55                   	push   %ebp
801026cf:	89 e5                	mov    %esp,%ebp
801026d1:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026d4:	83 ec 04             	sub    $0x4,%esp
801026d7:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026da:	50                   	push   %eax
801026db:	6a 00                	push   $0x0
801026dd:	ff 75 08             	pushl  0x8(%ebp)
801026e0:	e8 c9 fe ff ff       	call   801025ae <namex>
801026e5:	83 c4 10             	add    $0x10,%esp
}
801026e8:	c9                   	leave  
801026e9:	c3                   	ret    

801026ea <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801026ea:	55                   	push   %ebp
801026eb:	89 e5                	mov    %esp,%ebp
801026ed:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801026f0:	83 ec 04             	sub    $0x4,%esp
801026f3:	ff 75 0c             	pushl  0xc(%ebp)
801026f6:	6a 01                	push   $0x1
801026f8:	ff 75 08             	pushl  0x8(%ebp)
801026fb:	e8 ae fe ff ff       	call   801025ae <namex>
80102700:	83 c4 10             	add    $0x10,%esp
}
80102703:	c9                   	leave  
80102704:	c3                   	ret    

80102705 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102705:	55                   	push   %ebp
80102706:	89 e5                	mov    %esp,%ebp
80102708:	83 ec 14             	sub    $0x14,%esp
8010270b:	8b 45 08             	mov    0x8(%ebp),%eax
8010270e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102712:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102716:	89 c2                	mov    %eax,%edx
80102718:	ec                   	in     (%dx),%al
80102719:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010271c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102720:	c9                   	leave  
80102721:	c3                   	ret    

80102722 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102722:	55                   	push   %ebp
80102723:	89 e5                	mov    %esp,%ebp
80102725:	57                   	push   %edi
80102726:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102727:	8b 55 08             	mov    0x8(%ebp),%edx
8010272a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010272d:	8b 45 10             	mov    0x10(%ebp),%eax
80102730:	89 cb                	mov    %ecx,%ebx
80102732:	89 df                	mov    %ebx,%edi
80102734:	89 c1                	mov    %eax,%ecx
80102736:	fc                   	cld    
80102737:	f3 6d                	rep insl (%dx),%es:(%edi)
80102739:	89 c8                	mov    %ecx,%eax
8010273b:	89 fb                	mov    %edi,%ebx
8010273d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102740:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102743:	90                   	nop
80102744:	5b                   	pop    %ebx
80102745:	5f                   	pop    %edi
80102746:	5d                   	pop    %ebp
80102747:	c3                   	ret    

80102748 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102748:	55                   	push   %ebp
80102749:	89 e5                	mov    %esp,%ebp
8010274b:	83 ec 08             	sub    $0x8,%esp
8010274e:	8b 55 08             	mov    0x8(%ebp),%edx
80102751:	8b 45 0c             	mov    0xc(%ebp),%eax
80102754:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102758:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010275b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010275f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102763:	ee                   	out    %al,(%dx)
}
80102764:	90                   	nop
80102765:	c9                   	leave  
80102766:	c3                   	ret    

80102767 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102767:	55                   	push   %ebp
80102768:	89 e5                	mov    %esp,%ebp
8010276a:	56                   	push   %esi
8010276b:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010276c:	8b 55 08             	mov    0x8(%ebp),%edx
8010276f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102772:	8b 45 10             	mov    0x10(%ebp),%eax
80102775:	89 cb                	mov    %ecx,%ebx
80102777:	89 de                	mov    %ebx,%esi
80102779:	89 c1                	mov    %eax,%ecx
8010277b:	fc                   	cld    
8010277c:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010277e:	89 c8                	mov    %ecx,%eax
80102780:	89 f3                	mov    %esi,%ebx
80102782:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102785:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102788:	90                   	nop
80102789:	5b                   	pop    %ebx
8010278a:	5e                   	pop    %esi
8010278b:	5d                   	pop    %ebp
8010278c:	c3                   	ret    

8010278d <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010278d:	55                   	push   %ebp
8010278e:	89 e5                	mov    %esp,%ebp
80102790:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102793:	90                   	nop
80102794:	68 f7 01 00 00       	push   $0x1f7
80102799:	e8 67 ff ff ff       	call   80102705 <inb>
8010279e:	83 c4 04             	add    $0x4,%esp
801027a1:	0f b6 c0             	movzbl %al,%eax
801027a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
801027a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027aa:	25 c0 00 00 00       	and    $0xc0,%eax
801027af:	83 f8 40             	cmp    $0x40,%eax
801027b2:	75 e0                	jne    80102794 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801027b4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027b8:	74 11                	je     801027cb <idewait+0x3e>
801027ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027bd:	83 e0 21             	and    $0x21,%eax
801027c0:	85 c0                	test   %eax,%eax
801027c2:	74 07                	je     801027cb <idewait+0x3e>
    return -1;
801027c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027c9:	eb 05                	jmp    801027d0 <idewait+0x43>
  return 0;
801027cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801027d0:	c9                   	leave  
801027d1:	c3                   	ret    

801027d2 <ideinit>:

void
ideinit(void)
{
801027d2:	55                   	push   %ebp
801027d3:	89 e5                	mov    %esp,%ebp
801027d5:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801027d8:	83 ec 08             	sub    $0x8,%esp
801027db:	68 e0 84 10 80       	push   $0x801084e0
801027e0:	68 20 b6 10 80       	push   $0x8010b620
801027e5:	e8 c6 25 00 00       	call   80104db0 <initlock>
801027ea:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801027ed:	83 ec 0c             	sub    $0xc,%esp
801027f0:	6a 0e                	push   $0xe
801027f2:	e8 46 15 00 00       	call   80103d3d <picenable>
801027f7:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801027fa:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801027ff:	83 e8 01             	sub    $0x1,%eax
80102802:	83 ec 08             	sub    $0x8,%esp
80102805:	50                   	push   %eax
80102806:	6a 0e                	push   $0xe
80102808:	e8 37 04 00 00       	call   80102c44 <ioapicenable>
8010280d:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102810:	83 ec 0c             	sub    $0xc,%esp
80102813:	6a 00                	push   $0x0
80102815:	e8 73 ff ff ff       	call   8010278d <idewait>
8010281a:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010281d:	83 ec 08             	sub    $0x8,%esp
80102820:	68 f0 00 00 00       	push   $0xf0
80102825:	68 f6 01 00 00       	push   $0x1f6
8010282a:	e8 19 ff ff ff       	call   80102748 <outb>
8010282f:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102832:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102839:	eb 24                	jmp    8010285f <ideinit+0x8d>
    if(inb(0x1f7) != 0){
8010283b:	83 ec 0c             	sub    $0xc,%esp
8010283e:	68 f7 01 00 00       	push   $0x1f7
80102843:	e8 bd fe ff ff       	call   80102705 <inb>
80102848:	83 c4 10             	add    $0x10,%esp
8010284b:	84 c0                	test   %al,%al
8010284d:	74 0c                	je     8010285b <ideinit+0x89>
      havedisk1 = 1;
8010284f:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
80102856:	00 00 00 
      break;
80102859:	eb 0d                	jmp    80102868 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010285b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010285f:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102866:	7e d3                	jle    8010283b <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102868:	83 ec 08             	sub    $0x8,%esp
8010286b:	68 e0 00 00 00       	push   $0xe0
80102870:	68 f6 01 00 00       	push   $0x1f6
80102875:	e8 ce fe ff ff       	call   80102748 <outb>
8010287a:	83 c4 10             	add    $0x10,%esp
}
8010287d:	90                   	nop
8010287e:	c9                   	leave  
8010287f:	c3                   	ret    

80102880 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102880:	55                   	push   %ebp
80102881:	89 e5                	mov    %esp,%ebp
80102883:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
80102886:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010288a:	75 0d                	jne    80102899 <idestart+0x19>
    panic("idestart");
8010288c:	83 ec 0c             	sub    $0xc,%esp
8010288f:	68 e4 84 10 80       	push   $0x801084e4
80102894:	e8 cd dc ff ff       	call   80100566 <panic>

  idewait(0);
80102899:	83 ec 0c             	sub    $0xc,%esp
8010289c:	6a 00                	push   $0x0
8010289e:	e8 ea fe ff ff       	call   8010278d <idewait>
801028a3:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801028a6:	83 ec 08             	sub    $0x8,%esp
801028a9:	6a 00                	push   $0x0
801028ab:	68 f6 03 00 00       	push   $0x3f6
801028b0:	e8 93 fe ff ff       	call   80102748 <outb>
801028b5:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
801028b8:	83 ec 08             	sub    $0x8,%esp
801028bb:	6a 01                	push   $0x1
801028bd:	68 f2 01 00 00       	push   $0x1f2
801028c2:	e8 81 fe ff ff       	call   80102748 <outb>
801028c7:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
801028ca:	8b 45 08             	mov    0x8(%ebp),%eax
801028cd:	8b 40 08             	mov    0x8(%eax),%eax
801028d0:	0f b6 c0             	movzbl %al,%eax
801028d3:	83 ec 08             	sub    $0x8,%esp
801028d6:	50                   	push   %eax
801028d7:	68 f3 01 00 00       	push   $0x1f3
801028dc:	e8 67 fe ff ff       	call   80102748 <outb>
801028e1:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
801028e4:	8b 45 08             	mov    0x8(%ebp),%eax
801028e7:	8b 40 08             	mov    0x8(%eax),%eax
801028ea:	c1 e8 08             	shr    $0x8,%eax
801028ed:	0f b6 c0             	movzbl %al,%eax
801028f0:	83 ec 08             	sub    $0x8,%esp
801028f3:	50                   	push   %eax
801028f4:	68 f4 01 00 00       	push   $0x1f4
801028f9:	e8 4a fe ff ff       	call   80102748 <outb>
801028fe:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102901:	8b 45 08             	mov    0x8(%ebp),%eax
80102904:	8b 40 08             	mov    0x8(%eax),%eax
80102907:	c1 e8 10             	shr    $0x10,%eax
8010290a:	0f b6 c0             	movzbl %al,%eax
8010290d:	83 ec 08             	sub    $0x8,%esp
80102910:	50                   	push   %eax
80102911:	68 f5 01 00 00       	push   $0x1f5
80102916:	e8 2d fe ff ff       	call   80102748 <outb>
8010291b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
8010291e:	8b 45 08             	mov    0x8(%ebp),%eax
80102921:	8b 40 04             	mov    0x4(%eax),%eax
80102924:	83 e0 01             	and    $0x1,%eax
80102927:	c1 e0 04             	shl    $0x4,%eax
8010292a:	89 c2                	mov    %eax,%edx
8010292c:	8b 45 08             	mov    0x8(%ebp),%eax
8010292f:	8b 40 08             	mov    0x8(%eax),%eax
80102932:	c1 e8 18             	shr    $0x18,%eax
80102935:	83 e0 0f             	and    $0xf,%eax
80102938:	09 d0                	or     %edx,%eax
8010293a:	83 c8 e0             	or     $0xffffffe0,%eax
8010293d:	0f b6 c0             	movzbl %al,%eax
80102940:	83 ec 08             	sub    $0x8,%esp
80102943:	50                   	push   %eax
80102944:	68 f6 01 00 00       	push   $0x1f6
80102949:	e8 fa fd ff ff       	call   80102748 <outb>
8010294e:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102951:	8b 45 08             	mov    0x8(%ebp),%eax
80102954:	8b 00                	mov    (%eax),%eax
80102956:	83 e0 04             	and    $0x4,%eax
80102959:	85 c0                	test   %eax,%eax
8010295b:	74 30                	je     8010298d <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
8010295d:	83 ec 08             	sub    $0x8,%esp
80102960:	6a 30                	push   $0x30
80102962:	68 f7 01 00 00       	push   $0x1f7
80102967:	e8 dc fd ff ff       	call   80102748 <outb>
8010296c:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
8010296f:	8b 45 08             	mov    0x8(%ebp),%eax
80102972:	83 c0 18             	add    $0x18,%eax
80102975:	83 ec 04             	sub    $0x4,%esp
80102978:	68 80 00 00 00       	push   $0x80
8010297d:	50                   	push   %eax
8010297e:	68 f0 01 00 00       	push   $0x1f0
80102983:	e8 df fd ff ff       	call   80102767 <outsl>
80102988:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
8010298b:	eb 12                	jmp    8010299f <idestart+0x11f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010298d:	83 ec 08             	sub    $0x8,%esp
80102990:	6a 20                	push   $0x20
80102992:	68 f7 01 00 00       	push   $0x1f7
80102997:	e8 ac fd ff ff       	call   80102748 <outb>
8010299c:	83 c4 10             	add    $0x10,%esp
  }
}
8010299f:	90                   	nop
801029a0:	c9                   	leave  
801029a1:	c3                   	ret    

801029a2 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029a2:	55                   	push   %ebp
801029a3:	89 e5                	mov    %esp,%ebp
801029a5:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029a8:	83 ec 0c             	sub    $0xc,%esp
801029ab:	68 20 b6 10 80       	push   $0x8010b620
801029b0:	e8 1d 24 00 00       	call   80104dd2 <acquire>
801029b5:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801029b8:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801029bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801029c4:	75 15                	jne    801029db <ideintr+0x39>
    release(&idelock);
801029c6:	83 ec 0c             	sub    $0xc,%esp
801029c9:	68 20 b6 10 80       	push   $0x8010b620
801029ce:	e8 66 24 00 00       	call   80104e39 <release>
801029d3:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
801029d6:	e9 9a 00 00 00       	jmp    80102a75 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801029db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029de:	8b 40 14             	mov    0x14(%eax),%eax
801029e1:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801029e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e9:	8b 00                	mov    (%eax),%eax
801029eb:	83 e0 04             	and    $0x4,%eax
801029ee:	85 c0                	test   %eax,%eax
801029f0:	75 2d                	jne    80102a1f <ideintr+0x7d>
801029f2:	83 ec 0c             	sub    $0xc,%esp
801029f5:	6a 01                	push   $0x1
801029f7:	e8 91 fd ff ff       	call   8010278d <idewait>
801029fc:	83 c4 10             	add    $0x10,%esp
801029ff:	85 c0                	test   %eax,%eax
80102a01:	78 1c                	js     80102a1f <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
80102a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a06:	83 c0 18             	add    $0x18,%eax
80102a09:	83 ec 04             	sub    $0x4,%esp
80102a0c:	68 80 00 00 00       	push   $0x80
80102a11:	50                   	push   %eax
80102a12:	68 f0 01 00 00       	push   $0x1f0
80102a17:	e8 06 fd ff ff       	call   80102722 <insl>
80102a1c:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a22:	8b 00                	mov    (%eax),%eax
80102a24:	83 c8 02             	or     $0x2,%eax
80102a27:	89 c2                	mov    %eax,%edx
80102a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2c:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a31:	8b 00                	mov    (%eax),%eax
80102a33:	83 e0 fb             	and    $0xfffffffb,%eax
80102a36:	89 c2                	mov    %eax,%edx
80102a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3b:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a3d:	83 ec 0c             	sub    $0xc,%esp
80102a40:	ff 75 f4             	pushl  -0xc(%ebp)
80102a43:	e8 7c 21 00 00       	call   80104bc4 <wakeup>
80102a48:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a4b:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102a50:	85 c0                	test   %eax,%eax
80102a52:	74 11                	je     80102a65 <ideintr+0xc3>
    idestart(idequeue);
80102a54:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102a59:	83 ec 0c             	sub    $0xc,%esp
80102a5c:	50                   	push   %eax
80102a5d:	e8 1e fe ff ff       	call   80102880 <idestart>
80102a62:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102a65:	83 ec 0c             	sub    $0xc,%esp
80102a68:	68 20 b6 10 80       	push   $0x8010b620
80102a6d:	e8 c7 23 00 00       	call   80104e39 <release>
80102a72:	83 c4 10             	add    $0x10,%esp
}
80102a75:	c9                   	leave  
80102a76:	c3                   	ret    

80102a77 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a77:	55                   	push   %ebp
80102a78:	89 e5                	mov    %esp,%ebp
80102a7a:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a80:	8b 00                	mov    (%eax),%eax
80102a82:	83 e0 01             	and    $0x1,%eax
80102a85:	85 c0                	test   %eax,%eax
80102a87:	75 0d                	jne    80102a96 <iderw+0x1f>
    panic("iderw: buf not busy");
80102a89:	83 ec 0c             	sub    $0xc,%esp
80102a8c:	68 ed 84 10 80       	push   $0x801084ed
80102a91:	e8 d0 da ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a96:	8b 45 08             	mov    0x8(%ebp),%eax
80102a99:	8b 00                	mov    (%eax),%eax
80102a9b:	83 e0 06             	and    $0x6,%eax
80102a9e:	83 f8 02             	cmp    $0x2,%eax
80102aa1:	75 0d                	jne    80102ab0 <iderw+0x39>
    panic("iderw: nothing to do");
80102aa3:	83 ec 0c             	sub    $0xc,%esp
80102aa6:	68 01 85 10 80       	push   $0x80108501
80102aab:	e8 b6 da ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab3:	8b 40 04             	mov    0x4(%eax),%eax
80102ab6:	85 c0                	test   %eax,%eax
80102ab8:	74 16                	je     80102ad0 <iderw+0x59>
80102aba:	a1 58 b6 10 80       	mov    0x8010b658,%eax
80102abf:	85 c0                	test   %eax,%eax
80102ac1:	75 0d                	jne    80102ad0 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102ac3:	83 ec 0c             	sub    $0xc,%esp
80102ac6:	68 16 85 10 80       	push   $0x80108516
80102acb:	e8 96 da ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102ad0:	83 ec 0c             	sub    $0xc,%esp
80102ad3:	68 20 b6 10 80       	push   $0x8010b620
80102ad8:	e8 f5 22 00 00       	call   80104dd2 <acquire>
80102add:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102aea:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
80102af1:	eb 0b                	jmp    80102afe <iderw+0x87>
80102af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af6:	8b 00                	mov    (%eax),%eax
80102af8:	83 c0 14             	add    $0x14,%eax
80102afb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b01:	8b 00                	mov    (%eax),%eax
80102b03:	85 c0                	test   %eax,%eax
80102b05:	75 ec                	jne    80102af3 <iderw+0x7c>
    ;
  *pp = b;
80102b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0a:	8b 55 08             	mov    0x8(%ebp),%edx
80102b0d:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102b0f:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102b14:	3b 45 08             	cmp    0x8(%ebp),%eax
80102b17:	75 23                	jne    80102b3c <iderw+0xc5>
    idestart(b);
80102b19:	83 ec 0c             	sub    $0xc,%esp
80102b1c:	ff 75 08             	pushl  0x8(%ebp)
80102b1f:	e8 5c fd ff ff       	call   80102880 <idestart>
80102b24:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b27:	eb 13                	jmp    80102b3c <iderw+0xc5>
    sleep(b, &idelock);
80102b29:	83 ec 08             	sub    $0x8,%esp
80102b2c:	68 20 b6 10 80       	push   $0x8010b620
80102b31:	ff 75 08             	pushl  0x8(%ebp)
80102b34:	e8 a0 1f 00 00       	call   80104ad9 <sleep>
80102b39:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3f:	8b 00                	mov    (%eax),%eax
80102b41:	83 e0 06             	and    $0x6,%eax
80102b44:	83 f8 02             	cmp    $0x2,%eax
80102b47:	75 e0                	jne    80102b29 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102b49:	83 ec 0c             	sub    $0xc,%esp
80102b4c:	68 20 b6 10 80       	push   $0x8010b620
80102b51:	e8 e3 22 00 00       	call   80104e39 <release>
80102b56:	83 c4 10             	add    $0x10,%esp
}
80102b59:	90                   	nop
80102b5a:	c9                   	leave  
80102b5b:	c3                   	ret    

80102b5c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b5c:	55                   	push   %ebp
80102b5d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b5f:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b64:	8b 55 08             	mov    0x8(%ebp),%edx
80102b67:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b69:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b6e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b71:	5d                   	pop    %ebp
80102b72:	c3                   	ret    

80102b73 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b73:	55                   	push   %ebp
80102b74:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b76:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b7b:	8b 55 08             	mov    0x8(%ebp),%edx
80102b7e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b80:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b85:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b88:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b8b:	90                   	nop
80102b8c:	5d                   	pop    %ebp
80102b8d:	c3                   	ret    

80102b8e <ioapicinit>:

void
ioapicinit(void)
{
80102b8e:	55                   	push   %ebp
80102b8f:	89 e5                	mov    %esp,%ebp
80102b91:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102b94:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102b99:	85 c0                	test   %eax,%eax
80102b9b:	0f 84 a0 00 00 00    	je     80102c41 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ba1:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102ba8:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102bab:	6a 01                	push   $0x1
80102bad:	e8 aa ff ff ff       	call   80102b5c <ioapicread>
80102bb2:	83 c4 04             	add    $0x4,%esp
80102bb5:	c1 e8 10             	shr    $0x10,%eax
80102bb8:	25 ff 00 00 00       	and    $0xff,%eax
80102bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102bc0:	6a 00                	push   $0x0
80102bc2:	e8 95 ff ff ff       	call   80102b5c <ioapicread>
80102bc7:	83 c4 04             	add    $0x4,%esp
80102bca:	c1 e8 18             	shr    $0x18,%eax
80102bcd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102bd0:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102bd7:	0f b6 c0             	movzbl %al,%eax
80102bda:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102bdd:	74 10                	je     80102bef <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102bdf:	83 ec 0c             	sub    $0xc,%esp
80102be2:	68 34 85 10 80       	push   $0x80108534
80102be7:	e8 da d7 ff ff       	call   801003c6 <cprintf>
80102bec:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102bef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102bf6:	eb 3f                	jmp    80102c37 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bfb:	83 c0 20             	add    $0x20,%eax
80102bfe:	0d 00 00 01 00       	or     $0x10000,%eax
80102c03:	89 c2                	mov    %eax,%edx
80102c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c08:	83 c0 08             	add    $0x8,%eax
80102c0b:	01 c0                	add    %eax,%eax
80102c0d:	83 ec 08             	sub    $0x8,%esp
80102c10:	52                   	push   %edx
80102c11:	50                   	push   %eax
80102c12:	e8 5c ff ff ff       	call   80102b73 <ioapicwrite>
80102c17:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c1d:	83 c0 08             	add    $0x8,%eax
80102c20:	01 c0                	add    %eax,%eax
80102c22:	83 c0 01             	add    $0x1,%eax
80102c25:	83 ec 08             	sub    $0x8,%esp
80102c28:	6a 00                	push   $0x0
80102c2a:	50                   	push   %eax
80102c2b:	e8 43 ff ff ff       	call   80102b73 <ioapicwrite>
80102c30:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c33:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c3d:	7e b9                	jle    80102bf8 <ioapicinit+0x6a>
80102c3f:	eb 01                	jmp    80102c42 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102c41:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102c42:	c9                   	leave  
80102c43:	c3                   	ret    

80102c44 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c44:	55                   	push   %ebp
80102c45:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102c47:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102c4c:	85 c0                	test   %eax,%eax
80102c4e:	74 39                	je     80102c89 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c50:	8b 45 08             	mov    0x8(%ebp),%eax
80102c53:	83 c0 20             	add    $0x20,%eax
80102c56:	89 c2                	mov    %eax,%edx
80102c58:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5b:	83 c0 08             	add    $0x8,%eax
80102c5e:	01 c0                	add    %eax,%eax
80102c60:	52                   	push   %edx
80102c61:	50                   	push   %eax
80102c62:	e8 0c ff ff ff       	call   80102b73 <ioapicwrite>
80102c67:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c6d:	c1 e0 18             	shl    $0x18,%eax
80102c70:	89 c2                	mov    %eax,%edx
80102c72:	8b 45 08             	mov    0x8(%ebp),%eax
80102c75:	83 c0 08             	add    $0x8,%eax
80102c78:	01 c0                	add    %eax,%eax
80102c7a:	83 c0 01             	add    $0x1,%eax
80102c7d:	52                   	push   %edx
80102c7e:	50                   	push   %eax
80102c7f:	e8 ef fe ff ff       	call   80102b73 <ioapicwrite>
80102c84:	83 c4 08             	add    $0x8,%esp
80102c87:	eb 01                	jmp    80102c8a <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102c89:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102c8a:	c9                   	leave  
80102c8b:	c3                   	ret    

80102c8c <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102c8c:	55                   	push   %ebp
80102c8d:	89 e5                	mov    %esp,%ebp
80102c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c92:	05 00 00 00 80       	add    $0x80000000,%eax
80102c97:	5d                   	pop    %ebp
80102c98:	c3                   	ret    

80102c99 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102c99:	55                   	push   %ebp
80102c9a:	89 e5                	mov    %esp,%ebp
80102c9c:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102c9f:	83 ec 08             	sub    $0x8,%esp
80102ca2:	68 66 85 10 80       	push   $0x80108566
80102ca7:	68 60 f8 10 80       	push   $0x8010f860
80102cac:	e8 ff 20 00 00       	call   80104db0 <initlock>
80102cb1:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102cb4:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102cbb:	00 00 00 
  freerange(vstart, vend);
80102cbe:	83 ec 08             	sub    $0x8,%esp
80102cc1:	ff 75 0c             	pushl  0xc(%ebp)
80102cc4:	ff 75 08             	pushl  0x8(%ebp)
80102cc7:	e8 2a 00 00 00       	call   80102cf6 <freerange>
80102ccc:	83 c4 10             	add    $0x10,%esp
}
80102ccf:	90                   	nop
80102cd0:	c9                   	leave  
80102cd1:	c3                   	ret    

80102cd2 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102cd2:	55                   	push   %ebp
80102cd3:	89 e5                	mov    %esp,%ebp
80102cd5:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102cd8:	83 ec 08             	sub    $0x8,%esp
80102cdb:	ff 75 0c             	pushl  0xc(%ebp)
80102cde:	ff 75 08             	pushl  0x8(%ebp)
80102ce1:	e8 10 00 00 00       	call   80102cf6 <freerange>
80102ce6:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102ce9:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102cf0:	00 00 00 
}
80102cf3:	90                   	nop
80102cf4:	c9                   	leave  
80102cf5:	c3                   	ret    

80102cf6 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102cf6:	55                   	push   %ebp
80102cf7:	89 e5                	mov    %esp,%ebp
80102cf9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80102cff:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d04:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d0c:	eb 15                	jmp    80102d23 <freerange+0x2d>
    kfree(p);
80102d0e:	83 ec 0c             	sub    $0xc,%esp
80102d11:	ff 75 f4             	pushl  -0xc(%ebp)
80102d14:	e8 1a 00 00 00       	call   80102d33 <kfree>
80102d19:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d1c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d26:	05 00 10 00 00       	add    $0x1000,%eax
80102d2b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102d2e:	76 de                	jbe    80102d0e <freerange+0x18>
    kfree(p);
}
80102d30:	90                   	nop
80102d31:	c9                   	leave  
80102d32:	c3                   	ret    

80102d33 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d33:	55                   	push   %ebp
80102d34:	89 e5                	mov    %esp,%ebp
80102d36:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102d39:	8b 45 08             	mov    0x8(%ebp),%eax
80102d3c:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d41:	85 c0                	test   %eax,%eax
80102d43:	75 1b                	jne    80102d60 <kfree+0x2d>
80102d45:	81 7d 08 1c 27 11 80 	cmpl   $0x8011271c,0x8(%ebp)
80102d4c:	72 12                	jb     80102d60 <kfree+0x2d>
80102d4e:	ff 75 08             	pushl  0x8(%ebp)
80102d51:	e8 36 ff ff ff       	call   80102c8c <v2p>
80102d56:	83 c4 04             	add    $0x4,%esp
80102d59:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d5e:	76 0d                	jbe    80102d6d <kfree+0x3a>
    panic("kfree");
80102d60:	83 ec 0c             	sub    $0xc,%esp
80102d63:	68 6b 85 10 80       	push   $0x8010856b
80102d68:	e8 f9 d7 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d6d:	83 ec 04             	sub    $0x4,%esp
80102d70:	68 00 10 00 00       	push   $0x1000
80102d75:	6a 01                	push   $0x1
80102d77:	ff 75 08             	pushl  0x8(%ebp)
80102d7a:	e8 b6 22 00 00       	call   80105035 <memset>
80102d7f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102d82:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102d87:	85 c0                	test   %eax,%eax
80102d89:	74 10                	je     80102d9b <kfree+0x68>
    acquire(&kmem.lock);
80102d8b:	83 ec 0c             	sub    $0xc,%esp
80102d8e:	68 60 f8 10 80       	push   $0x8010f860
80102d93:	e8 3a 20 00 00       	call   80104dd2 <acquire>
80102d98:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102da1:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102daa:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102daf:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102db4:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102db9:	85 c0                	test   %eax,%eax
80102dbb:	74 10                	je     80102dcd <kfree+0x9a>
    release(&kmem.lock);
80102dbd:	83 ec 0c             	sub    $0xc,%esp
80102dc0:	68 60 f8 10 80       	push   $0x8010f860
80102dc5:	e8 6f 20 00 00       	call   80104e39 <release>
80102dca:	83 c4 10             	add    $0x10,%esp
}
80102dcd:	90                   	nop
80102dce:	c9                   	leave  
80102dcf:	c3                   	ret    

80102dd0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102dd0:	55                   	push   %ebp
80102dd1:	89 e5                	mov    %esp,%ebp
80102dd3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102dd6:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102ddb:	85 c0                	test   %eax,%eax
80102ddd:	74 10                	je     80102def <kalloc+0x1f>
    acquire(&kmem.lock);
80102ddf:	83 ec 0c             	sub    $0xc,%esp
80102de2:	68 60 f8 10 80       	push   $0x8010f860
80102de7:	e8 e6 1f 00 00       	call   80104dd2 <acquire>
80102dec:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102def:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102df4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102df7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102dfb:	74 0a                	je     80102e07 <kalloc+0x37>
    kmem.freelist = r->next;
80102dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e00:	8b 00                	mov    (%eax),%eax
80102e02:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e07:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e0c:	85 c0                	test   %eax,%eax
80102e0e:	74 10                	je     80102e20 <kalloc+0x50>
    release(&kmem.lock);
80102e10:	83 ec 0c             	sub    $0xc,%esp
80102e13:	68 60 f8 10 80       	push   $0x8010f860
80102e18:	e8 1c 20 00 00       	call   80104e39 <release>
80102e1d:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e23:	c9                   	leave  
80102e24:	c3                   	ret    

80102e25 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e25:	55                   	push   %ebp
80102e26:	89 e5                	mov    %esp,%ebp
80102e28:	83 ec 14             	sub    $0x14,%esp
80102e2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e2e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e32:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e36:	89 c2                	mov    %eax,%edx
80102e38:	ec                   	in     (%dx),%al
80102e39:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e3c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e40:	c9                   	leave  
80102e41:	c3                   	ret    

80102e42 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e42:	55                   	push   %ebp
80102e43:	89 e5                	mov    %esp,%ebp
80102e45:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e48:	6a 64                	push   $0x64
80102e4a:	e8 d6 ff ff ff       	call   80102e25 <inb>
80102e4f:	83 c4 04             	add    $0x4,%esp
80102e52:	0f b6 c0             	movzbl %al,%eax
80102e55:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e5b:	83 e0 01             	and    $0x1,%eax
80102e5e:	85 c0                	test   %eax,%eax
80102e60:	75 0a                	jne    80102e6c <kbdgetc+0x2a>
    return -1;
80102e62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e67:	e9 23 01 00 00       	jmp    80102f8f <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102e6c:	6a 60                	push   $0x60
80102e6e:	e8 b2 ff ff ff       	call   80102e25 <inb>
80102e73:	83 c4 04             	add    $0x4,%esp
80102e76:	0f b6 c0             	movzbl %al,%eax
80102e79:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e7c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e83:	75 17                	jne    80102e9c <kbdgetc+0x5a>
    shift |= E0ESC;
80102e85:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102e8a:	83 c8 40             	or     $0x40,%eax
80102e8d:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102e92:	b8 00 00 00 00       	mov    $0x0,%eax
80102e97:	e9 f3 00 00 00       	jmp    80102f8f <kbdgetc+0x14d>
  } else if(data & 0x80){
80102e9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e9f:	25 80 00 00 00       	and    $0x80,%eax
80102ea4:	85 c0                	test   %eax,%eax
80102ea6:	74 45                	je     80102eed <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ea8:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ead:	83 e0 40             	and    $0x40,%eax
80102eb0:	85 c0                	test   %eax,%eax
80102eb2:	75 08                	jne    80102ebc <kbdgetc+0x7a>
80102eb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eb7:	83 e0 7f             	and    $0x7f,%eax
80102eba:	eb 03                	jmp    80102ebf <kbdgetc+0x7d>
80102ebc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ebf:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102ec2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ec5:	05 20 90 10 80       	add    $0x80109020,%eax
80102eca:	0f b6 00             	movzbl (%eax),%eax
80102ecd:	83 c8 40             	or     $0x40,%eax
80102ed0:	0f b6 c0             	movzbl %al,%eax
80102ed3:	f7 d0                	not    %eax
80102ed5:	89 c2                	mov    %eax,%edx
80102ed7:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102edc:	21 d0                	and    %edx,%eax
80102ede:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102ee3:	b8 00 00 00 00       	mov    $0x0,%eax
80102ee8:	e9 a2 00 00 00       	jmp    80102f8f <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102eed:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ef2:	83 e0 40             	and    $0x40,%eax
80102ef5:	85 c0                	test   %eax,%eax
80102ef7:	74 14                	je     80102f0d <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102ef9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f00:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102f05:	83 e0 bf             	and    $0xffffffbf,%eax
80102f08:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102f0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f10:	05 20 90 10 80       	add    $0x80109020,%eax
80102f15:	0f b6 00             	movzbl (%eax),%eax
80102f18:	0f b6 d0             	movzbl %al,%edx
80102f1b:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102f20:	09 d0                	or     %edx,%eax
80102f22:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102f27:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f2a:	05 20 91 10 80       	add    $0x80109120,%eax
80102f2f:	0f b6 00             	movzbl (%eax),%eax
80102f32:	0f b6 d0             	movzbl %al,%edx
80102f35:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102f3a:	31 d0                	xor    %edx,%eax
80102f3c:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f41:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102f46:	83 e0 03             	and    $0x3,%eax
80102f49:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102f50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f53:	01 d0                	add    %edx,%eax
80102f55:	0f b6 00             	movzbl (%eax),%eax
80102f58:	0f b6 c0             	movzbl %al,%eax
80102f5b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f5e:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102f63:	83 e0 08             	and    $0x8,%eax
80102f66:	85 c0                	test   %eax,%eax
80102f68:	74 22                	je     80102f8c <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102f6a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f6e:	76 0c                	jbe    80102f7c <kbdgetc+0x13a>
80102f70:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f74:	77 06                	ja     80102f7c <kbdgetc+0x13a>
      c += 'A' - 'a';
80102f76:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f7a:	eb 10                	jmp    80102f8c <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102f7c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f80:	76 0a                	jbe    80102f8c <kbdgetc+0x14a>
80102f82:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f86:	77 04                	ja     80102f8c <kbdgetc+0x14a>
      c += 'a' - 'A';
80102f88:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f8f:	c9                   	leave  
80102f90:	c3                   	ret    

80102f91 <kbdintr>:

void
kbdintr(void)
{
80102f91:	55                   	push   %ebp
80102f92:	89 e5                	mov    %esp,%ebp
80102f94:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102f97:	83 ec 0c             	sub    $0xc,%esp
80102f9a:	68 42 2e 10 80       	push   $0x80102e42
80102f9f:	e8 39 d8 ff ff       	call   801007dd <consoleintr>
80102fa4:	83 c4 10             	add    $0x10,%esp
}
80102fa7:	90                   	nop
80102fa8:	c9                   	leave  
80102fa9:	c3                   	ret    

80102faa <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102faa:	55                   	push   %ebp
80102fab:	89 e5                	mov    %esp,%ebp
80102fad:	83 ec 08             	sub    $0x8,%esp
80102fb0:	8b 55 08             	mov    0x8(%ebp),%edx
80102fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fb6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102fba:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fbd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102fc1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102fc5:	ee                   	out    %al,(%dx)
}
80102fc6:	90                   	nop
80102fc7:	c9                   	leave  
80102fc8:	c3                   	ret    

80102fc9 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102fc9:	55                   	push   %ebp
80102fca:	89 e5                	mov    %esp,%ebp
80102fcc:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102fcf:	9c                   	pushf  
80102fd0:	58                   	pop    %eax
80102fd1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102fd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102fd7:	c9                   	leave  
80102fd8:	c3                   	ret    

80102fd9 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102fd9:	55                   	push   %ebp
80102fda:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102fdc:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102fe1:	8b 55 08             	mov    0x8(%ebp),%edx
80102fe4:	c1 e2 02             	shl    $0x2,%edx
80102fe7:	01 c2                	add    %eax,%edx
80102fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fec:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102fee:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102ff3:	83 c0 20             	add    $0x20,%eax
80102ff6:	8b 00                	mov    (%eax),%eax
}
80102ff8:	90                   	nop
80102ff9:	5d                   	pop    %ebp
80102ffa:	c3                   	ret    

80102ffb <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102ffb:	55                   	push   %ebp
80102ffc:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102ffe:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103003:	85 c0                	test   %eax,%eax
80103005:	0f 84 0b 01 00 00    	je     80103116 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010300b:	68 3f 01 00 00       	push   $0x13f
80103010:	6a 3c                	push   $0x3c
80103012:	e8 c2 ff ff ff       	call   80102fd9 <lapicw>
80103017:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
8010301a:	6a 0b                	push   $0xb
8010301c:	68 f8 00 00 00       	push   $0xf8
80103021:	e8 b3 ff ff ff       	call   80102fd9 <lapicw>
80103026:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103029:	68 20 00 02 00       	push   $0x20020
8010302e:	68 c8 00 00 00       	push   $0xc8
80103033:	e8 a1 ff ff ff       	call   80102fd9 <lapicw>
80103038:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
8010303b:	68 80 96 98 00       	push   $0x989680
80103040:	68 e0 00 00 00       	push   $0xe0
80103045:	e8 8f ff ff ff       	call   80102fd9 <lapicw>
8010304a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010304d:	68 00 00 01 00       	push   $0x10000
80103052:	68 d4 00 00 00       	push   $0xd4
80103057:	e8 7d ff ff ff       	call   80102fd9 <lapicw>
8010305c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
8010305f:	68 00 00 01 00       	push   $0x10000
80103064:	68 d8 00 00 00       	push   $0xd8
80103069:	e8 6b ff ff ff       	call   80102fd9 <lapicw>
8010306e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103071:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103076:	83 c0 30             	add    $0x30,%eax
80103079:	8b 00                	mov    (%eax),%eax
8010307b:	c1 e8 10             	shr    $0x10,%eax
8010307e:	0f b6 c0             	movzbl %al,%eax
80103081:	83 f8 03             	cmp    $0x3,%eax
80103084:	76 12                	jbe    80103098 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80103086:	68 00 00 01 00       	push   $0x10000
8010308b:	68 d0 00 00 00       	push   $0xd0
80103090:	e8 44 ff ff ff       	call   80102fd9 <lapicw>
80103095:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103098:	6a 33                	push   $0x33
8010309a:	68 dc 00 00 00       	push   $0xdc
8010309f:	e8 35 ff ff ff       	call   80102fd9 <lapicw>
801030a4:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801030a7:	6a 00                	push   $0x0
801030a9:	68 a0 00 00 00       	push   $0xa0
801030ae:	e8 26 ff ff ff       	call   80102fd9 <lapicw>
801030b3:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
801030b6:	6a 00                	push   $0x0
801030b8:	68 a0 00 00 00       	push   $0xa0
801030bd:	e8 17 ff ff ff       	call   80102fd9 <lapicw>
801030c2:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801030c5:	6a 00                	push   $0x0
801030c7:	6a 2c                	push   $0x2c
801030c9:	e8 0b ff ff ff       	call   80102fd9 <lapicw>
801030ce:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801030d1:	6a 00                	push   $0x0
801030d3:	68 c4 00 00 00       	push   $0xc4
801030d8:	e8 fc fe ff ff       	call   80102fd9 <lapicw>
801030dd:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801030e0:	68 00 85 08 00       	push   $0x88500
801030e5:	68 c0 00 00 00       	push   $0xc0
801030ea:	e8 ea fe ff ff       	call   80102fd9 <lapicw>
801030ef:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801030f2:	90                   	nop
801030f3:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801030f8:	05 00 03 00 00       	add    $0x300,%eax
801030fd:	8b 00                	mov    (%eax),%eax
801030ff:	25 00 10 00 00       	and    $0x1000,%eax
80103104:	85 c0                	test   %eax,%eax
80103106:	75 eb                	jne    801030f3 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103108:	6a 00                	push   $0x0
8010310a:	6a 20                	push   $0x20
8010310c:	e8 c8 fe ff ff       	call   80102fd9 <lapicw>
80103111:	83 c4 08             	add    $0x8,%esp
80103114:	eb 01                	jmp    80103117 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80103116:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80103117:	c9                   	leave  
80103118:	c3                   	ret    

80103119 <cpunum>:

int
cpunum(void)
{
80103119:	55                   	push   %ebp
8010311a:	89 e5                	mov    %esp,%ebp
8010311c:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
8010311f:	e8 a5 fe ff ff       	call   80102fc9 <readeflags>
80103124:	25 00 02 00 00       	and    $0x200,%eax
80103129:	85 c0                	test   %eax,%eax
8010312b:	74 26                	je     80103153 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
8010312d:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80103132:	8d 50 01             	lea    0x1(%eax),%edx
80103135:	89 15 60 b6 10 80    	mov    %edx,0x8010b660
8010313b:	85 c0                	test   %eax,%eax
8010313d:	75 14                	jne    80103153 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
8010313f:	8b 45 04             	mov    0x4(%ebp),%eax
80103142:	83 ec 08             	sub    $0x8,%esp
80103145:	50                   	push   %eax
80103146:	68 74 85 10 80       	push   $0x80108574
8010314b:	e8 76 d2 ff ff       	call   801003c6 <cprintf>
80103150:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103153:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103158:	85 c0                	test   %eax,%eax
8010315a:	74 0f                	je     8010316b <cpunum+0x52>
    return lapic[ID]>>24;
8010315c:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103161:	83 c0 20             	add    $0x20,%eax
80103164:	8b 00                	mov    (%eax),%eax
80103166:	c1 e8 18             	shr    $0x18,%eax
80103169:	eb 05                	jmp    80103170 <cpunum+0x57>
  return 0;
8010316b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103170:	c9                   	leave  
80103171:	c3                   	ret    

80103172 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103172:	55                   	push   %ebp
80103173:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103175:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010317a:	85 c0                	test   %eax,%eax
8010317c:	74 0c                	je     8010318a <lapiceoi+0x18>
    lapicw(EOI, 0);
8010317e:	6a 00                	push   $0x0
80103180:	6a 2c                	push   $0x2c
80103182:	e8 52 fe ff ff       	call   80102fd9 <lapicw>
80103187:	83 c4 08             	add    $0x8,%esp
}
8010318a:	90                   	nop
8010318b:	c9                   	leave  
8010318c:	c3                   	ret    

8010318d <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010318d:	55                   	push   %ebp
8010318e:	89 e5                	mov    %esp,%ebp
}
80103190:	90                   	nop
80103191:	5d                   	pop    %ebp
80103192:	c3                   	ret    

80103193 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103193:	55                   	push   %ebp
80103194:	89 e5                	mov    %esp,%ebp
80103196:	83 ec 14             	sub    $0x14,%esp
80103199:	8b 45 08             	mov    0x8(%ebp),%eax
8010319c:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
8010319f:	6a 0f                	push   $0xf
801031a1:	6a 70                	push   $0x70
801031a3:	e8 02 fe ff ff       	call   80102faa <outb>
801031a8:	83 c4 08             	add    $0x8,%esp
  outb(IO_RTC+1, 0x0A);
801031ab:	6a 0a                	push   $0xa
801031ad:	6a 71                	push   $0x71
801031af:	e8 f6 fd ff ff       	call   80102faa <outb>
801031b4:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801031b7:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801031be:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031c1:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801031c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031c9:	83 c0 02             	add    $0x2,%eax
801031cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801031cf:	c1 ea 04             	shr    $0x4,%edx
801031d2:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801031d5:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031d9:	c1 e0 18             	shl    $0x18,%eax
801031dc:	50                   	push   %eax
801031dd:	68 c4 00 00 00       	push   $0xc4
801031e2:	e8 f2 fd ff ff       	call   80102fd9 <lapicw>
801031e7:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801031ea:	68 00 c5 00 00       	push   $0xc500
801031ef:	68 c0 00 00 00       	push   $0xc0
801031f4:	e8 e0 fd ff ff       	call   80102fd9 <lapicw>
801031f9:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031fc:	68 c8 00 00 00       	push   $0xc8
80103201:	e8 87 ff ff ff       	call   8010318d <microdelay>
80103206:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103209:	68 00 85 00 00       	push   $0x8500
8010320e:	68 c0 00 00 00       	push   $0xc0
80103213:	e8 c1 fd ff ff       	call   80102fd9 <lapicw>
80103218:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010321b:	6a 64                	push   $0x64
8010321d:	e8 6b ff ff ff       	call   8010318d <microdelay>
80103222:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103225:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010322c:	eb 3d                	jmp    8010326b <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
8010322e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103232:	c1 e0 18             	shl    $0x18,%eax
80103235:	50                   	push   %eax
80103236:	68 c4 00 00 00       	push   $0xc4
8010323b:	e8 99 fd ff ff       	call   80102fd9 <lapicw>
80103240:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103243:	8b 45 0c             	mov    0xc(%ebp),%eax
80103246:	c1 e8 0c             	shr    $0xc,%eax
80103249:	80 cc 06             	or     $0x6,%ah
8010324c:	50                   	push   %eax
8010324d:	68 c0 00 00 00       	push   $0xc0
80103252:	e8 82 fd ff ff       	call   80102fd9 <lapicw>
80103257:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010325a:	68 c8 00 00 00       	push   $0xc8
8010325f:	e8 29 ff ff ff       	call   8010318d <microdelay>
80103264:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103267:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010326b:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010326f:	7e bd                	jle    8010322e <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103271:	90                   	nop
80103272:	c9                   	leave  
80103273:	c3                   	ret    

80103274 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103274:	55                   	push   %ebp
80103275:	89 e5                	mov    %esp,%ebp
80103277:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010327a:	83 ec 08             	sub    $0x8,%esp
8010327d:	68 a0 85 10 80       	push   $0x801085a0
80103282:	68 a0 f8 10 80       	push   $0x8010f8a0
80103287:	e8 24 1b 00 00       	call   80104db0 <initlock>
8010328c:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
8010328f:	83 ec 08             	sub    $0x8,%esp
80103292:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103295:	50                   	push   %eax
80103296:	6a 01                	push   $0x1
80103298:	e8 d7 e2 ff ff       	call   80101574 <readsb>
8010329d:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
801032a0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032a6:	29 c2                	sub    %eax,%edx
801032a8:	89 d0                	mov    %edx,%eax
801032aa:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
801032af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032b2:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
801032b7:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
801032be:	00 00 00 
  recover_from_log();
801032c1:	e8 b2 01 00 00       	call   80103478 <recover_from_log>
}
801032c6:	90                   	nop
801032c7:	c9                   	leave  
801032c8:	c3                   	ret    

801032c9 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801032c9:	55                   	push   %ebp
801032ca:	89 e5                	mov    %esp,%ebp
801032cc:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d6:	e9 95 00 00 00       	jmp    80103370 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801032db:	8b 15 d4 f8 10 80    	mov    0x8010f8d4,%edx
801032e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e4:	01 d0                	add    %edx,%eax
801032e6:	83 c0 01             	add    $0x1,%eax
801032e9:	89 c2                	mov    %eax,%edx
801032eb:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801032f0:	83 ec 08             	sub    $0x8,%esp
801032f3:	52                   	push   %edx
801032f4:	50                   	push   %eax
801032f5:	e8 bc ce ff ff       	call   801001b6 <bread>
801032fa:	83 c4 10             	add    $0x10,%esp
801032fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
80103300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103303:	83 c0 10             	add    $0x10,%eax
80103306:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010330d:	89 c2                	mov    %eax,%edx
8010330f:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103314:	83 ec 08             	sub    $0x8,%esp
80103317:	52                   	push   %edx
80103318:	50                   	push   %eax
80103319:	e8 98 ce ff ff       	call   801001b6 <bread>
8010331e:	83 c4 10             	add    $0x10,%esp
80103321:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103324:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103327:	8d 50 18             	lea    0x18(%eax),%edx
8010332a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010332d:	83 c0 18             	add    $0x18,%eax
80103330:	83 ec 04             	sub    $0x4,%esp
80103333:	68 00 02 00 00       	push   $0x200
80103338:	52                   	push   %edx
80103339:	50                   	push   %eax
8010333a:	e8 b5 1d 00 00       	call   801050f4 <memmove>
8010333f:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103342:	83 ec 0c             	sub    $0xc,%esp
80103345:	ff 75 ec             	pushl  -0x14(%ebp)
80103348:	e8 a2 ce ff ff       	call   801001ef <bwrite>
8010334d:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103350:	83 ec 0c             	sub    $0xc,%esp
80103353:	ff 75 f0             	pushl  -0x10(%ebp)
80103356:	e8 d3 ce ff ff       	call   8010022e <brelse>
8010335b:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010335e:	83 ec 0c             	sub    $0xc,%esp
80103361:	ff 75 ec             	pushl  -0x14(%ebp)
80103364:	e8 c5 ce ff ff       	call   8010022e <brelse>
80103369:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010336c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103370:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103375:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103378:	0f 8f 5d ff ff ff    	jg     801032db <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
8010337e:	90                   	nop
8010337f:	c9                   	leave  
80103380:	c3                   	ret    

80103381 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103381:	55                   	push   %ebp
80103382:	89 e5                	mov    %esp,%ebp
80103384:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103387:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
8010338c:	89 c2                	mov    %eax,%edx
8010338e:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103393:	83 ec 08             	sub    $0x8,%esp
80103396:	52                   	push   %edx
80103397:	50                   	push   %eax
80103398:	e8 19 ce ff ff       	call   801001b6 <bread>
8010339d:	83 c4 10             	add    $0x10,%esp
801033a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033a6:	83 c0 18             	add    $0x18,%eax
801033a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033af:	8b 00                	mov    (%eax),%eax
801033b1:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
801033b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033bd:	eb 1b                	jmp    801033da <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
801033bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033c5:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033cc:	83 c2 10             	add    $0x10,%edx
801033cf:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033da:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801033df:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033e2:	7f db                	jg     801033bf <read_head+0x3e>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801033e4:	83 ec 0c             	sub    $0xc,%esp
801033e7:	ff 75 f0             	pushl  -0x10(%ebp)
801033ea:	e8 3f ce ff ff       	call   8010022e <brelse>
801033ef:	83 c4 10             	add    $0x10,%esp
}
801033f2:	90                   	nop
801033f3:	c9                   	leave  
801033f4:	c3                   	ret    

801033f5 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801033f5:	55                   	push   %ebp
801033f6:	89 e5                	mov    %esp,%ebp
801033f8:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801033fb:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103400:	89 c2                	mov    %eax,%edx
80103402:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103407:	83 ec 08             	sub    $0x8,%esp
8010340a:	52                   	push   %edx
8010340b:	50                   	push   %eax
8010340c:	e8 a5 cd ff ff       	call   801001b6 <bread>
80103411:	83 c4 10             	add    $0x10,%esp
80103414:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010341a:	83 c0 18             	add    $0x18,%eax
8010341d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103420:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
80103426:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103429:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010342b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103432:	eb 1b                	jmp    8010344f <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
80103434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103437:	83 c0 10             	add    $0x10,%eax
8010343a:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
80103441:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103444:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103447:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010344b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010344f:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103454:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103457:	7f db                	jg     80103434 <write_head+0x3f>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103459:	83 ec 0c             	sub    $0xc,%esp
8010345c:	ff 75 f0             	pushl  -0x10(%ebp)
8010345f:	e8 8b cd ff ff       	call   801001ef <bwrite>
80103464:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103467:	83 ec 0c             	sub    $0xc,%esp
8010346a:	ff 75 f0             	pushl  -0x10(%ebp)
8010346d:	e8 bc cd ff ff       	call   8010022e <brelse>
80103472:	83 c4 10             	add    $0x10,%esp
}
80103475:	90                   	nop
80103476:	c9                   	leave  
80103477:	c3                   	ret    

80103478 <recover_from_log>:

static void
recover_from_log(void)
{
80103478:	55                   	push   %ebp
80103479:	89 e5                	mov    %esp,%ebp
8010347b:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010347e:	e8 fe fe ff ff       	call   80103381 <read_head>
  install_trans(); // if committed, copy from log to disk
80103483:	e8 41 fe ff ff       	call   801032c9 <install_trans>
  log.lh.n = 0;
80103488:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
8010348f:	00 00 00 
  write_head(); // clear the log
80103492:	e8 5e ff ff ff       	call   801033f5 <write_head>
}
80103497:	90                   	nop
80103498:	c9                   	leave  
80103499:	c3                   	ret    

8010349a <begin_trans>:

void
begin_trans(void)
{
8010349a:	55                   	push   %ebp
8010349b:	89 e5                	mov    %esp,%ebp
8010349d:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801034a0:	83 ec 0c             	sub    $0xc,%esp
801034a3:	68 a0 f8 10 80       	push   $0x8010f8a0
801034a8:	e8 25 19 00 00       	call   80104dd2 <acquire>
801034ad:	83 c4 10             	add    $0x10,%esp
  while (log.busy) {
801034b0:	eb 15                	jmp    801034c7 <begin_trans+0x2d>
    sleep(&log, &log.lock);
801034b2:	83 ec 08             	sub    $0x8,%esp
801034b5:	68 a0 f8 10 80       	push   $0x8010f8a0
801034ba:	68 a0 f8 10 80       	push   $0x8010f8a0
801034bf:	e8 15 16 00 00       	call   80104ad9 <sleep>
801034c4:	83 c4 10             	add    $0x10,%esp

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
801034c7:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
801034cc:	85 c0                	test   %eax,%eax
801034ce:	75 e2                	jne    801034b2 <begin_trans+0x18>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
801034d0:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
801034d7:	00 00 00 
  release(&log.lock);
801034da:	83 ec 0c             	sub    $0xc,%esp
801034dd:	68 a0 f8 10 80       	push   $0x8010f8a0
801034e2:	e8 52 19 00 00       	call   80104e39 <release>
801034e7:	83 c4 10             	add    $0x10,%esp
}
801034ea:	90                   	nop
801034eb:	c9                   	leave  
801034ec:	c3                   	ret    

801034ed <commit_trans>:

void
commit_trans(void)
{
801034ed:	55                   	push   %ebp
801034ee:	89 e5                	mov    %esp,%ebp
801034f0:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801034f3:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801034f8:	85 c0                	test   %eax,%eax
801034fa:	7e 19                	jle    80103515 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801034fc:	e8 f4 fe ff ff       	call   801033f5 <write_head>
    install_trans(); // Now install writes to home locations
80103501:	e8 c3 fd ff ff       	call   801032c9 <install_trans>
    log.lh.n = 0; 
80103506:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
8010350d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103510:	e8 e0 fe ff ff       	call   801033f5 <write_head>
  }
  
  acquire(&log.lock);
80103515:	83 ec 0c             	sub    $0xc,%esp
80103518:	68 a0 f8 10 80       	push   $0x8010f8a0
8010351d:	e8 b0 18 00 00       	call   80104dd2 <acquire>
80103522:	83 c4 10             	add    $0x10,%esp
  log.busy = 0;
80103525:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
8010352c:	00 00 00 
  wakeup(&log);
8010352f:	83 ec 0c             	sub    $0xc,%esp
80103532:	68 a0 f8 10 80       	push   $0x8010f8a0
80103537:	e8 88 16 00 00       	call   80104bc4 <wakeup>
8010353c:	83 c4 10             	add    $0x10,%esp
  release(&log.lock);
8010353f:	83 ec 0c             	sub    $0xc,%esp
80103542:	68 a0 f8 10 80       	push   $0x8010f8a0
80103547:	e8 ed 18 00 00       	call   80104e39 <release>
8010354c:	83 c4 10             	add    $0x10,%esp
}
8010354f:	90                   	nop
80103550:	c9                   	leave  
80103551:	c3                   	ret    

80103552 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103552:	55                   	push   %ebp
80103553:	89 e5                	mov    %esp,%ebp
80103555:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103558:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010355d:	83 f8 09             	cmp    $0x9,%eax
80103560:	7f 12                	jg     80103574 <log_write+0x22>
80103562:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103567:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
8010356d:	83 ea 01             	sub    $0x1,%edx
80103570:	39 d0                	cmp    %edx,%eax
80103572:	7c 0d                	jl     80103581 <log_write+0x2f>
    panic("too big a transaction");
80103574:	83 ec 0c             	sub    $0xc,%esp
80103577:	68 a4 85 10 80       	push   $0x801085a4
8010357c:	e8 e5 cf ff ff       	call   80100566 <panic>
  if (!log.busy)
80103581:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103586:	85 c0                	test   %eax,%eax
80103588:	75 0d                	jne    80103597 <log_write+0x45>
    panic("write outside of trans");
8010358a:	83 ec 0c             	sub    $0xc,%esp
8010358d:	68 ba 85 10 80       	push   $0x801085ba
80103592:	e8 cf cf ff ff       	call   80100566 <panic>

  for (i = 0; i < log.lh.n; i++) {
80103597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010359e:	eb 1d                	jmp    801035bd <log_write+0x6b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
801035a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035a3:	83 c0 10             	add    $0x10,%eax
801035a6:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801035ad:	89 c2                	mov    %eax,%edx
801035af:	8b 45 08             	mov    0x8(%ebp),%eax
801035b2:	8b 40 08             	mov    0x8(%eax),%eax
801035b5:	39 c2                	cmp    %eax,%edx
801035b7:	74 10                	je     801035c9 <log_write+0x77>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
801035b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035bd:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035c2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035c5:	7f d9                	jg     801035a0 <log_write+0x4e>
801035c7:	eb 01                	jmp    801035ca <log_write+0x78>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
801035c9:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
801035ca:	8b 45 08             	mov    0x8(%ebp),%eax
801035cd:	8b 40 08             	mov    0x8(%eax),%eax
801035d0:	89 c2                	mov    %eax,%edx
801035d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d5:	83 c0 10             	add    $0x10,%eax
801035d8:	89 14 85 a8 f8 10 80 	mov    %edx,-0x7fef0758(,%eax,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
801035df:	8b 15 d4 f8 10 80    	mov    0x8010f8d4,%edx
801035e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035e8:	01 d0                	add    %edx,%eax
801035ea:	83 c0 01             	add    $0x1,%eax
801035ed:	89 c2                	mov    %eax,%edx
801035ef:	8b 45 08             	mov    0x8(%ebp),%eax
801035f2:	8b 40 04             	mov    0x4(%eax),%eax
801035f5:	83 ec 08             	sub    $0x8,%esp
801035f8:	52                   	push   %edx
801035f9:	50                   	push   %eax
801035fa:	e8 b7 cb ff ff       	call   801001b6 <bread>
801035ff:	83 c4 10             	add    $0x10,%esp
80103602:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103605:	8b 45 08             	mov    0x8(%ebp),%eax
80103608:	8d 50 18             	lea    0x18(%eax),%edx
8010360b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010360e:	83 c0 18             	add    $0x18,%eax
80103611:	83 ec 04             	sub    $0x4,%esp
80103614:	68 00 02 00 00       	push   $0x200
80103619:	52                   	push   %edx
8010361a:	50                   	push   %eax
8010361b:	e8 d4 1a 00 00       	call   801050f4 <memmove>
80103620:	83 c4 10             	add    $0x10,%esp
  bwrite(lbuf);
80103623:	83 ec 0c             	sub    $0xc,%esp
80103626:	ff 75 f0             	pushl  -0x10(%ebp)
80103629:	e8 c1 cb ff ff       	call   801001ef <bwrite>
8010362e:	83 c4 10             	add    $0x10,%esp
  brelse(lbuf);
80103631:	83 ec 0c             	sub    $0xc,%esp
80103634:	ff 75 f0             	pushl  -0x10(%ebp)
80103637:	e8 f2 cb ff ff       	call   8010022e <brelse>
8010363c:	83 c4 10             	add    $0x10,%esp
  if (i == log.lh.n)
8010363f:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103644:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103647:	75 0d                	jne    80103656 <log_write+0x104>
    log.lh.n++;
80103649:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010364e:	83 c0 01             	add    $0x1,%eax
80103651:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
80103656:	8b 45 08             	mov    0x8(%ebp),%eax
80103659:	8b 00                	mov    (%eax),%eax
8010365b:	83 c8 04             	or     $0x4,%eax
8010365e:	89 c2                	mov    %eax,%edx
80103660:	8b 45 08             	mov    0x8(%ebp),%eax
80103663:	89 10                	mov    %edx,(%eax)
}
80103665:	90                   	nop
80103666:	c9                   	leave  
80103667:	c3                   	ret    

80103668 <v2p>:
80103668:	55                   	push   %ebp
80103669:	89 e5                	mov    %esp,%ebp
8010366b:	8b 45 08             	mov    0x8(%ebp),%eax
8010366e:	05 00 00 00 80       	add    $0x80000000,%eax
80103673:	5d                   	pop    %ebp
80103674:	c3                   	ret    

80103675 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103675:	55                   	push   %ebp
80103676:	89 e5                	mov    %esp,%ebp
80103678:	8b 45 08             	mov    0x8(%ebp),%eax
8010367b:	05 00 00 00 80       	add    $0x80000000,%eax
80103680:	5d                   	pop    %ebp
80103681:	c3                   	ret    

80103682 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103682:	55                   	push   %ebp
80103683:	89 e5                	mov    %esp,%ebp
80103685:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103688:	8b 55 08             	mov    0x8(%ebp),%edx
8010368b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010368e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103691:	f0 87 02             	lock xchg %eax,(%edx)
80103694:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103697:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010369a:	c9                   	leave  
8010369b:	c3                   	ret    

8010369c <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010369c:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801036a0:	83 e4 f0             	and    $0xfffffff0,%esp
801036a3:	ff 71 fc             	pushl  -0x4(%ecx)
801036a6:	55                   	push   %ebp
801036a7:	89 e5                	mov    %esp,%ebp
801036a9:	51                   	push   %ecx
801036aa:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801036ad:	83 ec 08             	sub    $0x8,%esp
801036b0:	68 00 00 40 80       	push   $0x80400000
801036b5:	68 1c 27 11 80       	push   $0x8011271c
801036ba:	e8 da f5 ff ff       	call   80102c99 <kinit1>
801036bf:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801036c2:	e8 59 45 00 00       	call   80107c20 <kvmalloc>
  mpinit();        // collect info about this machine
801036c7:	e8 48 04 00 00       	call   80103b14 <mpinit>
  lapicinit();
801036cc:	e8 2a f9 ff ff       	call   80102ffb <lapicinit>
  seginit();       // set up segments
801036d1:	e8 f3 3e 00 00       	call   801075c9 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801036d6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801036dc:	0f b6 00             	movzbl (%eax),%eax
801036df:	0f b6 c0             	movzbl %al,%eax
801036e2:	83 ec 08             	sub    $0x8,%esp
801036e5:	50                   	push   %eax
801036e6:	68 d1 85 10 80       	push   $0x801085d1
801036eb:	e8 d6 cc ff ff       	call   801003c6 <cprintf>
801036f0:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801036f3:	e8 72 06 00 00       	call   80103d6a <picinit>
  ioapicinit();    // another interrupt controller
801036f8:	e8 91 f4 ff ff       	call   80102b8e <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801036fd:	e8 e7 d3 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
80103702:	e8 1e 32 00 00       	call   80106925 <uartinit>
  pinit();         // process table
80103707:	e8 5b 0b 00 00       	call   80104267 <pinit>
  tvinit();        // trap vectors
8010370c:	e8 de 2d 00 00       	call   801064ef <tvinit>
  binit();         // buffer cache
80103711:	e8 1e c9 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103716:	e8 4a da ff ff       	call   80101165 <fileinit>
  iinit();         // inode cache
8010371b:	e8 23 e1 ff ff       	call   80101843 <iinit>
  ideinit();       // disk
80103720:	e8 ad f0 ff ff       	call   801027d2 <ideinit>
  if(!ismp)
80103725:	a1 24 f9 10 80       	mov    0x8010f924,%eax
8010372a:	85 c0                	test   %eax,%eax
8010372c:	75 05                	jne    80103733 <main+0x97>
    timerinit();   // uniprocessor timer
8010372e:	e8 19 2d 00 00       	call   8010644c <timerinit>
  startothers();   // start other processors
80103733:	e8 7f 00 00 00       	call   801037b7 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103738:	83 ec 08             	sub    $0x8,%esp
8010373b:	68 00 00 00 8e       	push   $0x8e000000
80103740:	68 00 00 40 80       	push   $0x80400000
80103745:	e8 88 f5 ff ff       	call   80102cd2 <kinit2>
8010374a:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010374d:	e8 39 0c 00 00       	call   8010438b <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103752:	e8 1a 00 00 00       	call   80103771 <mpmain>

80103757 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103757:	55                   	push   %ebp
80103758:	89 e5                	mov    %esp,%ebp
8010375a:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010375d:	e8 d6 44 00 00       	call   80107c38 <switchkvm>
  seginit();
80103762:	e8 62 3e 00 00       	call   801075c9 <seginit>
  lapicinit();
80103767:	e8 8f f8 ff ff       	call   80102ffb <lapicinit>
  mpmain();
8010376c:	e8 00 00 00 00       	call   80103771 <mpmain>

80103771 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103771:	55                   	push   %ebp
80103772:	89 e5                	mov    %esp,%ebp
80103774:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103777:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010377d:	0f b6 00             	movzbl (%eax),%eax
80103780:	0f b6 c0             	movzbl %al,%eax
80103783:	83 ec 08             	sub    $0x8,%esp
80103786:	50                   	push   %eax
80103787:	68 e8 85 10 80       	push   $0x801085e8
8010378c:	e8 35 cc ff ff       	call   801003c6 <cprintf>
80103791:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103794:	e8 cc 2e 00 00       	call   80106665 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103799:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010379f:	05 a8 00 00 00       	add    $0xa8,%eax
801037a4:	83 ec 08             	sub    $0x8,%esp
801037a7:	6a 01                	push   $0x1
801037a9:	50                   	push   %eax
801037aa:	e8 d3 fe ff ff       	call   80103682 <xchg>
801037af:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801037b2:	e8 55 11 00 00       	call   8010490c <scheduler>

801037b7 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801037b7:	55                   	push   %ebp
801037b8:	89 e5                	mov    %esp,%ebp
801037ba:	53                   	push   %ebx
801037bb:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801037be:	68 00 70 00 00       	push   $0x7000
801037c3:	e8 ad fe ff ff       	call   80103675 <p2v>
801037c8:	83 c4 04             	add    $0x4,%esp
801037cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801037ce:	b8 8a 00 00 00       	mov    $0x8a,%eax
801037d3:	83 ec 04             	sub    $0x4,%esp
801037d6:	50                   	push   %eax
801037d7:	68 2c b5 10 80       	push   $0x8010b52c
801037dc:	ff 75 f0             	pushl  -0x10(%ebp)
801037df:	e8 10 19 00 00       	call   801050f4 <memmove>
801037e4:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801037e7:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
801037ee:	e9 90 00 00 00       	jmp    80103883 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801037f3:	e8 21 f9 ff ff       	call   80103119 <cpunum>
801037f8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801037fe:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103803:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103806:	74 73                	je     8010387b <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103808:	e8 c3 f5 ff ff       	call   80102dd0 <kalloc>
8010380d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103810:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103813:	83 e8 04             	sub    $0x4,%eax
80103816:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103819:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010381f:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103821:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103824:	83 e8 08             	sub    $0x8,%eax
80103827:	c7 00 57 37 10 80    	movl   $0x80103757,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010382d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103830:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103833:	83 ec 0c             	sub    $0xc,%esp
80103836:	68 00 a0 10 80       	push   $0x8010a000
8010383b:	e8 28 fe ff ff       	call   80103668 <v2p>
80103840:	83 c4 10             	add    $0x10,%esp
80103843:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103845:	83 ec 0c             	sub    $0xc,%esp
80103848:	ff 75 f0             	pushl  -0x10(%ebp)
8010384b:	e8 18 fe ff ff       	call   80103668 <v2p>
80103850:	83 c4 10             	add    $0x10,%esp
80103853:	89 c2                	mov    %eax,%edx
80103855:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103858:	0f b6 00             	movzbl (%eax),%eax
8010385b:	0f b6 c0             	movzbl %al,%eax
8010385e:	83 ec 08             	sub    $0x8,%esp
80103861:	52                   	push   %edx
80103862:	50                   	push   %eax
80103863:	e8 2b f9 ff ff       	call   80103193 <lapicstartap>
80103868:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010386b:	90                   	nop
8010386c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010386f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103875:	85 c0                	test   %eax,%eax
80103877:	74 f3                	je     8010386c <startothers+0xb5>
80103879:	eb 01                	jmp    8010387c <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010387b:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010387c:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103883:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103888:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010388e:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103893:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103896:	0f 87 57 ff ff ff    	ja     801037f3 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010389c:	90                   	nop
8010389d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038a0:	c9                   	leave  
801038a1:	c3                   	ret    

801038a2 <p2v>:
801038a2:	55                   	push   %ebp
801038a3:	89 e5                	mov    %esp,%ebp
801038a5:	8b 45 08             	mov    0x8(%ebp),%eax
801038a8:	05 00 00 00 80       	add    $0x80000000,%eax
801038ad:	5d                   	pop    %ebp
801038ae:	c3                   	ret    

801038af <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801038af:	55                   	push   %ebp
801038b0:	89 e5                	mov    %esp,%ebp
801038b2:	83 ec 14             	sub    $0x14,%esp
801038b5:	8b 45 08             	mov    0x8(%ebp),%eax
801038b8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801038bc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801038c0:	89 c2                	mov    %eax,%edx
801038c2:	ec                   	in     (%dx),%al
801038c3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801038c6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801038ca:	c9                   	leave  
801038cb:	c3                   	ret    

801038cc <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801038cc:	55                   	push   %ebp
801038cd:	89 e5                	mov    %esp,%ebp
801038cf:	83 ec 08             	sub    $0x8,%esp
801038d2:	8b 55 08             	mov    0x8(%ebp),%edx
801038d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801038d8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801038dc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801038df:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801038e3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801038e7:	ee                   	out    %al,(%dx)
}
801038e8:	90                   	nop
801038e9:	c9                   	leave  
801038ea:	c3                   	ret    

801038eb <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801038eb:	55                   	push   %ebp
801038ec:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801038ee:	a1 64 b6 10 80       	mov    0x8010b664,%eax
801038f3:	89 c2                	mov    %eax,%edx
801038f5:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
801038fa:	29 c2                	sub    %eax,%edx
801038fc:	89 d0                	mov    %edx,%eax
801038fe:	c1 f8 02             	sar    $0x2,%eax
80103901:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103907:	5d                   	pop    %ebp
80103908:	c3                   	ret    

80103909 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103909:	55                   	push   %ebp
8010390a:	89 e5                	mov    %esp,%ebp
8010390c:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
8010390f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103916:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010391d:	eb 15                	jmp    80103934 <sum+0x2b>
    sum += addr[i];
8010391f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103922:	8b 45 08             	mov    0x8(%ebp),%eax
80103925:	01 d0                	add    %edx,%eax
80103927:	0f b6 00             	movzbl (%eax),%eax
8010392a:	0f b6 c0             	movzbl %al,%eax
8010392d:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103930:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103934:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103937:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010393a:	7c e3                	jl     8010391f <sum+0x16>
    sum += addr[i];
  return sum;
8010393c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010393f:	c9                   	leave  
80103940:	c3                   	ret    

80103941 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103941:	55                   	push   %ebp
80103942:	89 e5                	mov    %esp,%ebp
80103944:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103947:	ff 75 08             	pushl  0x8(%ebp)
8010394a:	e8 53 ff ff ff       	call   801038a2 <p2v>
8010394f:	83 c4 04             	add    $0x4,%esp
80103952:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103955:	8b 55 0c             	mov    0xc(%ebp),%edx
80103958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010395b:	01 d0                	add    %edx,%eax
8010395d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103960:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103963:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103966:	eb 36                	jmp    8010399e <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103968:	83 ec 04             	sub    $0x4,%esp
8010396b:	6a 04                	push   $0x4
8010396d:	68 fc 85 10 80       	push   $0x801085fc
80103972:	ff 75 f4             	pushl  -0xc(%ebp)
80103975:	e8 22 17 00 00       	call   8010509c <memcmp>
8010397a:	83 c4 10             	add    $0x10,%esp
8010397d:	85 c0                	test   %eax,%eax
8010397f:	75 19                	jne    8010399a <mpsearch1+0x59>
80103981:	83 ec 08             	sub    $0x8,%esp
80103984:	6a 10                	push   $0x10
80103986:	ff 75 f4             	pushl  -0xc(%ebp)
80103989:	e8 7b ff ff ff       	call   80103909 <sum>
8010398e:	83 c4 10             	add    $0x10,%esp
80103991:	84 c0                	test   %al,%al
80103993:	75 05                	jne    8010399a <mpsearch1+0x59>
      return (struct mp*)p;
80103995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103998:	eb 11                	jmp    801039ab <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
8010399a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010399e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039a1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801039a4:	72 c2                	jb     80103968 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801039a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801039ab:	c9                   	leave  
801039ac:	c3                   	ret    

801039ad <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801039ad:	55                   	push   %ebp
801039ae:	89 e5                	mov    %esp,%ebp
801039b0:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801039b3:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801039ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039bd:	83 c0 0f             	add    $0xf,%eax
801039c0:	0f b6 00             	movzbl (%eax),%eax
801039c3:	0f b6 c0             	movzbl %al,%eax
801039c6:	c1 e0 08             	shl    $0x8,%eax
801039c9:	89 c2                	mov    %eax,%edx
801039cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ce:	83 c0 0e             	add    $0xe,%eax
801039d1:	0f b6 00             	movzbl (%eax),%eax
801039d4:	0f b6 c0             	movzbl %al,%eax
801039d7:	09 d0                	or     %edx,%eax
801039d9:	c1 e0 04             	shl    $0x4,%eax
801039dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801039df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801039e3:	74 21                	je     80103a06 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801039e5:	83 ec 08             	sub    $0x8,%esp
801039e8:	68 00 04 00 00       	push   $0x400
801039ed:	ff 75 f0             	pushl  -0x10(%ebp)
801039f0:	e8 4c ff ff ff       	call   80103941 <mpsearch1>
801039f5:	83 c4 10             	add    $0x10,%esp
801039f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801039fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801039ff:	74 51                	je     80103a52 <mpsearch+0xa5>
      return mp;
80103a01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a04:	eb 61                	jmp    80103a67 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a09:	83 c0 14             	add    $0x14,%eax
80103a0c:	0f b6 00             	movzbl (%eax),%eax
80103a0f:	0f b6 c0             	movzbl %al,%eax
80103a12:	c1 e0 08             	shl    $0x8,%eax
80103a15:	89 c2                	mov    %eax,%edx
80103a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a1a:	83 c0 13             	add    $0x13,%eax
80103a1d:	0f b6 00             	movzbl (%eax),%eax
80103a20:	0f b6 c0             	movzbl %al,%eax
80103a23:	09 d0                	or     %edx,%eax
80103a25:	c1 e0 0a             	shl    $0xa,%eax
80103a28:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a2e:	2d 00 04 00 00       	sub    $0x400,%eax
80103a33:	83 ec 08             	sub    $0x8,%esp
80103a36:	68 00 04 00 00       	push   $0x400
80103a3b:	50                   	push   %eax
80103a3c:	e8 00 ff ff ff       	call   80103941 <mpsearch1>
80103a41:	83 c4 10             	add    $0x10,%esp
80103a44:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a47:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a4b:	74 05                	je     80103a52 <mpsearch+0xa5>
      return mp;
80103a4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a50:	eb 15                	jmp    80103a67 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103a52:	83 ec 08             	sub    $0x8,%esp
80103a55:	68 00 00 01 00       	push   $0x10000
80103a5a:	68 00 00 0f 00       	push   $0xf0000
80103a5f:	e8 dd fe ff ff       	call   80103941 <mpsearch1>
80103a64:	83 c4 10             	add    $0x10,%esp
}
80103a67:	c9                   	leave  
80103a68:	c3                   	ret    

80103a69 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103a69:	55                   	push   %ebp
80103a6a:	89 e5                	mov    %esp,%ebp
80103a6c:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103a6f:	e8 39 ff ff ff       	call   801039ad <mpsearch>
80103a74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103a7b:	74 0a                	je     80103a87 <mpconfig+0x1e>
80103a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a80:	8b 40 04             	mov    0x4(%eax),%eax
80103a83:	85 c0                	test   %eax,%eax
80103a85:	75 0a                	jne    80103a91 <mpconfig+0x28>
    return 0;
80103a87:	b8 00 00 00 00       	mov    $0x0,%eax
80103a8c:	e9 81 00 00 00       	jmp    80103b12 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a94:	8b 40 04             	mov    0x4(%eax),%eax
80103a97:	83 ec 0c             	sub    $0xc,%esp
80103a9a:	50                   	push   %eax
80103a9b:	e8 02 fe ff ff       	call   801038a2 <p2v>
80103aa0:	83 c4 10             	add    $0x10,%esp
80103aa3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103aa6:	83 ec 04             	sub    $0x4,%esp
80103aa9:	6a 04                	push   $0x4
80103aab:	68 01 86 10 80       	push   $0x80108601
80103ab0:	ff 75 f0             	pushl  -0x10(%ebp)
80103ab3:	e8 e4 15 00 00       	call   8010509c <memcmp>
80103ab8:	83 c4 10             	add    $0x10,%esp
80103abb:	85 c0                	test   %eax,%eax
80103abd:	74 07                	je     80103ac6 <mpconfig+0x5d>
    return 0;
80103abf:	b8 00 00 00 00       	mov    $0x0,%eax
80103ac4:	eb 4c                	jmp    80103b12 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac9:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103acd:	3c 01                	cmp    $0x1,%al
80103acf:	74 12                	je     80103ae3 <mpconfig+0x7a>
80103ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad4:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ad8:	3c 04                	cmp    $0x4,%al
80103ada:	74 07                	je     80103ae3 <mpconfig+0x7a>
    return 0;
80103adc:	b8 00 00 00 00       	mov    $0x0,%eax
80103ae1:	eb 2f                	jmp    80103b12 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ae6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103aea:	0f b7 c0             	movzwl %ax,%eax
80103aed:	83 ec 08             	sub    $0x8,%esp
80103af0:	50                   	push   %eax
80103af1:	ff 75 f0             	pushl  -0x10(%ebp)
80103af4:	e8 10 fe ff ff       	call   80103909 <sum>
80103af9:	83 c4 10             	add    $0x10,%esp
80103afc:	84 c0                	test   %al,%al
80103afe:	74 07                	je     80103b07 <mpconfig+0x9e>
    return 0;
80103b00:	b8 00 00 00 00       	mov    $0x0,%eax
80103b05:	eb 0b                	jmp    80103b12 <mpconfig+0xa9>
  *pmp = mp;
80103b07:	8b 45 08             	mov    0x8(%ebp),%eax
80103b0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b0d:	89 10                	mov    %edx,(%eax)
  return conf;
80103b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b12:	c9                   	leave  
80103b13:	c3                   	ret    

80103b14 <mpinit>:

void
mpinit(void)
{
80103b14:	55                   	push   %ebp
80103b15:	89 e5                	mov    %esp,%ebp
80103b17:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103b1a:	c7 05 64 b6 10 80 40 	movl   $0x8010f940,0x8010b664
80103b21:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103b24:	83 ec 0c             	sub    $0xc,%esp
80103b27:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103b2a:	50                   	push   %eax
80103b2b:	e8 39 ff ff ff       	call   80103a69 <mpconfig>
80103b30:	83 c4 10             	add    $0x10,%esp
80103b33:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b36:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b3a:	0f 84 96 01 00 00    	je     80103cd6 <mpinit+0x1c2>
    return;
  ismp = 1;
80103b40:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103b47:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b4d:	8b 40 24             	mov    0x24(%eax),%eax
80103b50:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b58:	83 c0 2c             	add    $0x2c,%eax
80103b5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b61:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b65:	0f b7 d0             	movzwl %ax,%edx
80103b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6b:	01 d0                	add    %edx,%eax
80103b6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b70:	e9 f2 00 00 00       	jmp    80103c67 <mpinit+0x153>
    switch(*p){
80103b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b78:	0f b6 00             	movzbl (%eax),%eax
80103b7b:	0f b6 c0             	movzbl %al,%eax
80103b7e:	83 f8 04             	cmp    $0x4,%eax
80103b81:	0f 87 bc 00 00 00    	ja     80103c43 <mpinit+0x12f>
80103b87:	8b 04 85 44 86 10 80 	mov    -0x7fef79bc(,%eax,4),%eax
80103b8e:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b93:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103b96:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103b99:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103b9d:	0f b6 d0             	movzbl %al,%edx
80103ba0:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103ba5:	39 c2                	cmp    %eax,%edx
80103ba7:	74 2b                	je     80103bd4 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103ba9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103bac:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103bb0:	0f b6 d0             	movzbl %al,%edx
80103bb3:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103bb8:	83 ec 04             	sub    $0x4,%esp
80103bbb:	52                   	push   %edx
80103bbc:	50                   	push   %eax
80103bbd:	68 06 86 10 80       	push   $0x80108606
80103bc2:	e8 ff c7 ff ff       	call   801003c6 <cprintf>
80103bc7:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103bca:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103bd1:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103bd4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103bd7:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103bdb:	0f b6 c0             	movzbl %al,%eax
80103bde:	83 e0 02             	and    $0x2,%eax
80103be1:	85 c0                	test   %eax,%eax
80103be3:	74 15                	je     80103bfa <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103be5:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103bea:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103bf0:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103bf5:	a3 64 b6 10 80       	mov    %eax,0x8010b664
      cpus[ncpu].id = ncpu;
80103bfa:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103bff:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103c05:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c0b:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103c10:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103c12:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c17:	83 c0 01             	add    $0x1,%eax
80103c1a:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103c1f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103c23:	eb 42                	jmp    80103c67 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c2e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c32:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103c37:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c3b:	eb 2a                	jmp    80103c67 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103c3d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c41:	eb 24                	jmp    80103c67 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c46:	0f b6 00             	movzbl (%eax),%eax
80103c49:	0f b6 c0             	movzbl %al,%eax
80103c4c:	83 ec 08             	sub    $0x8,%esp
80103c4f:	50                   	push   %eax
80103c50:	68 24 86 10 80       	push   $0x80108624
80103c55:	e8 6c c7 ff ff       	call   801003c6 <cprintf>
80103c5a:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103c5d:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103c64:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c6d:	0f 82 02 ff ff ff    	jb     80103b75 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103c73:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103c78:	85 c0                	test   %eax,%eax
80103c7a:	75 1d                	jne    80103c99 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103c7c:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
80103c83:	00 00 00 
    lapic = 0;
80103c86:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103c8d:	00 00 00 
    ioapicid = 0;
80103c90:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
80103c97:	eb 3e                	jmp    80103cd7 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103c99:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103c9c:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103ca0:	84 c0                	test   %al,%al
80103ca2:	74 33                	je     80103cd7 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103ca4:	83 ec 08             	sub    $0x8,%esp
80103ca7:	6a 70                	push   $0x70
80103ca9:	6a 22                	push   $0x22
80103cab:	e8 1c fc ff ff       	call   801038cc <outb>
80103cb0:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103cb3:	83 ec 0c             	sub    $0xc,%esp
80103cb6:	6a 23                	push   $0x23
80103cb8:	e8 f2 fb ff ff       	call   801038af <inb>
80103cbd:	83 c4 10             	add    $0x10,%esp
80103cc0:	83 c8 01             	or     $0x1,%eax
80103cc3:	0f b6 c0             	movzbl %al,%eax
80103cc6:	83 ec 08             	sub    $0x8,%esp
80103cc9:	50                   	push   %eax
80103cca:	6a 23                	push   $0x23
80103ccc:	e8 fb fb ff ff       	call   801038cc <outb>
80103cd1:	83 c4 10             	add    $0x10,%esp
80103cd4:	eb 01                	jmp    80103cd7 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103cd6:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103cd7:	c9                   	leave  
80103cd8:	c3                   	ret    

80103cd9 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103cd9:	55                   	push   %ebp
80103cda:	89 e5                	mov    %esp,%ebp
80103cdc:	83 ec 08             	sub    $0x8,%esp
80103cdf:	8b 55 08             	mov    0x8(%ebp),%edx
80103ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ce5:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ce9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103cec:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103cf0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103cf4:	ee                   	out    %al,(%dx)
}
80103cf5:	90                   	nop
80103cf6:	c9                   	leave  
80103cf7:	c3                   	ret    

80103cf8 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103cf8:	55                   	push   %ebp
80103cf9:	89 e5                	mov    %esp,%ebp
80103cfb:	83 ec 04             	sub    $0x4,%esp
80103cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80103d01:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d05:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d09:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103d0f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d13:	0f b6 c0             	movzbl %al,%eax
80103d16:	50                   	push   %eax
80103d17:	6a 21                	push   $0x21
80103d19:	e8 bb ff ff ff       	call   80103cd9 <outb>
80103d1e:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103d21:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d25:	66 c1 e8 08          	shr    $0x8,%ax
80103d29:	0f b6 c0             	movzbl %al,%eax
80103d2c:	50                   	push   %eax
80103d2d:	68 a1 00 00 00       	push   $0xa1
80103d32:	e8 a2 ff ff ff       	call   80103cd9 <outb>
80103d37:	83 c4 08             	add    $0x8,%esp
}
80103d3a:	90                   	nop
80103d3b:	c9                   	leave  
80103d3c:	c3                   	ret    

80103d3d <picenable>:

void
picenable(int irq)
{
80103d3d:	55                   	push   %ebp
80103d3e:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103d40:	8b 45 08             	mov    0x8(%ebp),%eax
80103d43:	ba 01 00 00 00       	mov    $0x1,%edx
80103d48:	89 c1                	mov    %eax,%ecx
80103d4a:	d3 e2                	shl    %cl,%edx
80103d4c:	89 d0                	mov    %edx,%eax
80103d4e:	f7 d0                	not    %eax
80103d50:	89 c2                	mov    %eax,%edx
80103d52:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103d59:	21 d0                	and    %edx,%eax
80103d5b:	0f b7 c0             	movzwl %ax,%eax
80103d5e:	50                   	push   %eax
80103d5f:	e8 94 ff ff ff       	call   80103cf8 <picsetmask>
80103d64:	83 c4 04             	add    $0x4,%esp
}
80103d67:	90                   	nop
80103d68:	c9                   	leave  
80103d69:	c3                   	ret    

80103d6a <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103d6a:	55                   	push   %ebp
80103d6b:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103d6d:	68 ff 00 00 00       	push   $0xff
80103d72:	6a 21                	push   $0x21
80103d74:	e8 60 ff ff ff       	call   80103cd9 <outb>
80103d79:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103d7c:	68 ff 00 00 00       	push   $0xff
80103d81:	68 a1 00 00 00       	push   $0xa1
80103d86:	e8 4e ff ff ff       	call   80103cd9 <outb>
80103d8b:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103d8e:	6a 11                	push   $0x11
80103d90:	6a 20                	push   $0x20
80103d92:	e8 42 ff ff ff       	call   80103cd9 <outb>
80103d97:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103d9a:	6a 20                	push   $0x20
80103d9c:	6a 21                	push   $0x21
80103d9e:	e8 36 ff ff ff       	call   80103cd9 <outb>
80103da3:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103da6:	6a 04                	push   $0x4
80103da8:	6a 21                	push   $0x21
80103daa:	e8 2a ff ff ff       	call   80103cd9 <outb>
80103daf:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103db2:	6a 03                	push   $0x3
80103db4:	6a 21                	push   $0x21
80103db6:	e8 1e ff ff ff       	call   80103cd9 <outb>
80103dbb:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103dbe:	6a 11                	push   $0x11
80103dc0:	68 a0 00 00 00       	push   $0xa0
80103dc5:	e8 0f ff ff ff       	call   80103cd9 <outb>
80103dca:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103dcd:	6a 28                	push   $0x28
80103dcf:	68 a1 00 00 00       	push   $0xa1
80103dd4:	e8 00 ff ff ff       	call   80103cd9 <outb>
80103dd9:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103ddc:	6a 02                	push   $0x2
80103dde:	68 a1 00 00 00       	push   $0xa1
80103de3:	e8 f1 fe ff ff       	call   80103cd9 <outb>
80103de8:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103deb:	6a 03                	push   $0x3
80103ded:	68 a1 00 00 00       	push   $0xa1
80103df2:	e8 e2 fe ff ff       	call   80103cd9 <outb>
80103df7:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103dfa:	6a 68                	push   $0x68
80103dfc:	6a 20                	push   $0x20
80103dfe:	e8 d6 fe ff ff       	call   80103cd9 <outb>
80103e03:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103e06:	6a 0a                	push   $0xa
80103e08:	6a 20                	push   $0x20
80103e0a:	e8 ca fe ff ff       	call   80103cd9 <outb>
80103e0f:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80103e12:	6a 68                	push   $0x68
80103e14:	68 a0 00 00 00       	push   $0xa0
80103e19:	e8 bb fe ff ff       	call   80103cd9 <outb>
80103e1e:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80103e21:	6a 0a                	push   $0xa
80103e23:	68 a0 00 00 00       	push   $0xa0
80103e28:	e8 ac fe ff ff       	call   80103cd9 <outb>
80103e2d:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80103e30:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e37:	66 83 f8 ff          	cmp    $0xffff,%ax
80103e3b:	74 13                	je     80103e50 <picinit+0xe6>
    picsetmask(irqmask);
80103e3d:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e44:	0f b7 c0             	movzwl %ax,%eax
80103e47:	50                   	push   %eax
80103e48:	e8 ab fe ff ff       	call   80103cf8 <picsetmask>
80103e4d:	83 c4 04             	add    $0x4,%esp
}
80103e50:	90                   	nop
80103e51:	c9                   	leave  
80103e52:	c3                   	ret    

80103e53 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103e53:	55                   	push   %ebp
80103e54:	89 e5                	mov    %esp,%ebp
80103e56:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103e59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103e60:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e63:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103e69:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e6c:	8b 10                	mov    (%eax),%edx
80103e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e71:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103e73:	e8 0b d3 ff ff       	call   80101183 <filealloc>
80103e78:	89 c2                	mov    %eax,%edx
80103e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7d:	89 10                	mov    %edx,(%eax)
80103e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e82:	8b 00                	mov    (%eax),%eax
80103e84:	85 c0                	test   %eax,%eax
80103e86:	0f 84 cb 00 00 00    	je     80103f57 <pipealloc+0x104>
80103e8c:	e8 f2 d2 ff ff       	call   80101183 <filealloc>
80103e91:	89 c2                	mov    %eax,%edx
80103e93:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e96:	89 10                	mov    %edx,(%eax)
80103e98:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e9b:	8b 00                	mov    (%eax),%eax
80103e9d:	85 c0                	test   %eax,%eax
80103e9f:	0f 84 b2 00 00 00    	je     80103f57 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103ea5:	e8 26 ef ff ff       	call   80102dd0 <kalloc>
80103eaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ead:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103eb1:	0f 84 9f 00 00 00    	je     80103f56 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80103eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eba:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ec1:	00 00 00 
  p->writeopen = 1;
80103ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec7:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ece:	00 00 00 
  p->nwrite = 0;
80103ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed4:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103edb:	00 00 00 
  p->nread = 0;
80103ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee1:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ee8:	00 00 00 
  initlock(&p->lock, "pipe");
80103eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eee:	83 ec 08             	sub    $0x8,%esp
80103ef1:	68 58 86 10 80       	push   $0x80108658
80103ef6:	50                   	push   %eax
80103ef7:	e8 b4 0e 00 00       	call   80104db0 <initlock>
80103efc:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103eff:	8b 45 08             	mov    0x8(%ebp),%eax
80103f02:	8b 00                	mov    (%eax),%eax
80103f04:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0d:	8b 00                	mov    (%eax),%eax
80103f0f:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103f13:	8b 45 08             	mov    0x8(%ebp),%eax
80103f16:	8b 00                	mov    (%eax),%eax
80103f18:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103f1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1f:	8b 00                	mov    (%eax),%eax
80103f21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f24:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103f27:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f2a:	8b 00                	mov    (%eax),%eax
80103f2c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103f32:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f35:	8b 00                	mov    (%eax),%eax
80103f37:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f3e:	8b 00                	mov    (%eax),%eax
80103f40:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103f44:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f47:	8b 00                	mov    (%eax),%eax
80103f49:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f4c:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103f4f:	b8 00 00 00 00       	mov    $0x0,%eax
80103f54:	eb 4e                	jmp    80103fa4 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103f56:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103f57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f5b:	74 0e                	je     80103f6b <pipealloc+0x118>
    kfree((char*)p);
80103f5d:	83 ec 0c             	sub    $0xc,%esp
80103f60:	ff 75 f4             	pushl  -0xc(%ebp)
80103f63:	e8 cb ed ff ff       	call   80102d33 <kfree>
80103f68:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6e:	8b 00                	mov    (%eax),%eax
80103f70:	85 c0                	test   %eax,%eax
80103f72:	74 11                	je     80103f85 <pipealloc+0x132>
    fileclose(*f0);
80103f74:	8b 45 08             	mov    0x8(%ebp),%eax
80103f77:	8b 00                	mov    (%eax),%eax
80103f79:	83 ec 0c             	sub    $0xc,%esp
80103f7c:	50                   	push   %eax
80103f7d:	e8 bf d2 ff ff       	call   80101241 <fileclose>
80103f82:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103f85:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f88:	8b 00                	mov    (%eax),%eax
80103f8a:	85 c0                	test   %eax,%eax
80103f8c:	74 11                	je     80103f9f <pipealloc+0x14c>
    fileclose(*f1);
80103f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f91:	8b 00                	mov    (%eax),%eax
80103f93:	83 ec 0c             	sub    $0xc,%esp
80103f96:	50                   	push   %eax
80103f97:	e8 a5 d2 ff ff       	call   80101241 <fileclose>
80103f9c:	83 c4 10             	add    $0x10,%esp
  return -1;
80103f9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103fa4:	c9                   	leave  
80103fa5:	c3                   	ret    

80103fa6 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103fa6:	55                   	push   %ebp
80103fa7:	89 e5                	mov    %esp,%ebp
80103fa9:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103fac:	8b 45 08             	mov    0x8(%ebp),%eax
80103faf:	83 ec 0c             	sub    $0xc,%esp
80103fb2:	50                   	push   %eax
80103fb3:	e8 1a 0e 00 00       	call   80104dd2 <acquire>
80103fb8:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103fbb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103fbf:	74 23                	je     80103fe4 <pipeclose+0x3e>
    p->writeopen = 0;
80103fc1:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc4:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103fcb:	00 00 00 
    wakeup(&p->nread);
80103fce:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd1:	05 34 02 00 00       	add    $0x234,%eax
80103fd6:	83 ec 0c             	sub    $0xc,%esp
80103fd9:	50                   	push   %eax
80103fda:	e8 e5 0b 00 00       	call   80104bc4 <wakeup>
80103fdf:	83 c4 10             	add    $0x10,%esp
80103fe2:	eb 21                	jmp    80104005 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe7:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103fee:	00 00 00 
    wakeup(&p->nwrite);
80103ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff4:	05 38 02 00 00       	add    $0x238,%eax
80103ff9:	83 ec 0c             	sub    $0xc,%esp
80103ffc:	50                   	push   %eax
80103ffd:	e8 c2 0b 00 00       	call   80104bc4 <wakeup>
80104002:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104005:	8b 45 08             	mov    0x8(%ebp),%eax
80104008:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010400e:	85 c0                	test   %eax,%eax
80104010:	75 2c                	jne    8010403e <pipeclose+0x98>
80104012:	8b 45 08             	mov    0x8(%ebp),%eax
80104015:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010401b:	85 c0                	test   %eax,%eax
8010401d:	75 1f                	jne    8010403e <pipeclose+0x98>
    release(&p->lock);
8010401f:	8b 45 08             	mov    0x8(%ebp),%eax
80104022:	83 ec 0c             	sub    $0xc,%esp
80104025:	50                   	push   %eax
80104026:	e8 0e 0e 00 00       	call   80104e39 <release>
8010402b:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010402e:	83 ec 0c             	sub    $0xc,%esp
80104031:	ff 75 08             	pushl  0x8(%ebp)
80104034:	e8 fa ec ff ff       	call   80102d33 <kfree>
80104039:	83 c4 10             	add    $0x10,%esp
8010403c:	eb 0f                	jmp    8010404d <pipeclose+0xa7>
  } else
    release(&p->lock);
8010403e:	8b 45 08             	mov    0x8(%ebp),%eax
80104041:	83 ec 0c             	sub    $0xc,%esp
80104044:	50                   	push   %eax
80104045:	e8 ef 0d 00 00       	call   80104e39 <release>
8010404a:	83 c4 10             	add    $0x10,%esp
}
8010404d:	90                   	nop
8010404e:	c9                   	leave  
8010404f:	c3                   	ret    

80104050 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104050:	55                   	push   %ebp
80104051:	89 e5                	mov    %esp,%ebp
80104053:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104056:	8b 45 08             	mov    0x8(%ebp),%eax
80104059:	83 ec 0c             	sub    $0xc,%esp
8010405c:	50                   	push   %eax
8010405d:	e8 70 0d 00 00       	call   80104dd2 <acquire>
80104062:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104065:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010406c:	e9 ad 00 00 00       	jmp    8010411e <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104071:	8b 45 08             	mov    0x8(%ebp),%eax
80104074:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010407a:	85 c0                	test   %eax,%eax
8010407c:	74 0d                	je     8010408b <pipewrite+0x3b>
8010407e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104084:	8b 40 24             	mov    0x24(%eax),%eax
80104087:	85 c0                	test   %eax,%eax
80104089:	74 19                	je     801040a4 <pipewrite+0x54>
        release(&p->lock);
8010408b:	8b 45 08             	mov    0x8(%ebp),%eax
8010408e:	83 ec 0c             	sub    $0xc,%esp
80104091:	50                   	push   %eax
80104092:	e8 a2 0d 00 00       	call   80104e39 <release>
80104097:	83 c4 10             	add    $0x10,%esp
        return -1;
8010409a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010409f:	e9 a8 00 00 00       	jmp    8010414c <pipewrite+0xfc>
      }
      wakeup(&p->nread);
801040a4:	8b 45 08             	mov    0x8(%ebp),%eax
801040a7:	05 34 02 00 00       	add    $0x234,%eax
801040ac:	83 ec 0c             	sub    $0xc,%esp
801040af:	50                   	push   %eax
801040b0:	e8 0f 0b 00 00       	call   80104bc4 <wakeup>
801040b5:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801040b8:	8b 45 08             	mov    0x8(%ebp),%eax
801040bb:	8b 55 08             	mov    0x8(%ebp),%edx
801040be:	81 c2 38 02 00 00    	add    $0x238,%edx
801040c4:	83 ec 08             	sub    $0x8,%esp
801040c7:	50                   	push   %eax
801040c8:	52                   	push   %edx
801040c9:	e8 0b 0a 00 00       	call   80104ad9 <sleep>
801040ce:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040d1:	8b 45 08             	mov    0x8(%ebp),%eax
801040d4:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801040da:	8b 45 08             	mov    0x8(%ebp),%eax
801040dd:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040e3:	05 00 02 00 00       	add    $0x200,%eax
801040e8:	39 c2                	cmp    %eax,%edx
801040ea:	74 85                	je     80104071 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801040ec:	8b 45 08             	mov    0x8(%ebp),%eax
801040ef:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040f5:	8d 48 01             	lea    0x1(%eax),%ecx
801040f8:	8b 55 08             	mov    0x8(%ebp),%edx
801040fb:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104101:	25 ff 01 00 00       	and    $0x1ff,%eax
80104106:	89 c1                	mov    %eax,%ecx
80104108:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010410b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010410e:	01 d0                	add    %edx,%eax
80104110:	0f b6 10             	movzbl (%eax),%edx
80104113:	8b 45 08             	mov    0x8(%ebp),%eax
80104116:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010411a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010411e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104121:	3b 45 10             	cmp    0x10(%ebp),%eax
80104124:	7c ab                	jl     801040d1 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104126:	8b 45 08             	mov    0x8(%ebp),%eax
80104129:	05 34 02 00 00       	add    $0x234,%eax
8010412e:	83 ec 0c             	sub    $0xc,%esp
80104131:	50                   	push   %eax
80104132:	e8 8d 0a 00 00       	call   80104bc4 <wakeup>
80104137:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010413a:	8b 45 08             	mov    0x8(%ebp),%eax
8010413d:	83 ec 0c             	sub    $0xc,%esp
80104140:	50                   	push   %eax
80104141:	e8 f3 0c 00 00       	call   80104e39 <release>
80104146:	83 c4 10             	add    $0x10,%esp
  return n;
80104149:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010414c:	c9                   	leave  
8010414d:	c3                   	ret    

8010414e <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010414e:	55                   	push   %ebp
8010414f:	89 e5                	mov    %esp,%ebp
80104151:	53                   	push   %ebx
80104152:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104155:	8b 45 08             	mov    0x8(%ebp),%eax
80104158:	83 ec 0c             	sub    $0xc,%esp
8010415b:	50                   	push   %eax
8010415c:	e8 71 0c 00 00       	call   80104dd2 <acquire>
80104161:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104164:	eb 3f                	jmp    801041a5 <piperead+0x57>
    if(proc->killed){
80104166:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010416c:	8b 40 24             	mov    0x24(%eax),%eax
8010416f:	85 c0                	test   %eax,%eax
80104171:	74 19                	je     8010418c <piperead+0x3e>
      release(&p->lock);
80104173:	8b 45 08             	mov    0x8(%ebp),%eax
80104176:	83 ec 0c             	sub    $0xc,%esp
80104179:	50                   	push   %eax
8010417a:	e8 ba 0c 00 00       	call   80104e39 <release>
8010417f:	83 c4 10             	add    $0x10,%esp
      return -1;
80104182:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104187:	e9 bf 00 00 00       	jmp    8010424b <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010418c:	8b 45 08             	mov    0x8(%ebp),%eax
8010418f:	8b 55 08             	mov    0x8(%ebp),%edx
80104192:	81 c2 34 02 00 00    	add    $0x234,%edx
80104198:	83 ec 08             	sub    $0x8,%esp
8010419b:	50                   	push   %eax
8010419c:	52                   	push   %edx
8010419d:	e8 37 09 00 00       	call   80104ad9 <sleep>
801041a2:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041a5:	8b 45 08             	mov    0x8(%ebp),%eax
801041a8:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041ae:	8b 45 08             	mov    0x8(%ebp),%eax
801041b1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041b7:	39 c2                	cmp    %eax,%edx
801041b9:	75 0d                	jne    801041c8 <piperead+0x7a>
801041bb:	8b 45 08             	mov    0x8(%ebp),%eax
801041be:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041c4:	85 c0                	test   %eax,%eax
801041c6:	75 9e                	jne    80104166 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801041c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041cf:	eb 49                	jmp    8010421a <piperead+0xcc>
    if(p->nread == p->nwrite)
801041d1:	8b 45 08             	mov    0x8(%ebp),%eax
801041d4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041da:	8b 45 08             	mov    0x8(%ebp),%eax
801041dd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041e3:	39 c2                	cmp    %eax,%edx
801041e5:	74 3d                	je     80104224 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801041e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ed:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801041f0:	8b 45 08             	mov    0x8(%ebp),%eax
801041f3:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041f9:	8d 48 01             	lea    0x1(%eax),%ecx
801041fc:	8b 55 08             	mov    0x8(%ebp),%edx
801041ff:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104205:	25 ff 01 00 00       	and    $0x1ff,%eax
8010420a:	89 c2                	mov    %eax,%edx
8010420c:	8b 45 08             	mov    0x8(%ebp),%eax
8010420f:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104214:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104216:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010421a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421d:	3b 45 10             	cmp    0x10(%ebp),%eax
80104220:	7c af                	jl     801041d1 <piperead+0x83>
80104222:	eb 01                	jmp    80104225 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104224:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104225:	8b 45 08             	mov    0x8(%ebp),%eax
80104228:	05 38 02 00 00       	add    $0x238,%eax
8010422d:	83 ec 0c             	sub    $0xc,%esp
80104230:	50                   	push   %eax
80104231:	e8 8e 09 00 00       	call   80104bc4 <wakeup>
80104236:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104239:	8b 45 08             	mov    0x8(%ebp),%eax
8010423c:	83 ec 0c             	sub    $0xc,%esp
8010423f:	50                   	push   %eax
80104240:	e8 f4 0b 00 00       	call   80104e39 <release>
80104245:	83 c4 10             	add    $0x10,%esp
  return i;
80104248:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010424b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010424e:	c9                   	leave  
8010424f:	c3                   	ret    

80104250 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104250:	55                   	push   %ebp
80104251:	89 e5                	mov    %esp,%ebp
80104253:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104256:	9c                   	pushf  
80104257:	58                   	pop    %eax
80104258:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010425b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010425e:	c9                   	leave  
8010425f:	c3                   	ret    

80104260 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104260:	55                   	push   %ebp
80104261:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104263:	fb                   	sti    
}
80104264:	90                   	nop
80104265:	5d                   	pop    %ebp
80104266:	c3                   	ret    

80104267 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104267:	55                   	push   %ebp
80104268:	89 e5                	mov    %esp,%ebp
8010426a:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010426d:	83 ec 08             	sub    $0x8,%esp
80104270:	68 5d 86 10 80       	push   $0x8010865d
80104275:	68 40 ff 10 80       	push   $0x8010ff40
8010427a:	e8 31 0b 00 00       	call   80104db0 <initlock>
8010427f:	83 c4 10             	add    $0x10,%esp
}
80104282:	90                   	nop
80104283:	c9                   	leave  
80104284:	c3                   	ret    

80104285 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104285:	55                   	push   %ebp
80104286:	89 e5                	mov    %esp,%ebp
80104288:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010428b:	83 ec 0c             	sub    $0xc,%esp
8010428e:	68 40 ff 10 80       	push   $0x8010ff40
80104293:	e8 3a 0b 00 00       	call   80104dd2 <acquire>
80104298:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010429b:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
801042a2:	eb 0e                	jmp    801042b2 <allocproc+0x2d>
    if(p->state == UNUSED)
801042a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a7:	8b 40 0c             	mov    0xc(%eax),%eax
801042aa:	85 c0                	test   %eax,%eax
801042ac:	74 27                	je     801042d5 <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042ae:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801042b2:	81 7d f4 74 1e 11 80 	cmpl   $0x80111e74,-0xc(%ebp)
801042b9:	72 e9                	jb     801042a4 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801042bb:	83 ec 0c             	sub    $0xc,%esp
801042be:	68 40 ff 10 80       	push   $0x8010ff40
801042c3:	e8 71 0b 00 00       	call   80104e39 <release>
801042c8:	83 c4 10             	add    $0x10,%esp
  return 0;
801042cb:	b8 00 00 00 00       	mov    $0x0,%eax
801042d0:	e9 b4 00 00 00       	jmp    80104389 <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801042d5:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801042d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d9:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801042e0:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801042e5:	8d 50 01             	lea    0x1(%eax),%edx
801042e8:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801042ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042f1:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801042f4:	83 ec 0c             	sub    $0xc,%esp
801042f7:	68 40 ff 10 80       	push   $0x8010ff40
801042fc:	e8 38 0b 00 00       	call   80104e39 <release>
80104301:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104304:	e8 c7 ea ff ff       	call   80102dd0 <kalloc>
80104309:	89 c2                	mov    %eax,%edx
8010430b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430e:	89 50 08             	mov    %edx,0x8(%eax)
80104311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104314:	8b 40 08             	mov    0x8(%eax),%eax
80104317:	85 c0                	test   %eax,%eax
80104319:	75 11                	jne    8010432c <allocproc+0xa7>
    p->state = UNUSED;
8010431b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010431e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104325:	b8 00 00 00 00       	mov    $0x0,%eax
8010432a:	eb 5d                	jmp    80104389 <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
8010432c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432f:	8b 40 08             	mov    0x8(%eax),%eax
80104332:	05 00 10 00 00       	add    $0x1000,%eax
80104337:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010433a:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010433e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104341:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104344:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104347:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010434b:	ba a9 64 10 80       	mov    $0x801064a9,%edx
80104350:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104353:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104355:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010435f:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104365:	8b 40 1c             	mov    0x1c(%eax),%eax
80104368:	83 ec 04             	sub    $0x4,%esp
8010436b:	6a 14                	push   $0x14
8010436d:	6a 00                	push   $0x0
8010436f:	50                   	push   %eax
80104370:	e8 c0 0c 00 00       	call   80105035 <memset>
80104375:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010437e:	ba a8 4a 10 80       	mov    $0x80104aa8,%edx
80104383:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104386:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104389:	c9                   	leave  
8010438a:	c3                   	ret    

8010438b <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010438b:	55                   	push   %ebp
8010438c:	89 e5                	mov    %esp,%ebp
8010438e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104391:	e8 ef fe ff ff       	call   80104285 <allocproc>
80104396:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439c:	a3 68 b6 10 80       	mov    %eax,0x8010b668
  if((p->pgdir = setupkvm()) == 0)
801043a1:	e8 c8 37 00 00       	call   80107b6e <setupkvm>
801043a6:	89 c2                	mov    %eax,%edx
801043a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ab:	89 50 04             	mov    %edx,0x4(%eax)
801043ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b1:	8b 40 04             	mov    0x4(%eax),%eax
801043b4:	85 c0                	test   %eax,%eax
801043b6:	75 0d                	jne    801043c5 <userinit+0x3a>
    panic("userinit: out of memory?");
801043b8:	83 ec 0c             	sub    $0xc,%esp
801043bb:	68 64 86 10 80       	push   $0x80108664
801043c0:	e8 a1 c1 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801043c5:	ba 2c 00 00 00       	mov    $0x2c,%edx
801043ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cd:	8b 40 04             	mov    0x4(%eax),%eax
801043d0:	83 ec 04             	sub    $0x4,%esp
801043d3:	52                   	push   %edx
801043d4:	68 00 b5 10 80       	push   $0x8010b500
801043d9:	50                   	push   %eax
801043da:	e8 e9 39 00 00       	call   80107dc8 <inituvm>
801043df:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801043e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801043eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ee:	8b 40 18             	mov    0x18(%eax),%eax
801043f1:	83 ec 04             	sub    $0x4,%esp
801043f4:	6a 4c                	push   $0x4c
801043f6:	6a 00                	push   $0x0
801043f8:	50                   	push   %eax
801043f9:	e8 37 0c 00 00       	call   80105035 <memset>
801043fe:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104404:	8b 40 18             	mov    0x18(%eax),%eax
80104407:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010440d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104410:	8b 40 18             	mov    0x18(%eax),%eax
80104413:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441c:	8b 40 18             	mov    0x18(%eax),%eax
8010441f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104422:	8b 52 18             	mov    0x18(%edx),%edx
80104425:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104429:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010442d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104430:	8b 40 18             	mov    0x18(%eax),%eax
80104433:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104436:	8b 52 18             	mov    0x18(%edx),%edx
80104439:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010443d:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104444:	8b 40 18             	mov    0x18(%eax),%eax
80104447:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010444e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104451:	8b 40 18             	mov    0x18(%eax),%eax
80104454:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010445b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445e:	8b 40 18             	mov    0x18(%eax),%eax
80104461:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446b:	83 c0 6c             	add    $0x6c,%eax
8010446e:	83 ec 04             	sub    $0x4,%esp
80104471:	6a 10                	push   $0x10
80104473:	68 7d 86 10 80       	push   $0x8010867d
80104478:	50                   	push   %eax
80104479:	e8 ba 0d 00 00       	call   80105238 <safestrcpy>
8010447e:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104481:	83 ec 0c             	sub    $0xc,%esp
80104484:	68 86 86 10 80       	push   $0x80108686
80104489:	e8 40 e2 ff ff       	call   801026ce <namei>
8010448e:	83 c4 10             	add    $0x10,%esp
80104491:	89 c2                	mov    %eax,%edx
80104493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104496:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
80104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801044a3:	90                   	nop
801044a4:	c9                   	leave  
801044a5:	c3                   	ret    

801044a6 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801044a6:	55                   	push   %ebp
801044a7:	89 e5                	mov    %esp,%ebp
801044a9:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801044ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044b2:	8b 00                	mov    (%eax),%eax
801044b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801044b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801044bb:	7e 31                	jle    801044ee <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801044bd:	8b 55 08             	mov    0x8(%ebp),%edx
801044c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c3:	01 c2                	add    %eax,%edx
801044c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044cb:	8b 40 04             	mov    0x4(%eax),%eax
801044ce:	83 ec 04             	sub    $0x4,%esp
801044d1:	52                   	push   %edx
801044d2:	ff 75 f4             	pushl  -0xc(%ebp)
801044d5:	50                   	push   %eax
801044d6:	e8 3a 3a 00 00       	call   80107f15 <allocuvm>
801044db:	83 c4 10             	add    $0x10,%esp
801044de:	89 45 f4             	mov    %eax,-0xc(%ebp)
801044e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044e5:	75 3e                	jne    80104525 <growproc+0x7f>
      return -1;
801044e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ec:	eb 59                	jmp    80104547 <growproc+0xa1>
  } else if(n < 0){
801044ee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801044f2:	79 31                	jns    80104525 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801044f4:	8b 55 08             	mov    0x8(%ebp),%edx
801044f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fa:	01 c2                	add    %eax,%edx
801044fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104502:	8b 40 04             	mov    0x4(%eax),%eax
80104505:	83 ec 04             	sub    $0x4,%esp
80104508:	52                   	push   %edx
80104509:	ff 75 f4             	pushl  -0xc(%ebp)
8010450c:	50                   	push   %eax
8010450d:	e8 cc 3a 00 00       	call   80107fde <deallocuvm>
80104512:	83 c4 10             	add    $0x10,%esp
80104515:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104518:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010451c:	75 07                	jne    80104525 <growproc+0x7f>
      return -1;
8010451e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104523:	eb 22                	jmp    80104547 <growproc+0xa1>
  }
  proc->sz = sz;
80104525:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010452b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010452e:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104530:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104536:	83 ec 0c             	sub    $0xc,%esp
80104539:	50                   	push   %eax
8010453a:	e8 16 37 00 00       	call   80107c55 <switchuvm>
8010453f:	83 c4 10             	add    $0x10,%esp
  return 0;
80104542:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104547:	c9                   	leave  
80104548:	c3                   	ret    

80104549 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104549:	55                   	push   %ebp
8010454a:	89 e5                	mov    %esp,%ebp
8010454c:	57                   	push   %edi
8010454d:	56                   	push   %esi
8010454e:	53                   	push   %ebx
8010454f:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104552:	e8 2e fd ff ff       	call   80104285 <allocproc>
80104557:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010455a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010455e:	75 0a                	jne    8010456a <fork+0x21>
    return -1;
80104560:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104565:	e9 48 01 00 00       	jmp    801046b2 <fork+0x169>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010456a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104570:	8b 10                	mov    (%eax),%edx
80104572:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104578:	8b 40 04             	mov    0x4(%eax),%eax
8010457b:	83 ec 08             	sub    $0x8,%esp
8010457e:	52                   	push   %edx
8010457f:	50                   	push   %eax
80104580:	e8 f7 3b 00 00       	call   8010817c <copyuvm>
80104585:	83 c4 10             	add    $0x10,%esp
80104588:	89 c2                	mov    %eax,%edx
8010458a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010458d:	89 50 04             	mov    %edx,0x4(%eax)
80104590:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104593:	8b 40 04             	mov    0x4(%eax),%eax
80104596:	85 c0                	test   %eax,%eax
80104598:	75 30                	jne    801045ca <fork+0x81>
    kfree(np->kstack);
8010459a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010459d:	8b 40 08             	mov    0x8(%eax),%eax
801045a0:	83 ec 0c             	sub    $0xc,%esp
801045a3:	50                   	push   %eax
801045a4:	e8 8a e7 ff ff       	call   80102d33 <kfree>
801045a9:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801045ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045af:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801045b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045b9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801045c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045c5:	e9 e8 00 00 00       	jmp    801046b2 <fork+0x169>
  }
  np->sz = proc->sz;
801045ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045d0:	8b 10                	mov    (%eax),%edx
801045d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045d5:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801045d7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801045de:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045e1:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801045e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045e7:	8b 50 18             	mov    0x18(%eax),%edx
801045ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045f0:	8b 40 18             	mov    0x18(%eax),%eax
801045f3:	89 c3                	mov    %eax,%ebx
801045f5:	b8 13 00 00 00       	mov    $0x13,%eax
801045fa:	89 d7                	mov    %edx,%edi
801045fc:	89 de                	mov    %ebx,%esi
801045fe:	89 c1                	mov    %eax,%ecx
80104600:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104602:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104605:	8b 40 18             	mov    0x18(%eax),%eax
80104608:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010460f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104616:	eb 43                	jmp    8010465b <fork+0x112>
    if(proc->ofile[i])
80104618:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010461e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104621:	83 c2 08             	add    $0x8,%edx
80104624:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104628:	85 c0                	test   %eax,%eax
8010462a:	74 2b                	je     80104657 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
8010462c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104632:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104635:	83 c2 08             	add    $0x8,%edx
80104638:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010463c:	83 ec 0c             	sub    $0xc,%esp
8010463f:	50                   	push   %eax
80104640:	e8 ab cb ff ff       	call   801011f0 <filedup>
80104645:	83 c4 10             	add    $0x10,%esp
80104648:	89 c1                	mov    %eax,%ecx
8010464a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010464d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104650:	83 c2 08             	add    $0x8,%edx
80104653:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104657:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010465b:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010465f:	7e b7                	jle    80104618 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104661:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104667:	8b 40 68             	mov    0x68(%eax),%eax
8010466a:	83 ec 0c             	sub    $0xc,%esp
8010466d:	50                   	push   %eax
8010466e:	e8 69 d4 ff ff       	call   80101adc <idup>
80104673:	83 c4 10             	add    $0x10,%esp
80104676:	89 c2                	mov    %eax,%edx
80104678:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010467b:	89 50 68             	mov    %edx,0x68(%eax)
 
  pid = np->pid;
8010467e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104681:	8b 40 10             	mov    0x10(%eax),%eax
80104684:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104687:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104691:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104697:	8d 50 6c             	lea    0x6c(%eax),%edx
8010469a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010469d:	83 c0 6c             	add    $0x6c,%eax
801046a0:	83 ec 04             	sub    $0x4,%esp
801046a3:	6a 10                	push   $0x10
801046a5:	52                   	push   %edx
801046a6:	50                   	push   %eax
801046a7:	e8 8c 0b 00 00       	call   80105238 <safestrcpy>
801046ac:	83 c4 10             	add    $0x10,%esp
  return pid;
801046af:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801046b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801046b5:	5b                   	pop    %ebx
801046b6:	5e                   	pop    %esi
801046b7:	5f                   	pop    %edi
801046b8:	5d                   	pop    %ebp
801046b9:	c3                   	ret    

801046ba <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801046ba:	55                   	push   %ebp
801046bb:	89 e5                	mov    %esp,%ebp
801046bd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801046c0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046c7:	a1 68 b6 10 80       	mov    0x8010b668,%eax
801046cc:	39 c2                	cmp    %eax,%edx
801046ce:	75 0d                	jne    801046dd <exit+0x23>
    panic("init exiting");
801046d0:	83 ec 0c             	sub    $0xc,%esp
801046d3:	68 88 86 10 80       	push   $0x80108688
801046d8:	e8 89 be ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801046dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801046e4:	eb 48                	jmp    8010472e <exit+0x74>
    if(proc->ofile[fd]){
801046e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046ef:	83 c2 08             	add    $0x8,%edx
801046f2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046f6:	85 c0                	test   %eax,%eax
801046f8:	74 30                	je     8010472a <exit+0x70>
      fileclose(proc->ofile[fd]);
801046fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104700:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104703:	83 c2 08             	add    $0x8,%edx
80104706:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010470a:	83 ec 0c             	sub    $0xc,%esp
8010470d:	50                   	push   %eax
8010470e:	e8 2e cb ff ff       	call   80101241 <fileclose>
80104713:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104716:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010471c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010471f:	83 c2 08             	add    $0x8,%edx
80104722:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104729:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010472a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010472e:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104732:	7e b2                	jle    801046e6 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104734:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473a:	8b 40 68             	mov    0x68(%eax),%eax
8010473d:	83 ec 0c             	sub    $0xc,%esp
80104740:	50                   	push   %eax
80104741:	e8 9a d5 ff ff       	call   80101ce0 <iput>
80104746:	83 c4 10             	add    $0x10,%esp
  proc->cwd = 0;
80104749:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010474f:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104756:	83 ec 0c             	sub    $0xc,%esp
80104759:	68 40 ff 10 80       	push   $0x8010ff40
8010475e:	e8 6f 06 00 00       	call   80104dd2 <acquire>
80104763:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104766:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476c:	8b 40 14             	mov    0x14(%eax),%eax
8010476f:	83 ec 0c             	sub    $0xc,%esp
80104772:	50                   	push   %eax
80104773:	e8 0d 04 00 00       	call   80104b85 <wakeup1>
80104778:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010477b:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104782:	eb 3c                	jmp    801047c0 <exit+0x106>
    if(p->parent == proc){
80104784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104787:	8b 50 14             	mov    0x14(%eax),%edx
8010478a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104790:	39 c2                	cmp    %eax,%edx
80104792:	75 28                	jne    801047bc <exit+0x102>
      p->parent = initproc;
80104794:	8b 15 68 b6 10 80    	mov    0x8010b668,%edx
8010479a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479d:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801047a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a3:	8b 40 0c             	mov    0xc(%eax),%eax
801047a6:	83 f8 05             	cmp    $0x5,%eax
801047a9:	75 11                	jne    801047bc <exit+0x102>
        wakeup1(initproc);
801047ab:	a1 68 b6 10 80       	mov    0x8010b668,%eax
801047b0:	83 ec 0c             	sub    $0xc,%esp
801047b3:	50                   	push   %eax
801047b4:	e8 cc 03 00 00       	call   80104b85 <wakeup1>
801047b9:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047bc:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801047c0:	81 7d f4 74 1e 11 80 	cmpl   $0x80111e74,-0xc(%ebp)
801047c7:	72 bb                	jb     80104784 <exit+0xca>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801047c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047cf:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801047d6:	e8 d6 01 00 00       	call   801049b1 <sched>
  panic("zombie exit");
801047db:	83 ec 0c             	sub    $0xc,%esp
801047de:	68 95 86 10 80       	push   $0x80108695
801047e3:	e8 7e bd ff ff       	call   80100566 <panic>

801047e8 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801047e8:	55                   	push   %ebp
801047e9:	89 e5                	mov    %esp,%ebp
801047eb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801047ee:	83 ec 0c             	sub    $0xc,%esp
801047f1:	68 40 ff 10 80       	push   $0x8010ff40
801047f6:	e8 d7 05 00 00       	call   80104dd2 <acquire>
801047fb:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801047fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104805:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
8010480c:	e9 a6 00 00 00       	jmp    801048b7 <wait+0xcf>
      if(p->parent != proc)
80104811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104814:	8b 50 14             	mov    0x14(%eax),%edx
80104817:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481d:	39 c2                	cmp    %eax,%edx
8010481f:	0f 85 8d 00 00 00    	jne    801048b2 <wait+0xca>
        continue;
      havekids = 1;
80104825:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010482c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482f:	8b 40 0c             	mov    0xc(%eax),%eax
80104832:	83 f8 05             	cmp    $0x5,%eax
80104835:	75 7c                	jne    801048b3 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483a:	8b 40 10             	mov    0x10(%eax),%eax
8010483d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104843:	8b 40 08             	mov    0x8(%eax),%eax
80104846:	83 ec 0c             	sub    $0xc,%esp
80104849:	50                   	push   %eax
8010484a:	e8 e4 e4 ff ff       	call   80102d33 <kfree>
8010484f:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104855:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010485c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485f:	8b 40 04             	mov    0x4(%eax),%eax
80104862:	83 ec 0c             	sub    $0xc,%esp
80104865:	50                   	push   %eax
80104866:	e8 30 38 00 00       	call   8010809b <freevm>
8010486b:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
8010486e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104871:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487b:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104885:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010488c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488f:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104896:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
8010489d:	83 ec 0c             	sub    $0xc,%esp
801048a0:	68 40 ff 10 80       	push   $0x8010ff40
801048a5:	e8 8f 05 00 00       	call   80104e39 <release>
801048aa:	83 c4 10             	add    $0x10,%esp
        return pid;
801048ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048b0:	eb 58                	jmp    8010490a <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801048b2:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048b3:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801048b7:	81 7d f4 74 1e 11 80 	cmpl   $0x80111e74,-0xc(%ebp)
801048be:	0f 82 4d ff ff ff    	jb     80104811 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801048c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801048c8:	74 0d                	je     801048d7 <wait+0xef>
801048ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d0:	8b 40 24             	mov    0x24(%eax),%eax
801048d3:	85 c0                	test   %eax,%eax
801048d5:	74 17                	je     801048ee <wait+0x106>
      release(&ptable.lock);
801048d7:	83 ec 0c             	sub    $0xc,%esp
801048da:	68 40 ff 10 80       	push   $0x8010ff40
801048df:	e8 55 05 00 00       	call   80104e39 <release>
801048e4:	83 c4 10             	add    $0x10,%esp
      return -1;
801048e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048ec:	eb 1c                	jmp    8010490a <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801048ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048f4:	83 ec 08             	sub    $0x8,%esp
801048f7:	68 40 ff 10 80       	push   $0x8010ff40
801048fc:	50                   	push   %eax
801048fd:	e8 d7 01 00 00       	call   80104ad9 <sleep>
80104902:	83 c4 10             	add    $0x10,%esp
  }
80104905:	e9 f4 fe ff ff       	jmp    801047fe <wait+0x16>
}
8010490a:	c9                   	leave  
8010490b:	c3                   	ret    

8010490c <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010490c:	55                   	push   %ebp
8010490d:	89 e5                	mov    %esp,%ebp
8010490f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104912:	e8 49 f9 ff ff       	call   80104260 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104917:	83 ec 0c             	sub    $0xc,%esp
8010491a:	68 40 ff 10 80       	push   $0x8010ff40
8010491f:	e8 ae 04 00 00       	call   80104dd2 <acquire>
80104924:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104927:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
8010492e:	eb 63                	jmp    80104993 <scheduler+0x87>
      if(p->state != RUNNABLE)
80104930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104933:	8b 40 0c             	mov    0xc(%eax),%eax
80104936:	83 f8 03             	cmp    $0x3,%eax
80104939:	75 53                	jne    8010498e <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
8010493b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493e:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104944:	83 ec 0c             	sub    $0xc,%esp
80104947:	ff 75 f4             	pushl  -0xc(%ebp)
8010494a:	e8 06 33 00 00       	call   80107c55 <switchuvm>
8010494f:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104955:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
8010495c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104962:	8b 40 1c             	mov    0x1c(%eax),%eax
80104965:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010496c:	83 c2 04             	add    $0x4,%edx
8010496f:	83 ec 08             	sub    $0x8,%esp
80104972:	50                   	push   %eax
80104973:	52                   	push   %edx
80104974:	e8 30 09 00 00       	call   801052a9 <swtch>
80104979:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010497c:	e8 b7 32 00 00       	call   80107c38 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104981:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104988:	00 00 00 00 
8010498c:	eb 01                	jmp    8010498f <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
8010498e:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010498f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104993:	81 7d f4 74 1e 11 80 	cmpl   $0x80111e74,-0xc(%ebp)
8010499a:	72 94                	jb     80104930 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
8010499c:	83 ec 0c             	sub    $0xc,%esp
8010499f:	68 40 ff 10 80       	push   $0x8010ff40
801049a4:	e8 90 04 00 00       	call   80104e39 <release>
801049a9:	83 c4 10             	add    $0x10,%esp

  }
801049ac:	e9 61 ff ff ff       	jmp    80104912 <scheduler+0x6>

801049b1 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801049b1:	55                   	push   %ebp
801049b2:	89 e5                	mov    %esp,%ebp
801049b4:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
801049b7:	83 ec 0c             	sub    $0xc,%esp
801049ba:	68 40 ff 10 80       	push   $0x8010ff40
801049bf:	e8 41 05 00 00       	call   80104f05 <holding>
801049c4:	83 c4 10             	add    $0x10,%esp
801049c7:	85 c0                	test   %eax,%eax
801049c9:	75 0d                	jne    801049d8 <sched+0x27>
    panic("sched ptable.lock");
801049cb:	83 ec 0c             	sub    $0xc,%esp
801049ce:	68 a1 86 10 80       	push   $0x801086a1
801049d3:	e8 8e bb ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
801049d8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801049de:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801049e4:	83 f8 01             	cmp    $0x1,%eax
801049e7:	74 0d                	je     801049f6 <sched+0x45>
    panic("sched locks");
801049e9:	83 ec 0c             	sub    $0xc,%esp
801049ec:	68 b3 86 10 80       	push   $0x801086b3
801049f1:	e8 70 bb ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
801049f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fc:	8b 40 0c             	mov    0xc(%eax),%eax
801049ff:	83 f8 04             	cmp    $0x4,%eax
80104a02:	75 0d                	jne    80104a11 <sched+0x60>
    panic("sched running");
80104a04:	83 ec 0c             	sub    $0xc,%esp
80104a07:	68 bf 86 10 80       	push   $0x801086bf
80104a0c:	e8 55 bb ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104a11:	e8 3a f8 ff ff       	call   80104250 <readeflags>
80104a16:	25 00 02 00 00       	and    $0x200,%eax
80104a1b:	85 c0                	test   %eax,%eax
80104a1d:	74 0d                	je     80104a2c <sched+0x7b>
    panic("sched interruptible");
80104a1f:	83 ec 0c             	sub    $0xc,%esp
80104a22:	68 cd 86 10 80       	push   $0x801086cd
80104a27:	e8 3a bb ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104a2c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a32:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104a38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104a3b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a41:	8b 40 04             	mov    0x4(%eax),%eax
80104a44:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104a4b:	83 c2 1c             	add    $0x1c,%edx
80104a4e:	83 ec 08             	sub    $0x8,%esp
80104a51:	50                   	push   %eax
80104a52:	52                   	push   %edx
80104a53:	e8 51 08 00 00       	call   801052a9 <swtch>
80104a58:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104a5b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a64:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104a6a:	90                   	nop
80104a6b:	c9                   	leave  
80104a6c:	c3                   	ret    

80104a6d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104a6d:	55                   	push   %ebp
80104a6e:	89 e5                	mov    %esp,%ebp
80104a70:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104a73:	83 ec 0c             	sub    $0xc,%esp
80104a76:	68 40 ff 10 80       	push   $0x8010ff40
80104a7b:	e8 52 03 00 00       	call   80104dd2 <acquire>
80104a80:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104a83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a89:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104a90:	e8 1c ff ff ff       	call   801049b1 <sched>
  release(&ptable.lock);
80104a95:	83 ec 0c             	sub    $0xc,%esp
80104a98:	68 40 ff 10 80       	push   $0x8010ff40
80104a9d:	e8 97 03 00 00       	call   80104e39 <release>
80104aa2:	83 c4 10             	add    $0x10,%esp
}
80104aa5:	90                   	nop
80104aa6:	c9                   	leave  
80104aa7:	c3                   	ret    

80104aa8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104aa8:	55                   	push   %ebp
80104aa9:	89 e5                	mov    %esp,%ebp
80104aab:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104aae:	83 ec 0c             	sub    $0xc,%esp
80104ab1:	68 40 ff 10 80       	push   $0x8010ff40
80104ab6:	e8 7e 03 00 00       	call   80104e39 <release>
80104abb:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104abe:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104ac3:	85 c0                	test   %eax,%eax
80104ac5:	74 0f                	je     80104ad6 <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104ac7:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104ace:	00 00 00 
    initlog();
80104ad1:	e8 9e e7 ff ff       	call   80103274 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104ad6:	90                   	nop
80104ad7:	c9                   	leave  
80104ad8:	c3                   	ret    

80104ad9 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104ad9:	55                   	push   %ebp
80104ada:	89 e5                	mov    %esp,%ebp
80104adc:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104adf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ae5:	85 c0                	test   %eax,%eax
80104ae7:	75 0d                	jne    80104af6 <sleep+0x1d>
    panic("sleep");
80104ae9:	83 ec 0c             	sub    $0xc,%esp
80104aec:	68 e1 86 10 80       	push   $0x801086e1
80104af1:	e8 70 ba ff ff       	call   80100566 <panic>

  if(lk == 0)
80104af6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104afa:	75 0d                	jne    80104b09 <sleep+0x30>
    panic("sleep without lk");
80104afc:	83 ec 0c             	sub    $0xc,%esp
80104aff:	68 e7 86 10 80       	push   $0x801086e7
80104b04:	e8 5d ba ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104b09:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104b10:	74 1e                	je     80104b30 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104b12:	83 ec 0c             	sub    $0xc,%esp
80104b15:	68 40 ff 10 80       	push   $0x8010ff40
80104b1a:	e8 b3 02 00 00       	call   80104dd2 <acquire>
80104b1f:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104b22:	83 ec 0c             	sub    $0xc,%esp
80104b25:	ff 75 0c             	pushl  0xc(%ebp)
80104b28:	e8 0c 03 00 00       	call   80104e39 <release>
80104b2d:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104b30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b36:	8b 55 08             	mov    0x8(%ebp),%edx
80104b39:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104b3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b42:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104b49:	e8 63 fe ff ff       	call   801049b1 <sched>

  // Tidy up.
  proc->chan = 0;
80104b4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b54:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104b5b:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104b62:	74 1e                	je     80104b82 <sleep+0xa9>
    release(&ptable.lock);
80104b64:	83 ec 0c             	sub    $0xc,%esp
80104b67:	68 40 ff 10 80       	push   $0x8010ff40
80104b6c:	e8 c8 02 00 00       	call   80104e39 <release>
80104b71:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104b74:	83 ec 0c             	sub    $0xc,%esp
80104b77:	ff 75 0c             	pushl  0xc(%ebp)
80104b7a:	e8 53 02 00 00       	call   80104dd2 <acquire>
80104b7f:	83 c4 10             	add    $0x10,%esp
  }
}
80104b82:	90                   	nop
80104b83:	c9                   	leave  
80104b84:	c3                   	ret    

80104b85 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104b85:	55                   	push   %ebp
80104b86:	89 e5                	mov    %esp,%ebp
80104b88:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b8b:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
80104b92:	eb 24                	jmp    80104bb8 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104b94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b97:	8b 40 0c             	mov    0xc(%eax),%eax
80104b9a:	83 f8 02             	cmp    $0x2,%eax
80104b9d:	75 15                	jne    80104bb4 <wakeup1+0x2f>
80104b9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ba2:	8b 40 20             	mov    0x20(%eax),%eax
80104ba5:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ba8:	75 0a                	jne    80104bb4 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104baa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bad:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bb4:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104bb8:	81 7d fc 74 1e 11 80 	cmpl   $0x80111e74,-0x4(%ebp)
80104bbf:	72 d3                	jb     80104b94 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104bc1:	90                   	nop
80104bc2:	c9                   	leave  
80104bc3:	c3                   	ret    

80104bc4 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104bc4:	55                   	push   %ebp
80104bc5:	89 e5                	mov    %esp,%ebp
80104bc7:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104bca:	83 ec 0c             	sub    $0xc,%esp
80104bcd:	68 40 ff 10 80       	push   $0x8010ff40
80104bd2:	e8 fb 01 00 00       	call   80104dd2 <acquire>
80104bd7:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104bda:	83 ec 0c             	sub    $0xc,%esp
80104bdd:	ff 75 08             	pushl  0x8(%ebp)
80104be0:	e8 a0 ff ff ff       	call   80104b85 <wakeup1>
80104be5:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104be8:	83 ec 0c             	sub    $0xc,%esp
80104beb:	68 40 ff 10 80       	push   $0x8010ff40
80104bf0:	e8 44 02 00 00       	call   80104e39 <release>
80104bf5:	83 c4 10             	add    $0x10,%esp
}
80104bf8:	90                   	nop
80104bf9:	c9                   	leave  
80104bfa:	c3                   	ret    

80104bfb <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104bfb:	55                   	push   %ebp
80104bfc:	89 e5                	mov    %esp,%ebp
80104bfe:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104c01:	83 ec 0c             	sub    $0xc,%esp
80104c04:	68 40 ff 10 80       	push   $0x8010ff40
80104c09:	e8 c4 01 00 00       	call   80104dd2 <acquire>
80104c0e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c11:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104c18:	eb 45                	jmp    80104c5f <kill+0x64>
    if(p->pid == pid){
80104c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1d:	8b 40 10             	mov    0x10(%eax),%eax
80104c20:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c23:	75 36                	jne    80104c5b <kill+0x60>
      p->killed = 1;
80104c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c28:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c32:	8b 40 0c             	mov    0xc(%eax),%eax
80104c35:	83 f8 02             	cmp    $0x2,%eax
80104c38:	75 0a                	jne    80104c44 <kill+0x49>
        p->state = RUNNABLE;
80104c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104c44:	83 ec 0c             	sub    $0xc,%esp
80104c47:	68 40 ff 10 80       	push   $0x8010ff40
80104c4c:	e8 e8 01 00 00       	call   80104e39 <release>
80104c51:	83 c4 10             	add    $0x10,%esp
      return 0;
80104c54:	b8 00 00 00 00       	mov    $0x0,%eax
80104c59:	eb 22                	jmp    80104c7d <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c5b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104c5f:	81 7d f4 74 1e 11 80 	cmpl   $0x80111e74,-0xc(%ebp)
80104c66:	72 b2                	jb     80104c1a <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104c68:	83 ec 0c             	sub    $0xc,%esp
80104c6b:	68 40 ff 10 80       	push   $0x8010ff40
80104c70:	e8 c4 01 00 00       	call   80104e39 <release>
80104c75:	83 c4 10             	add    $0x10,%esp
  return -1;
80104c78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c7d:	c9                   	leave  
80104c7e:	c3                   	ret    

80104c7f <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104c7f:	55                   	push   %ebp
80104c80:	89 e5                	mov    %esp,%ebp
80104c82:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c85:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
80104c8c:	e9 d7 00 00 00       	jmp    80104d68 <procdump+0xe9>
    if(p->state == UNUSED)
80104c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c94:	8b 40 0c             	mov    0xc(%eax),%eax
80104c97:	85 c0                	test   %eax,%eax
80104c99:	0f 84 c4 00 00 00    	je     80104d63 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ca2:	8b 40 0c             	mov    0xc(%eax),%eax
80104ca5:	83 f8 05             	cmp    $0x5,%eax
80104ca8:	77 23                	ja     80104ccd <procdump+0x4e>
80104caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cad:	8b 40 0c             	mov    0xc(%eax),%eax
80104cb0:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104cb7:	85 c0                	test   %eax,%eax
80104cb9:	74 12                	je     80104ccd <procdump+0x4e>
      state = states[p->state];
80104cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cbe:	8b 40 0c             	mov    0xc(%eax),%eax
80104cc1:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104cc8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104ccb:	eb 07                	jmp    80104cd4 <procdump+0x55>
    else
      state = "???";
80104ccd:	c7 45 ec f8 86 10 80 	movl   $0x801086f8,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cd7:	8d 50 6c             	lea    0x6c(%eax),%edx
80104cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cdd:	8b 40 10             	mov    0x10(%eax),%eax
80104ce0:	52                   	push   %edx
80104ce1:	ff 75 ec             	pushl  -0x14(%ebp)
80104ce4:	50                   	push   %eax
80104ce5:	68 fc 86 10 80       	push   $0x801086fc
80104cea:	e8 d7 b6 ff ff       	call   801003c6 <cprintf>
80104cef:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104cf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cf5:	8b 40 0c             	mov    0xc(%eax),%eax
80104cf8:	83 f8 02             	cmp    $0x2,%eax
80104cfb:	75 54                	jne    80104d51 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d00:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d03:	8b 40 0c             	mov    0xc(%eax),%eax
80104d06:	83 c0 08             	add    $0x8,%eax
80104d09:	89 c2                	mov    %eax,%edx
80104d0b:	83 ec 08             	sub    $0x8,%esp
80104d0e:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104d11:	50                   	push   %eax
80104d12:	52                   	push   %edx
80104d13:	e8 73 01 00 00       	call   80104e8b <getcallerpcs>
80104d18:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104d1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d22:	eb 1c                	jmp    80104d40 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d27:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d2b:	83 ec 08             	sub    $0x8,%esp
80104d2e:	50                   	push   %eax
80104d2f:	68 05 87 10 80       	push   $0x80108705
80104d34:	e8 8d b6 ff ff       	call   801003c6 <cprintf>
80104d39:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104d3c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104d40:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104d44:	7f 0b                	jg     80104d51 <procdump+0xd2>
80104d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d49:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d4d:	85 c0                	test   %eax,%eax
80104d4f:	75 d3                	jne    80104d24 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104d51:	83 ec 0c             	sub    $0xc,%esp
80104d54:	68 09 87 10 80       	push   $0x80108709
80104d59:	e8 68 b6 ff ff       	call   801003c6 <cprintf>
80104d5e:	83 c4 10             	add    $0x10,%esp
80104d61:	eb 01                	jmp    80104d64 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104d63:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d64:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104d68:	81 7d f0 74 1e 11 80 	cmpl   $0x80111e74,-0x10(%ebp)
80104d6f:	0f 82 1c ff ff ff    	jb     80104c91 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104d75:	90                   	nop
80104d76:	c9                   	leave  
80104d77:	c3                   	ret    

80104d78 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104d78:	55                   	push   %ebp
80104d79:	89 e5                	mov    %esp,%ebp
80104d7b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d7e:	9c                   	pushf  
80104d7f:	58                   	pop    %eax
80104d80:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104d83:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d86:	c9                   	leave  
80104d87:	c3                   	ret    

80104d88 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104d88:	55                   	push   %ebp
80104d89:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104d8b:	fa                   	cli    
}
80104d8c:	90                   	nop
80104d8d:	5d                   	pop    %ebp
80104d8e:	c3                   	ret    

80104d8f <sti>:

static inline void
sti(void)
{
80104d8f:	55                   	push   %ebp
80104d90:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104d92:	fb                   	sti    
}
80104d93:	90                   	nop
80104d94:	5d                   	pop    %ebp
80104d95:	c3                   	ret    

80104d96 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104d96:	55                   	push   %ebp
80104d97:	89 e5                	mov    %esp,%ebp
80104d99:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104d9c:	8b 55 08             	mov    0x8(%ebp),%edx
80104d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104da2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104da5:	f0 87 02             	lock xchg %eax,(%edx)
80104da8:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104dab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104dae:	c9                   	leave  
80104daf:	c3                   	ret    

80104db0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104db0:	55                   	push   %ebp
80104db1:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104db3:	8b 45 08             	mov    0x8(%ebp),%eax
80104db6:	8b 55 0c             	mov    0xc(%ebp),%edx
80104db9:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104dcf:	90                   	nop
80104dd0:	5d                   	pop    %ebp
80104dd1:	c3                   	ret    

80104dd2 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104dd2:	55                   	push   %ebp
80104dd3:	89 e5                	mov    %esp,%ebp
80104dd5:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104dd8:	e8 52 01 00 00       	call   80104f2f <pushcli>
  if(holding(lk))
80104ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80104de0:	83 ec 0c             	sub    $0xc,%esp
80104de3:	50                   	push   %eax
80104de4:	e8 1c 01 00 00       	call   80104f05 <holding>
80104de9:	83 c4 10             	add    $0x10,%esp
80104dec:	85 c0                	test   %eax,%eax
80104dee:	74 0d                	je     80104dfd <acquire+0x2b>
    panic("acquire");
80104df0:	83 ec 0c             	sub    $0xc,%esp
80104df3:	68 35 87 10 80       	push   $0x80108735
80104df8:	e8 69 b7 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104dfd:	90                   	nop
80104dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80104e01:	83 ec 08             	sub    $0x8,%esp
80104e04:	6a 01                	push   $0x1
80104e06:	50                   	push   %eax
80104e07:	e8 8a ff ff ff       	call   80104d96 <xchg>
80104e0c:	83 c4 10             	add    $0x10,%esp
80104e0f:	85 c0                	test   %eax,%eax
80104e11:	75 eb                	jne    80104dfe <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104e13:	8b 45 08             	mov    0x8(%ebp),%eax
80104e16:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104e1d:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104e20:	8b 45 08             	mov    0x8(%ebp),%eax
80104e23:	83 c0 0c             	add    $0xc,%eax
80104e26:	83 ec 08             	sub    $0x8,%esp
80104e29:	50                   	push   %eax
80104e2a:	8d 45 08             	lea    0x8(%ebp),%eax
80104e2d:	50                   	push   %eax
80104e2e:	e8 58 00 00 00       	call   80104e8b <getcallerpcs>
80104e33:	83 c4 10             	add    $0x10,%esp
}
80104e36:	90                   	nop
80104e37:	c9                   	leave  
80104e38:	c3                   	ret    

80104e39 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104e39:	55                   	push   %ebp
80104e3a:	89 e5                	mov    %esp,%ebp
80104e3c:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104e3f:	83 ec 0c             	sub    $0xc,%esp
80104e42:	ff 75 08             	pushl  0x8(%ebp)
80104e45:	e8 bb 00 00 00       	call   80104f05 <holding>
80104e4a:	83 c4 10             	add    $0x10,%esp
80104e4d:	85 c0                	test   %eax,%eax
80104e4f:	75 0d                	jne    80104e5e <release+0x25>
    panic("release");
80104e51:	83 ec 0c             	sub    $0xc,%esp
80104e54:	68 3d 87 10 80       	push   $0x8010873d
80104e59:	e8 08 b7 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80104e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e61:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104e68:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104e72:	8b 45 08             	mov    0x8(%ebp),%eax
80104e75:	83 ec 08             	sub    $0x8,%esp
80104e78:	6a 00                	push   $0x0
80104e7a:	50                   	push   %eax
80104e7b:	e8 16 ff ff ff       	call   80104d96 <xchg>
80104e80:	83 c4 10             	add    $0x10,%esp

  popcli();
80104e83:	e8 ec 00 00 00       	call   80104f74 <popcli>
}
80104e88:	90                   	nop
80104e89:	c9                   	leave  
80104e8a:	c3                   	ret    

80104e8b <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104e8b:	55                   	push   %ebp
80104e8c:	89 e5                	mov    %esp,%ebp
80104e8e:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104e91:	8b 45 08             	mov    0x8(%ebp),%eax
80104e94:	83 e8 08             	sub    $0x8,%eax
80104e97:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e9a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104ea1:	eb 38                	jmp    80104edb <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104ea3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104ea7:	74 53                	je     80104efc <getcallerpcs+0x71>
80104ea9:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104eb0:	76 4a                	jbe    80104efc <getcallerpcs+0x71>
80104eb2:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104eb6:	74 44                	je     80104efc <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104eb8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ebb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ec5:	01 c2                	add    %eax,%edx
80104ec7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eca:	8b 40 04             	mov    0x4(%eax),%eax
80104ecd:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104ecf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ed2:	8b 00                	mov    (%eax),%eax
80104ed4:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104ed7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104edb:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104edf:	7e c2                	jle    80104ea3 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104ee1:	eb 19                	jmp    80104efc <getcallerpcs+0x71>
    pcs[i] = 0;
80104ee3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ee6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104eed:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ef0:	01 d0                	add    %edx,%eax
80104ef2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104ef8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104efc:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f00:	7e e1                	jle    80104ee3 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80104f02:	90                   	nop
80104f03:	c9                   	leave  
80104f04:	c3                   	ret    

80104f05 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104f05:	55                   	push   %ebp
80104f06:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104f08:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0b:	8b 00                	mov    (%eax),%eax
80104f0d:	85 c0                	test   %eax,%eax
80104f0f:	74 17                	je     80104f28 <holding+0x23>
80104f11:	8b 45 08             	mov    0x8(%ebp),%eax
80104f14:	8b 50 08             	mov    0x8(%eax),%edx
80104f17:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f1d:	39 c2                	cmp    %eax,%edx
80104f1f:	75 07                	jne    80104f28 <holding+0x23>
80104f21:	b8 01 00 00 00       	mov    $0x1,%eax
80104f26:	eb 05                	jmp    80104f2d <holding+0x28>
80104f28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f2d:	5d                   	pop    %ebp
80104f2e:	c3                   	ret    

80104f2f <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104f2f:	55                   	push   %ebp
80104f30:	89 e5                	mov    %esp,%ebp
80104f32:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104f35:	e8 3e fe ff ff       	call   80104d78 <readeflags>
80104f3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104f3d:	e8 46 fe ff ff       	call   80104d88 <cli>
  if(cpu->ncli++ == 0)
80104f42:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104f49:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80104f4f:	8d 48 01             	lea    0x1(%eax),%ecx
80104f52:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80104f58:	85 c0                	test   %eax,%eax
80104f5a:	75 15                	jne    80104f71 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80104f5c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f62:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f65:	81 e2 00 02 00 00    	and    $0x200,%edx
80104f6b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104f71:	90                   	nop
80104f72:	c9                   	leave  
80104f73:	c3                   	ret    

80104f74 <popcli>:

void
popcli(void)
{
80104f74:	55                   	push   %ebp
80104f75:	89 e5                	mov    %esp,%ebp
80104f77:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104f7a:	e8 f9 fd ff ff       	call   80104d78 <readeflags>
80104f7f:	25 00 02 00 00       	and    $0x200,%eax
80104f84:	85 c0                	test   %eax,%eax
80104f86:	74 0d                	je     80104f95 <popcli+0x21>
    panic("popcli - interruptible");
80104f88:	83 ec 0c             	sub    $0xc,%esp
80104f8b:	68 45 87 10 80       	push   $0x80108745
80104f90:	e8 d1 b5 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80104f95:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f9b:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104fa1:	83 ea 01             	sub    $0x1,%edx
80104fa4:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104faa:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104fb0:	85 c0                	test   %eax,%eax
80104fb2:	79 0d                	jns    80104fc1 <popcli+0x4d>
    panic("popcli");
80104fb4:	83 ec 0c             	sub    $0xc,%esp
80104fb7:	68 5c 87 10 80       	push   $0x8010875c
80104fbc:	e8 a5 b5 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80104fc1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fc7:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104fcd:	85 c0                	test   %eax,%eax
80104fcf:	75 15                	jne    80104fe6 <popcli+0x72>
80104fd1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fd7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104fdd:	85 c0                	test   %eax,%eax
80104fdf:	74 05                	je     80104fe6 <popcli+0x72>
    sti();
80104fe1:	e8 a9 fd ff ff       	call   80104d8f <sti>
}
80104fe6:	90                   	nop
80104fe7:	c9                   	leave  
80104fe8:	c3                   	ret    

80104fe9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80104fe9:	55                   	push   %ebp
80104fea:	89 e5                	mov    %esp,%ebp
80104fec:	57                   	push   %edi
80104fed:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104fee:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ff1:	8b 55 10             	mov    0x10(%ebp),%edx
80104ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff7:	89 cb                	mov    %ecx,%ebx
80104ff9:	89 df                	mov    %ebx,%edi
80104ffb:	89 d1                	mov    %edx,%ecx
80104ffd:	fc                   	cld    
80104ffe:	f3 aa                	rep stos %al,%es:(%edi)
80105000:	89 ca                	mov    %ecx,%edx
80105002:	89 fb                	mov    %edi,%ebx
80105004:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105007:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010500a:	90                   	nop
8010500b:	5b                   	pop    %ebx
8010500c:	5f                   	pop    %edi
8010500d:	5d                   	pop    %ebp
8010500e:	c3                   	ret    

8010500f <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010500f:	55                   	push   %ebp
80105010:	89 e5                	mov    %esp,%ebp
80105012:	57                   	push   %edi
80105013:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105014:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105017:	8b 55 10             	mov    0x10(%ebp),%edx
8010501a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010501d:	89 cb                	mov    %ecx,%ebx
8010501f:	89 df                	mov    %ebx,%edi
80105021:	89 d1                	mov    %edx,%ecx
80105023:	fc                   	cld    
80105024:	f3 ab                	rep stos %eax,%es:(%edi)
80105026:	89 ca                	mov    %ecx,%edx
80105028:	89 fb                	mov    %edi,%ebx
8010502a:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010502d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105030:	90                   	nop
80105031:	5b                   	pop    %ebx
80105032:	5f                   	pop    %edi
80105033:	5d                   	pop    %ebp
80105034:	c3                   	ret    

80105035 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105035:	55                   	push   %ebp
80105036:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105038:	8b 45 08             	mov    0x8(%ebp),%eax
8010503b:	83 e0 03             	and    $0x3,%eax
8010503e:	85 c0                	test   %eax,%eax
80105040:	75 43                	jne    80105085 <memset+0x50>
80105042:	8b 45 10             	mov    0x10(%ebp),%eax
80105045:	83 e0 03             	and    $0x3,%eax
80105048:	85 c0                	test   %eax,%eax
8010504a:	75 39                	jne    80105085 <memset+0x50>
    c &= 0xFF;
8010504c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105053:	8b 45 10             	mov    0x10(%ebp),%eax
80105056:	c1 e8 02             	shr    $0x2,%eax
80105059:	89 c1                	mov    %eax,%ecx
8010505b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010505e:	c1 e0 18             	shl    $0x18,%eax
80105061:	89 c2                	mov    %eax,%edx
80105063:	8b 45 0c             	mov    0xc(%ebp),%eax
80105066:	c1 e0 10             	shl    $0x10,%eax
80105069:	09 c2                	or     %eax,%edx
8010506b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010506e:	c1 e0 08             	shl    $0x8,%eax
80105071:	09 d0                	or     %edx,%eax
80105073:	0b 45 0c             	or     0xc(%ebp),%eax
80105076:	51                   	push   %ecx
80105077:	50                   	push   %eax
80105078:	ff 75 08             	pushl  0x8(%ebp)
8010507b:	e8 8f ff ff ff       	call   8010500f <stosl>
80105080:	83 c4 0c             	add    $0xc,%esp
80105083:	eb 12                	jmp    80105097 <memset+0x62>
  } else
    stosb(dst, c, n);
80105085:	8b 45 10             	mov    0x10(%ebp),%eax
80105088:	50                   	push   %eax
80105089:	ff 75 0c             	pushl  0xc(%ebp)
8010508c:	ff 75 08             	pushl  0x8(%ebp)
8010508f:	e8 55 ff ff ff       	call   80104fe9 <stosb>
80105094:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105097:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010509a:	c9                   	leave  
8010509b:	c3                   	ret    

8010509c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010509c:	55                   	push   %ebp
8010509d:	89 e5                	mov    %esp,%ebp
8010509f:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801050a2:	8b 45 08             	mov    0x8(%ebp),%eax
801050a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801050a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801050ae:	eb 30                	jmp    801050e0 <memcmp+0x44>
    if(*s1 != *s2)
801050b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050b3:	0f b6 10             	movzbl (%eax),%edx
801050b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050b9:	0f b6 00             	movzbl (%eax),%eax
801050bc:	38 c2                	cmp    %al,%dl
801050be:	74 18                	je     801050d8 <memcmp+0x3c>
      return *s1 - *s2;
801050c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050c3:	0f b6 00             	movzbl (%eax),%eax
801050c6:	0f b6 d0             	movzbl %al,%edx
801050c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050cc:	0f b6 00             	movzbl (%eax),%eax
801050cf:	0f b6 c0             	movzbl %al,%eax
801050d2:	29 c2                	sub    %eax,%edx
801050d4:	89 d0                	mov    %edx,%eax
801050d6:	eb 1a                	jmp    801050f2 <memcmp+0x56>
    s1++, s2++;
801050d8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050dc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801050e0:	8b 45 10             	mov    0x10(%ebp),%eax
801050e3:	8d 50 ff             	lea    -0x1(%eax),%edx
801050e6:	89 55 10             	mov    %edx,0x10(%ebp)
801050e9:	85 c0                	test   %eax,%eax
801050eb:	75 c3                	jne    801050b0 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801050ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050f2:	c9                   	leave  
801050f3:	c3                   	ret    

801050f4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801050f4:	55                   	push   %ebp
801050f5:	89 e5                	mov    %esp,%ebp
801050f7:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801050fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105100:	8b 45 08             	mov    0x8(%ebp),%eax
80105103:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105106:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105109:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010510c:	73 54                	jae    80105162 <memmove+0x6e>
8010510e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105111:	8b 45 10             	mov    0x10(%ebp),%eax
80105114:	01 d0                	add    %edx,%eax
80105116:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105119:	76 47                	jbe    80105162 <memmove+0x6e>
    s += n;
8010511b:	8b 45 10             	mov    0x10(%ebp),%eax
8010511e:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105121:	8b 45 10             	mov    0x10(%ebp),%eax
80105124:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105127:	eb 13                	jmp    8010513c <memmove+0x48>
      *--d = *--s;
80105129:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010512d:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105131:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105134:	0f b6 10             	movzbl (%eax),%edx
80105137:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010513a:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010513c:	8b 45 10             	mov    0x10(%ebp),%eax
8010513f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105142:	89 55 10             	mov    %edx,0x10(%ebp)
80105145:	85 c0                	test   %eax,%eax
80105147:	75 e0                	jne    80105129 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105149:	eb 24                	jmp    8010516f <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010514b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010514e:	8d 50 01             	lea    0x1(%eax),%edx
80105151:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105154:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105157:	8d 4a 01             	lea    0x1(%edx),%ecx
8010515a:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010515d:	0f b6 12             	movzbl (%edx),%edx
80105160:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105162:	8b 45 10             	mov    0x10(%ebp),%eax
80105165:	8d 50 ff             	lea    -0x1(%eax),%edx
80105168:	89 55 10             	mov    %edx,0x10(%ebp)
8010516b:	85 c0                	test   %eax,%eax
8010516d:	75 dc                	jne    8010514b <memmove+0x57>
      *d++ = *s++;

  return dst;
8010516f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105172:	c9                   	leave  
80105173:	c3                   	ret    

80105174 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105174:	55                   	push   %ebp
80105175:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105177:	ff 75 10             	pushl  0x10(%ebp)
8010517a:	ff 75 0c             	pushl  0xc(%ebp)
8010517d:	ff 75 08             	pushl  0x8(%ebp)
80105180:	e8 6f ff ff ff       	call   801050f4 <memmove>
80105185:	83 c4 0c             	add    $0xc,%esp
}
80105188:	c9                   	leave  
80105189:	c3                   	ret    

8010518a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010518a:	55                   	push   %ebp
8010518b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010518d:	eb 0c                	jmp    8010519b <strncmp+0x11>
    n--, p++, q++;
8010518f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105193:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105197:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010519b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010519f:	74 1a                	je     801051bb <strncmp+0x31>
801051a1:	8b 45 08             	mov    0x8(%ebp),%eax
801051a4:	0f b6 00             	movzbl (%eax),%eax
801051a7:	84 c0                	test   %al,%al
801051a9:	74 10                	je     801051bb <strncmp+0x31>
801051ab:	8b 45 08             	mov    0x8(%ebp),%eax
801051ae:	0f b6 10             	movzbl (%eax),%edx
801051b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801051b4:	0f b6 00             	movzbl (%eax),%eax
801051b7:	38 c2                	cmp    %al,%dl
801051b9:	74 d4                	je     8010518f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801051bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051bf:	75 07                	jne    801051c8 <strncmp+0x3e>
    return 0;
801051c1:	b8 00 00 00 00       	mov    $0x0,%eax
801051c6:	eb 16                	jmp    801051de <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801051c8:	8b 45 08             	mov    0x8(%ebp),%eax
801051cb:	0f b6 00             	movzbl (%eax),%eax
801051ce:	0f b6 d0             	movzbl %al,%edx
801051d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801051d4:	0f b6 00             	movzbl (%eax),%eax
801051d7:	0f b6 c0             	movzbl %al,%eax
801051da:	29 c2                	sub    %eax,%edx
801051dc:	89 d0                	mov    %edx,%eax
}
801051de:	5d                   	pop    %ebp
801051df:	c3                   	ret    

801051e0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801051e0:	55                   	push   %ebp
801051e1:	89 e5                	mov    %esp,%ebp
801051e3:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801051e6:	8b 45 08             	mov    0x8(%ebp),%eax
801051e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801051ec:	90                   	nop
801051ed:	8b 45 10             	mov    0x10(%ebp),%eax
801051f0:	8d 50 ff             	lea    -0x1(%eax),%edx
801051f3:	89 55 10             	mov    %edx,0x10(%ebp)
801051f6:	85 c0                	test   %eax,%eax
801051f8:	7e 2c                	jle    80105226 <strncpy+0x46>
801051fa:	8b 45 08             	mov    0x8(%ebp),%eax
801051fd:	8d 50 01             	lea    0x1(%eax),%edx
80105200:	89 55 08             	mov    %edx,0x8(%ebp)
80105203:	8b 55 0c             	mov    0xc(%ebp),%edx
80105206:	8d 4a 01             	lea    0x1(%edx),%ecx
80105209:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010520c:	0f b6 12             	movzbl (%edx),%edx
8010520f:	88 10                	mov    %dl,(%eax)
80105211:	0f b6 00             	movzbl (%eax),%eax
80105214:	84 c0                	test   %al,%al
80105216:	75 d5                	jne    801051ed <strncpy+0xd>
    ;
  while(n-- > 0)
80105218:	eb 0c                	jmp    80105226 <strncpy+0x46>
    *s++ = 0;
8010521a:	8b 45 08             	mov    0x8(%ebp),%eax
8010521d:	8d 50 01             	lea    0x1(%eax),%edx
80105220:	89 55 08             	mov    %edx,0x8(%ebp)
80105223:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105226:	8b 45 10             	mov    0x10(%ebp),%eax
80105229:	8d 50 ff             	lea    -0x1(%eax),%edx
8010522c:	89 55 10             	mov    %edx,0x10(%ebp)
8010522f:	85 c0                	test   %eax,%eax
80105231:	7f e7                	jg     8010521a <strncpy+0x3a>
    *s++ = 0;
  return os;
80105233:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105236:	c9                   	leave  
80105237:	c3                   	ret    

80105238 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105238:	55                   	push   %ebp
80105239:	89 e5                	mov    %esp,%ebp
8010523b:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010523e:	8b 45 08             	mov    0x8(%ebp),%eax
80105241:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105244:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105248:	7f 05                	jg     8010524f <safestrcpy+0x17>
    return os;
8010524a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010524d:	eb 31                	jmp    80105280 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010524f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105253:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105257:	7e 1e                	jle    80105277 <safestrcpy+0x3f>
80105259:	8b 45 08             	mov    0x8(%ebp),%eax
8010525c:	8d 50 01             	lea    0x1(%eax),%edx
8010525f:	89 55 08             	mov    %edx,0x8(%ebp)
80105262:	8b 55 0c             	mov    0xc(%ebp),%edx
80105265:	8d 4a 01             	lea    0x1(%edx),%ecx
80105268:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010526b:	0f b6 12             	movzbl (%edx),%edx
8010526e:	88 10                	mov    %dl,(%eax)
80105270:	0f b6 00             	movzbl (%eax),%eax
80105273:	84 c0                	test   %al,%al
80105275:	75 d8                	jne    8010524f <safestrcpy+0x17>
    ;
  *s = 0;
80105277:	8b 45 08             	mov    0x8(%ebp),%eax
8010527a:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010527d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105280:	c9                   	leave  
80105281:	c3                   	ret    

80105282 <strlen>:

int
strlen(const char *s)
{
80105282:	55                   	push   %ebp
80105283:	89 e5                	mov    %esp,%ebp
80105285:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105288:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010528f:	eb 04                	jmp    80105295 <strlen+0x13>
80105291:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105295:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105298:	8b 45 08             	mov    0x8(%ebp),%eax
8010529b:	01 d0                	add    %edx,%eax
8010529d:	0f b6 00             	movzbl (%eax),%eax
801052a0:	84 c0                	test   %al,%al
801052a2:	75 ed                	jne    80105291 <strlen+0xf>
    ;
  return n;
801052a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052a7:	c9                   	leave  
801052a8:	c3                   	ret    

801052a9 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801052a9:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801052ad:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801052b1:	55                   	push   %ebp
  pushl %ebx
801052b2:	53                   	push   %ebx
  pushl %esi
801052b3:	56                   	push   %esi
  pushl %edi
801052b4:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801052b5:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801052b7:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801052b9:	5f                   	pop    %edi
  popl %esi
801052ba:	5e                   	pop    %esi
  popl %ebx
801052bb:	5b                   	pop    %ebx
  popl %ebp
801052bc:	5d                   	pop    %ebp
  ret
801052bd:	c3                   	ret    

801052be <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801052be:	55                   	push   %ebp
801052bf:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801052c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052c7:	8b 00                	mov    (%eax),%eax
801052c9:	3b 45 08             	cmp    0x8(%ebp),%eax
801052cc:	76 12                	jbe    801052e0 <fetchint+0x22>
801052ce:	8b 45 08             	mov    0x8(%ebp),%eax
801052d1:	8d 50 04             	lea    0x4(%eax),%edx
801052d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052da:	8b 00                	mov    (%eax),%eax
801052dc:	39 c2                	cmp    %eax,%edx
801052de:	76 07                	jbe    801052e7 <fetchint+0x29>
    return -1;
801052e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e5:	eb 0f                	jmp    801052f6 <fetchint+0x38>
  *ip = *(int*)(addr);
801052e7:	8b 45 08             	mov    0x8(%ebp),%eax
801052ea:	8b 10                	mov    (%eax),%edx
801052ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ef:	89 10                	mov    %edx,(%eax)
  return 0;
801052f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052f6:	5d                   	pop    %ebp
801052f7:	c3                   	ret    

801052f8 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801052f8:	55                   	push   %ebp
801052f9:	89 e5                	mov    %esp,%ebp
801052fb:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801052fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105304:	8b 00                	mov    (%eax),%eax
80105306:	3b 45 08             	cmp    0x8(%ebp),%eax
80105309:	77 07                	ja     80105312 <fetchstr+0x1a>
    return -1;
8010530b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105310:	eb 46                	jmp    80105358 <fetchstr+0x60>
  *pp = (char*)addr;
80105312:	8b 55 08             	mov    0x8(%ebp),%edx
80105315:	8b 45 0c             	mov    0xc(%ebp),%eax
80105318:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010531a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105320:	8b 00                	mov    (%eax),%eax
80105322:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105325:	8b 45 0c             	mov    0xc(%ebp),%eax
80105328:	8b 00                	mov    (%eax),%eax
8010532a:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010532d:	eb 1c                	jmp    8010534b <fetchstr+0x53>
    if(*s == 0)
8010532f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105332:	0f b6 00             	movzbl (%eax),%eax
80105335:	84 c0                	test   %al,%al
80105337:	75 0e                	jne    80105347 <fetchstr+0x4f>
      return s - *pp;
80105339:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010533c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533f:	8b 00                	mov    (%eax),%eax
80105341:	29 c2                	sub    %eax,%edx
80105343:	89 d0                	mov    %edx,%eax
80105345:	eb 11                	jmp    80105358 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105347:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010534b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010534e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105351:	72 dc                	jb     8010532f <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105353:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105358:	c9                   	leave  
80105359:	c3                   	ret    

8010535a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010535a:	55                   	push   %ebp
8010535b:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010535d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105363:	8b 40 18             	mov    0x18(%eax),%eax
80105366:	8b 40 44             	mov    0x44(%eax),%eax
80105369:	8b 55 08             	mov    0x8(%ebp),%edx
8010536c:	c1 e2 02             	shl    $0x2,%edx
8010536f:	01 d0                	add    %edx,%eax
80105371:	83 c0 04             	add    $0x4,%eax
80105374:	ff 75 0c             	pushl  0xc(%ebp)
80105377:	50                   	push   %eax
80105378:	e8 41 ff ff ff       	call   801052be <fetchint>
8010537d:	83 c4 08             	add    $0x8,%esp
}
80105380:	c9                   	leave  
80105381:	c3                   	ret    

80105382 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105382:	55                   	push   %ebp
80105383:	89 e5                	mov    %esp,%ebp
80105385:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105388:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010538b:	50                   	push   %eax
8010538c:	ff 75 08             	pushl  0x8(%ebp)
8010538f:	e8 c6 ff ff ff       	call   8010535a <argint>
80105394:	83 c4 08             	add    $0x8,%esp
80105397:	85 c0                	test   %eax,%eax
80105399:	79 07                	jns    801053a2 <argptr+0x20>
    return -1;
8010539b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a0:	eb 3b                	jmp    801053dd <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801053a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053a8:	8b 00                	mov    (%eax),%eax
801053aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053ad:	39 d0                	cmp    %edx,%eax
801053af:	76 16                	jbe    801053c7 <argptr+0x45>
801053b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053b4:	89 c2                	mov    %eax,%edx
801053b6:	8b 45 10             	mov    0x10(%ebp),%eax
801053b9:	01 c2                	add    %eax,%edx
801053bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053c1:	8b 00                	mov    (%eax),%eax
801053c3:	39 c2                	cmp    %eax,%edx
801053c5:	76 07                	jbe    801053ce <argptr+0x4c>
    return -1;
801053c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053cc:	eb 0f                	jmp    801053dd <argptr+0x5b>
  *pp = (char*)i;
801053ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053d1:	89 c2                	mov    %eax,%edx
801053d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053d6:	89 10                	mov    %edx,(%eax)
  return 0;
801053d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053dd:	c9                   	leave  
801053de:	c3                   	ret    

801053df <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801053df:	55                   	push   %ebp
801053e0:	89 e5                	mov    %esp,%ebp
801053e2:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801053e5:	8d 45 fc             	lea    -0x4(%ebp),%eax
801053e8:	50                   	push   %eax
801053e9:	ff 75 08             	pushl  0x8(%ebp)
801053ec:	e8 69 ff ff ff       	call   8010535a <argint>
801053f1:	83 c4 08             	add    $0x8,%esp
801053f4:	85 c0                	test   %eax,%eax
801053f6:	79 07                	jns    801053ff <argstr+0x20>
    return -1;
801053f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053fd:	eb 0f                	jmp    8010540e <argstr+0x2f>
  return fetchstr(addr, pp);
801053ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105402:	ff 75 0c             	pushl  0xc(%ebp)
80105405:	50                   	push   %eax
80105406:	e8 ed fe ff ff       	call   801052f8 <fetchstr>
8010540b:	83 c4 08             	add    $0x8,%esp
}
8010540e:	c9                   	leave  
8010540f:	c3                   	ret    

80105410 <syscall>:

};

void
syscall(void)
{
80105410:	55                   	push   %ebp
80105411:	89 e5                	mov    %esp,%ebp
80105413:	53                   	push   %ebx
80105414:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105417:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010541d:	8b 40 18             	mov    0x18(%eax),%eax
80105420:	8b 40 1c             	mov    0x1c(%eax),%eax
80105423:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105426:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010542a:	7e 30                	jle    8010545c <syscall+0x4c>
8010542c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010542f:	83 f8 19             	cmp    $0x19,%eax
80105432:	77 28                	ja     8010545c <syscall+0x4c>
80105434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105437:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010543e:	85 c0                	test   %eax,%eax
80105440:	74 1a                	je     8010545c <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105442:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105448:	8b 58 18             	mov    0x18(%eax),%ebx
8010544b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544e:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105455:	ff d0                	call   *%eax
80105457:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010545a:	eb 34                	jmp    80105490 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010545c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105462:	8d 50 6c             	lea    0x6c(%eax),%edx
80105465:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010546b:	8b 40 10             	mov    0x10(%eax),%eax
8010546e:	ff 75 f4             	pushl  -0xc(%ebp)
80105471:	52                   	push   %edx
80105472:	50                   	push   %eax
80105473:	68 63 87 10 80       	push   $0x80108763
80105478:	e8 49 af ff ff       	call   801003c6 <cprintf>
8010547d:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105480:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105486:	8b 40 18             	mov    0x18(%eax),%eax
80105489:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105490:	90                   	nop
80105491:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105494:	c9                   	leave  
80105495:	c3                   	ret    

80105496 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105496:	55                   	push   %ebp
80105497:	89 e5                	mov    %esp,%ebp
80105499:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010549c:	83 ec 08             	sub    $0x8,%esp
8010549f:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054a2:	50                   	push   %eax
801054a3:	ff 75 08             	pushl  0x8(%ebp)
801054a6:	e8 af fe ff ff       	call   8010535a <argint>
801054ab:	83 c4 10             	add    $0x10,%esp
801054ae:	85 c0                	test   %eax,%eax
801054b0:	79 07                	jns    801054b9 <argfd+0x23>
    return -1;
801054b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054b7:	eb 50                	jmp    80105509 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801054b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054bc:	85 c0                	test   %eax,%eax
801054be:	78 21                	js     801054e1 <argfd+0x4b>
801054c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054c3:	83 f8 0f             	cmp    $0xf,%eax
801054c6:	7f 19                	jg     801054e1 <argfd+0x4b>
801054c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054d1:	83 c2 08             	add    $0x8,%edx
801054d4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054df:	75 07                	jne    801054e8 <argfd+0x52>
    return -1;
801054e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054e6:	eb 21                	jmp    80105509 <argfd+0x73>
  if(pfd)
801054e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801054ec:	74 08                	je     801054f6 <argfd+0x60>
    *pfd = fd;
801054ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f4:	89 10                	mov    %edx,(%eax)
  if(pf)
801054f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054fa:	74 08                	je     80105504 <argfd+0x6e>
    *pf = f;
801054fc:	8b 45 10             	mov    0x10(%ebp),%eax
801054ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105502:	89 10                	mov    %edx,(%eax)
  return 0;
80105504:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105509:	c9                   	leave  
8010550a:	c3                   	ret    

8010550b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010550b:	55                   	push   %ebp
8010550c:	89 e5                	mov    %esp,%ebp
8010550e:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105511:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105518:	eb 30                	jmp    8010554a <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010551a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105520:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105523:	83 c2 08             	add    $0x8,%edx
80105526:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010552a:	85 c0                	test   %eax,%eax
8010552c:	75 18                	jne    80105546 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010552e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105534:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105537:	8d 4a 08             	lea    0x8(%edx),%ecx
8010553a:	8b 55 08             	mov    0x8(%ebp),%edx
8010553d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105541:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105544:	eb 0f                	jmp    80105555 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105546:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010554a:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010554e:	7e ca                	jle    8010551a <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105550:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105555:	c9                   	leave  
80105556:	c3                   	ret    

80105557 <sys_dup>:

int
sys_dup(void)
{
80105557:	55                   	push   %ebp
80105558:	89 e5                	mov    %esp,%ebp
8010555a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010555d:	83 ec 04             	sub    $0x4,%esp
80105560:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105563:	50                   	push   %eax
80105564:	6a 00                	push   $0x0
80105566:	6a 00                	push   $0x0
80105568:	e8 29 ff ff ff       	call   80105496 <argfd>
8010556d:	83 c4 10             	add    $0x10,%esp
80105570:	85 c0                	test   %eax,%eax
80105572:	79 07                	jns    8010557b <sys_dup+0x24>
    return -1;
80105574:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105579:	eb 31                	jmp    801055ac <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010557b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010557e:	83 ec 0c             	sub    $0xc,%esp
80105581:	50                   	push   %eax
80105582:	e8 84 ff ff ff       	call   8010550b <fdalloc>
80105587:	83 c4 10             	add    $0x10,%esp
8010558a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010558d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105591:	79 07                	jns    8010559a <sys_dup+0x43>
    return -1;
80105593:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105598:	eb 12                	jmp    801055ac <sys_dup+0x55>
  filedup(f);
8010559a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010559d:	83 ec 0c             	sub    $0xc,%esp
801055a0:	50                   	push   %eax
801055a1:	e8 4a bc ff ff       	call   801011f0 <filedup>
801055a6:	83 c4 10             	add    $0x10,%esp
  return fd;
801055a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801055ac:	c9                   	leave  
801055ad:	c3                   	ret    

801055ae <sys_read>:

int
sys_read(void)
{
801055ae:	55                   	push   %ebp
801055af:	89 e5                	mov    %esp,%ebp
801055b1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801055b4:	83 ec 04             	sub    $0x4,%esp
801055b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055ba:	50                   	push   %eax
801055bb:	6a 00                	push   $0x0
801055bd:	6a 00                	push   $0x0
801055bf:	e8 d2 fe ff ff       	call   80105496 <argfd>
801055c4:	83 c4 10             	add    $0x10,%esp
801055c7:	85 c0                	test   %eax,%eax
801055c9:	78 2e                	js     801055f9 <sys_read+0x4b>
801055cb:	83 ec 08             	sub    $0x8,%esp
801055ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055d1:	50                   	push   %eax
801055d2:	6a 02                	push   $0x2
801055d4:	e8 81 fd ff ff       	call   8010535a <argint>
801055d9:	83 c4 10             	add    $0x10,%esp
801055dc:	85 c0                	test   %eax,%eax
801055de:	78 19                	js     801055f9 <sys_read+0x4b>
801055e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055e3:	83 ec 04             	sub    $0x4,%esp
801055e6:	50                   	push   %eax
801055e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055ea:	50                   	push   %eax
801055eb:	6a 01                	push   $0x1
801055ed:	e8 90 fd ff ff       	call   80105382 <argptr>
801055f2:	83 c4 10             	add    $0x10,%esp
801055f5:	85 c0                	test   %eax,%eax
801055f7:	79 07                	jns    80105600 <sys_read+0x52>
    return -1;
801055f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055fe:	eb 17                	jmp    80105617 <sys_read+0x69>
  return fileread(f, p, n);
80105600:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105603:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105609:	83 ec 04             	sub    $0x4,%esp
8010560c:	51                   	push   %ecx
8010560d:	52                   	push   %edx
8010560e:	50                   	push   %eax
8010560f:	e8 6c bd ff ff       	call   80101380 <fileread>
80105614:	83 c4 10             	add    $0x10,%esp
}
80105617:	c9                   	leave  
80105618:	c3                   	ret    

80105619 <sys_write>:

int
sys_write(void)
{
80105619:	55                   	push   %ebp
8010561a:	89 e5                	mov    %esp,%ebp
8010561c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010561f:	83 ec 04             	sub    $0x4,%esp
80105622:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105625:	50                   	push   %eax
80105626:	6a 00                	push   $0x0
80105628:	6a 00                	push   $0x0
8010562a:	e8 67 fe ff ff       	call   80105496 <argfd>
8010562f:	83 c4 10             	add    $0x10,%esp
80105632:	85 c0                	test   %eax,%eax
80105634:	78 2e                	js     80105664 <sys_write+0x4b>
80105636:	83 ec 08             	sub    $0x8,%esp
80105639:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010563c:	50                   	push   %eax
8010563d:	6a 02                	push   $0x2
8010563f:	e8 16 fd ff ff       	call   8010535a <argint>
80105644:	83 c4 10             	add    $0x10,%esp
80105647:	85 c0                	test   %eax,%eax
80105649:	78 19                	js     80105664 <sys_write+0x4b>
8010564b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010564e:	83 ec 04             	sub    $0x4,%esp
80105651:	50                   	push   %eax
80105652:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105655:	50                   	push   %eax
80105656:	6a 01                	push   $0x1
80105658:	e8 25 fd ff ff       	call   80105382 <argptr>
8010565d:	83 c4 10             	add    $0x10,%esp
80105660:	85 c0                	test   %eax,%eax
80105662:	79 07                	jns    8010566b <sys_write+0x52>
    return -1;
80105664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105669:	eb 17                	jmp    80105682 <sys_write+0x69>
  return filewrite(f, p, n);
8010566b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010566e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105674:	83 ec 04             	sub    $0x4,%esp
80105677:	51                   	push   %ecx
80105678:	52                   	push   %edx
80105679:	50                   	push   %eax
8010567a:	e8 b9 bd ff ff       	call   80101438 <filewrite>
8010567f:	83 c4 10             	add    $0x10,%esp
}
80105682:	c9                   	leave  
80105683:	c3                   	ret    

80105684 <sys_close>:

int
sys_close(void)
{
80105684:	55                   	push   %ebp
80105685:	89 e5                	mov    %esp,%ebp
80105687:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010568a:	83 ec 04             	sub    $0x4,%esp
8010568d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105690:	50                   	push   %eax
80105691:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105694:	50                   	push   %eax
80105695:	6a 00                	push   $0x0
80105697:	e8 fa fd ff ff       	call   80105496 <argfd>
8010569c:	83 c4 10             	add    $0x10,%esp
8010569f:	85 c0                	test   %eax,%eax
801056a1:	79 07                	jns    801056aa <sys_close+0x26>
    return -1;
801056a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056a8:	eb 28                	jmp    801056d2 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801056aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056b3:	83 c2 08             	add    $0x8,%edx
801056b6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801056bd:	00 
  fileclose(f);
801056be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c1:	83 ec 0c             	sub    $0xc,%esp
801056c4:	50                   	push   %eax
801056c5:	e8 77 bb ff ff       	call   80101241 <fileclose>
801056ca:	83 c4 10             	add    $0x10,%esp
  return 0;
801056cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056d2:	c9                   	leave  
801056d3:	c3                   	ret    

801056d4 <sys_fstat>:

int
sys_fstat(void)
{
801056d4:	55                   	push   %ebp
801056d5:	89 e5                	mov    %esp,%ebp
801056d7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801056da:	83 ec 04             	sub    $0x4,%esp
801056dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056e0:	50                   	push   %eax
801056e1:	6a 00                	push   $0x0
801056e3:	6a 00                	push   $0x0
801056e5:	e8 ac fd ff ff       	call   80105496 <argfd>
801056ea:	83 c4 10             	add    $0x10,%esp
801056ed:	85 c0                	test   %eax,%eax
801056ef:	78 17                	js     80105708 <sys_fstat+0x34>
801056f1:	83 ec 04             	sub    $0x4,%esp
801056f4:	6a 14                	push   $0x14
801056f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056f9:	50                   	push   %eax
801056fa:	6a 01                	push   $0x1
801056fc:	e8 81 fc ff ff       	call   80105382 <argptr>
80105701:	83 c4 10             	add    $0x10,%esp
80105704:	85 c0                	test   %eax,%eax
80105706:	79 07                	jns    8010570f <sys_fstat+0x3b>
    return -1;
80105708:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010570d:	eb 13                	jmp    80105722 <sys_fstat+0x4e>
  return filestat(f, st);
8010570f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105715:	83 ec 08             	sub    $0x8,%esp
80105718:	52                   	push   %edx
80105719:	50                   	push   %eax
8010571a:	e8 0a bc ff ff       	call   80101329 <filestat>
8010571f:	83 c4 10             	add    $0x10,%esp
}
80105722:	c9                   	leave  
80105723:	c3                   	ret    

80105724 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105724:	55                   	push   %ebp
80105725:	89 e5                	mov    %esp,%ebp
80105727:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010572a:	83 ec 08             	sub    $0x8,%esp
8010572d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105730:	50                   	push   %eax
80105731:	6a 00                	push   $0x0
80105733:	e8 a7 fc ff ff       	call   801053df <argstr>
80105738:	83 c4 10             	add    $0x10,%esp
8010573b:	85 c0                	test   %eax,%eax
8010573d:	78 15                	js     80105754 <sys_link+0x30>
8010573f:	83 ec 08             	sub    $0x8,%esp
80105742:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105745:	50                   	push   %eax
80105746:	6a 01                	push   $0x1
80105748:	e8 92 fc ff ff       	call   801053df <argstr>
8010574d:	83 c4 10             	add    $0x10,%esp
80105750:	85 c0                	test   %eax,%eax
80105752:	79 0a                	jns    8010575e <sys_link+0x3a>
    return -1;
80105754:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105759:	e9 63 01 00 00       	jmp    801058c1 <sys_link+0x19d>
  if((ip = namei(old)) == 0)
8010575e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105761:	83 ec 0c             	sub    $0xc,%esp
80105764:	50                   	push   %eax
80105765:	e8 64 cf ff ff       	call   801026ce <namei>
8010576a:	83 c4 10             	add    $0x10,%esp
8010576d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105770:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105774:	75 0a                	jne    80105780 <sys_link+0x5c>
    return -1;
80105776:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010577b:	e9 41 01 00 00       	jmp    801058c1 <sys_link+0x19d>

  begin_trans();
80105780:	e8 15 dd ff ff       	call   8010349a <begin_trans>

  ilock(ip);
80105785:	83 ec 0c             	sub    $0xc,%esp
80105788:	ff 75 f4             	pushl  -0xc(%ebp)
8010578b:	e8 86 c3 ff ff       	call   80101b16 <ilock>
80105790:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105796:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010579a:	66 83 f8 01          	cmp    $0x1,%ax
8010579e:	75 1d                	jne    801057bd <sys_link+0x99>
    iunlockput(ip);
801057a0:	83 ec 0c             	sub    $0xc,%esp
801057a3:	ff 75 f4             	pushl  -0xc(%ebp)
801057a6:	e8 25 c6 ff ff       	call   80101dd0 <iunlockput>
801057ab:	83 c4 10             	add    $0x10,%esp
    commit_trans();
801057ae:	e8 3a dd ff ff       	call   801034ed <commit_trans>
    return -1;
801057b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b8:	e9 04 01 00 00       	jmp    801058c1 <sys_link+0x19d>
  }

  ip->nlink++;
801057bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801057c4:	83 c0 01             	add    $0x1,%eax
801057c7:	89 c2                	mov    %eax,%edx
801057c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057cc:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801057d0:	83 ec 0c             	sub    $0xc,%esp
801057d3:	ff 75 f4             	pushl  -0xc(%ebp)
801057d6:	e8 67 c1 ff ff       	call   80101942 <iupdate>
801057db:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801057de:	83 ec 0c             	sub    $0xc,%esp
801057e1:	ff 75 f4             	pushl  -0xc(%ebp)
801057e4:	e8 85 c4 ff ff       	call   80101c6e <iunlock>
801057e9:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801057ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
801057ef:	83 ec 08             	sub    $0x8,%esp
801057f2:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801057f5:	52                   	push   %edx
801057f6:	50                   	push   %eax
801057f7:	e8 ee ce ff ff       	call   801026ea <nameiparent>
801057fc:	83 c4 10             	add    $0x10,%esp
801057ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105802:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105806:	74 71                	je     80105879 <sys_link+0x155>
    goto bad;
  ilock(dp);
80105808:	83 ec 0c             	sub    $0xc,%esp
8010580b:	ff 75 f0             	pushl  -0x10(%ebp)
8010580e:	e8 03 c3 ff ff       	call   80101b16 <ilock>
80105813:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105816:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105819:	8b 10                	mov    (%eax),%edx
8010581b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010581e:	8b 00                	mov    (%eax),%eax
80105820:	39 c2                	cmp    %eax,%edx
80105822:	75 1d                	jne    80105841 <sys_link+0x11d>
80105824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105827:	8b 40 04             	mov    0x4(%eax),%eax
8010582a:	83 ec 04             	sub    $0x4,%esp
8010582d:	50                   	push   %eax
8010582e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105831:	50                   	push   %eax
80105832:	ff 75 f0             	pushl  -0x10(%ebp)
80105835:	e8 f8 cb ff ff       	call   80102432 <dirlink>
8010583a:	83 c4 10             	add    $0x10,%esp
8010583d:	85 c0                	test   %eax,%eax
8010583f:	79 10                	jns    80105851 <sys_link+0x12d>
    iunlockput(dp);
80105841:	83 ec 0c             	sub    $0xc,%esp
80105844:	ff 75 f0             	pushl  -0x10(%ebp)
80105847:	e8 84 c5 ff ff       	call   80101dd0 <iunlockput>
8010584c:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010584f:	eb 29                	jmp    8010587a <sys_link+0x156>
  }
  iunlockput(dp);
80105851:	83 ec 0c             	sub    $0xc,%esp
80105854:	ff 75 f0             	pushl  -0x10(%ebp)
80105857:	e8 74 c5 ff ff       	call   80101dd0 <iunlockput>
8010585c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010585f:	83 ec 0c             	sub    $0xc,%esp
80105862:	ff 75 f4             	pushl  -0xc(%ebp)
80105865:	e8 76 c4 ff ff       	call   80101ce0 <iput>
8010586a:	83 c4 10             	add    $0x10,%esp

  commit_trans();
8010586d:	e8 7b dc ff ff       	call   801034ed <commit_trans>

  return 0;
80105872:	b8 00 00 00 00       	mov    $0x0,%eax
80105877:	eb 48                	jmp    801058c1 <sys_link+0x19d>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105879:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
8010587a:	83 ec 0c             	sub    $0xc,%esp
8010587d:	ff 75 f4             	pushl  -0xc(%ebp)
80105880:	e8 91 c2 ff ff       	call   80101b16 <ilock>
80105885:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010588f:	83 e8 01             	sub    $0x1,%eax
80105892:	89 c2                	mov    %eax,%edx
80105894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105897:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010589b:	83 ec 0c             	sub    $0xc,%esp
8010589e:	ff 75 f4             	pushl  -0xc(%ebp)
801058a1:	e8 9c c0 ff ff       	call   80101942 <iupdate>
801058a6:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801058a9:	83 ec 0c             	sub    $0xc,%esp
801058ac:	ff 75 f4             	pushl  -0xc(%ebp)
801058af:	e8 1c c5 ff ff       	call   80101dd0 <iunlockput>
801058b4:	83 c4 10             	add    $0x10,%esp
  commit_trans();
801058b7:	e8 31 dc ff ff       	call   801034ed <commit_trans>
  return -1;
801058bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058c1:	c9                   	leave  
801058c2:	c3                   	ret    

801058c3 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801058c3:	55                   	push   %ebp
801058c4:	89 e5                	mov    %esp,%ebp
801058c6:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801058c9:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801058d0:	eb 40                	jmp    80105912 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801058d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d5:	6a 10                	push   $0x10
801058d7:	50                   	push   %eax
801058d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801058db:	50                   	push   %eax
801058dc:	ff 75 08             	pushl  0x8(%ebp)
801058df:	e8 9a c7 ff ff       	call   8010207e <readi>
801058e4:	83 c4 10             	add    $0x10,%esp
801058e7:	83 f8 10             	cmp    $0x10,%eax
801058ea:	74 0d                	je     801058f9 <isdirempty+0x36>
      panic("isdirempty: readi");
801058ec:	83 ec 0c             	sub    $0xc,%esp
801058ef:	68 7f 87 10 80       	push   $0x8010877f
801058f4:	e8 6d ac ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801058f9:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801058fd:	66 85 c0             	test   %ax,%ax
80105900:	74 07                	je     80105909 <isdirempty+0x46>
      return 0;
80105902:	b8 00 00 00 00       	mov    $0x0,%eax
80105907:	eb 1b                	jmp    80105924 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010590c:	83 c0 10             	add    $0x10,%eax
8010590f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105912:	8b 45 08             	mov    0x8(%ebp),%eax
80105915:	8b 50 18             	mov    0x18(%eax),%edx
80105918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010591b:	39 c2                	cmp    %eax,%edx
8010591d:	77 b3                	ja     801058d2 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010591f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105924:	c9                   	leave  
80105925:	c3                   	ret    

80105926 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105926:	55                   	push   %ebp
80105927:	89 e5                	mov    %esp,%ebp
80105929:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010592c:	83 ec 08             	sub    $0x8,%esp
8010592f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105932:	50                   	push   %eax
80105933:	6a 00                	push   $0x0
80105935:	e8 a5 fa ff ff       	call   801053df <argstr>
8010593a:	83 c4 10             	add    $0x10,%esp
8010593d:	85 c0                	test   %eax,%eax
8010593f:	79 0a                	jns    8010594b <sys_unlink+0x25>
    return -1;
80105941:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105946:	e9 b7 01 00 00       	jmp    80105b02 <sys_unlink+0x1dc>
  if((dp = nameiparent(path, name)) == 0)
8010594b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010594e:	83 ec 08             	sub    $0x8,%esp
80105951:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105954:	52                   	push   %edx
80105955:	50                   	push   %eax
80105956:	e8 8f cd ff ff       	call   801026ea <nameiparent>
8010595b:	83 c4 10             	add    $0x10,%esp
8010595e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105961:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105965:	75 0a                	jne    80105971 <sys_unlink+0x4b>
    return -1;
80105967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596c:	e9 91 01 00 00       	jmp    80105b02 <sys_unlink+0x1dc>

  begin_trans();
80105971:	e8 24 db ff ff       	call   8010349a <begin_trans>

  ilock(dp);
80105976:	83 ec 0c             	sub    $0xc,%esp
80105979:	ff 75 f4             	pushl  -0xc(%ebp)
8010597c:	e8 95 c1 ff ff       	call   80101b16 <ilock>
80105981:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105984:	83 ec 08             	sub    $0x8,%esp
80105987:	68 91 87 10 80       	push   $0x80108791
8010598c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010598f:	50                   	push   %eax
80105990:	e8 c8 c9 ff ff       	call   8010235d <namecmp>
80105995:	83 c4 10             	add    $0x10,%esp
80105998:	85 c0                	test   %eax,%eax
8010599a:	0f 84 4a 01 00 00    	je     80105aea <sys_unlink+0x1c4>
801059a0:	83 ec 08             	sub    $0x8,%esp
801059a3:	68 93 87 10 80       	push   $0x80108793
801059a8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059ab:	50                   	push   %eax
801059ac:	e8 ac c9 ff ff       	call   8010235d <namecmp>
801059b1:	83 c4 10             	add    $0x10,%esp
801059b4:	85 c0                	test   %eax,%eax
801059b6:	0f 84 2e 01 00 00    	je     80105aea <sys_unlink+0x1c4>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801059bc:	83 ec 04             	sub    $0x4,%esp
801059bf:	8d 45 c8             	lea    -0x38(%ebp),%eax
801059c2:	50                   	push   %eax
801059c3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059c6:	50                   	push   %eax
801059c7:	ff 75 f4             	pushl  -0xc(%ebp)
801059ca:	e8 a9 c9 ff ff       	call   80102378 <dirlookup>
801059cf:	83 c4 10             	add    $0x10,%esp
801059d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059d9:	0f 84 0a 01 00 00    	je     80105ae9 <sys_unlink+0x1c3>
    goto bad;
  ilock(ip);
801059df:	83 ec 0c             	sub    $0xc,%esp
801059e2:	ff 75 f0             	pushl  -0x10(%ebp)
801059e5:	e8 2c c1 ff ff       	call   80101b16 <ilock>
801059ea:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801059ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801059f4:	66 85 c0             	test   %ax,%ax
801059f7:	7f 0d                	jg     80105a06 <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
801059f9:	83 ec 0c             	sub    $0xc,%esp
801059fc:	68 96 87 10 80       	push   $0x80108796
80105a01:	e8 60 ab ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a09:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a0d:	66 83 f8 01          	cmp    $0x1,%ax
80105a11:	75 25                	jne    80105a38 <sys_unlink+0x112>
80105a13:	83 ec 0c             	sub    $0xc,%esp
80105a16:	ff 75 f0             	pushl  -0x10(%ebp)
80105a19:	e8 a5 fe ff ff       	call   801058c3 <isdirempty>
80105a1e:	83 c4 10             	add    $0x10,%esp
80105a21:	85 c0                	test   %eax,%eax
80105a23:	75 13                	jne    80105a38 <sys_unlink+0x112>
    iunlockput(ip);
80105a25:	83 ec 0c             	sub    $0xc,%esp
80105a28:	ff 75 f0             	pushl  -0x10(%ebp)
80105a2b:	e8 a0 c3 ff ff       	call   80101dd0 <iunlockput>
80105a30:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105a33:	e9 b2 00 00 00       	jmp    80105aea <sys_unlink+0x1c4>
  }

  memset(&de, 0, sizeof(de));
80105a38:	83 ec 04             	sub    $0x4,%esp
80105a3b:	6a 10                	push   $0x10
80105a3d:	6a 00                	push   $0x0
80105a3f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a42:	50                   	push   %eax
80105a43:	e8 ed f5 ff ff       	call   80105035 <memset>
80105a48:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a4b:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105a4e:	6a 10                	push   $0x10
80105a50:	50                   	push   %eax
80105a51:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a54:	50                   	push   %eax
80105a55:	ff 75 f4             	pushl  -0xc(%ebp)
80105a58:	e8 78 c7 ff ff       	call   801021d5 <writei>
80105a5d:	83 c4 10             	add    $0x10,%esp
80105a60:	83 f8 10             	cmp    $0x10,%eax
80105a63:	74 0d                	je     80105a72 <sys_unlink+0x14c>
    panic("unlink: writei");
80105a65:	83 ec 0c             	sub    $0xc,%esp
80105a68:	68 a8 87 10 80       	push   $0x801087a8
80105a6d:	e8 f4 aa ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80105a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a75:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a79:	66 83 f8 01          	cmp    $0x1,%ax
80105a7d:	75 21                	jne    80105aa0 <sys_unlink+0x17a>
    dp->nlink--;
80105a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a82:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a86:	83 e8 01             	sub    $0x1,%eax
80105a89:	89 c2                	mov    %eax,%edx
80105a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8e:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105a92:	83 ec 0c             	sub    $0xc,%esp
80105a95:	ff 75 f4             	pushl  -0xc(%ebp)
80105a98:	e8 a5 be ff ff       	call   80101942 <iupdate>
80105a9d:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105aa0:	83 ec 0c             	sub    $0xc,%esp
80105aa3:	ff 75 f4             	pushl  -0xc(%ebp)
80105aa6:	e8 25 c3 ff ff       	call   80101dd0 <iunlockput>
80105aab:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ab5:	83 e8 01             	sub    $0x1,%eax
80105ab8:	89 c2                	mov    %eax,%edx
80105aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abd:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105ac1:	83 ec 0c             	sub    $0xc,%esp
80105ac4:	ff 75 f0             	pushl  -0x10(%ebp)
80105ac7:	e8 76 be ff ff       	call   80101942 <iupdate>
80105acc:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105acf:	83 ec 0c             	sub    $0xc,%esp
80105ad2:	ff 75 f0             	pushl  -0x10(%ebp)
80105ad5:	e8 f6 c2 ff ff       	call   80101dd0 <iunlockput>
80105ada:	83 c4 10             	add    $0x10,%esp

  commit_trans();
80105add:	e8 0b da ff ff       	call   801034ed <commit_trans>

  return 0;
80105ae2:	b8 00 00 00 00       	mov    $0x0,%eax
80105ae7:	eb 19                	jmp    80105b02 <sys_unlink+0x1dc>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105ae9:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105aea:	83 ec 0c             	sub    $0xc,%esp
80105aed:	ff 75 f4             	pushl  -0xc(%ebp)
80105af0:	e8 db c2 ff ff       	call   80101dd0 <iunlockput>
80105af5:	83 c4 10             	add    $0x10,%esp
  commit_trans();
80105af8:	e8 f0 d9 ff ff       	call   801034ed <commit_trans>
  return -1;
80105afd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b02:	c9                   	leave  
80105b03:	c3                   	ret    

80105b04 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105b04:	55                   	push   %ebp
80105b05:	89 e5                	mov    %esp,%ebp
80105b07:	83 ec 38             	sub    $0x38,%esp
80105b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105b0d:	8b 55 10             	mov    0x10(%ebp),%edx
80105b10:	8b 45 14             	mov    0x14(%ebp),%eax
80105b13:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105b17:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105b1b:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105b1f:	83 ec 08             	sub    $0x8,%esp
80105b22:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b25:	50                   	push   %eax
80105b26:	ff 75 08             	pushl  0x8(%ebp)
80105b29:	e8 bc cb ff ff       	call   801026ea <nameiparent>
80105b2e:	83 c4 10             	add    $0x10,%esp
80105b31:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b34:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b38:	75 0a                	jne    80105b44 <create+0x40>
    return 0;
80105b3a:	b8 00 00 00 00       	mov    $0x0,%eax
80105b3f:	e9 90 01 00 00       	jmp    80105cd4 <create+0x1d0>
  ilock(dp);
80105b44:	83 ec 0c             	sub    $0xc,%esp
80105b47:	ff 75 f4             	pushl  -0xc(%ebp)
80105b4a:	e8 c7 bf ff ff       	call   80101b16 <ilock>
80105b4f:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105b52:	83 ec 04             	sub    $0x4,%esp
80105b55:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b58:	50                   	push   %eax
80105b59:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b5c:	50                   	push   %eax
80105b5d:	ff 75 f4             	pushl  -0xc(%ebp)
80105b60:	e8 13 c8 ff ff       	call   80102378 <dirlookup>
80105b65:	83 c4 10             	add    $0x10,%esp
80105b68:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b6f:	74 50                	je     80105bc1 <create+0xbd>
    iunlockput(dp);
80105b71:	83 ec 0c             	sub    $0xc,%esp
80105b74:	ff 75 f4             	pushl  -0xc(%ebp)
80105b77:	e8 54 c2 ff ff       	call   80101dd0 <iunlockput>
80105b7c:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105b7f:	83 ec 0c             	sub    $0xc,%esp
80105b82:	ff 75 f0             	pushl  -0x10(%ebp)
80105b85:	e8 8c bf ff ff       	call   80101b16 <ilock>
80105b8a:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105b8d:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105b92:	75 15                	jne    80105ba9 <create+0xa5>
80105b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b97:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b9b:	66 83 f8 02          	cmp    $0x2,%ax
80105b9f:	75 08                	jne    80105ba9 <create+0xa5>
      return ip;
80105ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba4:	e9 2b 01 00 00       	jmp    80105cd4 <create+0x1d0>
    iunlockput(ip);
80105ba9:	83 ec 0c             	sub    $0xc,%esp
80105bac:	ff 75 f0             	pushl  -0x10(%ebp)
80105baf:	e8 1c c2 ff ff       	call   80101dd0 <iunlockput>
80105bb4:	83 c4 10             	add    $0x10,%esp
    return 0;
80105bb7:	b8 00 00 00 00       	mov    $0x0,%eax
80105bbc:	e9 13 01 00 00       	jmp    80105cd4 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105bc1:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc8:	8b 00                	mov    (%eax),%eax
80105bca:	83 ec 08             	sub    $0x8,%esp
80105bcd:	52                   	push   %edx
80105bce:	50                   	push   %eax
80105bcf:	e8 8d bc ff ff       	call   80101861 <ialloc>
80105bd4:	83 c4 10             	add    $0x10,%esp
80105bd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bda:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bde:	75 0d                	jne    80105bed <create+0xe9>
    panic("create: ialloc");
80105be0:	83 ec 0c             	sub    $0xc,%esp
80105be3:	68 b7 87 10 80       	push   $0x801087b7
80105be8:	e8 79 a9 ff ff       	call   80100566 <panic>

  ilock(ip);
80105bed:	83 ec 0c             	sub    $0xc,%esp
80105bf0:	ff 75 f0             	pushl  -0x10(%ebp)
80105bf3:	e8 1e bf ff ff       	call   80101b16 <ilock>
80105bf8:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfe:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105c02:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c09:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105c0d:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c14:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105c1a:	83 ec 0c             	sub    $0xc,%esp
80105c1d:	ff 75 f0             	pushl  -0x10(%ebp)
80105c20:	e8 1d bd ff ff       	call   80101942 <iupdate>
80105c25:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105c28:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105c2d:	75 6a                	jne    80105c99 <create+0x195>
    dp->nlink++;  // for ".."
80105c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c32:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c36:	83 c0 01             	add    $0x1,%eax
80105c39:	89 c2                	mov    %eax,%edx
80105c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3e:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105c42:	83 ec 0c             	sub    $0xc,%esp
80105c45:	ff 75 f4             	pushl  -0xc(%ebp)
80105c48:	e8 f5 bc ff ff       	call   80101942 <iupdate>
80105c4d:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105c50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c53:	8b 40 04             	mov    0x4(%eax),%eax
80105c56:	83 ec 04             	sub    $0x4,%esp
80105c59:	50                   	push   %eax
80105c5a:	68 91 87 10 80       	push   $0x80108791
80105c5f:	ff 75 f0             	pushl  -0x10(%ebp)
80105c62:	e8 cb c7 ff ff       	call   80102432 <dirlink>
80105c67:	83 c4 10             	add    $0x10,%esp
80105c6a:	85 c0                	test   %eax,%eax
80105c6c:	78 1e                	js     80105c8c <create+0x188>
80105c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c71:	8b 40 04             	mov    0x4(%eax),%eax
80105c74:	83 ec 04             	sub    $0x4,%esp
80105c77:	50                   	push   %eax
80105c78:	68 93 87 10 80       	push   $0x80108793
80105c7d:	ff 75 f0             	pushl  -0x10(%ebp)
80105c80:	e8 ad c7 ff ff       	call   80102432 <dirlink>
80105c85:	83 c4 10             	add    $0x10,%esp
80105c88:	85 c0                	test   %eax,%eax
80105c8a:	79 0d                	jns    80105c99 <create+0x195>
      panic("create dots");
80105c8c:	83 ec 0c             	sub    $0xc,%esp
80105c8f:	68 c6 87 10 80       	push   $0x801087c6
80105c94:	e8 cd a8 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9c:	8b 40 04             	mov    0x4(%eax),%eax
80105c9f:	83 ec 04             	sub    $0x4,%esp
80105ca2:	50                   	push   %eax
80105ca3:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ca6:	50                   	push   %eax
80105ca7:	ff 75 f4             	pushl  -0xc(%ebp)
80105caa:	e8 83 c7 ff ff       	call   80102432 <dirlink>
80105caf:	83 c4 10             	add    $0x10,%esp
80105cb2:	85 c0                	test   %eax,%eax
80105cb4:	79 0d                	jns    80105cc3 <create+0x1bf>
    panic("create: dirlink");
80105cb6:	83 ec 0c             	sub    $0xc,%esp
80105cb9:	68 d2 87 10 80       	push   $0x801087d2
80105cbe:	e8 a3 a8 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80105cc3:	83 ec 0c             	sub    $0xc,%esp
80105cc6:	ff 75 f4             	pushl  -0xc(%ebp)
80105cc9:	e8 02 c1 ff ff       	call   80101dd0 <iunlockput>
80105cce:	83 c4 10             	add    $0x10,%esp

  return ip;
80105cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105cd4:	c9                   	leave  
80105cd5:	c3                   	ret    

80105cd6 <sys_open>:

int
sys_open(void)
{
80105cd6:	55                   	push   %ebp
80105cd7:	89 e5                	mov    %esp,%ebp
80105cd9:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105cdc:	83 ec 08             	sub    $0x8,%esp
80105cdf:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ce2:	50                   	push   %eax
80105ce3:	6a 00                	push   $0x0
80105ce5:	e8 f5 f6 ff ff       	call   801053df <argstr>
80105cea:	83 c4 10             	add    $0x10,%esp
80105ced:	85 c0                	test   %eax,%eax
80105cef:	78 15                	js     80105d06 <sys_open+0x30>
80105cf1:	83 ec 08             	sub    $0x8,%esp
80105cf4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cf7:	50                   	push   %eax
80105cf8:	6a 01                	push   $0x1
80105cfa:	e8 5b f6 ff ff       	call   8010535a <argint>
80105cff:	83 c4 10             	add    $0x10,%esp
80105d02:	85 c0                	test   %eax,%eax
80105d04:	79 0a                	jns    80105d10 <sys_open+0x3a>
    return -1;
80105d06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0b:	e9 4d 01 00 00       	jmp    80105e5d <sys_open+0x187>
  if(omode & O_CREATE){
80105d10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d13:	25 00 02 00 00       	and    $0x200,%eax
80105d18:	85 c0                	test   %eax,%eax
80105d1a:	74 2f                	je     80105d4b <sys_open+0x75>
    begin_trans();
80105d1c:	e8 79 d7 ff ff       	call   8010349a <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105d21:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d24:	6a 00                	push   $0x0
80105d26:	6a 00                	push   $0x0
80105d28:	6a 02                	push   $0x2
80105d2a:	50                   	push   %eax
80105d2b:	e8 d4 fd ff ff       	call   80105b04 <create>
80105d30:	83 c4 10             	add    $0x10,%esp
80105d33:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105d36:	e8 b2 d7 ff ff       	call   801034ed <commit_trans>
    if(ip == 0)
80105d3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d3f:	75 66                	jne    80105da7 <sys_open+0xd1>
      return -1;
80105d41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d46:	e9 12 01 00 00       	jmp    80105e5d <sys_open+0x187>
  } else {
    if((ip = namei(path)) == 0)
80105d4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d4e:	83 ec 0c             	sub    $0xc,%esp
80105d51:	50                   	push   %eax
80105d52:	e8 77 c9 ff ff       	call   801026ce <namei>
80105d57:	83 c4 10             	add    $0x10,%esp
80105d5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d61:	75 0a                	jne    80105d6d <sys_open+0x97>
      return -1;
80105d63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d68:	e9 f0 00 00 00       	jmp    80105e5d <sys_open+0x187>
    ilock(ip);
80105d6d:	83 ec 0c             	sub    $0xc,%esp
80105d70:	ff 75 f4             	pushl  -0xc(%ebp)
80105d73:	e8 9e bd ff ff       	call   80101b16 <ilock>
80105d78:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d82:	66 83 f8 01          	cmp    $0x1,%ax
80105d86:	75 1f                	jne    80105da7 <sys_open+0xd1>
80105d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d8b:	85 c0                	test   %eax,%eax
80105d8d:	74 18                	je     80105da7 <sys_open+0xd1>
      iunlockput(ip);
80105d8f:	83 ec 0c             	sub    $0xc,%esp
80105d92:	ff 75 f4             	pushl  -0xc(%ebp)
80105d95:	e8 36 c0 ff ff       	call   80101dd0 <iunlockput>
80105d9a:	83 c4 10             	add    $0x10,%esp
      return -1;
80105d9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da2:	e9 b6 00 00 00       	jmp    80105e5d <sys_open+0x187>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105da7:	e8 d7 b3 ff ff       	call   80101183 <filealloc>
80105dac:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105daf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105db3:	74 17                	je     80105dcc <sys_open+0xf6>
80105db5:	83 ec 0c             	sub    $0xc,%esp
80105db8:	ff 75 f0             	pushl  -0x10(%ebp)
80105dbb:	e8 4b f7 ff ff       	call   8010550b <fdalloc>
80105dc0:	83 c4 10             	add    $0x10,%esp
80105dc3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105dc6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105dca:	79 29                	jns    80105df5 <sys_open+0x11f>
    if(f)
80105dcc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dd0:	74 0e                	je     80105de0 <sys_open+0x10a>
      fileclose(f);
80105dd2:	83 ec 0c             	sub    $0xc,%esp
80105dd5:	ff 75 f0             	pushl  -0x10(%ebp)
80105dd8:	e8 64 b4 ff ff       	call   80101241 <fileclose>
80105ddd:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105de0:	83 ec 0c             	sub    $0xc,%esp
80105de3:	ff 75 f4             	pushl  -0xc(%ebp)
80105de6:	e8 e5 bf ff ff       	call   80101dd0 <iunlockput>
80105deb:	83 c4 10             	add    $0x10,%esp
    return -1;
80105dee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df3:	eb 68                	jmp    80105e5d <sys_open+0x187>
  }
  iunlock(ip);
80105df5:	83 ec 0c             	sub    $0xc,%esp
80105df8:	ff 75 f4             	pushl  -0xc(%ebp)
80105dfb:	e8 6e be ff ff       	call   80101c6e <iunlock>
80105e00:	83 c4 10             	add    $0x10,%esp

  f->type = FD_INODE;
80105e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e06:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e12:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e18:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105e1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e22:	83 e0 01             	and    $0x1,%eax
80105e25:	85 c0                	test   %eax,%eax
80105e27:	0f 94 c0             	sete   %al
80105e2a:	89 c2                	mov    %eax,%edx
80105e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105e32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e35:	83 e0 01             	and    $0x1,%eax
80105e38:	85 c0                	test   %eax,%eax
80105e3a:	75 0a                	jne    80105e46 <sys_open+0x170>
80105e3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e3f:	83 e0 02             	and    $0x2,%eax
80105e42:	85 c0                	test   %eax,%eax
80105e44:	74 07                	je     80105e4d <sys_open+0x177>
80105e46:	b8 01 00 00 00       	mov    $0x1,%eax
80105e4b:	eb 05                	jmp    80105e52 <sys_open+0x17c>
80105e4d:	b8 00 00 00 00       	mov    $0x0,%eax
80105e52:	89 c2                	mov    %eax,%edx
80105e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e57:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105e5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105e5d:	c9                   	leave  
80105e5e:	c3                   	ret    

80105e5f <sys_mkdir>:

int
sys_mkdir(void)
{
80105e5f:	55                   	push   %ebp
80105e60:	89 e5                	mov    %esp,%ebp
80105e62:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80105e65:	e8 30 d6 ff ff       	call   8010349a <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105e6a:	83 ec 08             	sub    $0x8,%esp
80105e6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e70:	50                   	push   %eax
80105e71:	6a 00                	push   $0x0
80105e73:	e8 67 f5 ff ff       	call   801053df <argstr>
80105e78:	83 c4 10             	add    $0x10,%esp
80105e7b:	85 c0                	test   %eax,%eax
80105e7d:	78 1b                	js     80105e9a <sys_mkdir+0x3b>
80105e7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e82:	6a 00                	push   $0x0
80105e84:	6a 00                	push   $0x0
80105e86:	6a 01                	push   $0x1
80105e88:	50                   	push   %eax
80105e89:	e8 76 fc ff ff       	call   80105b04 <create>
80105e8e:	83 c4 10             	add    $0x10,%esp
80105e91:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e94:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e98:	75 0c                	jne    80105ea6 <sys_mkdir+0x47>
    commit_trans();
80105e9a:	e8 4e d6 ff ff       	call   801034ed <commit_trans>
    return -1;
80105e9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea4:	eb 18                	jmp    80105ebe <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105ea6:	83 ec 0c             	sub    $0xc,%esp
80105ea9:	ff 75 f4             	pushl  -0xc(%ebp)
80105eac:	e8 1f bf ff ff       	call   80101dd0 <iunlockput>
80105eb1:	83 c4 10             	add    $0x10,%esp
  commit_trans();
80105eb4:	e8 34 d6 ff ff       	call   801034ed <commit_trans>
  return 0;
80105eb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ebe:	c9                   	leave  
80105ebf:	c3                   	ret    

80105ec0 <sys_mknod>:

int
sys_mknod(void)
{
80105ec0:	55                   	push   %ebp
80105ec1:	89 e5                	mov    %esp,%ebp
80105ec3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80105ec6:	e8 cf d5 ff ff       	call   8010349a <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80105ecb:	83 ec 08             	sub    $0x8,%esp
80105ece:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ed1:	50                   	push   %eax
80105ed2:	6a 00                	push   $0x0
80105ed4:	e8 06 f5 ff ff       	call   801053df <argstr>
80105ed9:	83 c4 10             	add    $0x10,%esp
80105edc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105edf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ee3:	78 4f                	js     80105f34 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80105ee5:	83 ec 08             	sub    $0x8,%esp
80105ee8:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105eeb:	50                   	push   %eax
80105eec:	6a 01                	push   $0x1
80105eee:	e8 67 f4 ff ff       	call   8010535a <argint>
80105ef3:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80105ef6:	85 c0                	test   %eax,%eax
80105ef8:	78 3a                	js     80105f34 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105efa:	83 ec 08             	sub    $0x8,%esp
80105efd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f00:	50                   	push   %eax
80105f01:	6a 02                	push   $0x2
80105f03:	e8 52 f4 ff ff       	call   8010535a <argint>
80105f08:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105f0b:	85 c0                	test   %eax,%eax
80105f0d:	78 25                	js     80105f34 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105f0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f12:	0f bf c8             	movswl %ax,%ecx
80105f15:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f18:	0f bf d0             	movswl %ax,%edx
80105f1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105f1e:	51                   	push   %ecx
80105f1f:	52                   	push   %edx
80105f20:	6a 03                	push   $0x3
80105f22:	50                   	push   %eax
80105f23:	e8 dc fb ff ff       	call   80105b04 <create>
80105f28:	83 c4 10             	add    $0x10,%esp
80105f2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f32:	75 0c                	jne    80105f40 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80105f34:	e8 b4 d5 ff ff       	call   801034ed <commit_trans>
    return -1;
80105f39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f3e:	eb 18                	jmp    80105f58 <sys_mknod+0x98>
  }
  iunlockput(ip);
80105f40:	83 ec 0c             	sub    $0xc,%esp
80105f43:	ff 75 f0             	pushl  -0x10(%ebp)
80105f46:	e8 85 be ff ff       	call   80101dd0 <iunlockput>
80105f4b:	83 c4 10             	add    $0x10,%esp
  commit_trans();
80105f4e:	e8 9a d5 ff ff       	call   801034ed <commit_trans>
  return 0;
80105f53:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f58:	c9                   	leave  
80105f59:	c3                   	ret    

80105f5a <sys_chdir>:

int
sys_chdir(void)
{
80105f5a:	55                   	push   %ebp
80105f5b:	89 e5                	mov    %esp,%ebp
80105f5d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80105f60:	83 ec 08             	sub    $0x8,%esp
80105f63:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f66:	50                   	push   %eax
80105f67:	6a 00                	push   $0x0
80105f69:	e8 71 f4 ff ff       	call   801053df <argstr>
80105f6e:	83 c4 10             	add    $0x10,%esp
80105f71:	85 c0                	test   %eax,%eax
80105f73:	78 18                	js     80105f8d <sys_chdir+0x33>
80105f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f78:	83 ec 0c             	sub    $0xc,%esp
80105f7b:	50                   	push   %eax
80105f7c:	e8 4d c7 ff ff       	call   801026ce <namei>
80105f81:	83 c4 10             	add    $0x10,%esp
80105f84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f8b:	75 07                	jne    80105f94 <sys_chdir+0x3a>
    return -1;
80105f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f92:	eb 64                	jmp    80105ff8 <sys_chdir+0x9e>
  ilock(ip);
80105f94:	83 ec 0c             	sub    $0xc,%esp
80105f97:	ff 75 f4             	pushl  -0xc(%ebp)
80105f9a:	e8 77 bb ff ff       	call   80101b16 <ilock>
80105f9f:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fa9:	66 83 f8 01          	cmp    $0x1,%ax
80105fad:	74 15                	je     80105fc4 <sys_chdir+0x6a>
    iunlockput(ip);
80105faf:	83 ec 0c             	sub    $0xc,%esp
80105fb2:	ff 75 f4             	pushl  -0xc(%ebp)
80105fb5:	e8 16 be ff ff       	call   80101dd0 <iunlockput>
80105fba:	83 c4 10             	add    $0x10,%esp
    return -1;
80105fbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc2:	eb 34                	jmp    80105ff8 <sys_chdir+0x9e>
  }
  iunlock(ip);
80105fc4:	83 ec 0c             	sub    $0xc,%esp
80105fc7:	ff 75 f4             	pushl  -0xc(%ebp)
80105fca:	e8 9f bc ff ff       	call   80101c6e <iunlock>
80105fcf:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80105fd2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fd8:	8b 40 68             	mov    0x68(%eax),%eax
80105fdb:	83 ec 0c             	sub    $0xc,%esp
80105fde:	50                   	push   %eax
80105fdf:	e8 fc bc ff ff       	call   80101ce0 <iput>
80105fe4:	83 c4 10             	add    $0x10,%esp
  proc->cwd = ip;
80105fe7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ff0:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105ff3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ff8:	c9                   	leave  
80105ff9:	c3                   	ret    

80105ffa <sys_exec>:

int
sys_exec(void)
{
80105ffa:	55                   	push   %ebp
80105ffb:	89 e5                	mov    %esp,%ebp
80105ffd:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106003:	83 ec 08             	sub    $0x8,%esp
80106006:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106009:	50                   	push   %eax
8010600a:	6a 00                	push   $0x0
8010600c:	e8 ce f3 ff ff       	call   801053df <argstr>
80106011:	83 c4 10             	add    $0x10,%esp
80106014:	85 c0                	test   %eax,%eax
80106016:	78 18                	js     80106030 <sys_exec+0x36>
80106018:	83 ec 08             	sub    $0x8,%esp
8010601b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106021:	50                   	push   %eax
80106022:	6a 01                	push   $0x1
80106024:	e8 31 f3 ff ff       	call   8010535a <argint>
80106029:	83 c4 10             	add    $0x10,%esp
8010602c:	85 c0                	test   %eax,%eax
8010602e:	79 0a                	jns    8010603a <sys_exec+0x40>
    return -1;
80106030:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106035:	e9 c6 00 00 00       	jmp    80106100 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010603a:	83 ec 04             	sub    $0x4,%esp
8010603d:	68 80 00 00 00       	push   $0x80
80106042:	6a 00                	push   $0x0
80106044:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010604a:	50                   	push   %eax
8010604b:	e8 e5 ef ff ff       	call   80105035 <memset>
80106050:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106053:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010605a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605d:	83 f8 1f             	cmp    $0x1f,%eax
80106060:	76 0a                	jbe    8010606c <sys_exec+0x72>
      return -1;
80106062:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106067:	e9 94 00 00 00       	jmp    80106100 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010606c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010606f:	c1 e0 02             	shl    $0x2,%eax
80106072:	89 c2                	mov    %eax,%edx
80106074:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010607a:	01 c2                	add    %eax,%edx
8010607c:	83 ec 08             	sub    $0x8,%esp
8010607f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106085:	50                   	push   %eax
80106086:	52                   	push   %edx
80106087:	e8 32 f2 ff ff       	call   801052be <fetchint>
8010608c:	83 c4 10             	add    $0x10,%esp
8010608f:	85 c0                	test   %eax,%eax
80106091:	79 07                	jns    8010609a <sys_exec+0xa0>
      return -1;
80106093:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106098:	eb 66                	jmp    80106100 <sys_exec+0x106>
    if(uarg == 0){
8010609a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801060a0:	85 c0                	test   %eax,%eax
801060a2:	75 27                	jne    801060cb <sys_exec+0xd1>
      argv[i] = 0;
801060a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a7:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801060ae:	00 00 00 00 
      break;
801060b2:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801060b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b6:	83 ec 08             	sub    $0x8,%esp
801060b9:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801060bf:	52                   	push   %edx
801060c0:	50                   	push   %eax
801060c1:	e8 af ac ff ff       	call   80100d75 <exec>
801060c6:	83 c4 10             	add    $0x10,%esp
801060c9:	eb 35                	jmp    80106100 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801060cb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801060d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060d4:	c1 e2 02             	shl    $0x2,%edx
801060d7:	01 c2                	add    %eax,%edx
801060d9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801060df:	83 ec 08             	sub    $0x8,%esp
801060e2:	52                   	push   %edx
801060e3:	50                   	push   %eax
801060e4:	e8 0f f2 ff ff       	call   801052f8 <fetchstr>
801060e9:	83 c4 10             	add    $0x10,%esp
801060ec:	85 c0                	test   %eax,%eax
801060ee:	79 07                	jns    801060f7 <sys_exec+0xfd>
      return -1;
801060f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f5:	eb 09                	jmp    80106100 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801060f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801060fb:	e9 5a ff ff ff       	jmp    8010605a <sys_exec+0x60>
  return exec(path, argv);
}
80106100:	c9                   	leave  
80106101:	c3                   	ret    

80106102 <sys_pipe>:

int
sys_pipe(void)
{
80106102:	55                   	push   %ebp
80106103:	89 e5                	mov    %esp,%ebp
80106105:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106108:	83 ec 04             	sub    $0x4,%esp
8010610b:	6a 08                	push   $0x8
8010610d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106110:	50                   	push   %eax
80106111:	6a 00                	push   $0x0
80106113:	e8 6a f2 ff ff       	call   80105382 <argptr>
80106118:	83 c4 10             	add    $0x10,%esp
8010611b:	85 c0                	test   %eax,%eax
8010611d:	79 0a                	jns    80106129 <sys_pipe+0x27>
    return -1;
8010611f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106124:	e9 af 00 00 00       	jmp    801061d8 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106129:	83 ec 08             	sub    $0x8,%esp
8010612c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010612f:	50                   	push   %eax
80106130:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106133:	50                   	push   %eax
80106134:	e8 1a dd ff ff       	call   80103e53 <pipealloc>
80106139:	83 c4 10             	add    $0x10,%esp
8010613c:	85 c0                	test   %eax,%eax
8010613e:	79 0a                	jns    8010614a <sys_pipe+0x48>
    return -1;
80106140:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106145:	e9 8e 00 00 00       	jmp    801061d8 <sys_pipe+0xd6>
  fd0 = -1;
8010614a:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106151:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106154:	83 ec 0c             	sub    $0xc,%esp
80106157:	50                   	push   %eax
80106158:	e8 ae f3 ff ff       	call   8010550b <fdalloc>
8010615d:	83 c4 10             	add    $0x10,%esp
80106160:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106163:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106167:	78 18                	js     80106181 <sys_pipe+0x7f>
80106169:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010616c:	83 ec 0c             	sub    $0xc,%esp
8010616f:	50                   	push   %eax
80106170:	e8 96 f3 ff ff       	call   8010550b <fdalloc>
80106175:	83 c4 10             	add    $0x10,%esp
80106178:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010617b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010617f:	79 3f                	jns    801061c0 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106181:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106185:	78 14                	js     8010619b <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106187:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010618d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106190:	83 c2 08             	add    $0x8,%edx
80106193:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010619a:	00 
    fileclose(rf);
8010619b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010619e:	83 ec 0c             	sub    $0xc,%esp
801061a1:	50                   	push   %eax
801061a2:	e8 9a b0 ff ff       	call   80101241 <fileclose>
801061a7:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801061aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ad:	83 ec 0c             	sub    $0xc,%esp
801061b0:	50                   	push   %eax
801061b1:	e8 8b b0 ff ff       	call   80101241 <fileclose>
801061b6:	83 c4 10             	add    $0x10,%esp
    return -1;
801061b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061be:	eb 18                	jmp    801061d8 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801061c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061c6:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801061c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061cb:	8d 50 04             	lea    0x4(%eax),%edx
801061ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d1:	89 02                	mov    %eax,(%edx)
  return 0;
801061d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061d8:	c9                   	leave  
801061d9:	c3                   	ret    

801061da <sys_getCuPos>:

//新增函数
int sys_getCuPos(void){
801061da:	55                   	push   %ebp
801061db:	89 e5                	mov    %esp,%ebp
801061dd:	83 ec 08             	sub    $0x8,%esp
  return getCuPos();
801061e0:	e8 71 a9 ff ff       	call   80100b56 <getCuPos>
}
801061e5:	c9                   	leave  
801061e6:	c3                   	ret    

801061e7 <sys_setCuPos>:
int sys_setCuPos(void){
801061e7:	55                   	push   %ebp
801061e8:	89 e5                	mov    %esp,%ebp
801061ea:	83 ec 18             	sub    $0x18,%esp
	int row,col;
	if(argint(0,&row)<0 || argint(1,&col)<0)
801061ed:	83 ec 08             	sub    $0x8,%esp
801061f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061f3:	50                   	push   %eax
801061f4:	6a 00                	push   $0x0
801061f6:	e8 5f f1 ff ff       	call   8010535a <argint>
801061fb:	83 c4 10             	add    $0x10,%esp
801061fe:	85 c0                	test   %eax,%eax
80106200:	78 15                	js     80106217 <sys_setCuPos+0x30>
80106202:	83 ec 08             	sub    $0x8,%esp
80106205:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106208:	50                   	push   %eax
80106209:	6a 01                	push   $0x1
8010620b:	e8 4a f1 ff ff       	call   8010535a <argint>
80106210:	83 c4 10             	add    $0x10,%esp
80106213:	85 c0                	test   %eax,%eax
80106215:	79 07                	jns    8010621e <sys_setCuPos+0x37>
		return -1;
80106217:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621c:	eb 18                	jmp    80106236 <sys_setCuPos+0x4f>
  setCuPos(row,col);
8010621e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106224:	83 ec 08             	sub    $0x8,%esp
80106227:	52                   	push   %edx
80106228:	50                   	push   %eax
80106229:	e8 7a a9 ff ff       	call   80100ba8 <setCuPos>
8010622e:	83 c4 10             	add    $0x10,%esp
  return 0;
80106231:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106236:	c9                   	leave  
80106237:	c3                   	ret    

80106238 <sys_getSnapshot>:
int sys_getSnapshot(void){
80106238:	55                   	push   %ebp
80106239:	89 e5                	mov    %esp,%ebp
8010623b:	83 ec 18             	sub    $0x18,%esp
  ushort *screen_buffer;
  int pos;
  if(argint(1,&pos)<0)return -1;
8010623e:	83 ec 08             	sub    $0x8,%esp
80106241:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106244:	50                   	push   %eax
80106245:	6a 01                	push   $0x1
80106247:	e8 0e f1 ff ff       	call   8010535a <argint>
8010624c:	83 c4 10             	add    $0x10,%esp
8010624f:	85 c0                	test   %eax,%eax
80106251:	79 07                	jns    8010625a <sys_getSnapshot+0x22>
80106253:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106258:	eb 38                	jmp    80106292 <sys_getSnapshot+0x5a>
  if(argptr(0,(char **)&screen_buffer, pos)<0)return -1;
8010625a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010625d:	83 ec 04             	sub    $0x4,%esp
80106260:	50                   	push   %eax
80106261:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106264:	50                   	push   %eax
80106265:	6a 00                	push   $0x0
80106267:	e8 16 f1 ff ff       	call   80105382 <argptr>
8010626c:	83 c4 10             	add    $0x10,%esp
8010626f:	85 c0                	test   %eax,%eax
80106271:	79 07                	jns    8010627a <sys_getSnapshot+0x42>
80106273:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106278:	eb 18                	jmp    80106292 <sys_getSnapshot+0x5a>
  
   getSnapshot(screen_buffer,pos);
8010627a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010627d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106280:	83 ec 08             	sub    $0x8,%esp
80106283:	52                   	push   %edx
80106284:	50                   	push   %eax
80106285:	e8 98 a9 ff ff       	call   80100c22 <getSnapshot>
8010628a:	83 c4 10             	add    $0x10,%esp
   return 0;
8010628d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106292:	c9                   	leave  
80106293:	c3                   	ret    

80106294 <sys_clearScreen>:
int sys_clearScreen(void){
80106294:	55                   	push   %ebp
80106295:	89 e5                	mov    %esp,%ebp
80106297:	83 ec 08             	sub    $0x8,%esp
    clearScreen();
8010629a:	e8 cc a9 ff ff       	call   80100c6b <clearScreen>
    return 0;
8010629f:	b8 00 00 00 00       	mov    $0x0,%eax
801062a4:	c9                   	leave  
801062a5:	c3                   	ret    

801062a6 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801062a6:	55                   	push   %ebp
801062a7:	89 e5                	mov    %esp,%ebp
801062a9:	83 ec 08             	sub    $0x8,%esp
  return fork();
801062ac:	e8 98 e2 ff ff       	call   80104549 <fork>
}
801062b1:	c9                   	leave  
801062b2:	c3                   	ret    

801062b3 <sys_exit>:

int
sys_exit(void)
{
801062b3:	55                   	push   %ebp
801062b4:	89 e5                	mov    %esp,%ebp
801062b6:	83 ec 08             	sub    $0x8,%esp
  exit();
801062b9:	e8 fc e3 ff ff       	call   801046ba <exit>
  return 0;  // not reached
801062be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062c3:	c9                   	leave  
801062c4:	c3                   	ret    

801062c5 <sys_wait>:

int
sys_wait(void)
{
801062c5:	55                   	push   %ebp
801062c6:	89 e5                	mov    %esp,%ebp
801062c8:	83 ec 08             	sub    $0x8,%esp
  return wait();
801062cb:	e8 18 e5 ff ff       	call   801047e8 <wait>
}
801062d0:	c9                   	leave  
801062d1:	c3                   	ret    

801062d2 <sys_kill>:

int
sys_kill(void)
{
801062d2:	55                   	push   %ebp
801062d3:	89 e5                	mov    %esp,%ebp
801062d5:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801062d8:	83 ec 08             	sub    $0x8,%esp
801062db:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062de:	50                   	push   %eax
801062df:	6a 00                	push   $0x0
801062e1:	e8 74 f0 ff ff       	call   8010535a <argint>
801062e6:	83 c4 10             	add    $0x10,%esp
801062e9:	85 c0                	test   %eax,%eax
801062eb:	79 07                	jns    801062f4 <sys_kill+0x22>
    return -1;
801062ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f2:	eb 0f                	jmp    80106303 <sys_kill+0x31>
  return kill(pid);
801062f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f7:	83 ec 0c             	sub    $0xc,%esp
801062fa:	50                   	push   %eax
801062fb:	e8 fb e8 ff ff       	call   80104bfb <kill>
80106300:	83 c4 10             	add    $0x10,%esp
}
80106303:	c9                   	leave  
80106304:	c3                   	ret    

80106305 <sys_getpid>:

int
sys_getpid(void)
{
80106305:	55                   	push   %ebp
80106306:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106308:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010630e:	8b 40 10             	mov    0x10(%eax),%eax
}
80106311:	5d                   	pop    %ebp
80106312:	c3                   	ret    

80106313 <sys_sbrk>:

int
sys_sbrk(void)
{
80106313:	55                   	push   %ebp
80106314:	89 e5                	mov    %esp,%ebp
80106316:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106319:	83 ec 08             	sub    $0x8,%esp
8010631c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010631f:	50                   	push   %eax
80106320:	6a 00                	push   $0x0
80106322:	e8 33 f0 ff ff       	call   8010535a <argint>
80106327:	83 c4 10             	add    $0x10,%esp
8010632a:	85 c0                	test   %eax,%eax
8010632c:	79 07                	jns    80106335 <sys_sbrk+0x22>
    return -1;
8010632e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106333:	eb 28                	jmp    8010635d <sys_sbrk+0x4a>
  addr = proc->sz;
80106335:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010633b:	8b 00                	mov    (%eax),%eax
8010633d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106340:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106343:	83 ec 0c             	sub    $0xc,%esp
80106346:	50                   	push   %eax
80106347:	e8 5a e1 ff ff       	call   801044a6 <growproc>
8010634c:	83 c4 10             	add    $0x10,%esp
8010634f:	85 c0                	test   %eax,%eax
80106351:	79 07                	jns    8010635a <sys_sbrk+0x47>
    return -1;
80106353:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106358:	eb 03                	jmp    8010635d <sys_sbrk+0x4a>
  return addr;
8010635a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010635d:	c9                   	leave  
8010635e:	c3                   	ret    

8010635f <sys_sleep>:

int
sys_sleep(void)
{
8010635f:	55                   	push   %ebp
80106360:	89 e5                	mov    %esp,%ebp
80106362:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106365:	83 ec 08             	sub    $0x8,%esp
80106368:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010636b:	50                   	push   %eax
8010636c:	6a 00                	push   $0x0
8010636e:	e8 e7 ef ff ff       	call   8010535a <argint>
80106373:	83 c4 10             	add    $0x10,%esp
80106376:	85 c0                	test   %eax,%eax
80106378:	79 07                	jns    80106381 <sys_sleep+0x22>
    return -1;
8010637a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637f:	eb 77                	jmp    801063f8 <sys_sleep+0x99>
  acquire(&tickslock);
80106381:	83 ec 0c             	sub    $0xc,%esp
80106384:	68 80 1e 11 80       	push   $0x80111e80
80106389:	e8 44 ea ff ff       	call   80104dd2 <acquire>
8010638e:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106391:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80106396:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106399:	eb 39                	jmp    801063d4 <sys_sleep+0x75>
    if(proc->killed){
8010639b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063a1:	8b 40 24             	mov    0x24(%eax),%eax
801063a4:	85 c0                	test   %eax,%eax
801063a6:	74 17                	je     801063bf <sys_sleep+0x60>
      release(&tickslock);
801063a8:	83 ec 0c             	sub    $0xc,%esp
801063ab:	68 80 1e 11 80       	push   $0x80111e80
801063b0:	e8 84 ea ff ff       	call   80104e39 <release>
801063b5:	83 c4 10             	add    $0x10,%esp
      return -1;
801063b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063bd:	eb 39                	jmp    801063f8 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801063bf:	83 ec 08             	sub    $0x8,%esp
801063c2:	68 80 1e 11 80       	push   $0x80111e80
801063c7:	68 c0 26 11 80       	push   $0x801126c0
801063cc:	e8 08 e7 ff ff       	call   80104ad9 <sleep>
801063d1:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801063d4:	a1 c0 26 11 80       	mov    0x801126c0,%eax
801063d9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801063dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063df:	39 d0                	cmp    %edx,%eax
801063e1:	72 b8                	jb     8010639b <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801063e3:	83 ec 0c             	sub    $0xc,%esp
801063e6:	68 80 1e 11 80       	push   $0x80111e80
801063eb:	e8 49 ea ff ff       	call   80104e39 <release>
801063f0:	83 c4 10             	add    $0x10,%esp
  return 0;
801063f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063f8:	c9                   	leave  
801063f9:	c3                   	ret    

801063fa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801063fa:	55                   	push   %ebp
801063fb:	89 e5                	mov    %esp,%ebp
801063fd:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106400:	83 ec 0c             	sub    $0xc,%esp
80106403:	68 80 1e 11 80       	push   $0x80111e80
80106408:	e8 c5 e9 ff ff       	call   80104dd2 <acquire>
8010640d:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106410:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80106415:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106418:	83 ec 0c             	sub    $0xc,%esp
8010641b:	68 80 1e 11 80       	push   $0x80111e80
80106420:	e8 14 ea ff ff       	call   80104e39 <release>
80106425:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106428:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010642b:	c9                   	leave  
8010642c:	c3                   	ret    

8010642d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010642d:	55                   	push   %ebp
8010642e:	89 e5                	mov    %esp,%ebp
80106430:	83 ec 08             	sub    $0x8,%esp
80106433:	8b 55 08             	mov    0x8(%ebp),%edx
80106436:	8b 45 0c             	mov    0xc(%ebp),%eax
80106439:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010643d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106440:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106444:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106448:	ee                   	out    %al,(%dx)
}
80106449:	90                   	nop
8010644a:	c9                   	leave  
8010644b:	c3                   	ret    

8010644c <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010644c:	55                   	push   %ebp
8010644d:	89 e5                	mov    %esp,%ebp
8010644f:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106452:	6a 34                	push   $0x34
80106454:	6a 43                	push   $0x43
80106456:	e8 d2 ff ff ff       	call   8010642d <outb>
8010645b:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010645e:	68 9c 00 00 00       	push   $0x9c
80106463:	6a 40                	push   $0x40
80106465:	e8 c3 ff ff ff       	call   8010642d <outb>
8010646a:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
8010646d:	6a 2e                	push   $0x2e
8010646f:	6a 40                	push   $0x40
80106471:	e8 b7 ff ff ff       	call   8010642d <outb>
80106476:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106479:	83 ec 0c             	sub    $0xc,%esp
8010647c:	6a 00                	push   $0x0
8010647e:	e8 ba d8 ff ff       	call   80103d3d <picenable>
80106483:	83 c4 10             	add    $0x10,%esp
}
80106486:	90                   	nop
80106487:	c9                   	leave  
80106488:	c3                   	ret    

80106489 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106489:	1e                   	push   %ds
  pushl %es
8010648a:	06                   	push   %es
  pushl %fs
8010648b:	0f a0                	push   %fs
  pushl %gs
8010648d:	0f a8                	push   %gs
  pushal
8010648f:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106490:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106494:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106496:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106498:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010649c:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010649e:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801064a0:	54                   	push   %esp
  call trap
801064a1:	e8 d7 01 00 00       	call   8010667d <trap>
  addl $4, %esp
801064a6:	83 c4 04             	add    $0x4,%esp

801064a9 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801064a9:	61                   	popa   
  popl %gs
801064aa:	0f a9                	pop    %gs
  popl %fs
801064ac:	0f a1                	pop    %fs
  popl %es
801064ae:	07                   	pop    %es
  popl %ds
801064af:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801064b0:	83 c4 08             	add    $0x8,%esp
  iret
801064b3:	cf                   	iret   

801064b4 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801064b4:	55                   	push   %ebp
801064b5:	89 e5                	mov    %esp,%ebp
801064b7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801064ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801064bd:	83 e8 01             	sub    $0x1,%eax
801064c0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801064c4:	8b 45 08             	mov    0x8(%ebp),%eax
801064c7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801064cb:	8b 45 08             	mov    0x8(%ebp),%eax
801064ce:	c1 e8 10             	shr    $0x10,%eax
801064d1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801064d5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801064d8:	0f 01 18             	lidtl  (%eax)
}
801064db:	90                   	nop
801064dc:	c9                   	leave  
801064dd:	c3                   	ret    

801064de <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801064de:	55                   	push   %ebp
801064df:	89 e5                	mov    %esp,%ebp
801064e1:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801064e4:	0f 20 d0             	mov    %cr2,%eax
801064e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801064ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801064ed:	c9                   	leave  
801064ee:	c3                   	ret    

801064ef <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801064ef:	55                   	push   %ebp
801064f0:	89 e5                	mov    %esp,%ebp
801064f2:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801064f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801064fc:	e9 c3 00 00 00       	jmp    801065c4 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106504:	8b 04 85 a8 b0 10 80 	mov    -0x7fef4f58(,%eax,4),%eax
8010650b:	89 c2                	mov    %eax,%edx
8010650d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106510:	66 89 14 c5 c0 1e 11 	mov    %dx,-0x7feee140(,%eax,8)
80106517:	80 
80106518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651b:	66 c7 04 c5 c2 1e 11 	movw   $0x8,-0x7feee13e(,%eax,8)
80106522:	80 08 00 
80106525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106528:	0f b6 14 c5 c4 1e 11 	movzbl -0x7feee13c(,%eax,8),%edx
8010652f:	80 
80106530:	83 e2 e0             	and    $0xffffffe0,%edx
80106533:	88 14 c5 c4 1e 11 80 	mov    %dl,-0x7feee13c(,%eax,8)
8010653a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010653d:	0f b6 14 c5 c4 1e 11 	movzbl -0x7feee13c(,%eax,8),%edx
80106544:	80 
80106545:	83 e2 1f             	and    $0x1f,%edx
80106548:	88 14 c5 c4 1e 11 80 	mov    %dl,-0x7feee13c(,%eax,8)
8010654f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106552:	0f b6 14 c5 c5 1e 11 	movzbl -0x7feee13b(,%eax,8),%edx
80106559:	80 
8010655a:	83 e2 f0             	and    $0xfffffff0,%edx
8010655d:	83 ca 0e             	or     $0xe,%edx
80106560:	88 14 c5 c5 1e 11 80 	mov    %dl,-0x7feee13b(,%eax,8)
80106567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010656a:	0f b6 14 c5 c5 1e 11 	movzbl -0x7feee13b(,%eax,8),%edx
80106571:	80 
80106572:	83 e2 ef             	and    $0xffffffef,%edx
80106575:	88 14 c5 c5 1e 11 80 	mov    %dl,-0x7feee13b(,%eax,8)
8010657c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657f:	0f b6 14 c5 c5 1e 11 	movzbl -0x7feee13b(,%eax,8),%edx
80106586:	80 
80106587:	83 e2 9f             	and    $0xffffff9f,%edx
8010658a:	88 14 c5 c5 1e 11 80 	mov    %dl,-0x7feee13b(,%eax,8)
80106591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106594:	0f b6 14 c5 c5 1e 11 	movzbl -0x7feee13b(,%eax,8),%edx
8010659b:	80 
8010659c:	83 ca 80             	or     $0xffffff80,%edx
8010659f:	88 14 c5 c5 1e 11 80 	mov    %dl,-0x7feee13b(,%eax,8)
801065a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a9:	8b 04 85 a8 b0 10 80 	mov    -0x7fef4f58(,%eax,4),%eax
801065b0:	c1 e8 10             	shr    $0x10,%eax
801065b3:	89 c2                	mov    %eax,%edx
801065b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b8:	66 89 14 c5 c6 1e 11 	mov    %dx,-0x7feee13a(,%eax,8)
801065bf:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801065c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801065c4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801065cb:	0f 8e 30 ff ff ff    	jle    80106501 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801065d1:	a1 a8 b1 10 80       	mov    0x8010b1a8,%eax
801065d6:	66 a3 c0 20 11 80    	mov    %ax,0x801120c0
801065dc:	66 c7 05 c2 20 11 80 	movw   $0x8,0x801120c2
801065e3:	08 00 
801065e5:	0f b6 05 c4 20 11 80 	movzbl 0x801120c4,%eax
801065ec:	83 e0 e0             	and    $0xffffffe0,%eax
801065ef:	a2 c4 20 11 80       	mov    %al,0x801120c4
801065f4:	0f b6 05 c4 20 11 80 	movzbl 0x801120c4,%eax
801065fb:	83 e0 1f             	and    $0x1f,%eax
801065fe:	a2 c4 20 11 80       	mov    %al,0x801120c4
80106603:	0f b6 05 c5 20 11 80 	movzbl 0x801120c5,%eax
8010660a:	83 c8 0f             	or     $0xf,%eax
8010660d:	a2 c5 20 11 80       	mov    %al,0x801120c5
80106612:	0f b6 05 c5 20 11 80 	movzbl 0x801120c5,%eax
80106619:	83 e0 ef             	and    $0xffffffef,%eax
8010661c:	a2 c5 20 11 80       	mov    %al,0x801120c5
80106621:	0f b6 05 c5 20 11 80 	movzbl 0x801120c5,%eax
80106628:	83 c8 60             	or     $0x60,%eax
8010662b:	a2 c5 20 11 80       	mov    %al,0x801120c5
80106630:	0f b6 05 c5 20 11 80 	movzbl 0x801120c5,%eax
80106637:	83 c8 80             	or     $0xffffff80,%eax
8010663a:	a2 c5 20 11 80       	mov    %al,0x801120c5
8010663f:	a1 a8 b1 10 80       	mov    0x8010b1a8,%eax
80106644:	c1 e8 10             	shr    $0x10,%eax
80106647:	66 a3 c6 20 11 80    	mov    %ax,0x801120c6
  
  initlock(&tickslock, "time");
8010664d:	83 ec 08             	sub    $0x8,%esp
80106650:	68 e4 87 10 80       	push   $0x801087e4
80106655:	68 80 1e 11 80       	push   $0x80111e80
8010665a:	e8 51 e7 ff ff       	call   80104db0 <initlock>
8010665f:	83 c4 10             	add    $0x10,%esp
}
80106662:	90                   	nop
80106663:	c9                   	leave  
80106664:	c3                   	ret    

80106665 <idtinit>:

void
idtinit(void)
{
80106665:	55                   	push   %ebp
80106666:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106668:	68 00 08 00 00       	push   $0x800
8010666d:	68 c0 1e 11 80       	push   $0x80111ec0
80106672:	e8 3d fe ff ff       	call   801064b4 <lidt>
80106677:	83 c4 08             	add    $0x8,%esp
}
8010667a:	90                   	nop
8010667b:	c9                   	leave  
8010667c:	c3                   	ret    

8010667d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010667d:	55                   	push   %ebp
8010667e:	89 e5                	mov    %esp,%ebp
80106680:	57                   	push   %edi
80106681:	56                   	push   %esi
80106682:	53                   	push   %ebx
80106683:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106686:	8b 45 08             	mov    0x8(%ebp),%eax
80106689:	8b 40 30             	mov    0x30(%eax),%eax
8010668c:	83 f8 40             	cmp    $0x40,%eax
8010668f:	75 3e                	jne    801066cf <trap+0x52>
    if(proc->killed)
80106691:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106697:	8b 40 24             	mov    0x24(%eax),%eax
8010669a:	85 c0                	test   %eax,%eax
8010669c:	74 05                	je     801066a3 <trap+0x26>
      exit();
8010669e:	e8 17 e0 ff ff       	call   801046ba <exit>
    proc->tf = tf;
801066a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066a9:	8b 55 08             	mov    0x8(%ebp),%edx
801066ac:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801066af:	e8 5c ed ff ff       	call   80105410 <syscall>
    if(proc->killed)
801066b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066ba:	8b 40 24             	mov    0x24(%eax),%eax
801066bd:	85 c0                	test   %eax,%eax
801066bf:	0f 84 1b 02 00 00    	je     801068e0 <trap+0x263>
      exit();
801066c5:	e8 f0 df ff ff       	call   801046ba <exit>
    return;
801066ca:	e9 11 02 00 00       	jmp    801068e0 <trap+0x263>
  }

  switch(tf->trapno){
801066cf:	8b 45 08             	mov    0x8(%ebp),%eax
801066d2:	8b 40 30             	mov    0x30(%eax),%eax
801066d5:	83 e8 20             	sub    $0x20,%eax
801066d8:	83 f8 1f             	cmp    $0x1f,%eax
801066db:	0f 87 c0 00 00 00    	ja     801067a1 <trap+0x124>
801066e1:	8b 04 85 8c 88 10 80 	mov    -0x7fef7774(,%eax,4),%eax
801066e8:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801066ea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801066f0:	0f b6 00             	movzbl (%eax),%eax
801066f3:	84 c0                	test   %al,%al
801066f5:	75 3d                	jne    80106734 <trap+0xb7>
      acquire(&tickslock);
801066f7:	83 ec 0c             	sub    $0xc,%esp
801066fa:	68 80 1e 11 80       	push   $0x80111e80
801066ff:	e8 ce e6 ff ff       	call   80104dd2 <acquire>
80106704:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106707:	a1 c0 26 11 80       	mov    0x801126c0,%eax
8010670c:	83 c0 01             	add    $0x1,%eax
8010670f:	a3 c0 26 11 80       	mov    %eax,0x801126c0
      wakeup(&ticks);
80106714:	83 ec 0c             	sub    $0xc,%esp
80106717:	68 c0 26 11 80       	push   $0x801126c0
8010671c:	e8 a3 e4 ff ff       	call   80104bc4 <wakeup>
80106721:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106724:	83 ec 0c             	sub    $0xc,%esp
80106727:	68 80 1e 11 80       	push   $0x80111e80
8010672c:	e8 08 e7 ff ff       	call   80104e39 <release>
80106731:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106734:	e8 39 ca ff ff       	call   80103172 <lapiceoi>
    break;
80106739:	e9 1c 01 00 00       	jmp    8010685a <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010673e:	e8 5f c2 ff ff       	call   801029a2 <ideintr>
    lapiceoi();
80106743:	e8 2a ca ff ff       	call   80103172 <lapiceoi>
    break;
80106748:	e9 0d 01 00 00       	jmp    8010685a <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010674d:	e8 3f c8 ff ff       	call   80102f91 <kbdintr>
    lapiceoi();
80106752:	e8 1b ca ff ff       	call   80103172 <lapiceoi>
    break;
80106757:	e9 fe 00 00 00       	jmp    8010685a <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010675c:	e8 60 03 00 00       	call   80106ac1 <uartintr>
    lapiceoi();
80106761:	e8 0c ca ff ff       	call   80103172 <lapiceoi>
    break;
80106766:	e9 ef 00 00 00       	jmp    8010685a <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010676b:	8b 45 08             	mov    0x8(%ebp),%eax
8010676e:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106771:	8b 45 08             	mov    0x8(%ebp),%eax
80106774:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106778:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010677b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106781:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106784:	0f b6 c0             	movzbl %al,%eax
80106787:	51                   	push   %ecx
80106788:	52                   	push   %edx
80106789:	50                   	push   %eax
8010678a:	68 ec 87 10 80       	push   $0x801087ec
8010678f:	e8 32 9c ff ff       	call   801003c6 <cprintf>
80106794:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106797:	e8 d6 c9 ff ff       	call   80103172 <lapiceoi>
    break;
8010679c:	e9 b9 00 00 00       	jmp    8010685a <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801067a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067a7:	85 c0                	test   %eax,%eax
801067a9:	74 11                	je     801067bc <trap+0x13f>
801067ab:	8b 45 08             	mov    0x8(%ebp),%eax
801067ae:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067b2:	0f b7 c0             	movzwl %ax,%eax
801067b5:	83 e0 03             	and    $0x3,%eax
801067b8:	85 c0                	test   %eax,%eax
801067ba:	75 40                	jne    801067fc <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801067bc:	e8 1d fd ff ff       	call   801064de <rcr2>
801067c1:	89 c3                	mov    %eax,%ebx
801067c3:	8b 45 08             	mov    0x8(%ebp),%eax
801067c6:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801067c9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801067cf:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801067d2:	0f b6 d0             	movzbl %al,%edx
801067d5:	8b 45 08             	mov    0x8(%ebp),%eax
801067d8:	8b 40 30             	mov    0x30(%eax),%eax
801067db:	83 ec 0c             	sub    $0xc,%esp
801067de:	53                   	push   %ebx
801067df:	51                   	push   %ecx
801067e0:	52                   	push   %edx
801067e1:	50                   	push   %eax
801067e2:	68 10 88 10 80       	push   $0x80108810
801067e7:	e8 da 9b ff ff       	call   801003c6 <cprintf>
801067ec:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801067ef:	83 ec 0c             	sub    $0xc,%esp
801067f2:	68 42 88 10 80       	push   $0x80108842
801067f7:	e8 6a 9d ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801067fc:	e8 dd fc ff ff       	call   801064de <rcr2>
80106801:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106804:	8b 45 08             	mov    0x8(%ebp),%eax
80106807:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010680a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106810:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106813:	0f b6 d8             	movzbl %al,%ebx
80106816:	8b 45 08             	mov    0x8(%ebp),%eax
80106819:	8b 48 34             	mov    0x34(%eax),%ecx
8010681c:	8b 45 08             	mov    0x8(%ebp),%eax
8010681f:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106822:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106828:	8d 78 6c             	lea    0x6c(%eax),%edi
8010682b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106831:	8b 40 10             	mov    0x10(%eax),%eax
80106834:	ff 75 e4             	pushl  -0x1c(%ebp)
80106837:	56                   	push   %esi
80106838:	53                   	push   %ebx
80106839:	51                   	push   %ecx
8010683a:	52                   	push   %edx
8010683b:	57                   	push   %edi
8010683c:	50                   	push   %eax
8010683d:	68 48 88 10 80       	push   $0x80108848
80106842:	e8 7f 9b ff ff       	call   801003c6 <cprintf>
80106847:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010684a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106850:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106857:	eb 01                	jmp    8010685a <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106859:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010685a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106860:	85 c0                	test   %eax,%eax
80106862:	74 24                	je     80106888 <trap+0x20b>
80106864:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010686a:	8b 40 24             	mov    0x24(%eax),%eax
8010686d:	85 c0                	test   %eax,%eax
8010686f:	74 17                	je     80106888 <trap+0x20b>
80106871:	8b 45 08             	mov    0x8(%ebp),%eax
80106874:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106878:	0f b7 c0             	movzwl %ax,%eax
8010687b:	83 e0 03             	and    $0x3,%eax
8010687e:	83 f8 03             	cmp    $0x3,%eax
80106881:	75 05                	jne    80106888 <trap+0x20b>
    exit();
80106883:	e8 32 de ff ff       	call   801046ba <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106888:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010688e:	85 c0                	test   %eax,%eax
80106890:	74 1e                	je     801068b0 <trap+0x233>
80106892:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106898:	8b 40 0c             	mov    0xc(%eax),%eax
8010689b:	83 f8 04             	cmp    $0x4,%eax
8010689e:	75 10                	jne    801068b0 <trap+0x233>
801068a0:	8b 45 08             	mov    0x8(%ebp),%eax
801068a3:	8b 40 30             	mov    0x30(%eax),%eax
801068a6:	83 f8 20             	cmp    $0x20,%eax
801068a9:	75 05                	jne    801068b0 <trap+0x233>
    yield();
801068ab:	e8 bd e1 ff ff       	call   80104a6d <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801068b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068b6:	85 c0                	test   %eax,%eax
801068b8:	74 27                	je     801068e1 <trap+0x264>
801068ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068c0:	8b 40 24             	mov    0x24(%eax),%eax
801068c3:	85 c0                	test   %eax,%eax
801068c5:	74 1a                	je     801068e1 <trap+0x264>
801068c7:	8b 45 08             	mov    0x8(%ebp),%eax
801068ca:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068ce:	0f b7 c0             	movzwl %ax,%eax
801068d1:	83 e0 03             	and    $0x3,%eax
801068d4:	83 f8 03             	cmp    $0x3,%eax
801068d7:	75 08                	jne    801068e1 <trap+0x264>
    exit();
801068d9:	e8 dc dd ff ff       	call   801046ba <exit>
801068de:	eb 01                	jmp    801068e1 <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801068e0:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801068e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068e4:	5b                   	pop    %ebx
801068e5:	5e                   	pop    %esi
801068e6:	5f                   	pop    %edi
801068e7:	5d                   	pop    %ebp
801068e8:	c3                   	ret    

801068e9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801068e9:	55                   	push   %ebp
801068ea:	89 e5                	mov    %esp,%ebp
801068ec:	83 ec 14             	sub    $0x14,%esp
801068ef:	8b 45 08             	mov    0x8(%ebp),%eax
801068f2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801068f6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801068fa:	89 c2                	mov    %eax,%edx
801068fc:	ec                   	in     (%dx),%al
801068fd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106900:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106904:	c9                   	leave  
80106905:	c3                   	ret    

80106906 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106906:	55                   	push   %ebp
80106907:	89 e5                	mov    %esp,%ebp
80106909:	83 ec 08             	sub    $0x8,%esp
8010690c:	8b 55 08             	mov    0x8(%ebp),%edx
8010690f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106912:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106916:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106919:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010691d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106921:	ee                   	out    %al,(%dx)
}
80106922:	90                   	nop
80106923:	c9                   	leave  
80106924:	c3                   	ret    

80106925 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106925:	55                   	push   %ebp
80106926:	89 e5                	mov    %esp,%ebp
80106928:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010692b:	6a 00                	push   $0x0
8010692d:	68 fa 03 00 00       	push   $0x3fa
80106932:	e8 cf ff ff ff       	call   80106906 <outb>
80106937:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010693a:	68 80 00 00 00       	push   $0x80
8010693f:	68 fb 03 00 00       	push   $0x3fb
80106944:	e8 bd ff ff ff       	call   80106906 <outb>
80106949:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010694c:	6a 0c                	push   $0xc
8010694e:	68 f8 03 00 00       	push   $0x3f8
80106953:	e8 ae ff ff ff       	call   80106906 <outb>
80106958:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010695b:	6a 00                	push   $0x0
8010695d:	68 f9 03 00 00       	push   $0x3f9
80106962:	e8 9f ff ff ff       	call   80106906 <outb>
80106967:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010696a:	6a 03                	push   $0x3
8010696c:	68 fb 03 00 00       	push   $0x3fb
80106971:	e8 90 ff ff ff       	call   80106906 <outb>
80106976:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106979:	6a 00                	push   $0x0
8010697b:	68 fc 03 00 00       	push   $0x3fc
80106980:	e8 81 ff ff ff       	call   80106906 <outb>
80106985:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106988:	6a 01                	push   $0x1
8010698a:	68 f9 03 00 00       	push   $0x3f9
8010698f:	e8 72 ff ff ff       	call   80106906 <outb>
80106994:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106997:	68 fd 03 00 00       	push   $0x3fd
8010699c:	e8 48 ff ff ff       	call   801068e9 <inb>
801069a1:	83 c4 04             	add    $0x4,%esp
801069a4:	3c ff                	cmp    $0xff,%al
801069a6:	74 6e                	je     80106a16 <uartinit+0xf1>
    return;
  uart = 1;
801069a8:	c7 05 6c b6 10 80 01 	movl   $0x1,0x8010b66c
801069af:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801069b2:	68 fa 03 00 00       	push   $0x3fa
801069b7:	e8 2d ff ff ff       	call   801068e9 <inb>
801069bc:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801069bf:	68 f8 03 00 00       	push   $0x3f8
801069c4:	e8 20 ff ff ff       	call   801068e9 <inb>
801069c9:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
801069cc:	83 ec 0c             	sub    $0xc,%esp
801069cf:	6a 04                	push   $0x4
801069d1:	e8 67 d3 ff ff       	call   80103d3d <picenable>
801069d6:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801069d9:	83 ec 08             	sub    $0x8,%esp
801069dc:	6a 00                	push   $0x0
801069de:	6a 04                	push   $0x4
801069e0:	e8 5f c2 ff ff       	call   80102c44 <ioapicenable>
801069e5:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801069e8:	c7 45 f4 0c 89 10 80 	movl   $0x8010890c,-0xc(%ebp)
801069ef:	eb 19                	jmp    80106a0a <uartinit+0xe5>
    uartputc(*p);
801069f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f4:	0f b6 00             	movzbl (%eax),%eax
801069f7:	0f be c0             	movsbl %al,%eax
801069fa:	83 ec 0c             	sub    $0xc,%esp
801069fd:	50                   	push   %eax
801069fe:	e8 16 00 00 00       	call   80106a19 <uartputc>
80106a03:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106a06:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0d:	0f b6 00             	movzbl (%eax),%eax
80106a10:	84 c0                	test   %al,%al
80106a12:	75 dd                	jne    801069f1 <uartinit+0xcc>
80106a14:	eb 01                	jmp    80106a17 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106a16:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106a17:	c9                   	leave  
80106a18:	c3                   	ret    

80106a19 <uartputc>:

void
uartputc(int c)
{
80106a19:	55                   	push   %ebp
80106a1a:	89 e5                	mov    %esp,%ebp
80106a1c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106a1f:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106a24:	85 c0                	test   %eax,%eax
80106a26:	74 53                	je     80106a7b <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a2f:	eb 11                	jmp    80106a42 <uartputc+0x29>
    microdelay(10);
80106a31:	83 ec 0c             	sub    $0xc,%esp
80106a34:	6a 0a                	push   $0xa
80106a36:	e8 52 c7 ff ff       	call   8010318d <microdelay>
80106a3b:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a3e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a42:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106a46:	7f 1a                	jg     80106a62 <uartputc+0x49>
80106a48:	83 ec 0c             	sub    $0xc,%esp
80106a4b:	68 fd 03 00 00       	push   $0x3fd
80106a50:	e8 94 fe ff ff       	call   801068e9 <inb>
80106a55:	83 c4 10             	add    $0x10,%esp
80106a58:	0f b6 c0             	movzbl %al,%eax
80106a5b:	83 e0 20             	and    $0x20,%eax
80106a5e:	85 c0                	test   %eax,%eax
80106a60:	74 cf                	je     80106a31 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106a62:	8b 45 08             	mov    0x8(%ebp),%eax
80106a65:	0f b6 c0             	movzbl %al,%eax
80106a68:	83 ec 08             	sub    $0x8,%esp
80106a6b:	50                   	push   %eax
80106a6c:	68 f8 03 00 00       	push   $0x3f8
80106a71:	e8 90 fe ff ff       	call   80106906 <outb>
80106a76:	83 c4 10             	add    $0x10,%esp
80106a79:	eb 01                	jmp    80106a7c <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106a7b:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106a7c:	c9                   	leave  
80106a7d:	c3                   	ret    

80106a7e <uartgetc>:

static int
uartgetc(void)
{
80106a7e:	55                   	push   %ebp
80106a7f:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106a81:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106a86:	85 c0                	test   %eax,%eax
80106a88:	75 07                	jne    80106a91 <uartgetc+0x13>
    return -1;
80106a8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a8f:	eb 2e                	jmp    80106abf <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106a91:	68 fd 03 00 00       	push   $0x3fd
80106a96:	e8 4e fe ff ff       	call   801068e9 <inb>
80106a9b:	83 c4 04             	add    $0x4,%esp
80106a9e:	0f b6 c0             	movzbl %al,%eax
80106aa1:	83 e0 01             	and    $0x1,%eax
80106aa4:	85 c0                	test   %eax,%eax
80106aa6:	75 07                	jne    80106aaf <uartgetc+0x31>
    return -1;
80106aa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aad:	eb 10                	jmp    80106abf <uartgetc+0x41>
  return inb(COM1+0);
80106aaf:	68 f8 03 00 00       	push   $0x3f8
80106ab4:	e8 30 fe ff ff       	call   801068e9 <inb>
80106ab9:	83 c4 04             	add    $0x4,%esp
80106abc:	0f b6 c0             	movzbl %al,%eax
}
80106abf:	c9                   	leave  
80106ac0:	c3                   	ret    

80106ac1 <uartintr>:

void
uartintr(void)
{
80106ac1:	55                   	push   %ebp
80106ac2:	89 e5                	mov    %esp,%ebp
80106ac4:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106ac7:	83 ec 0c             	sub    $0xc,%esp
80106aca:	68 7e 6a 10 80       	push   $0x80106a7e
80106acf:	e8 09 9d ff ff       	call   801007dd <consoleintr>
80106ad4:	83 c4 10             	add    $0x10,%esp
}
80106ad7:	90                   	nop
80106ad8:	c9                   	leave  
80106ad9:	c3                   	ret    

80106ada <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106ada:	6a 00                	push   $0x0
  pushl $0
80106adc:	6a 00                	push   $0x0
  jmp alltraps
80106ade:	e9 a6 f9 ff ff       	jmp    80106489 <alltraps>

80106ae3 <vector1>:
.globl vector1
vector1:
  pushl $0
80106ae3:	6a 00                	push   $0x0
  pushl $1
80106ae5:	6a 01                	push   $0x1
  jmp alltraps
80106ae7:	e9 9d f9 ff ff       	jmp    80106489 <alltraps>

80106aec <vector2>:
.globl vector2
vector2:
  pushl $0
80106aec:	6a 00                	push   $0x0
  pushl $2
80106aee:	6a 02                	push   $0x2
  jmp alltraps
80106af0:	e9 94 f9 ff ff       	jmp    80106489 <alltraps>

80106af5 <vector3>:
.globl vector3
vector3:
  pushl $0
80106af5:	6a 00                	push   $0x0
  pushl $3
80106af7:	6a 03                	push   $0x3
  jmp alltraps
80106af9:	e9 8b f9 ff ff       	jmp    80106489 <alltraps>

80106afe <vector4>:
.globl vector4
vector4:
  pushl $0
80106afe:	6a 00                	push   $0x0
  pushl $4
80106b00:	6a 04                	push   $0x4
  jmp alltraps
80106b02:	e9 82 f9 ff ff       	jmp    80106489 <alltraps>

80106b07 <vector5>:
.globl vector5
vector5:
  pushl $0
80106b07:	6a 00                	push   $0x0
  pushl $5
80106b09:	6a 05                	push   $0x5
  jmp alltraps
80106b0b:	e9 79 f9 ff ff       	jmp    80106489 <alltraps>

80106b10 <vector6>:
.globl vector6
vector6:
  pushl $0
80106b10:	6a 00                	push   $0x0
  pushl $6
80106b12:	6a 06                	push   $0x6
  jmp alltraps
80106b14:	e9 70 f9 ff ff       	jmp    80106489 <alltraps>

80106b19 <vector7>:
.globl vector7
vector7:
  pushl $0
80106b19:	6a 00                	push   $0x0
  pushl $7
80106b1b:	6a 07                	push   $0x7
  jmp alltraps
80106b1d:	e9 67 f9 ff ff       	jmp    80106489 <alltraps>

80106b22 <vector8>:
.globl vector8
vector8:
  pushl $8
80106b22:	6a 08                	push   $0x8
  jmp alltraps
80106b24:	e9 60 f9 ff ff       	jmp    80106489 <alltraps>

80106b29 <vector9>:
.globl vector9
vector9:
  pushl $0
80106b29:	6a 00                	push   $0x0
  pushl $9
80106b2b:	6a 09                	push   $0x9
  jmp alltraps
80106b2d:	e9 57 f9 ff ff       	jmp    80106489 <alltraps>

80106b32 <vector10>:
.globl vector10
vector10:
  pushl $10
80106b32:	6a 0a                	push   $0xa
  jmp alltraps
80106b34:	e9 50 f9 ff ff       	jmp    80106489 <alltraps>

80106b39 <vector11>:
.globl vector11
vector11:
  pushl $11
80106b39:	6a 0b                	push   $0xb
  jmp alltraps
80106b3b:	e9 49 f9 ff ff       	jmp    80106489 <alltraps>

80106b40 <vector12>:
.globl vector12
vector12:
  pushl $12
80106b40:	6a 0c                	push   $0xc
  jmp alltraps
80106b42:	e9 42 f9 ff ff       	jmp    80106489 <alltraps>

80106b47 <vector13>:
.globl vector13
vector13:
  pushl $13
80106b47:	6a 0d                	push   $0xd
  jmp alltraps
80106b49:	e9 3b f9 ff ff       	jmp    80106489 <alltraps>

80106b4e <vector14>:
.globl vector14
vector14:
  pushl $14
80106b4e:	6a 0e                	push   $0xe
  jmp alltraps
80106b50:	e9 34 f9 ff ff       	jmp    80106489 <alltraps>

80106b55 <vector15>:
.globl vector15
vector15:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $15
80106b57:	6a 0f                	push   $0xf
  jmp alltraps
80106b59:	e9 2b f9 ff ff       	jmp    80106489 <alltraps>

80106b5e <vector16>:
.globl vector16
vector16:
  pushl $0
80106b5e:	6a 00                	push   $0x0
  pushl $16
80106b60:	6a 10                	push   $0x10
  jmp alltraps
80106b62:	e9 22 f9 ff ff       	jmp    80106489 <alltraps>

80106b67 <vector17>:
.globl vector17
vector17:
  pushl $17
80106b67:	6a 11                	push   $0x11
  jmp alltraps
80106b69:	e9 1b f9 ff ff       	jmp    80106489 <alltraps>

80106b6e <vector18>:
.globl vector18
vector18:
  pushl $0
80106b6e:	6a 00                	push   $0x0
  pushl $18
80106b70:	6a 12                	push   $0x12
  jmp alltraps
80106b72:	e9 12 f9 ff ff       	jmp    80106489 <alltraps>

80106b77 <vector19>:
.globl vector19
vector19:
  pushl $0
80106b77:	6a 00                	push   $0x0
  pushl $19
80106b79:	6a 13                	push   $0x13
  jmp alltraps
80106b7b:	e9 09 f9 ff ff       	jmp    80106489 <alltraps>

80106b80 <vector20>:
.globl vector20
vector20:
  pushl $0
80106b80:	6a 00                	push   $0x0
  pushl $20
80106b82:	6a 14                	push   $0x14
  jmp alltraps
80106b84:	e9 00 f9 ff ff       	jmp    80106489 <alltraps>

80106b89 <vector21>:
.globl vector21
vector21:
  pushl $0
80106b89:	6a 00                	push   $0x0
  pushl $21
80106b8b:	6a 15                	push   $0x15
  jmp alltraps
80106b8d:	e9 f7 f8 ff ff       	jmp    80106489 <alltraps>

80106b92 <vector22>:
.globl vector22
vector22:
  pushl $0
80106b92:	6a 00                	push   $0x0
  pushl $22
80106b94:	6a 16                	push   $0x16
  jmp alltraps
80106b96:	e9 ee f8 ff ff       	jmp    80106489 <alltraps>

80106b9b <vector23>:
.globl vector23
vector23:
  pushl $0
80106b9b:	6a 00                	push   $0x0
  pushl $23
80106b9d:	6a 17                	push   $0x17
  jmp alltraps
80106b9f:	e9 e5 f8 ff ff       	jmp    80106489 <alltraps>

80106ba4 <vector24>:
.globl vector24
vector24:
  pushl $0
80106ba4:	6a 00                	push   $0x0
  pushl $24
80106ba6:	6a 18                	push   $0x18
  jmp alltraps
80106ba8:	e9 dc f8 ff ff       	jmp    80106489 <alltraps>

80106bad <vector25>:
.globl vector25
vector25:
  pushl $0
80106bad:	6a 00                	push   $0x0
  pushl $25
80106baf:	6a 19                	push   $0x19
  jmp alltraps
80106bb1:	e9 d3 f8 ff ff       	jmp    80106489 <alltraps>

80106bb6 <vector26>:
.globl vector26
vector26:
  pushl $0
80106bb6:	6a 00                	push   $0x0
  pushl $26
80106bb8:	6a 1a                	push   $0x1a
  jmp alltraps
80106bba:	e9 ca f8 ff ff       	jmp    80106489 <alltraps>

80106bbf <vector27>:
.globl vector27
vector27:
  pushl $0
80106bbf:	6a 00                	push   $0x0
  pushl $27
80106bc1:	6a 1b                	push   $0x1b
  jmp alltraps
80106bc3:	e9 c1 f8 ff ff       	jmp    80106489 <alltraps>

80106bc8 <vector28>:
.globl vector28
vector28:
  pushl $0
80106bc8:	6a 00                	push   $0x0
  pushl $28
80106bca:	6a 1c                	push   $0x1c
  jmp alltraps
80106bcc:	e9 b8 f8 ff ff       	jmp    80106489 <alltraps>

80106bd1 <vector29>:
.globl vector29
vector29:
  pushl $0
80106bd1:	6a 00                	push   $0x0
  pushl $29
80106bd3:	6a 1d                	push   $0x1d
  jmp alltraps
80106bd5:	e9 af f8 ff ff       	jmp    80106489 <alltraps>

80106bda <vector30>:
.globl vector30
vector30:
  pushl $0
80106bda:	6a 00                	push   $0x0
  pushl $30
80106bdc:	6a 1e                	push   $0x1e
  jmp alltraps
80106bde:	e9 a6 f8 ff ff       	jmp    80106489 <alltraps>

80106be3 <vector31>:
.globl vector31
vector31:
  pushl $0
80106be3:	6a 00                	push   $0x0
  pushl $31
80106be5:	6a 1f                	push   $0x1f
  jmp alltraps
80106be7:	e9 9d f8 ff ff       	jmp    80106489 <alltraps>

80106bec <vector32>:
.globl vector32
vector32:
  pushl $0
80106bec:	6a 00                	push   $0x0
  pushl $32
80106bee:	6a 20                	push   $0x20
  jmp alltraps
80106bf0:	e9 94 f8 ff ff       	jmp    80106489 <alltraps>

80106bf5 <vector33>:
.globl vector33
vector33:
  pushl $0
80106bf5:	6a 00                	push   $0x0
  pushl $33
80106bf7:	6a 21                	push   $0x21
  jmp alltraps
80106bf9:	e9 8b f8 ff ff       	jmp    80106489 <alltraps>

80106bfe <vector34>:
.globl vector34
vector34:
  pushl $0
80106bfe:	6a 00                	push   $0x0
  pushl $34
80106c00:	6a 22                	push   $0x22
  jmp alltraps
80106c02:	e9 82 f8 ff ff       	jmp    80106489 <alltraps>

80106c07 <vector35>:
.globl vector35
vector35:
  pushl $0
80106c07:	6a 00                	push   $0x0
  pushl $35
80106c09:	6a 23                	push   $0x23
  jmp alltraps
80106c0b:	e9 79 f8 ff ff       	jmp    80106489 <alltraps>

80106c10 <vector36>:
.globl vector36
vector36:
  pushl $0
80106c10:	6a 00                	push   $0x0
  pushl $36
80106c12:	6a 24                	push   $0x24
  jmp alltraps
80106c14:	e9 70 f8 ff ff       	jmp    80106489 <alltraps>

80106c19 <vector37>:
.globl vector37
vector37:
  pushl $0
80106c19:	6a 00                	push   $0x0
  pushl $37
80106c1b:	6a 25                	push   $0x25
  jmp alltraps
80106c1d:	e9 67 f8 ff ff       	jmp    80106489 <alltraps>

80106c22 <vector38>:
.globl vector38
vector38:
  pushl $0
80106c22:	6a 00                	push   $0x0
  pushl $38
80106c24:	6a 26                	push   $0x26
  jmp alltraps
80106c26:	e9 5e f8 ff ff       	jmp    80106489 <alltraps>

80106c2b <vector39>:
.globl vector39
vector39:
  pushl $0
80106c2b:	6a 00                	push   $0x0
  pushl $39
80106c2d:	6a 27                	push   $0x27
  jmp alltraps
80106c2f:	e9 55 f8 ff ff       	jmp    80106489 <alltraps>

80106c34 <vector40>:
.globl vector40
vector40:
  pushl $0
80106c34:	6a 00                	push   $0x0
  pushl $40
80106c36:	6a 28                	push   $0x28
  jmp alltraps
80106c38:	e9 4c f8 ff ff       	jmp    80106489 <alltraps>

80106c3d <vector41>:
.globl vector41
vector41:
  pushl $0
80106c3d:	6a 00                	push   $0x0
  pushl $41
80106c3f:	6a 29                	push   $0x29
  jmp alltraps
80106c41:	e9 43 f8 ff ff       	jmp    80106489 <alltraps>

80106c46 <vector42>:
.globl vector42
vector42:
  pushl $0
80106c46:	6a 00                	push   $0x0
  pushl $42
80106c48:	6a 2a                	push   $0x2a
  jmp alltraps
80106c4a:	e9 3a f8 ff ff       	jmp    80106489 <alltraps>

80106c4f <vector43>:
.globl vector43
vector43:
  pushl $0
80106c4f:	6a 00                	push   $0x0
  pushl $43
80106c51:	6a 2b                	push   $0x2b
  jmp alltraps
80106c53:	e9 31 f8 ff ff       	jmp    80106489 <alltraps>

80106c58 <vector44>:
.globl vector44
vector44:
  pushl $0
80106c58:	6a 00                	push   $0x0
  pushl $44
80106c5a:	6a 2c                	push   $0x2c
  jmp alltraps
80106c5c:	e9 28 f8 ff ff       	jmp    80106489 <alltraps>

80106c61 <vector45>:
.globl vector45
vector45:
  pushl $0
80106c61:	6a 00                	push   $0x0
  pushl $45
80106c63:	6a 2d                	push   $0x2d
  jmp alltraps
80106c65:	e9 1f f8 ff ff       	jmp    80106489 <alltraps>

80106c6a <vector46>:
.globl vector46
vector46:
  pushl $0
80106c6a:	6a 00                	push   $0x0
  pushl $46
80106c6c:	6a 2e                	push   $0x2e
  jmp alltraps
80106c6e:	e9 16 f8 ff ff       	jmp    80106489 <alltraps>

80106c73 <vector47>:
.globl vector47
vector47:
  pushl $0
80106c73:	6a 00                	push   $0x0
  pushl $47
80106c75:	6a 2f                	push   $0x2f
  jmp alltraps
80106c77:	e9 0d f8 ff ff       	jmp    80106489 <alltraps>

80106c7c <vector48>:
.globl vector48
vector48:
  pushl $0
80106c7c:	6a 00                	push   $0x0
  pushl $48
80106c7e:	6a 30                	push   $0x30
  jmp alltraps
80106c80:	e9 04 f8 ff ff       	jmp    80106489 <alltraps>

80106c85 <vector49>:
.globl vector49
vector49:
  pushl $0
80106c85:	6a 00                	push   $0x0
  pushl $49
80106c87:	6a 31                	push   $0x31
  jmp alltraps
80106c89:	e9 fb f7 ff ff       	jmp    80106489 <alltraps>

80106c8e <vector50>:
.globl vector50
vector50:
  pushl $0
80106c8e:	6a 00                	push   $0x0
  pushl $50
80106c90:	6a 32                	push   $0x32
  jmp alltraps
80106c92:	e9 f2 f7 ff ff       	jmp    80106489 <alltraps>

80106c97 <vector51>:
.globl vector51
vector51:
  pushl $0
80106c97:	6a 00                	push   $0x0
  pushl $51
80106c99:	6a 33                	push   $0x33
  jmp alltraps
80106c9b:	e9 e9 f7 ff ff       	jmp    80106489 <alltraps>

80106ca0 <vector52>:
.globl vector52
vector52:
  pushl $0
80106ca0:	6a 00                	push   $0x0
  pushl $52
80106ca2:	6a 34                	push   $0x34
  jmp alltraps
80106ca4:	e9 e0 f7 ff ff       	jmp    80106489 <alltraps>

80106ca9 <vector53>:
.globl vector53
vector53:
  pushl $0
80106ca9:	6a 00                	push   $0x0
  pushl $53
80106cab:	6a 35                	push   $0x35
  jmp alltraps
80106cad:	e9 d7 f7 ff ff       	jmp    80106489 <alltraps>

80106cb2 <vector54>:
.globl vector54
vector54:
  pushl $0
80106cb2:	6a 00                	push   $0x0
  pushl $54
80106cb4:	6a 36                	push   $0x36
  jmp alltraps
80106cb6:	e9 ce f7 ff ff       	jmp    80106489 <alltraps>

80106cbb <vector55>:
.globl vector55
vector55:
  pushl $0
80106cbb:	6a 00                	push   $0x0
  pushl $55
80106cbd:	6a 37                	push   $0x37
  jmp alltraps
80106cbf:	e9 c5 f7 ff ff       	jmp    80106489 <alltraps>

80106cc4 <vector56>:
.globl vector56
vector56:
  pushl $0
80106cc4:	6a 00                	push   $0x0
  pushl $56
80106cc6:	6a 38                	push   $0x38
  jmp alltraps
80106cc8:	e9 bc f7 ff ff       	jmp    80106489 <alltraps>

80106ccd <vector57>:
.globl vector57
vector57:
  pushl $0
80106ccd:	6a 00                	push   $0x0
  pushl $57
80106ccf:	6a 39                	push   $0x39
  jmp alltraps
80106cd1:	e9 b3 f7 ff ff       	jmp    80106489 <alltraps>

80106cd6 <vector58>:
.globl vector58
vector58:
  pushl $0
80106cd6:	6a 00                	push   $0x0
  pushl $58
80106cd8:	6a 3a                	push   $0x3a
  jmp alltraps
80106cda:	e9 aa f7 ff ff       	jmp    80106489 <alltraps>

80106cdf <vector59>:
.globl vector59
vector59:
  pushl $0
80106cdf:	6a 00                	push   $0x0
  pushl $59
80106ce1:	6a 3b                	push   $0x3b
  jmp alltraps
80106ce3:	e9 a1 f7 ff ff       	jmp    80106489 <alltraps>

80106ce8 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ce8:	6a 00                	push   $0x0
  pushl $60
80106cea:	6a 3c                	push   $0x3c
  jmp alltraps
80106cec:	e9 98 f7 ff ff       	jmp    80106489 <alltraps>

80106cf1 <vector61>:
.globl vector61
vector61:
  pushl $0
80106cf1:	6a 00                	push   $0x0
  pushl $61
80106cf3:	6a 3d                	push   $0x3d
  jmp alltraps
80106cf5:	e9 8f f7 ff ff       	jmp    80106489 <alltraps>

80106cfa <vector62>:
.globl vector62
vector62:
  pushl $0
80106cfa:	6a 00                	push   $0x0
  pushl $62
80106cfc:	6a 3e                	push   $0x3e
  jmp alltraps
80106cfe:	e9 86 f7 ff ff       	jmp    80106489 <alltraps>

80106d03 <vector63>:
.globl vector63
vector63:
  pushl $0
80106d03:	6a 00                	push   $0x0
  pushl $63
80106d05:	6a 3f                	push   $0x3f
  jmp alltraps
80106d07:	e9 7d f7 ff ff       	jmp    80106489 <alltraps>

80106d0c <vector64>:
.globl vector64
vector64:
  pushl $0
80106d0c:	6a 00                	push   $0x0
  pushl $64
80106d0e:	6a 40                	push   $0x40
  jmp alltraps
80106d10:	e9 74 f7 ff ff       	jmp    80106489 <alltraps>

80106d15 <vector65>:
.globl vector65
vector65:
  pushl $0
80106d15:	6a 00                	push   $0x0
  pushl $65
80106d17:	6a 41                	push   $0x41
  jmp alltraps
80106d19:	e9 6b f7 ff ff       	jmp    80106489 <alltraps>

80106d1e <vector66>:
.globl vector66
vector66:
  pushl $0
80106d1e:	6a 00                	push   $0x0
  pushl $66
80106d20:	6a 42                	push   $0x42
  jmp alltraps
80106d22:	e9 62 f7 ff ff       	jmp    80106489 <alltraps>

80106d27 <vector67>:
.globl vector67
vector67:
  pushl $0
80106d27:	6a 00                	push   $0x0
  pushl $67
80106d29:	6a 43                	push   $0x43
  jmp alltraps
80106d2b:	e9 59 f7 ff ff       	jmp    80106489 <alltraps>

80106d30 <vector68>:
.globl vector68
vector68:
  pushl $0
80106d30:	6a 00                	push   $0x0
  pushl $68
80106d32:	6a 44                	push   $0x44
  jmp alltraps
80106d34:	e9 50 f7 ff ff       	jmp    80106489 <alltraps>

80106d39 <vector69>:
.globl vector69
vector69:
  pushl $0
80106d39:	6a 00                	push   $0x0
  pushl $69
80106d3b:	6a 45                	push   $0x45
  jmp alltraps
80106d3d:	e9 47 f7 ff ff       	jmp    80106489 <alltraps>

80106d42 <vector70>:
.globl vector70
vector70:
  pushl $0
80106d42:	6a 00                	push   $0x0
  pushl $70
80106d44:	6a 46                	push   $0x46
  jmp alltraps
80106d46:	e9 3e f7 ff ff       	jmp    80106489 <alltraps>

80106d4b <vector71>:
.globl vector71
vector71:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $71
80106d4d:	6a 47                	push   $0x47
  jmp alltraps
80106d4f:	e9 35 f7 ff ff       	jmp    80106489 <alltraps>

80106d54 <vector72>:
.globl vector72
vector72:
  pushl $0
80106d54:	6a 00                	push   $0x0
  pushl $72
80106d56:	6a 48                	push   $0x48
  jmp alltraps
80106d58:	e9 2c f7 ff ff       	jmp    80106489 <alltraps>

80106d5d <vector73>:
.globl vector73
vector73:
  pushl $0
80106d5d:	6a 00                	push   $0x0
  pushl $73
80106d5f:	6a 49                	push   $0x49
  jmp alltraps
80106d61:	e9 23 f7 ff ff       	jmp    80106489 <alltraps>

80106d66 <vector74>:
.globl vector74
vector74:
  pushl $0
80106d66:	6a 00                	push   $0x0
  pushl $74
80106d68:	6a 4a                	push   $0x4a
  jmp alltraps
80106d6a:	e9 1a f7 ff ff       	jmp    80106489 <alltraps>

80106d6f <vector75>:
.globl vector75
vector75:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $75
80106d71:	6a 4b                	push   $0x4b
  jmp alltraps
80106d73:	e9 11 f7 ff ff       	jmp    80106489 <alltraps>

80106d78 <vector76>:
.globl vector76
vector76:
  pushl $0
80106d78:	6a 00                	push   $0x0
  pushl $76
80106d7a:	6a 4c                	push   $0x4c
  jmp alltraps
80106d7c:	e9 08 f7 ff ff       	jmp    80106489 <alltraps>

80106d81 <vector77>:
.globl vector77
vector77:
  pushl $0
80106d81:	6a 00                	push   $0x0
  pushl $77
80106d83:	6a 4d                	push   $0x4d
  jmp alltraps
80106d85:	e9 ff f6 ff ff       	jmp    80106489 <alltraps>

80106d8a <vector78>:
.globl vector78
vector78:
  pushl $0
80106d8a:	6a 00                	push   $0x0
  pushl $78
80106d8c:	6a 4e                	push   $0x4e
  jmp alltraps
80106d8e:	e9 f6 f6 ff ff       	jmp    80106489 <alltraps>

80106d93 <vector79>:
.globl vector79
vector79:
  pushl $0
80106d93:	6a 00                	push   $0x0
  pushl $79
80106d95:	6a 4f                	push   $0x4f
  jmp alltraps
80106d97:	e9 ed f6 ff ff       	jmp    80106489 <alltraps>

80106d9c <vector80>:
.globl vector80
vector80:
  pushl $0
80106d9c:	6a 00                	push   $0x0
  pushl $80
80106d9e:	6a 50                	push   $0x50
  jmp alltraps
80106da0:	e9 e4 f6 ff ff       	jmp    80106489 <alltraps>

80106da5 <vector81>:
.globl vector81
vector81:
  pushl $0
80106da5:	6a 00                	push   $0x0
  pushl $81
80106da7:	6a 51                	push   $0x51
  jmp alltraps
80106da9:	e9 db f6 ff ff       	jmp    80106489 <alltraps>

80106dae <vector82>:
.globl vector82
vector82:
  pushl $0
80106dae:	6a 00                	push   $0x0
  pushl $82
80106db0:	6a 52                	push   $0x52
  jmp alltraps
80106db2:	e9 d2 f6 ff ff       	jmp    80106489 <alltraps>

80106db7 <vector83>:
.globl vector83
vector83:
  pushl $0
80106db7:	6a 00                	push   $0x0
  pushl $83
80106db9:	6a 53                	push   $0x53
  jmp alltraps
80106dbb:	e9 c9 f6 ff ff       	jmp    80106489 <alltraps>

80106dc0 <vector84>:
.globl vector84
vector84:
  pushl $0
80106dc0:	6a 00                	push   $0x0
  pushl $84
80106dc2:	6a 54                	push   $0x54
  jmp alltraps
80106dc4:	e9 c0 f6 ff ff       	jmp    80106489 <alltraps>

80106dc9 <vector85>:
.globl vector85
vector85:
  pushl $0
80106dc9:	6a 00                	push   $0x0
  pushl $85
80106dcb:	6a 55                	push   $0x55
  jmp alltraps
80106dcd:	e9 b7 f6 ff ff       	jmp    80106489 <alltraps>

80106dd2 <vector86>:
.globl vector86
vector86:
  pushl $0
80106dd2:	6a 00                	push   $0x0
  pushl $86
80106dd4:	6a 56                	push   $0x56
  jmp alltraps
80106dd6:	e9 ae f6 ff ff       	jmp    80106489 <alltraps>

80106ddb <vector87>:
.globl vector87
vector87:
  pushl $0
80106ddb:	6a 00                	push   $0x0
  pushl $87
80106ddd:	6a 57                	push   $0x57
  jmp alltraps
80106ddf:	e9 a5 f6 ff ff       	jmp    80106489 <alltraps>

80106de4 <vector88>:
.globl vector88
vector88:
  pushl $0
80106de4:	6a 00                	push   $0x0
  pushl $88
80106de6:	6a 58                	push   $0x58
  jmp alltraps
80106de8:	e9 9c f6 ff ff       	jmp    80106489 <alltraps>

80106ded <vector89>:
.globl vector89
vector89:
  pushl $0
80106ded:	6a 00                	push   $0x0
  pushl $89
80106def:	6a 59                	push   $0x59
  jmp alltraps
80106df1:	e9 93 f6 ff ff       	jmp    80106489 <alltraps>

80106df6 <vector90>:
.globl vector90
vector90:
  pushl $0
80106df6:	6a 00                	push   $0x0
  pushl $90
80106df8:	6a 5a                	push   $0x5a
  jmp alltraps
80106dfa:	e9 8a f6 ff ff       	jmp    80106489 <alltraps>

80106dff <vector91>:
.globl vector91
vector91:
  pushl $0
80106dff:	6a 00                	push   $0x0
  pushl $91
80106e01:	6a 5b                	push   $0x5b
  jmp alltraps
80106e03:	e9 81 f6 ff ff       	jmp    80106489 <alltraps>

80106e08 <vector92>:
.globl vector92
vector92:
  pushl $0
80106e08:	6a 00                	push   $0x0
  pushl $92
80106e0a:	6a 5c                	push   $0x5c
  jmp alltraps
80106e0c:	e9 78 f6 ff ff       	jmp    80106489 <alltraps>

80106e11 <vector93>:
.globl vector93
vector93:
  pushl $0
80106e11:	6a 00                	push   $0x0
  pushl $93
80106e13:	6a 5d                	push   $0x5d
  jmp alltraps
80106e15:	e9 6f f6 ff ff       	jmp    80106489 <alltraps>

80106e1a <vector94>:
.globl vector94
vector94:
  pushl $0
80106e1a:	6a 00                	push   $0x0
  pushl $94
80106e1c:	6a 5e                	push   $0x5e
  jmp alltraps
80106e1e:	e9 66 f6 ff ff       	jmp    80106489 <alltraps>

80106e23 <vector95>:
.globl vector95
vector95:
  pushl $0
80106e23:	6a 00                	push   $0x0
  pushl $95
80106e25:	6a 5f                	push   $0x5f
  jmp alltraps
80106e27:	e9 5d f6 ff ff       	jmp    80106489 <alltraps>

80106e2c <vector96>:
.globl vector96
vector96:
  pushl $0
80106e2c:	6a 00                	push   $0x0
  pushl $96
80106e2e:	6a 60                	push   $0x60
  jmp alltraps
80106e30:	e9 54 f6 ff ff       	jmp    80106489 <alltraps>

80106e35 <vector97>:
.globl vector97
vector97:
  pushl $0
80106e35:	6a 00                	push   $0x0
  pushl $97
80106e37:	6a 61                	push   $0x61
  jmp alltraps
80106e39:	e9 4b f6 ff ff       	jmp    80106489 <alltraps>

80106e3e <vector98>:
.globl vector98
vector98:
  pushl $0
80106e3e:	6a 00                	push   $0x0
  pushl $98
80106e40:	6a 62                	push   $0x62
  jmp alltraps
80106e42:	e9 42 f6 ff ff       	jmp    80106489 <alltraps>

80106e47 <vector99>:
.globl vector99
vector99:
  pushl $0
80106e47:	6a 00                	push   $0x0
  pushl $99
80106e49:	6a 63                	push   $0x63
  jmp alltraps
80106e4b:	e9 39 f6 ff ff       	jmp    80106489 <alltraps>

80106e50 <vector100>:
.globl vector100
vector100:
  pushl $0
80106e50:	6a 00                	push   $0x0
  pushl $100
80106e52:	6a 64                	push   $0x64
  jmp alltraps
80106e54:	e9 30 f6 ff ff       	jmp    80106489 <alltraps>

80106e59 <vector101>:
.globl vector101
vector101:
  pushl $0
80106e59:	6a 00                	push   $0x0
  pushl $101
80106e5b:	6a 65                	push   $0x65
  jmp alltraps
80106e5d:	e9 27 f6 ff ff       	jmp    80106489 <alltraps>

80106e62 <vector102>:
.globl vector102
vector102:
  pushl $0
80106e62:	6a 00                	push   $0x0
  pushl $102
80106e64:	6a 66                	push   $0x66
  jmp alltraps
80106e66:	e9 1e f6 ff ff       	jmp    80106489 <alltraps>

80106e6b <vector103>:
.globl vector103
vector103:
  pushl $0
80106e6b:	6a 00                	push   $0x0
  pushl $103
80106e6d:	6a 67                	push   $0x67
  jmp alltraps
80106e6f:	e9 15 f6 ff ff       	jmp    80106489 <alltraps>

80106e74 <vector104>:
.globl vector104
vector104:
  pushl $0
80106e74:	6a 00                	push   $0x0
  pushl $104
80106e76:	6a 68                	push   $0x68
  jmp alltraps
80106e78:	e9 0c f6 ff ff       	jmp    80106489 <alltraps>

80106e7d <vector105>:
.globl vector105
vector105:
  pushl $0
80106e7d:	6a 00                	push   $0x0
  pushl $105
80106e7f:	6a 69                	push   $0x69
  jmp alltraps
80106e81:	e9 03 f6 ff ff       	jmp    80106489 <alltraps>

80106e86 <vector106>:
.globl vector106
vector106:
  pushl $0
80106e86:	6a 00                	push   $0x0
  pushl $106
80106e88:	6a 6a                	push   $0x6a
  jmp alltraps
80106e8a:	e9 fa f5 ff ff       	jmp    80106489 <alltraps>

80106e8f <vector107>:
.globl vector107
vector107:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $107
80106e91:	6a 6b                	push   $0x6b
  jmp alltraps
80106e93:	e9 f1 f5 ff ff       	jmp    80106489 <alltraps>

80106e98 <vector108>:
.globl vector108
vector108:
  pushl $0
80106e98:	6a 00                	push   $0x0
  pushl $108
80106e9a:	6a 6c                	push   $0x6c
  jmp alltraps
80106e9c:	e9 e8 f5 ff ff       	jmp    80106489 <alltraps>

80106ea1 <vector109>:
.globl vector109
vector109:
  pushl $0
80106ea1:	6a 00                	push   $0x0
  pushl $109
80106ea3:	6a 6d                	push   $0x6d
  jmp alltraps
80106ea5:	e9 df f5 ff ff       	jmp    80106489 <alltraps>

80106eaa <vector110>:
.globl vector110
vector110:
  pushl $0
80106eaa:	6a 00                	push   $0x0
  pushl $110
80106eac:	6a 6e                	push   $0x6e
  jmp alltraps
80106eae:	e9 d6 f5 ff ff       	jmp    80106489 <alltraps>

80106eb3 <vector111>:
.globl vector111
vector111:
  pushl $0
80106eb3:	6a 00                	push   $0x0
  pushl $111
80106eb5:	6a 6f                	push   $0x6f
  jmp alltraps
80106eb7:	e9 cd f5 ff ff       	jmp    80106489 <alltraps>

80106ebc <vector112>:
.globl vector112
vector112:
  pushl $0
80106ebc:	6a 00                	push   $0x0
  pushl $112
80106ebe:	6a 70                	push   $0x70
  jmp alltraps
80106ec0:	e9 c4 f5 ff ff       	jmp    80106489 <alltraps>

80106ec5 <vector113>:
.globl vector113
vector113:
  pushl $0
80106ec5:	6a 00                	push   $0x0
  pushl $113
80106ec7:	6a 71                	push   $0x71
  jmp alltraps
80106ec9:	e9 bb f5 ff ff       	jmp    80106489 <alltraps>

80106ece <vector114>:
.globl vector114
vector114:
  pushl $0
80106ece:	6a 00                	push   $0x0
  pushl $114
80106ed0:	6a 72                	push   $0x72
  jmp alltraps
80106ed2:	e9 b2 f5 ff ff       	jmp    80106489 <alltraps>

80106ed7 <vector115>:
.globl vector115
vector115:
  pushl $0
80106ed7:	6a 00                	push   $0x0
  pushl $115
80106ed9:	6a 73                	push   $0x73
  jmp alltraps
80106edb:	e9 a9 f5 ff ff       	jmp    80106489 <alltraps>

80106ee0 <vector116>:
.globl vector116
vector116:
  pushl $0
80106ee0:	6a 00                	push   $0x0
  pushl $116
80106ee2:	6a 74                	push   $0x74
  jmp alltraps
80106ee4:	e9 a0 f5 ff ff       	jmp    80106489 <alltraps>

80106ee9 <vector117>:
.globl vector117
vector117:
  pushl $0
80106ee9:	6a 00                	push   $0x0
  pushl $117
80106eeb:	6a 75                	push   $0x75
  jmp alltraps
80106eed:	e9 97 f5 ff ff       	jmp    80106489 <alltraps>

80106ef2 <vector118>:
.globl vector118
vector118:
  pushl $0
80106ef2:	6a 00                	push   $0x0
  pushl $118
80106ef4:	6a 76                	push   $0x76
  jmp alltraps
80106ef6:	e9 8e f5 ff ff       	jmp    80106489 <alltraps>

80106efb <vector119>:
.globl vector119
vector119:
  pushl $0
80106efb:	6a 00                	push   $0x0
  pushl $119
80106efd:	6a 77                	push   $0x77
  jmp alltraps
80106eff:	e9 85 f5 ff ff       	jmp    80106489 <alltraps>

80106f04 <vector120>:
.globl vector120
vector120:
  pushl $0
80106f04:	6a 00                	push   $0x0
  pushl $120
80106f06:	6a 78                	push   $0x78
  jmp alltraps
80106f08:	e9 7c f5 ff ff       	jmp    80106489 <alltraps>

80106f0d <vector121>:
.globl vector121
vector121:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $121
80106f0f:	6a 79                	push   $0x79
  jmp alltraps
80106f11:	e9 73 f5 ff ff       	jmp    80106489 <alltraps>

80106f16 <vector122>:
.globl vector122
vector122:
  pushl $0
80106f16:	6a 00                	push   $0x0
  pushl $122
80106f18:	6a 7a                	push   $0x7a
  jmp alltraps
80106f1a:	e9 6a f5 ff ff       	jmp    80106489 <alltraps>

80106f1f <vector123>:
.globl vector123
vector123:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $123
80106f21:	6a 7b                	push   $0x7b
  jmp alltraps
80106f23:	e9 61 f5 ff ff       	jmp    80106489 <alltraps>

80106f28 <vector124>:
.globl vector124
vector124:
  pushl $0
80106f28:	6a 00                	push   $0x0
  pushl $124
80106f2a:	6a 7c                	push   $0x7c
  jmp alltraps
80106f2c:	e9 58 f5 ff ff       	jmp    80106489 <alltraps>

80106f31 <vector125>:
.globl vector125
vector125:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $125
80106f33:	6a 7d                	push   $0x7d
  jmp alltraps
80106f35:	e9 4f f5 ff ff       	jmp    80106489 <alltraps>

80106f3a <vector126>:
.globl vector126
vector126:
  pushl $0
80106f3a:	6a 00                	push   $0x0
  pushl $126
80106f3c:	6a 7e                	push   $0x7e
  jmp alltraps
80106f3e:	e9 46 f5 ff ff       	jmp    80106489 <alltraps>

80106f43 <vector127>:
.globl vector127
vector127:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $127
80106f45:	6a 7f                	push   $0x7f
  jmp alltraps
80106f47:	e9 3d f5 ff ff       	jmp    80106489 <alltraps>

80106f4c <vector128>:
.globl vector128
vector128:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $128
80106f4e:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106f53:	e9 31 f5 ff ff       	jmp    80106489 <alltraps>

80106f58 <vector129>:
.globl vector129
vector129:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $129
80106f5a:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106f5f:	e9 25 f5 ff ff       	jmp    80106489 <alltraps>

80106f64 <vector130>:
.globl vector130
vector130:
  pushl $0
80106f64:	6a 00                	push   $0x0
  pushl $130
80106f66:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106f6b:	e9 19 f5 ff ff       	jmp    80106489 <alltraps>

80106f70 <vector131>:
.globl vector131
vector131:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $131
80106f72:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106f77:	e9 0d f5 ff ff       	jmp    80106489 <alltraps>

80106f7c <vector132>:
.globl vector132
vector132:
  pushl $0
80106f7c:	6a 00                	push   $0x0
  pushl $132
80106f7e:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106f83:	e9 01 f5 ff ff       	jmp    80106489 <alltraps>

80106f88 <vector133>:
.globl vector133
vector133:
  pushl $0
80106f88:	6a 00                	push   $0x0
  pushl $133
80106f8a:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106f8f:	e9 f5 f4 ff ff       	jmp    80106489 <alltraps>

80106f94 <vector134>:
.globl vector134
vector134:
  pushl $0
80106f94:	6a 00                	push   $0x0
  pushl $134
80106f96:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106f9b:	e9 e9 f4 ff ff       	jmp    80106489 <alltraps>

80106fa0 <vector135>:
.globl vector135
vector135:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $135
80106fa2:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106fa7:	e9 dd f4 ff ff       	jmp    80106489 <alltraps>

80106fac <vector136>:
.globl vector136
vector136:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $136
80106fae:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106fb3:	e9 d1 f4 ff ff       	jmp    80106489 <alltraps>

80106fb8 <vector137>:
.globl vector137
vector137:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $137
80106fba:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106fbf:	e9 c5 f4 ff ff       	jmp    80106489 <alltraps>

80106fc4 <vector138>:
.globl vector138
vector138:
  pushl $0
80106fc4:	6a 00                	push   $0x0
  pushl $138
80106fc6:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106fcb:	e9 b9 f4 ff ff       	jmp    80106489 <alltraps>

80106fd0 <vector139>:
.globl vector139
vector139:
  pushl $0
80106fd0:	6a 00                	push   $0x0
  pushl $139
80106fd2:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106fd7:	e9 ad f4 ff ff       	jmp    80106489 <alltraps>

80106fdc <vector140>:
.globl vector140
vector140:
  pushl $0
80106fdc:	6a 00                	push   $0x0
  pushl $140
80106fde:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106fe3:	e9 a1 f4 ff ff       	jmp    80106489 <alltraps>

80106fe8 <vector141>:
.globl vector141
vector141:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $141
80106fea:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106fef:	e9 95 f4 ff ff       	jmp    80106489 <alltraps>

80106ff4 <vector142>:
.globl vector142
vector142:
  pushl $0
80106ff4:	6a 00                	push   $0x0
  pushl $142
80106ff6:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106ffb:	e9 89 f4 ff ff       	jmp    80106489 <alltraps>

80107000 <vector143>:
.globl vector143
vector143:
  pushl $0
80107000:	6a 00                	push   $0x0
  pushl $143
80107002:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107007:	e9 7d f4 ff ff       	jmp    80106489 <alltraps>

8010700c <vector144>:
.globl vector144
vector144:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $144
8010700e:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107013:	e9 71 f4 ff ff       	jmp    80106489 <alltraps>

80107018 <vector145>:
.globl vector145
vector145:
  pushl $0
80107018:	6a 00                	push   $0x0
  pushl $145
8010701a:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010701f:	e9 65 f4 ff ff       	jmp    80106489 <alltraps>

80107024 <vector146>:
.globl vector146
vector146:
  pushl $0
80107024:	6a 00                	push   $0x0
  pushl $146
80107026:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010702b:	e9 59 f4 ff ff       	jmp    80106489 <alltraps>

80107030 <vector147>:
.globl vector147
vector147:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $147
80107032:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107037:	e9 4d f4 ff ff       	jmp    80106489 <alltraps>

8010703c <vector148>:
.globl vector148
vector148:
  pushl $0
8010703c:	6a 00                	push   $0x0
  pushl $148
8010703e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107043:	e9 41 f4 ff ff       	jmp    80106489 <alltraps>

80107048 <vector149>:
.globl vector149
vector149:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $149
8010704a:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010704f:	e9 35 f4 ff ff       	jmp    80106489 <alltraps>

80107054 <vector150>:
.globl vector150
vector150:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $150
80107056:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010705b:	e9 29 f4 ff ff       	jmp    80106489 <alltraps>

80107060 <vector151>:
.globl vector151
vector151:
  pushl $0
80107060:	6a 00                	push   $0x0
  pushl $151
80107062:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107067:	e9 1d f4 ff ff       	jmp    80106489 <alltraps>

8010706c <vector152>:
.globl vector152
vector152:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $152
8010706e:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107073:	e9 11 f4 ff ff       	jmp    80106489 <alltraps>

80107078 <vector153>:
.globl vector153
vector153:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $153
8010707a:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010707f:	e9 05 f4 ff ff       	jmp    80106489 <alltraps>

80107084 <vector154>:
.globl vector154
vector154:
  pushl $0
80107084:	6a 00                	push   $0x0
  pushl $154
80107086:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010708b:	e9 f9 f3 ff ff       	jmp    80106489 <alltraps>

80107090 <vector155>:
.globl vector155
vector155:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $155
80107092:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107097:	e9 ed f3 ff ff       	jmp    80106489 <alltraps>

8010709c <vector156>:
.globl vector156
vector156:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $156
8010709e:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801070a3:	e9 e1 f3 ff ff       	jmp    80106489 <alltraps>

801070a8 <vector157>:
.globl vector157
vector157:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $157
801070aa:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801070af:	e9 d5 f3 ff ff       	jmp    80106489 <alltraps>

801070b4 <vector158>:
.globl vector158
vector158:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $158
801070b6:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801070bb:	e9 c9 f3 ff ff       	jmp    80106489 <alltraps>

801070c0 <vector159>:
.globl vector159
vector159:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $159
801070c2:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801070c7:	e9 bd f3 ff ff       	jmp    80106489 <alltraps>

801070cc <vector160>:
.globl vector160
vector160:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $160
801070ce:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801070d3:	e9 b1 f3 ff ff       	jmp    80106489 <alltraps>

801070d8 <vector161>:
.globl vector161
vector161:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $161
801070da:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801070df:	e9 a5 f3 ff ff       	jmp    80106489 <alltraps>

801070e4 <vector162>:
.globl vector162
vector162:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $162
801070e6:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801070eb:	e9 99 f3 ff ff       	jmp    80106489 <alltraps>

801070f0 <vector163>:
.globl vector163
vector163:
  pushl $0
801070f0:	6a 00                	push   $0x0
  pushl $163
801070f2:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801070f7:	e9 8d f3 ff ff       	jmp    80106489 <alltraps>

801070fc <vector164>:
.globl vector164
vector164:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $164
801070fe:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107103:	e9 81 f3 ff ff       	jmp    80106489 <alltraps>

80107108 <vector165>:
.globl vector165
vector165:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $165
8010710a:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010710f:	e9 75 f3 ff ff       	jmp    80106489 <alltraps>

80107114 <vector166>:
.globl vector166
vector166:
  pushl $0
80107114:	6a 00                	push   $0x0
  pushl $166
80107116:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010711b:	e9 69 f3 ff ff       	jmp    80106489 <alltraps>

80107120 <vector167>:
.globl vector167
vector167:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $167
80107122:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107127:	e9 5d f3 ff ff       	jmp    80106489 <alltraps>

8010712c <vector168>:
.globl vector168
vector168:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $168
8010712e:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107133:	e9 51 f3 ff ff       	jmp    80106489 <alltraps>

80107138 <vector169>:
.globl vector169
vector169:
  pushl $0
80107138:	6a 00                	push   $0x0
  pushl $169
8010713a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010713f:	e9 45 f3 ff ff       	jmp    80106489 <alltraps>

80107144 <vector170>:
.globl vector170
vector170:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $170
80107146:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010714b:	e9 39 f3 ff ff       	jmp    80106489 <alltraps>

80107150 <vector171>:
.globl vector171
vector171:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $171
80107152:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107157:	e9 2d f3 ff ff       	jmp    80106489 <alltraps>

8010715c <vector172>:
.globl vector172
vector172:
  pushl $0
8010715c:	6a 00                	push   $0x0
  pushl $172
8010715e:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107163:	e9 21 f3 ff ff       	jmp    80106489 <alltraps>

80107168 <vector173>:
.globl vector173
vector173:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $173
8010716a:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010716f:	e9 15 f3 ff ff       	jmp    80106489 <alltraps>

80107174 <vector174>:
.globl vector174
vector174:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $174
80107176:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010717b:	e9 09 f3 ff ff       	jmp    80106489 <alltraps>

80107180 <vector175>:
.globl vector175
vector175:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $175
80107182:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107187:	e9 fd f2 ff ff       	jmp    80106489 <alltraps>

8010718c <vector176>:
.globl vector176
vector176:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $176
8010718e:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107193:	e9 f1 f2 ff ff       	jmp    80106489 <alltraps>

80107198 <vector177>:
.globl vector177
vector177:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $177
8010719a:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010719f:	e9 e5 f2 ff ff       	jmp    80106489 <alltraps>

801071a4 <vector178>:
.globl vector178
vector178:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $178
801071a6:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801071ab:	e9 d9 f2 ff ff       	jmp    80106489 <alltraps>

801071b0 <vector179>:
.globl vector179
vector179:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $179
801071b2:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801071b7:	e9 cd f2 ff ff       	jmp    80106489 <alltraps>

801071bc <vector180>:
.globl vector180
vector180:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $180
801071be:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801071c3:	e9 c1 f2 ff ff       	jmp    80106489 <alltraps>

801071c8 <vector181>:
.globl vector181
vector181:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $181
801071ca:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801071cf:	e9 b5 f2 ff ff       	jmp    80106489 <alltraps>

801071d4 <vector182>:
.globl vector182
vector182:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $182
801071d6:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801071db:	e9 a9 f2 ff ff       	jmp    80106489 <alltraps>

801071e0 <vector183>:
.globl vector183
vector183:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $183
801071e2:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801071e7:	e9 9d f2 ff ff       	jmp    80106489 <alltraps>

801071ec <vector184>:
.globl vector184
vector184:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $184
801071ee:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801071f3:	e9 91 f2 ff ff       	jmp    80106489 <alltraps>

801071f8 <vector185>:
.globl vector185
vector185:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $185
801071fa:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801071ff:	e9 85 f2 ff ff       	jmp    80106489 <alltraps>

80107204 <vector186>:
.globl vector186
vector186:
  pushl $0
80107204:	6a 00                	push   $0x0
  pushl $186
80107206:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010720b:	e9 79 f2 ff ff       	jmp    80106489 <alltraps>

80107210 <vector187>:
.globl vector187
vector187:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $187
80107212:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107217:	e9 6d f2 ff ff       	jmp    80106489 <alltraps>

8010721c <vector188>:
.globl vector188
vector188:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $188
8010721e:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107223:	e9 61 f2 ff ff       	jmp    80106489 <alltraps>

80107228 <vector189>:
.globl vector189
vector189:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $189
8010722a:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010722f:	e9 55 f2 ff ff       	jmp    80106489 <alltraps>

80107234 <vector190>:
.globl vector190
vector190:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $190
80107236:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010723b:	e9 49 f2 ff ff       	jmp    80106489 <alltraps>

80107240 <vector191>:
.globl vector191
vector191:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $191
80107242:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107247:	e9 3d f2 ff ff       	jmp    80106489 <alltraps>

8010724c <vector192>:
.globl vector192
vector192:
  pushl $0
8010724c:	6a 00                	push   $0x0
  pushl $192
8010724e:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107253:	e9 31 f2 ff ff       	jmp    80106489 <alltraps>

80107258 <vector193>:
.globl vector193
vector193:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $193
8010725a:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010725f:	e9 25 f2 ff ff       	jmp    80106489 <alltraps>

80107264 <vector194>:
.globl vector194
vector194:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $194
80107266:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010726b:	e9 19 f2 ff ff       	jmp    80106489 <alltraps>

80107270 <vector195>:
.globl vector195
vector195:
  pushl $0
80107270:	6a 00                	push   $0x0
  pushl $195
80107272:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107277:	e9 0d f2 ff ff       	jmp    80106489 <alltraps>

8010727c <vector196>:
.globl vector196
vector196:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $196
8010727e:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107283:	e9 01 f2 ff ff       	jmp    80106489 <alltraps>

80107288 <vector197>:
.globl vector197
vector197:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $197
8010728a:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010728f:	e9 f5 f1 ff ff       	jmp    80106489 <alltraps>

80107294 <vector198>:
.globl vector198
vector198:
  pushl $0
80107294:	6a 00                	push   $0x0
  pushl $198
80107296:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010729b:	e9 e9 f1 ff ff       	jmp    80106489 <alltraps>

801072a0 <vector199>:
.globl vector199
vector199:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $199
801072a2:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801072a7:	e9 dd f1 ff ff       	jmp    80106489 <alltraps>

801072ac <vector200>:
.globl vector200
vector200:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $200
801072ae:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801072b3:	e9 d1 f1 ff ff       	jmp    80106489 <alltraps>

801072b8 <vector201>:
.globl vector201
vector201:
  pushl $0
801072b8:	6a 00                	push   $0x0
  pushl $201
801072ba:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801072bf:	e9 c5 f1 ff ff       	jmp    80106489 <alltraps>

801072c4 <vector202>:
.globl vector202
vector202:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $202
801072c6:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801072cb:	e9 b9 f1 ff ff       	jmp    80106489 <alltraps>

801072d0 <vector203>:
.globl vector203
vector203:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $203
801072d2:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801072d7:	e9 ad f1 ff ff       	jmp    80106489 <alltraps>

801072dc <vector204>:
.globl vector204
vector204:
  pushl $0
801072dc:	6a 00                	push   $0x0
  pushl $204
801072de:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801072e3:	e9 a1 f1 ff ff       	jmp    80106489 <alltraps>

801072e8 <vector205>:
.globl vector205
vector205:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $205
801072ea:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801072ef:	e9 95 f1 ff ff       	jmp    80106489 <alltraps>

801072f4 <vector206>:
.globl vector206
vector206:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $206
801072f6:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801072fb:	e9 89 f1 ff ff       	jmp    80106489 <alltraps>

80107300 <vector207>:
.globl vector207
vector207:
  pushl $0
80107300:	6a 00                	push   $0x0
  pushl $207
80107302:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107307:	e9 7d f1 ff ff       	jmp    80106489 <alltraps>

8010730c <vector208>:
.globl vector208
vector208:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $208
8010730e:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107313:	e9 71 f1 ff ff       	jmp    80106489 <alltraps>

80107318 <vector209>:
.globl vector209
vector209:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $209
8010731a:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010731f:	e9 65 f1 ff ff       	jmp    80106489 <alltraps>

80107324 <vector210>:
.globl vector210
vector210:
  pushl $0
80107324:	6a 00                	push   $0x0
  pushl $210
80107326:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010732b:	e9 59 f1 ff ff       	jmp    80106489 <alltraps>

80107330 <vector211>:
.globl vector211
vector211:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $211
80107332:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107337:	e9 4d f1 ff ff       	jmp    80106489 <alltraps>

8010733c <vector212>:
.globl vector212
vector212:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $212
8010733e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107343:	e9 41 f1 ff ff       	jmp    80106489 <alltraps>

80107348 <vector213>:
.globl vector213
vector213:
  pushl $0
80107348:	6a 00                	push   $0x0
  pushl $213
8010734a:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010734f:	e9 35 f1 ff ff       	jmp    80106489 <alltraps>

80107354 <vector214>:
.globl vector214
vector214:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $214
80107356:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010735b:	e9 29 f1 ff ff       	jmp    80106489 <alltraps>

80107360 <vector215>:
.globl vector215
vector215:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $215
80107362:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107367:	e9 1d f1 ff ff       	jmp    80106489 <alltraps>

8010736c <vector216>:
.globl vector216
vector216:
  pushl $0
8010736c:	6a 00                	push   $0x0
  pushl $216
8010736e:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107373:	e9 11 f1 ff ff       	jmp    80106489 <alltraps>

80107378 <vector217>:
.globl vector217
vector217:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $217
8010737a:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010737f:	e9 05 f1 ff ff       	jmp    80106489 <alltraps>

80107384 <vector218>:
.globl vector218
vector218:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $218
80107386:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010738b:	e9 f9 f0 ff ff       	jmp    80106489 <alltraps>

80107390 <vector219>:
.globl vector219
vector219:
  pushl $0
80107390:	6a 00                	push   $0x0
  pushl $219
80107392:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107397:	e9 ed f0 ff ff       	jmp    80106489 <alltraps>

8010739c <vector220>:
.globl vector220
vector220:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $220
8010739e:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801073a3:	e9 e1 f0 ff ff       	jmp    80106489 <alltraps>

801073a8 <vector221>:
.globl vector221
vector221:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $221
801073aa:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801073af:	e9 d5 f0 ff ff       	jmp    80106489 <alltraps>

801073b4 <vector222>:
.globl vector222
vector222:
  pushl $0
801073b4:	6a 00                	push   $0x0
  pushl $222
801073b6:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801073bb:	e9 c9 f0 ff ff       	jmp    80106489 <alltraps>

801073c0 <vector223>:
.globl vector223
vector223:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $223
801073c2:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801073c7:	e9 bd f0 ff ff       	jmp    80106489 <alltraps>

801073cc <vector224>:
.globl vector224
vector224:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $224
801073ce:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801073d3:	e9 b1 f0 ff ff       	jmp    80106489 <alltraps>

801073d8 <vector225>:
.globl vector225
vector225:
  pushl $0
801073d8:	6a 00                	push   $0x0
  pushl $225
801073da:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801073df:	e9 a5 f0 ff ff       	jmp    80106489 <alltraps>

801073e4 <vector226>:
.globl vector226
vector226:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $226
801073e6:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801073eb:	e9 99 f0 ff ff       	jmp    80106489 <alltraps>

801073f0 <vector227>:
.globl vector227
vector227:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $227
801073f2:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801073f7:	e9 8d f0 ff ff       	jmp    80106489 <alltraps>

801073fc <vector228>:
.globl vector228
vector228:
  pushl $0
801073fc:	6a 00                	push   $0x0
  pushl $228
801073fe:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107403:	e9 81 f0 ff ff       	jmp    80106489 <alltraps>

80107408 <vector229>:
.globl vector229
vector229:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $229
8010740a:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010740f:	e9 75 f0 ff ff       	jmp    80106489 <alltraps>

80107414 <vector230>:
.globl vector230
vector230:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $230
80107416:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010741b:	e9 69 f0 ff ff       	jmp    80106489 <alltraps>

80107420 <vector231>:
.globl vector231
vector231:
  pushl $0
80107420:	6a 00                	push   $0x0
  pushl $231
80107422:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107427:	e9 5d f0 ff ff       	jmp    80106489 <alltraps>

8010742c <vector232>:
.globl vector232
vector232:
  pushl $0
8010742c:	6a 00                	push   $0x0
  pushl $232
8010742e:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107433:	e9 51 f0 ff ff       	jmp    80106489 <alltraps>

80107438 <vector233>:
.globl vector233
vector233:
  pushl $0
80107438:	6a 00                	push   $0x0
  pushl $233
8010743a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010743f:	e9 45 f0 ff ff       	jmp    80106489 <alltraps>

80107444 <vector234>:
.globl vector234
vector234:
  pushl $0
80107444:	6a 00                	push   $0x0
  pushl $234
80107446:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010744b:	e9 39 f0 ff ff       	jmp    80106489 <alltraps>

80107450 <vector235>:
.globl vector235
vector235:
  pushl $0
80107450:	6a 00                	push   $0x0
  pushl $235
80107452:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107457:	e9 2d f0 ff ff       	jmp    80106489 <alltraps>

8010745c <vector236>:
.globl vector236
vector236:
  pushl $0
8010745c:	6a 00                	push   $0x0
  pushl $236
8010745e:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107463:	e9 21 f0 ff ff       	jmp    80106489 <alltraps>

80107468 <vector237>:
.globl vector237
vector237:
  pushl $0
80107468:	6a 00                	push   $0x0
  pushl $237
8010746a:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010746f:	e9 15 f0 ff ff       	jmp    80106489 <alltraps>

80107474 <vector238>:
.globl vector238
vector238:
  pushl $0
80107474:	6a 00                	push   $0x0
  pushl $238
80107476:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010747b:	e9 09 f0 ff ff       	jmp    80106489 <alltraps>

80107480 <vector239>:
.globl vector239
vector239:
  pushl $0
80107480:	6a 00                	push   $0x0
  pushl $239
80107482:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107487:	e9 fd ef ff ff       	jmp    80106489 <alltraps>

8010748c <vector240>:
.globl vector240
vector240:
  pushl $0
8010748c:	6a 00                	push   $0x0
  pushl $240
8010748e:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107493:	e9 f1 ef ff ff       	jmp    80106489 <alltraps>

80107498 <vector241>:
.globl vector241
vector241:
  pushl $0
80107498:	6a 00                	push   $0x0
  pushl $241
8010749a:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010749f:	e9 e5 ef ff ff       	jmp    80106489 <alltraps>

801074a4 <vector242>:
.globl vector242
vector242:
  pushl $0
801074a4:	6a 00                	push   $0x0
  pushl $242
801074a6:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801074ab:	e9 d9 ef ff ff       	jmp    80106489 <alltraps>

801074b0 <vector243>:
.globl vector243
vector243:
  pushl $0
801074b0:	6a 00                	push   $0x0
  pushl $243
801074b2:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801074b7:	e9 cd ef ff ff       	jmp    80106489 <alltraps>

801074bc <vector244>:
.globl vector244
vector244:
  pushl $0
801074bc:	6a 00                	push   $0x0
  pushl $244
801074be:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801074c3:	e9 c1 ef ff ff       	jmp    80106489 <alltraps>

801074c8 <vector245>:
.globl vector245
vector245:
  pushl $0
801074c8:	6a 00                	push   $0x0
  pushl $245
801074ca:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801074cf:	e9 b5 ef ff ff       	jmp    80106489 <alltraps>

801074d4 <vector246>:
.globl vector246
vector246:
  pushl $0
801074d4:	6a 00                	push   $0x0
  pushl $246
801074d6:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801074db:	e9 a9 ef ff ff       	jmp    80106489 <alltraps>

801074e0 <vector247>:
.globl vector247
vector247:
  pushl $0
801074e0:	6a 00                	push   $0x0
  pushl $247
801074e2:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801074e7:	e9 9d ef ff ff       	jmp    80106489 <alltraps>

801074ec <vector248>:
.globl vector248
vector248:
  pushl $0
801074ec:	6a 00                	push   $0x0
  pushl $248
801074ee:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801074f3:	e9 91 ef ff ff       	jmp    80106489 <alltraps>

801074f8 <vector249>:
.globl vector249
vector249:
  pushl $0
801074f8:	6a 00                	push   $0x0
  pushl $249
801074fa:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801074ff:	e9 85 ef ff ff       	jmp    80106489 <alltraps>

80107504 <vector250>:
.globl vector250
vector250:
  pushl $0
80107504:	6a 00                	push   $0x0
  pushl $250
80107506:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010750b:	e9 79 ef ff ff       	jmp    80106489 <alltraps>

80107510 <vector251>:
.globl vector251
vector251:
  pushl $0
80107510:	6a 00                	push   $0x0
  pushl $251
80107512:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107517:	e9 6d ef ff ff       	jmp    80106489 <alltraps>

8010751c <vector252>:
.globl vector252
vector252:
  pushl $0
8010751c:	6a 00                	push   $0x0
  pushl $252
8010751e:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107523:	e9 61 ef ff ff       	jmp    80106489 <alltraps>

80107528 <vector253>:
.globl vector253
vector253:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $253
8010752a:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010752f:	e9 55 ef ff ff       	jmp    80106489 <alltraps>

80107534 <vector254>:
.globl vector254
vector254:
  pushl $0
80107534:	6a 00                	push   $0x0
  pushl $254
80107536:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010753b:	e9 49 ef ff ff       	jmp    80106489 <alltraps>

80107540 <vector255>:
.globl vector255
vector255:
  pushl $0
80107540:	6a 00                	push   $0x0
  pushl $255
80107542:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107547:	e9 3d ef ff ff       	jmp    80106489 <alltraps>

8010754c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010754c:	55                   	push   %ebp
8010754d:	89 e5                	mov    %esp,%ebp
8010754f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107552:	8b 45 0c             	mov    0xc(%ebp),%eax
80107555:	83 e8 01             	sub    $0x1,%eax
80107558:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010755c:	8b 45 08             	mov    0x8(%ebp),%eax
8010755f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107563:	8b 45 08             	mov    0x8(%ebp),%eax
80107566:	c1 e8 10             	shr    $0x10,%eax
80107569:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010756d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107570:	0f 01 10             	lgdtl  (%eax)
}
80107573:	90                   	nop
80107574:	c9                   	leave  
80107575:	c3                   	ret    

80107576 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107576:	55                   	push   %ebp
80107577:	89 e5                	mov    %esp,%ebp
80107579:	83 ec 04             	sub    $0x4,%esp
8010757c:	8b 45 08             	mov    0x8(%ebp),%eax
8010757f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107583:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107587:	0f 00 d8             	ltr    %ax
}
8010758a:	90                   	nop
8010758b:	c9                   	leave  
8010758c:	c3                   	ret    

8010758d <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010758d:	55                   	push   %ebp
8010758e:	89 e5                	mov    %esp,%ebp
80107590:	83 ec 04             	sub    $0x4,%esp
80107593:	8b 45 08             	mov    0x8(%ebp),%eax
80107596:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010759a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010759e:	8e e8                	mov    %eax,%gs
}
801075a0:	90                   	nop
801075a1:	c9                   	leave  
801075a2:	c3                   	ret    

801075a3 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801075a3:	55                   	push   %ebp
801075a4:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801075a6:	8b 45 08             	mov    0x8(%ebp),%eax
801075a9:	0f 22 d8             	mov    %eax,%cr3
}
801075ac:	90                   	nop
801075ad:	5d                   	pop    %ebp
801075ae:	c3                   	ret    

801075af <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801075af:	55                   	push   %ebp
801075b0:	89 e5                	mov    %esp,%ebp
801075b2:	8b 45 08             	mov    0x8(%ebp),%eax
801075b5:	05 00 00 00 80       	add    $0x80000000,%eax
801075ba:	5d                   	pop    %ebp
801075bb:	c3                   	ret    

801075bc <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801075bc:	55                   	push   %ebp
801075bd:	89 e5                	mov    %esp,%ebp
801075bf:	8b 45 08             	mov    0x8(%ebp),%eax
801075c2:	05 00 00 00 80       	add    $0x80000000,%eax
801075c7:	5d                   	pop    %ebp
801075c8:	c3                   	ret    

801075c9 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801075c9:	55                   	push   %ebp
801075ca:	89 e5                	mov    %esp,%ebp
801075cc:	53                   	push   %ebx
801075cd:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801075d0:	e8 44 bb ff ff       	call   80103119 <cpunum>
801075d5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801075db:	05 40 f9 10 80       	add    $0x8010f940,%eax
801075e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801075e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e6:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801075ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ef:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801075f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f8:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801075fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ff:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107603:	83 e2 f0             	and    $0xfffffff0,%edx
80107606:	83 ca 0a             	or     $0xa,%edx
80107609:	88 50 7d             	mov    %dl,0x7d(%eax)
8010760c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107613:	83 ca 10             	or     $0x10,%edx
80107616:	88 50 7d             	mov    %dl,0x7d(%eax)
80107619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107620:	83 e2 9f             	and    $0xffffff9f,%edx
80107623:	88 50 7d             	mov    %dl,0x7d(%eax)
80107626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107629:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010762d:	83 ca 80             	or     $0xffffff80,%edx
80107630:	88 50 7d             	mov    %dl,0x7d(%eax)
80107633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107636:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010763a:	83 ca 0f             	or     $0xf,%edx
8010763d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107643:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107647:	83 e2 ef             	and    $0xffffffef,%edx
8010764a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010764d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107650:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107654:	83 e2 df             	and    $0xffffffdf,%edx
80107657:	88 50 7e             	mov    %dl,0x7e(%eax)
8010765a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107661:	83 ca 40             	or     $0x40,%edx
80107664:	88 50 7e             	mov    %dl,0x7e(%eax)
80107667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010766e:	83 ca 80             	or     $0xffffff80,%edx
80107671:	88 50 7e             	mov    %dl,0x7e(%eax)
80107674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107677:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010767b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107685:	ff ff 
80107687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107691:	00 00 
80107693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107696:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010769d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076a7:	83 e2 f0             	and    $0xfffffff0,%edx
801076aa:	83 ca 02             	or     $0x2,%edx
801076ad:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076bd:	83 ca 10             	or     $0x10,%edx
801076c0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076d0:	83 e2 9f             	and    $0xffffff9f,%edx
801076d3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076dc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076e3:	83 ca 80             	or     $0xffffff80,%edx
801076e6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ef:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076f6:	83 ca 0f             	or     $0xf,%edx
801076f9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107702:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107709:	83 e2 ef             	and    $0xffffffef,%edx
8010770c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107715:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010771c:	83 e2 df             	and    $0xffffffdf,%edx
8010771f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107728:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010772f:	83 ca 40             	or     $0x40,%edx
80107732:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107742:	83 ca 80             	or     $0xffffff80,%edx
80107745:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010774b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107758:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010775f:	ff ff 
80107761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107764:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010776b:	00 00 
8010776d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107770:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107781:	83 e2 f0             	and    $0xfffffff0,%edx
80107784:	83 ca 0a             	or     $0xa,%edx
80107787:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010778d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107790:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107797:	83 ca 10             	or     $0x10,%edx
8010779a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077aa:	83 ca 60             	or     $0x60,%edx
801077ad:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077bd:	83 ca 80             	or     $0xffffff80,%edx
801077c0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077d0:	83 ca 0f             	or     $0xf,%edx
801077d3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077dc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077e3:	83 e2 ef             	and    $0xffffffef,%edx
801077e6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ef:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077f6:	83 e2 df             	and    $0xffffffdf,%edx
801077f9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107802:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107809:	83 ca 40             	or     $0x40,%edx
8010780c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107815:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010781c:	83 ca 80             	or     $0xffffff80,%edx
8010781f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107828:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010782f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107832:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107839:	ff ff 
8010783b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783e:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107845:	00 00 
80107847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784a:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107854:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010785b:	83 e2 f0             	and    $0xfffffff0,%edx
8010785e:	83 ca 02             	or     $0x2,%edx
80107861:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107867:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107871:	83 ca 10             	or     $0x10,%edx
80107874:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010787a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107884:	83 ca 60             	or     $0x60,%edx
80107887:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010788d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107890:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107897:	83 ca 80             	or     $0xffffff80,%edx
8010789a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801078a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801078aa:	83 ca 0f             	or     $0xf,%edx
801078ad:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801078b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801078bd:	83 e2 ef             	and    $0xffffffef,%edx
801078c0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801078c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c9:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801078d0:	83 e2 df             	and    $0xffffffdf,%edx
801078d3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801078d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078dc:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801078e3:	83 ca 40             	or     $0x40,%edx
801078e6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801078ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ef:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801078f6:	83 ca 80             	or     $0xffffff80,%edx
801078f9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801078ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107902:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790c:	05 b4 00 00 00       	add    $0xb4,%eax
80107911:	89 c3                	mov    %eax,%ebx
80107913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107916:	05 b4 00 00 00       	add    $0xb4,%eax
8010791b:	c1 e8 10             	shr    $0x10,%eax
8010791e:	89 c2                	mov    %eax,%edx
80107920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107923:	05 b4 00 00 00       	add    $0xb4,%eax
80107928:	c1 e8 18             	shr    $0x18,%eax
8010792b:	89 c1                	mov    %eax,%ecx
8010792d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107930:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107937:	00 00 
80107939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793c:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107946:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
8010794c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107956:	83 e2 f0             	and    $0xfffffff0,%edx
80107959:	83 ca 02             	or     $0x2,%edx
8010795c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107965:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010796c:	83 ca 10             	or     $0x10,%edx
8010796f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107978:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010797f:	83 e2 9f             	and    $0xffffff9f,%edx
80107982:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107992:	83 ca 80             	or     $0xffffff80,%edx
80107995:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010799b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079a5:	83 e2 f0             	and    $0xfffffff0,%edx
801079a8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079b8:	83 e2 ef             	and    $0xffffffef,%edx
801079bb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079cb:	83 e2 df             	and    $0xffffffdf,%edx
801079ce:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079de:	83 ca 40             	or     $0x40,%edx
801079e1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ea:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079f1:	83 ca 80             	or     $0xffffff80,%edx
801079f4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fd:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a06:	83 c0 70             	add    $0x70,%eax
80107a09:	83 ec 08             	sub    $0x8,%esp
80107a0c:	6a 38                	push   $0x38
80107a0e:	50                   	push   %eax
80107a0f:	e8 38 fb ff ff       	call   8010754c <lgdt>
80107a14:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107a17:	83 ec 0c             	sub    $0xc,%esp
80107a1a:	6a 18                	push   $0x18
80107a1c:	e8 6c fb ff ff       	call   8010758d <loadgs>
80107a21:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a27:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107a2d:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107a34:	00 00 00 00 
}
80107a38:	90                   	nop
80107a39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107a3c:	c9                   	leave  
80107a3d:	c3                   	ret    

80107a3e <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107a3e:	55                   	push   %ebp
80107a3f:	89 e5                	mov    %esp,%ebp
80107a41:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107a44:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a47:	c1 e8 16             	shr    $0x16,%eax
80107a4a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a51:	8b 45 08             	mov    0x8(%ebp),%eax
80107a54:	01 d0                	add    %edx,%eax
80107a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a5c:	8b 00                	mov    (%eax),%eax
80107a5e:	83 e0 01             	and    $0x1,%eax
80107a61:	85 c0                	test   %eax,%eax
80107a63:	74 18                	je     80107a7d <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a68:	8b 00                	mov    (%eax),%eax
80107a6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a6f:	50                   	push   %eax
80107a70:	e8 47 fb ff ff       	call   801075bc <p2v>
80107a75:	83 c4 04             	add    $0x4,%esp
80107a78:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a7b:	eb 48                	jmp    80107ac5 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107a7d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107a81:	74 0e                	je     80107a91 <walkpgdir+0x53>
80107a83:	e8 48 b3 ff ff       	call   80102dd0 <kalloc>
80107a88:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a8f:	75 07                	jne    80107a98 <walkpgdir+0x5a>
      return 0;
80107a91:	b8 00 00 00 00       	mov    $0x0,%eax
80107a96:	eb 44                	jmp    80107adc <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107a98:	83 ec 04             	sub    $0x4,%esp
80107a9b:	68 00 10 00 00       	push   $0x1000
80107aa0:	6a 00                	push   $0x0
80107aa2:	ff 75 f4             	pushl  -0xc(%ebp)
80107aa5:	e8 8b d5 ff ff       	call   80105035 <memset>
80107aaa:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107aad:	83 ec 0c             	sub    $0xc,%esp
80107ab0:	ff 75 f4             	pushl  -0xc(%ebp)
80107ab3:	e8 f7 fa ff ff       	call   801075af <v2p>
80107ab8:	83 c4 10             	add    $0x10,%esp
80107abb:	83 c8 07             	or     $0x7,%eax
80107abe:	89 c2                	mov    %eax,%edx
80107ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ac3:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ac8:	c1 e8 0c             	shr    $0xc,%eax
80107acb:	25 ff 03 00 00       	and    $0x3ff,%eax
80107ad0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ada:	01 d0                	add    %edx,%eax
}
80107adc:	c9                   	leave  
80107add:	c3                   	ret    

80107ade <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107ade:	55                   	push   %ebp
80107adf:	89 e5                	mov    %esp,%ebp
80107ae1:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ae7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107aec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107aef:	8b 55 0c             	mov    0xc(%ebp),%edx
80107af2:	8b 45 10             	mov    0x10(%ebp),%eax
80107af5:	01 d0                	add    %edx,%eax
80107af7:	83 e8 01             	sub    $0x1,%eax
80107afa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107aff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107b02:	83 ec 04             	sub    $0x4,%esp
80107b05:	6a 01                	push   $0x1
80107b07:	ff 75 f4             	pushl  -0xc(%ebp)
80107b0a:	ff 75 08             	pushl  0x8(%ebp)
80107b0d:	e8 2c ff ff ff       	call   80107a3e <walkpgdir>
80107b12:	83 c4 10             	add    $0x10,%esp
80107b15:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b18:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b1c:	75 07                	jne    80107b25 <mappages+0x47>
      return -1;
80107b1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b23:	eb 47                	jmp    80107b6c <mappages+0x8e>
    if(*pte & PTE_P)
80107b25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b28:	8b 00                	mov    (%eax),%eax
80107b2a:	83 e0 01             	and    $0x1,%eax
80107b2d:	85 c0                	test   %eax,%eax
80107b2f:	74 0d                	je     80107b3e <mappages+0x60>
      panic("remap");
80107b31:	83 ec 0c             	sub    $0xc,%esp
80107b34:	68 14 89 10 80       	push   $0x80108914
80107b39:	e8 28 8a ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80107b3e:	8b 45 18             	mov    0x18(%ebp),%eax
80107b41:	0b 45 14             	or     0x14(%ebp),%eax
80107b44:	83 c8 01             	or     $0x1,%eax
80107b47:	89 c2                	mov    %eax,%edx
80107b49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b4c:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b51:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107b54:	74 10                	je     80107b66 <mappages+0x88>
      break;
    a += PGSIZE;
80107b56:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107b5d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107b64:	eb 9c                	jmp    80107b02 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107b66:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107b67:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b6c:	c9                   	leave  
80107b6d:	c3                   	ret    

80107b6e <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107b6e:	55                   	push   %ebp
80107b6f:	89 e5                	mov    %esp,%ebp
80107b71:	53                   	push   %ebx
80107b72:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107b75:	e8 56 b2 ff ff       	call   80102dd0 <kalloc>
80107b7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107b81:	75 0a                	jne    80107b8d <setupkvm+0x1f>
    return 0;
80107b83:	b8 00 00 00 00       	mov    $0x0,%eax
80107b88:	e9 8e 00 00 00       	jmp    80107c1b <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107b8d:	83 ec 04             	sub    $0x4,%esp
80107b90:	68 00 10 00 00       	push   $0x1000
80107b95:	6a 00                	push   $0x0
80107b97:	ff 75 f0             	pushl  -0x10(%ebp)
80107b9a:	e8 96 d4 ff ff       	call   80105035 <memset>
80107b9f:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107ba2:	83 ec 0c             	sub    $0xc,%esp
80107ba5:	68 00 00 00 0e       	push   $0xe000000
80107baa:	e8 0d fa ff ff       	call   801075bc <p2v>
80107baf:	83 c4 10             	add    $0x10,%esp
80107bb2:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107bb7:	76 0d                	jbe    80107bc6 <setupkvm+0x58>
    panic("PHYSTOP too high");
80107bb9:	83 ec 0c             	sub    $0xc,%esp
80107bbc:	68 1a 89 10 80       	push   $0x8010891a
80107bc1:	e8 a0 89 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107bc6:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80107bcd:	eb 40                	jmp    80107c0f <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd2:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd8:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bde:	8b 58 08             	mov    0x8(%eax),%ebx
80107be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be4:	8b 40 04             	mov    0x4(%eax),%eax
80107be7:	29 c3                	sub    %eax,%ebx
80107be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bec:	8b 00                	mov    (%eax),%eax
80107bee:	83 ec 0c             	sub    $0xc,%esp
80107bf1:	51                   	push   %ecx
80107bf2:	52                   	push   %edx
80107bf3:	53                   	push   %ebx
80107bf4:	50                   	push   %eax
80107bf5:	ff 75 f0             	pushl  -0x10(%ebp)
80107bf8:	e8 e1 fe ff ff       	call   80107ade <mappages>
80107bfd:	83 c4 20             	add    $0x20,%esp
80107c00:	85 c0                	test   %eax,%eax
80107c02:	79 07                	jns    80107c0b <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107c04:	b8 00 00 00 00       	mov    $0x0,%eax
80107c09:	eb 10                	jmp    80107c1b <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c0b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107c0f:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80107c16:	72 b7                	jb     80107bcf <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107c1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107c1e:	c9                   	leave  
80107c1f:	c3                   	ret    

80107c20 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107c20:	55                   	push   %ebp
80107c21:	89 e5                	mov    %esp,%ebp
80107c23:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107c26:	e8 43 ff ff ff       	call   80107b6e <setupkvm>
80107c2b:	a3 18 27 11 80       	mov    %eax,0x80112718
  switchkvm();
80107c30:	e8 03 00 00 00       	call   80107c38 <switchkvm>
}
80107c35:	90                   	nop
80107c36:	c9                   	leave  
80107c37:	c3                   	ret    

80107c38 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107c38:	55                   	push   %ebp
80107c39:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107c3b:	a1 18 27 11 80       	mov    0x80112718,%eax
80107c40:	50                   	push   %eax
80107c41:	e8 69 f9 ff ff       	call   801075af <v2p>
80107c46:	83 c4 04             	add    $0x4,%esp
80107c49:	50                   	push   %eax
80107c4a:	e8 54 f9 ff ff       	call   801075a3 <lcr3>
80107c4f:	83 c4 04             	add    $0x4,%esp
}
80107c52:	90                   	nop
80107c53:	c9                   	leave  
80107c54:	c3                   	ret    

80107c55 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107c55:	55                   	push   %ebp
80107c56:	89 e5                	mov    %esp,%ebp
80107c58:	56                   	push   %esi
80107c59:	53                   	push   %ebx
  pushcli();
80107c5a:	e8 d0 d2 ff ff       	call   80104f2f <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107c5f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107c65:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107c6c:	83 c2 08             	add    $0x8,%edx
80107c6f:	89 d6                	mov    %edx,%esi
80107c71:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107c78:	83 c2 08             	add    $0x8,%edx
80107c7b:	c1 ea 10             	shr    $0x10,%edx
80107c7e:	89 d3                	mov    %edx,%ebx
80107c80:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107c87:	83 c2 08             	add    $0x8,%edx
80107c8a:	c1 ea 18             	shr    $0x18,%edx
80107c8d:	89 d1                	mov    %edx,%ecx
80107c8f:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107c96:	67 00 
80107c98:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107c9f:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107ca5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107cac:	83 e2 f0             	and    $0xfffffff0,%edx
80107caf:	83 ca 09             	or     $0x9,%edx
80107cb2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107cb8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107cbf:	83 ca 10             	or     $0x10,%edx
80107cc2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107cc8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ccf:	83 e2 9f             	and    $0xffffff9f,%edx
80107cd2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107cd8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107cdf:	83 ca 80             	or     $0xffffff80,%edx
80107ce2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ce8:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107cef:	83 e2 f0             	and    $0xfffffff0,%edx
80107cf2:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107cf8:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107cff:	83 e2 ef             	and    $0xffffffef,%edx
80107d02:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107d08:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107d0f:	83 e2 df             	and    $0xffffffdf,%edx
80107d12:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107d18:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107d1f:	83 ca 40             	or     $0x40,%edx
80107d22:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107d28:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107d2f:	83 e2 7f             	and    $0x7f,%edx
80107d32:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107d38:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107d3e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d44:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107d4b:	83 e2 ef             	and    $0xffffffef,%edx
80107d4e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107d54:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d5a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107d60:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d66:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107d6d:	8b 52 08             	mov    0x8(%edx),%edx
80107d70:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107d76:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107d79:	83 ec 0c             	sub    $0xc,%esp
80107d7c:	6a 30                	push   $0x30
80107d7e:	e8 f3 f7 ff ff       	call   80107576 <ltr>
80107d83:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80107d86:	8b 45 08             	mov    0x8(%ebp),%eax
80107d89:	8b 40 04             	mov    0x4(%eax),%eax
80107d8c:	85 c0                	test   %eax,%eax
80107d8e:	75 0d                	jne    80107d9d <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80107d90:	83 ec 0c             	sub    $0xc,%esp
80107d93:	68 2b 89 10 80       	push   $0x8010892b
80107d98:	e8 c9 87 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107d9d:	8b 45 08             	mov    0x8(%ebp),%eax
80107da0:	8b 40 04             	mov    0x4(%eax),%eax
80107da3:	83 ec 0c             	sub    $0xc,%esp
80107da6:	50                   	push   %eax
80107da7:	e8 03 f8 ff ff       	call   801075af <v2p>
80107dac:	83 c4 10             	add    $0x10,%esp
80107daf:	83 ec 0c             	sub    $0xc,%esp
80107db2:	50                   	push   %eax
80107db3:	e8 eb f7 ff ff       	call   801075a3 <lcr3>
80107db8:	83 c4 10             	add    $0x10,%esp
  popcli();
80107dbb:	e8 b4 d1 ff ff       	call   80104f74 <popcli>
}
80107dc0:	90                   	nop
80107dc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107dc4:	5b                   	pop    %ebx
80107dc5:	5e                   	pop    %esi
80107dc6:	5d                   	pop    %ebp
80107dc7:	c3                   	ret    

80107dc8 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107dc8:	55                   	push   %ebp
80107dc9:	89 e5                	mov    %esp,%ebp
80107dcb:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107dce:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107dd5:	76 0d                	jbe    80107de4 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107dd7:	83 ec 0c             	sub    $0xc,%esp
80107dda:	68 3f 89 10 80       	push   $0x8010893f
80107ddf:	e8 82 87 ff ff       	call   80100566 <panic>
  mem = kalloc();
80107de4:	e8 e7 af ff ff       	call   80102dd0 <kalloc>
80107de9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107dec:	83 ec 04             	sub    $0x4,%esp
80107def:	68 00 10 00 00       	push   $0x1000
80107df4:	6a 00                	push   $0x0
80107df6:	ff 75 f4             	pushl  -0xc(%ebp)
80107df9:	e8 37 d2 ff ff       	call   80105035 <memset>
80107dfe:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107e01:	83 ec 0c             	sub    $0xc,%esp
80107e04:	ff 75 f4             	pushl  -0xc(%ebp)
80107e07:	e8 a3 f7 ff ff       	call   801075af <v2p>
80107e0c:	83 c4 10             	add    $0x10,%esp
80107e0f:	83 ec 0c             	sub    $0xc,%esp
80107e12:	6a 06                	push   $0x6
80107e14:	50                   	push   %eax
80107e15:	68 00 10 00 00       	push   $0x1000
80107e1a:	6a 00                	push   $0x0
80107e1c:	ff 75 08             	pushl  0x8(%ebp)
80107e1f:	e8 ba fc ff ff       	call   80107ade <mappages>
80107e24:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107e27:	83 ec 04             	sub    $0x4,%esp
80107e2a:	ff 75 10             	pushl  0x10(%ebp)
80107e2d:	ff 75 0c             	pushl  0xc(%ebp)
80107e30:	ff 75 f4             	pushl  -0xc(%ebp)
80107e33:	e8 bc d2 ff ff       	call   801050f4 <memmove>
80107e38:	83 c4 10             	add    $0x10,%esp
}
80107e3b:	90                   	nop
80107e3c:	c9                   	leave  
80107e3d:	c3                   	ret    

80107e3e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107e3e:	55                   	push   %ebp
80107e3f:	89 e5                	mov    %esp,%ebp
80107e41:	53                   	push   %ebx
80107e42:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107e45:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e48:	25 ff 0f 00 00       	and    $0xfff,%eax
80107e4d:	85 c0                	test   %eax,%eax
80107e4f:	74 0d                	je     80107e5e <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80107e51:	83 ec 0c             	sub    $0xc,%esp
80107e54:	68 5c 89 10 80       	push   $0x8010895c
80107e59:	e8 08 87 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107e5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e65:	e9 95 00 00 00       	jmp    80107eff <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e70:	01 d0                	add    %edx,%eax
80107e72:	83 ec 04             	sub    $0x4,%esp
80107e75:	6a 00                	push   $0x0
80107e77:	50                   	push   %eax
80107e78:	ff 75 08             	pushl  0x8(%ebp)
80107e7b:	e8 be fb ff ff       	call   80107a3e <walkpgdir>
80107e80:	83 c4 10             	add    $0x10,%esp
80107e83:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e86:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e8a:	75 0d                	jne    80107e99 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80107e8c:	83 ec 0c             	sub    $0xc,%esp
80107e8f:	68 7f 89 10 80       	push   $0x8010897f
80107e94:	e8 cd 86 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80107e99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e9c:	8b 00                	mov    (%eax),%eax
80107e9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ea3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107ea6:	8b 45 18             	mov    0x18(%ebp),%eax
80107ea9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107eac:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107eb1:	77 0b                	ja     80107ebe <loaduvm+0x80>
      n = sz - i;
80107eb3:	8b 45 18             	mov    0x18(%ebp),%eax
80107eb6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107eb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ebc:	eb 07                	jmp    80107ec5 <loaduvm+0x87>
    else
      n = PGSIZE;
80107ebe:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107ec5:	8b 55 14             	mov    0x14(%ebp),%edx
80107ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecb:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107ece:	83 ec 0c             	sub    $0xc,%esp
80107ed1:	ff 75 e8             	pushl  -0x18(%ebp)
80107ed4:	e8 e3 f6 ff ff       	call   801075bc <p2v>
80107ed9:	83 c4 10             	add    $0x10,%esp
80107edc:	ff 75 f0             	pushl  -0x10(%ebp)
80107edf:	53                   	push   %ebx
80107ee0:	50                   	push   %eax
80107ee1:	ff 75 10             	pushl  0x10(%ebp)
80107ee4:	e8 95 a1 ff ff       	call   8010207e <readi>
80107ee9:	83 c4 10             	add    $0x10,%esp
80107eec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107eef:	74 07                	je     80107ef8 <loaduvm+0xba>
      return -1;
80107ef1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ef6:	eb 18                	jmp    80107f10 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107ef8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f02:	3b 45 18             	cmp    0x18(%ebp),%eax
80107f05:	0f 82 5f ff ff ff    	jb     80107e6a <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107f0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107f13:	c9                   	leave  
80107f14:	c3                   	ret    

80107f15 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f15:	55                   	push   %ebp
80107f16:	89 e5                	mov    %esp,%ebp
80107f18:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107f1b:	8b 45 10             	mov    0x10(%ebp),%eax
80107f1e:	85 c0                	test   %eax,%eax
80107f20:	79 0a                	jns    80107f2c <allocuvm+0x17>
    return 0;
80107f22:	b8 00 00 00 00       	mov    $0x0,%eax
80107f27:	e9 b0 00 00 00       	jmp    80107fdc <allocuvm+0xc7>
  if(newsz < oldsz)
80107f2c:	8b 45 10             	mov    0x10(%ebp),%eax
80107f2f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f32:	73 08                	jae    80107f3c <allocuvm+0x27>
    return oldsz;
80107f34:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f37:	e9 a0 00 00 00       	jmp    80107fdc <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80107f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f3f:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f49:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107f4c:	eb 7f                	jmp    80107fcd <allocuvm+0xb8>
    mem = kalloc();
80107f4e:	e8 7d ae ff ff       	call   80102dd0 <kalloc>
80107f53:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107f56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f5a:	75 2b                	jne    80107f87 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80107f5c:	83 ec 0c             	sub    $0xc,%esp
80107f5f:	68 9d 89 10 80       	push   $0x8010899d
80107f64:	e8 5d 84 ff ff       	call   801003c6 <cprintf>
80107f69:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107f6c:	83 ec 04             	sub    $0x4,%esp
80107f6f:	ff 75 0c             	pushl  0xc(%ebp)
80107f72:	ff 75 10             	pushl  0x10(%ebp)
80107f75:	ff 75 08             	pushl  0x8(%ebp)
80107f78:	e8 61 00 00 00       	call   80107fde <deallocuvm>
80107f7d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107f80:	b8 00 00 00 00       	mov    $0x0,%eax
80107f85:	eb 55                	jmp    80107fdc <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80107f87:	83 ec 04             	sub    $0x4,%esp
80107f8a:	68 00 10 00 00       	push   $0x1000
80107f8f:	6a 00                	push   $0x0
80107f91:	ff 75 f0             	pushl  -0x10(%ebp)
80107f94:	e8 9c d0 ff ff       	call   80105035 <memset>
80107f99:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107f9c:	83 ec 0c             	sub    $0xc,%esp
80107f9f:	ff 75 f0             	pushl  -0x10(%ebp)
80107fa2:	e8 08 f6 ff ff       	call   801075af <v2p>
80107fa7:	83 c4 10             	add    $0x10,%esp
80107faa:	89 c2                	mov    %eax,%edx
80107fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107faf:	83 ec 0c             	sub    $0xc,%esp
80107fb2:	6a 06                	push   $0x6
80107fb4:	52                   	push   %edx
80107fb5:	68 00 10 00 00       	push   $0x1000
80107fba:	50                   	push   %eax
80107fbb:	ff 75 08             	pushl  0x8(%ebp)
80107fbe:	e8 1b fb ff ff       	call   80107ade <mappages>
80107fc3:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80107fc6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd0:	3b 45 10             	cmp    0x10(%ebp),%eax
80107fd3:	0f 82 75 ff ff ff    	jb     80107f4e <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80107fd9:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107fdc:	c9                   	leave  
80107fdd:	c3                   	ret    

80107fde <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107fde:	55                   	push   %ebp
80107fdf:	89 e5                	mov    %esp,%ebp
80107fe1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107fe4:	8b 45 10             	mov    0x10(%ebp),%eax
80107fe7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107fea:	72 08                	jb     80107ff4 <deallocuvm+0x16>
    return oldsz;
80107fec:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fef:	e9 a5 00 00 00       	jmp    80108099 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80107ff4:	8b 45 10             	mov    0x10(%ebp),%eax
80107ff7:	05 ff 0f 00 00       	add    $0xfff,%eax
80107ffc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108001:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108004:	e9 81 00 00 00       	jmp    8010808a <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800c:	83 ec 04             	sub    $0x4,%esp
8010800f:	6a 00                	push   $0x0
80108011:	50                   	push   %eax
80108012:	ff 75 08             	pushl  0x8(%ebp)
80108015:	e8 24 fa ff ff       	call   80107a3e <walkpgdir>
8010801a:	83 c4 10             	add    $0x10,%esp
8010801d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108020:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108024:	75 09                	jne    8010802f <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108026:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010802d:	eb 54                	jmp    80108083 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010802f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108032:	8b 00                	mov    (%eax),%eax
80108034:	83 e0 01             	and    $0x1,%eax
80108037:	85 c0                	test   %eax,%eax
80108039:	74 48                	je     80108083 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010803b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010803e:	8b 00                	mov    (%eax),%eax
80108040:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108045:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108048:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010804c:	75 0d                	jne    8010805b <deallocuvm+0x7d>
        panic("kfree");
8010804e:	83 ec 0c             	sub    $0xc,%esp
80108051:	68 b5 89 10 80       	push   $0x801089b5
80108056:	e8 0b 85 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
8010805b:	83 ec 0c             	sub    $0xc,%esp
8010805e:	ff 75 ec             	pushl  -0x14(%ebp)
80108061:	e8 56 f5 ff ff       	call   801075bc <p2v>
80108066:	83 c4 10             	add    $0x10,%esp
80108069:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010806c:	83 ec 0c             	sub    $0xc,%esp
8010806f:	ff 75 e8             	pushl  -0x18(%ebp)
80108072:	e8 bc ac ff ff       	call   80102d33 <kfree>
80108077:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010807a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010807d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108083:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010808a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108090:	0f 82 73 ff ff ff    	jb     80108009 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108096:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108099:	c9                   	leave  
8010809a:	c3                   	ret    

8010809b <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010809b:	55                   	push   %ebp
8010809c:	89 e5                	mov    %esp,%ebp
8010809e:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801080a1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801080a5:	75 0d                	jne    801080b4 <freevm+0x19>
    panic("freevm: no pgdir");
801080a7:	83 ec 0c             	sub    $0xc,%esp
801080aa:	68 bb 89 10 80       	push   $0x801089bb
801080af:	e8 b2 84 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801080b4:	83 ec 04             	sub    $0x4,%esp
801080b7:	6a 00                	push   $0x0
801080b9:	68 00 00 00 80       	push   $0x80000000
801080be:	ff 75 08             	pushl  0x8(%ebp)
801080c1:	e8 18 ff ff ff       	call   80107fde <deallocuvm>
801080c6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801080c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080d0:	eb 4f                	jmp    80108121 <freevm+0x86>
    if(pgdir[i] & PTE_P){
801080d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080dc:	8b 45 08             	mov    0x8(%ebp),%eax
801080df:	01 d0                	add    %edx,%eax
801080e1:	8b 00                	mov    (%eax),%eax
801080e3:	83 e0 01             	and    $0x1,%eax
801080e6:	85 c0                	test   %eax,%eax
801080e8:	74 33                	je     8010811d <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801080ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080f4:	8b 45 08             	mov    0x8(%ebp),%eax
801080f7:	01 d0                	add    %edx,%eax
801080f9:	8b 00                	mov    (%eax),%eax
801080fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108100:	83 ec 0c             	sub    $0xc,%esp
80108103:	50                   	push   %eax
80108104:	e8 b3 f4 ff ff       	call   801075bc <p2v>
80108109:	83 c4 10             	add    $0x10,%esp
8010810c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010810f:	83 ec 0c             	sub    $0xc,%esp
80108112:	ff 75 f0             	pushl  -0x10(%ebp)
80108115:	e8 19 ac ff ff       	call   80102d33 <kfree>
8010811a:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010811d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108121:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108128:	76 a8                	jbe    801080d2 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010812a:	83 ec 0c             	sub    $0xc,%esp
8010812d:	ff 75 08             	pushl  0x8(%ebp)
80108130:	e8 fe ab ff ff       	call   80102d33 <kfree>
80108135:	83 c4 10             	add    $0x10,%esp
}
80108138:	90                   	nop
80108139:	c9                   	leave  
8010813a:	c3                   	ret    

8010813b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010813b:	55                   	push   %ebp
8010813c:	89 e5                	mov    %esp,%ebp
8010813e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108141:	83 ec 04             	sub    $0x4,%esp
80108144:	6a 00                	push   $0x0
80108146:	ff 75 0c             	pushl  0xc(%ebp)
80108149:	ff 75 08             	pushl  0x8(%ebp)
8010814c:	e8 ed f8 ff ff       	call   80107a3e <walkpgdir>
80108151:	83 c4 10             	add    $0x10,%esp
80108154:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108157:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010815b:	75 0d                	jne    8010816a <clearpteu+0x2f>
    panic("clearpteu");
8010815d:	83 ec 0c             	sub    $0xc,%esp
80108160:	68 cc 89 10 80       	push   $0x801089cc
80108165:	e8 fc 83 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
8010816a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816d:	8b 00                	mov    (%eax),%eax
8010816f:	83 e0 fb             	and    $0xfffffffb,%eax
80108172:	89 c2                	mov    %eax,%edx
80108174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108177:	89 10                	mov    %edx,(%eax)
}
80108179:	90                   	nop
8010817a:	c9                   	leave  
8010817b:	c3                   	ret    

8010817c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010817c:	55                   	push   %ebp
8010817d:	89 e5                	mov    %esp,%ebp
8010817f:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
80108182:	e8 e7 f9 ff ff       	call   80107b6e <setupkvm>
80108187:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010818a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010818e:	75 0a                	jne    8010819a <copyuvm+0x1e>
    return 0;
80108190:	b8 00 00 00 00       	mov    $0x0,%eax
80108195:	e9 e9 00 00 00       	jmp    80108283 <copyuvm+0x107>
  for(i = 0; i < sz; i += PGSIZE){
8010819a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081a1:	e9 b5 00 00 00       	jmp    8010825b <copyuvm+0xdf>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801081a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a9:	83 ec 04             	sub    $0x4,%esp
801081ac:	6a 00                	push   $0x0
801081ae:	50                   	push   %eax
801081af:	ff 75 08             	pushl  0x8(%ebp)
801081b2:	e8 87 f8 ff ff       	call   80107a3e <walkpgdir>
801081b7:	83 c4 10             	add    $0x10,%esp
801081ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081c1:	75 0d                	jne    801081d0 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801081c3:	83 ec 0c             	sub    $0xc,%esp
801081c6:	68 d6 89 10 80       	push   $0x801089d6
801081cb:	e8 96 83 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
801081d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081d3:	8b 00                	mov    (%eax),%eax
801081d5:	83 e0 01             	and    $0x1,%eax
801081d8:	85 c0                	test   %eax,%eax
801081da:	75 0d                	jne    801081e9 <copyuvm+0x6d>
      panic("copyuvm: page not present");
801081dc:	83 ec 0c             	sub    $0xc,%esp
801081df:	68 f0 89 10 80       	push   $0x801089f0
801081e4:	e8 7d 83 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801081e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081ec:	8b 00                	mov    (%eax),%eax
801081ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
801081f6:	e8 d5 ab ff ff       	call   80102dd0 <kalloc>
801081fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801081fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108202:	74 68                	je     8010826c <copyuvm+0xf0>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108204:	83 ec 0c             	sub    $0xc,%esp
80108207:	ff 75 e8             	pushl  -0x18(%ebp)
8010820a:	e8 ad f3 ff ff       	call   801075bc <p2v>
8010820f:	83 c4 10             	add    $0x10,%esp
80108212:	83 ec 04             	sub    $0x4,%esp
80108215:	68 00 10 00 00       	push   $0x1000
8010821a:	50                   	push   %eax
8010821b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010821e:	e8 d1 ce ff ff       	call   801050f4 <memmove>
80108223:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
80108226:	83 ec 0c             	sub    $0xc,%esp
80108229:	ff 75 e4             	pushl  -0x1c(%ebp)
8010822c:	e8 7e f3 ff ff       	call   801075af <v2p>
80108231:	83 c4 10             	add    $0x10,%esp
80108234:	89 c2                	mov    %eax,%edx
80108236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108239:	83 ec 0c             	sub    $0xc,%esp
8010823c:	6a 06                	push   $0x6
8010823e:	52                   	push   %edx
8010823f:	68 00 10 00 00       	push   $0x1000
80108244:	50                   	push   %eax
80108245:	ff 75 f0             	pushl  -0x10(%ebp)
80108248:	e8 91 f8 ff ff       	call   80107ade <mappages>
8010824d:	83 c4 20             	add    $0x20,%esp
80108250:	85 c0                	test   %eax,%eax
80108252:	78 1b                	js     8010826f <copyuvm+0xf3>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108254:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010825b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108261:	0f 82 3f ff ff ff    	jb     801081a6 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
80108267:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826a:	eb 17                	jmp    80108283 <copyuvm+0x107>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010826c:	90                   	nop
8010826d:	eb 01                	jmp    80108270 <copyuvm+0xf4>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
8010826f:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108270:	83 ec 0c             	sub    $0xc,%esp
80108273:	ff 75 f0             	pushl  -0x10(%ebp)
80108276:	e8 20 fe ff ff       	call   8010809b <freevm>
8010827b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010827e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108283:	c9                   	leave  
80108284:	c3                   	ret    

80108285 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108285:	55                   	push   %ebp
80108286:	89 e5                	mov    %esp,%ebp
80108288:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010828b:	83 ec 04             	sub    $0x4,%esp
8010828e:	6a 00                	push   $0x0
80108290:	ff 75 0c             	pushl  0xc(%ebp)
80108293:	ff 75 08             	pushl  0x8(%ebp)
80108296:	e8 a3 f7 ff ff       	call   80107a3e <walkpgdir>
8010829b:	83 c4 10             	add    $0x10,%esp
8010829e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801082a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a4:	8b 00                	mov    (%eax),%eax
801082a6:	83 e0 01             	and    $0x1,%eax
801082a9:	85 c0                	test   %eax,%eax
801082ab:	75 07                	jne    801082b4 <uva2ka+0x2f>
    return 0;
801082ad:	b8 00 00 00 00       	mov    $0x0,%eax
801082b2:	eb 29                	jmp    801082dd <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801082b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b7:	8b 00                	mov    (%eax),%eax
801082b9:	83 e0 04             	and    $0x4,%eax
801082bc:	85 c0                	test   %eax,%eax
801082be:	75 07                	jne    801082c7 <uva2ka+0x42>
    return 0;
801082c0:	b8 00 00 00 00       	mov    $0x0,%eax
801082c5:	eb 16                	jmp    801082dd <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801082c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ca:	8b 00                	mov    (%eax),%eax
801082cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082d1:	83 ec 0c             	sub    $0xc,%esp
801082d4:	50                   	push   %eax
801082d5:	e8 e2 f2 ff ff       	call   801075bc <p2v>
801082da:	83 c4 10             	add    $0x10,%esp
}
801082dd:	c9                   	leave  
801082de:	c3                   	ret    

801082df <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801082df:	55                   	push   %ebp
801082e0:	89 e5                	mov    %esp,%ebp
801082e2:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801082e5:	8b 45 10             	mov    0x10(%ebp),%eax
801082e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801082eb:	eb 7f                	jmp    8010836c <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801082ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801082f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801082f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082fb:	83 ec 08             	sub    $0x8,%esp
801082fe:	50                   	push   %eax
801082ff:	ff 75 08             	pushl  0x8(%ebp)
80108302:	e8 7e ff ff ff       	call   80108285 <uva2ka>
80108307:	83 c4 10             	add    $0x10,%esp
8010830a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010830d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108311:	75 07                	jne    8010831a <copyout+0x3b>
      return -1;
80108313:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108318:	eb 61                	jmp    8010837b <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010831a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010831d:	2b 45 0c             	sub    0xc(%ebp),%eax
80108320:	05 00 10 00 00       	add    $0x1000,%eax
80108325:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108328:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010832b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010832e:	76 06                	jbe    80108336 <copyout+0x57>
      n = len;
80108330:	8b 45 14             	mov    0x14(%ebp),%eax
80108333:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108336:	8b 45 0c             	mov    0xc(%ebp),%eax
80108339:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010833c:	89 c2                	mov    %eax,%edx
8010833e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108341:	01 d0                	add    %edx,%eax
80108343:	83 ec 04             	sub    $0x4,%esp
80108346:	ff 75 f0             	pushl  -0x10(%ebp)
80108349:	ff 75 f4             	pushl  -0xc(%ebp)
8010834c:	50                   	push   %eax
8010834d:	e8 a2 cd ff ff       	call   801050f4 <memmove>
80108352:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108358:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010835b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010835e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108361:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108364:	05 00 10 00 00       	add    $0x1000,%eax
80108369:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010836c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108370:	0f 85 77 ff ff ff    	jne    801082ed <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108376:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010837b:	c9                   	leave  
8010837c:	c3                   	ret    
