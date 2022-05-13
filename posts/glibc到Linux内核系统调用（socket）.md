调用系统中断是程序从用户态到内核态的一个过程，进入内核态程序才能使用硬件资源。

socket（）要用到网卡进行数据收发，open（）用磁盘操作，fork（）要在内核的内存空间开辟一个空间保存寄存器的值才能进行任务切换的。都要用到系统调用。

## 简单socket代码准备

```c
// sk.c
#include  <stdio.h> 
#include  <sys/socket.h> 
#include  <unistd.h> 
#include  <sys/types.h> 
#include  <netinet/in.h> 
#include  <stdlib.h> 
#include  <time.h> 
#include  <string.h>

int main(int argc, char** argv)
{
    int  sfd,cfd;
    struct  sockaddr_in saddr,caddr;
    // socket
    sfd  =  socket(AF_INET,SOCK_STREAM, 0);

    // bind
    bzero(&saddr, sizeof(saddr));
    saddr.sin_family  =  AF_INET;
    saddr.sin_port  =  htons(8080);
    saddr.sin_addr.s_addr  =  htons(INADDR_ANY);
    bind(sfd,(struct sockaddr *)&saddr, sizeof(saddr));

    // linsten
    listen(sfd,10);
    while(1)
    { 

        char  buf[255] = {'\0'};
        socklen_t length = sizeof(caddr);
        cfd = accept(sfd,(struct sockaddr *)&caddr, &length);
        if( cfd >=0 )
        {
            recv(cfd, buf, 255, 0);
            printf("%s", buf);
        }         
        close(cfd); 
    } 
    
    close(sfd);
    return 0;
}
```

简单的开启一个socket，监听8080端口。

编译glibc2.27。并指定使用自己编译的代码，默认的glibc没有调试信息，gdb不能调试。

#### 编译glibc2.27

```shell
wget https://ftp.gnu.org/gnu/glibc/glibc-2.27.tar.gz
tar -xvf glibc-2.27.tar.gz
mkdir -p glibc-2.27/build/target && cd glibc-2.27/build/
CFLAGS="-g -g3 -ggdb -gdwarf-4 -Og"
CXXFLAGS="-g -g3 -ggdb -gdwarf-4 -Og"
../configure --prefix=/root/src/glibc-2.27/build/target
make && make install
# ls target/lib 可以看到生成的动态库和链接器
```

## socket 汇编分析

首先程序链接自己的glibc

```shell
gcc sk.c -g \
-Wl,--rpath=/root/src/glibc-2.27/build/target/lib \
-Wl,--dynamic-linker=/root/src/glibc-2.27/build/target/lib/ld-linux-x86-64.so.2 
# -fno-stack-protector     # 关闭栈破环标志方便调试而已
```

编译完就可以 gdb a.out 进入socket的代码了。

```asm
// sk.c  src
int main(int argc, char** argv)
{
    int  sfd,cfd;
    struct  sockaddr_in saddr,caddr;
    // socket
    sfd  =  socket(AF_INET,SOCK_STREAM, 0);
    ...
```

汇编代码分析，就是简单的函数调用，只不过函数在 libc-2.27.so 所以必须应用自己编译的库才能调试

```asm
// sk.c asm
   |0x5555555548ca <main>           push   %rbp  
   │0x5555555548cb <main+1>         mov    %rsp,%rbp     # 设置当前栈空间
   │0x5555555548ce <main+4>         sub    $0x150,%rsp     # 留出 336个字节放 argc 和 argc 的数据
   │0x5555555548d5 <main+11>        mov    %edi,-0x144(%rbp)     # 设置 argc, argv的数据 
   │0x5555555548db <main+17>        mov    %rsi,-0x150(%rbp)                   
B+>│0x5555555548e2 <main+24>        mov    $0x0,%edx     # 函数跳转时读取 edx si di 的寄存器的值当作函数传入参数  
   │0x5555555548e7 <main+29>        mov    $0x1,%esi     # define SOCK_STREAM 1                      
   │0x5555555548ec <main+34>        mov    $0x2,%edi     # define AF_INET 2                      
   │0x5555555548f1 <main+39>        callq  0x5555555547a0 <socket@plt>         
   │0x5555555548f6 <main+44>        mov    %eax,-0x4(%rbp)
```

socket函数调用分析，调用41号中断。

```asm
// glibc-2.27/build/socket/socket.c
  >│0x7ffff7b17e00 <socket>         mov    $0x29,%eax      # 调用第41号中断
   │0x7ffff7b17e05 <socket+5>       syscall                                                                                        │0x7ffff7b17e07 <socket+7>       cmp    $0xfffffffffffff001,%rax                                                                │0x7ffff7b17e0d <socket+13>      jae    0x7ffff7b17e10 <socket+16>                                                              │0x7ffff7b17e0f <socket+15>      retq                                                                                            │0x7ffff7b17e10 <socket+16>      mov    0x2ba051(%rip),%rcx        # 0x7ffff7dd1e68                                              │0x7ffff7b17e17 <socket+23>      neg    %eax                                                                                    │0x7ffff7b17e19 <socket+25>      mov    %eax,%fs:(%rcx)                                                                          │0x7ffff7b17e1c <socket+28>      or     $0xffffffffffffffff,%rax                                                                │0x7ffff7b17e20 <socket+32>      retq
```

## socket 系统中断分析

linux 内核中对于系统中断，有一个总表用于说明: [arch/x86/entry/syscalls/syscall_64.tbl]([linux/syscall_64.tbl at master · torvalds/linux (github.com)](https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl)) 。

四列分别对应，<系统调用号> <架构相关/x32/x64/通用> <系统调用名> <实现函数名>

```
...
38	common	setitimer		sys_setitimer
39	common	getpid			sys_getpid
40	common	sendfile		sys_sendfile64
41	common	socket			sys_socket
42	common	connect			sys_connect
43	common	accept			sys_accept
44	common	sendto			sys_sendto
...
```

函数声明: [include/linux/syscalls.h ]([linux/syscalls.h at master · torvalds/linux (github.com)](https://github.com/torvalds/linux/blob/master/include/linux/syscalls.h))

```
...
621 asmlinkage long sys_recvmsg(int fd, struct user_msghdr __user *msg, unsigned flags);
622 asmlinkage long sys_recvmmsg(int fd, struct mmsghdr __user *msg,
			     unsigned int vlen, unsigned flags,
			     struct timespec __user *timeout);
623 asmlinkage long sys_socket(int, int, int);
624 asmlinkage long sys_socketpair(int, int, int, int __user *);
625 asmlinkage long sys_socketcall(int call, unsigned long __user *args);
...
```

函数实现: [net/socket.c]([linux/socket.c at master · torvalds/linux (github.com)](https://github.com/torvalds/linux/blob/master/net/socket.c))
