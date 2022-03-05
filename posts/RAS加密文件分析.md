---
layout: post
title:  "RAS加密文件分析"
platform: "CentOS 7.6"
author: "harmful-chan"
date: "2021-01-07 17:10"
tags: 
  - ssl
---
对于 X.509 标准的证书有两种不同编码格式,一般采用 PEM 编码就以 .pem 作为文件扩展名，
若采用 DER 编码，就应以 .der 作为扩展名。但常见的证书扩展名还包括 .crt、.cer、.p12 等，
他们采用的编码格式可能不同，内容也有所差别，但大多数都能互相转换。 

## 密钥格式及编码<span id="10"/>
**x.509**：公钥证书标准，就是一个整数里面要包含什么内容；  
**RSA**：非对称加密算法，可以用于对文本加密，常用 1024 4086 位；  
**ASN.1**：抽象语法标记，描述了一种对数据进行表示、编码、传输和解码的数据格式；  
**PKCS**（The Public-Key Cryptography Standards）：是一系列公钥密码学的相关标准；  
**PKCS#1**（RSA Cryptography Standard）：定义了RSA公钥和私钥的语法格式；  
**PKCS#8**（Private-Key Information Syntax Standard）：定义了一种私钥信息的语法，同时还提供一种加密密钥的语法；  
**DER编码**：把符合ASN.1语法的密钥或证书文件输出为二进制文件;  
**PEM编码**：把DER编码后的二进制数据用Base64进行编码，输出文本数据再加上开始和结束行， 
如证书文件的"-----BEGIN CERTIFICATE-----“和”-----END CERTIFICATE-----";  


## 证书的几种扩展名<span id="20"/>
**.pem**: 采用 PEM 编码格式的 X.509 证书的文件扩展名；    
**.der**：采用 DER 编码格式的 X.509 证书的文件扩展名；    
**.crt**(certificate)：证书格式，常见于类 UNIX 系统，PEM 或 DER 编码，大多数采用 PEM 编码；  
**.cer**(certificate)：证书格式，常见于 Windows 系统，同样地，PEM 或 DER 编码，大多数采用 DER 编码；  
**.p12**(.pfx)：加密标准，PKCS #12，是公钥加密标准（Public Key Cryptography Standards，PKCS）系列的一种，
包含对应 X.509 证书和证书对应的私钥。简单理解：一份 .p12 文件 = X.509 证书+私钥；  
**.csr**(Certificate Signing Request)：证书签名请求，它并不是证书的格式，向CA申请证书用，
包含一个 RSA 公钥和其他附带信息，在生成这个 .csr 申请的时候，同时也会生成一个配对 RSA 私钥。  
**.key**：通常用来存放一个 RSA 公钥或者私钥，它并非 X.509 证书格式，编码同样可能是 PEM，也可能是 DER，查看方式如下：
```
PEM 编码格式：openssl rsa -in xxx.key -text -noout 
DER 编码格式：openssl rsa -in xxx.key -text -noout -inform der
```

## PKCS#1 格式  
包含一系列数据，可以从从导出私钥和公钥，怎么生成我是看不懂的...
#### 密钥
```example
# PKCS#1 格式 密钥数据结构
RSAPrivateKey ::= SEQUENCE 
{ 
  version Version,    // 版本号，V2中这个版本号应该是0，但如果使用了多素数，则版本号应该是1
  modulus INTEGER, -- n     //RSA的模数 n
  publicExponent INTEGER, -- e    //RSA的公钥幂指数 e
  privateExponent INTEGER, -- d    //RSA的公钥幂指数 d
  prime1 INTEGER, -- p    //n的素因子 p
  prime2 INTEGER, -- q    //n的素因子 q
  exponent1 INTEGER, -- d mod (p-1) 
  exponent2 INTEGER, -- d mod (q-1) 
  coefficient INTEGER, -- (inverse of q) mod p，//代表CRT(中国剩余定理)系数
  otherPrimeInfos OtherPrimeInfos OPTIONAL    //如果version是0，则它被忽略；如果version是1，那么它至少应该包含一个OtherPrimeInfo实例
}

OtherPrimeInfo ::= SEQUENCE 
{ 
  prime INTEGER, -- ri 
  exponent INTEGER, -- di 
  coefficient INTEGER -- ti 
}
```
利用openssl生成，pkcs#1格式，pem编码的密钥文件 prikey.pkcs1.pem  
`openssl genrsa -out prikey.pkcs1.pem`  
```example
# cat prikey.pkcs1.pem
-----BEGIN RSA PRIVATE KEY-----
MIICWwIBAAKBgQC2FKCULiab15n1BD6QvFz382kt4GsDvuOM5tmYeZD7l8MucSyP
pPORFyaWGoKI+pTwAKKbDy2epqq7WtYxOfqA1AzU1mNsk6XRTBHa2XzuSF+/0rXY
...
j78p2hP4dnYPVbpCZCdrXNMWl+7hmrKfXNB7PvPAe0fQctUno7WElS37qwIDAQAB
-----END RSA PRIVATE KEY-----
```
文件是base64打码的，可以利用工具解码  
`openssl rsa -inform PEM -outform DER -in prikey.pkcs1.pem -out prikey.pkcs1.der`  
得到的.der文件就是按照pkcs#1格式的密钥的二进制输出  
```example
# xxd prike.pkcs#1.der
0000000: 3082 025b 0201 0002 8181 00f0 7f55 6009  0..[.........U`.
0000010: cd94 e296 4870 4ee1 f960 64bc 5379 7f52  ....HpN..`
0000020: 3521 5fb9 5a34 8d15 c416 aa08 cfdf 3835  5!_.Z4........
0000030: 499d 3ffb 31a2 b72e 8256 81f7 9eec cbc4  I.?.1....V......
...
```
直接二进制没啥用，用opnssl可以查看各字段信息
`openssl asn1parse -i -in prikey.pkcs1.pem`  
```example
# cat prikey.pkcs1.pem
  0:d=0  hl=4 l= 603 cons: SEQUENCE
  4:d=1  hl=2 l=   1 prim:  INTEGER :00
  7:d=1  hl=3 l= 129 prim:  INTEGER :B614A0942E269BD799F5043...07B47D072D527A3B584952DFBAB                                                                
139:d=1  hl=2 l=   3 prim:  INTEGER :010001
144:d=1  hl=3 l= 128 prim:  INTEGER :69132647DD0A32CD0CEFB46F...D2AC424E1E4064BCB85B3AAB9AE1AC1                                                                
275:d=1  hl=2 l=  65 prim:  INTEGER :D9232CD625CFF3512F2C26D2E9...68327792926561E64C600013781E5EC569
342:d=1  hl=2 l=  65 prim:  INTEGER :D6AB36F17373EF5B73229939DA11...6054E2E813FF00B                                                     
409:d=1  hl=2 l=  64 prim:  INTEGER :1EDA40A4ACFABF37E9DBFC283BC...C80E4DCC71258D2BC0FFFC7390B43864E1BF2105104BA701                                                                         
475:d=1  hl=2 l=  64 prim:  INTEGER :A1D672959574D1...62CFAFB6A7FE42C90DDBDBEE147D749445BA7EE5802B76E7C8A4B55D9FC181D62773                                                                           541:d=1  hl=2 l=  64 prim:  INTEGER :7AC9618673B62E277A8FB...D83C21460E2A6BEE
```
**左半部分**  
`0:d=0  hl=4 l= 603 cons: SEQUENCE`  
0 表示节点在整个文件中的偏移长度  
d=0 表示节点深度   
hl=4 表示节点头字节长度  
l=603 表示节点数据字节长度  
cons 表示该节点为结构节点，表示包含子节点或者子结构数据  
prim 表示该节点为原始节点，包含数据  
OCTET STRING      [HEX DUMP]，就是加密后的私钥数据。
// SEQUENCE、OCTETSTRING等都是ASN.1中定义的数据类型，具体可以参考ASN.1格式说明。  
**右半部分**  
参照上两段的格式可以一一对应各字段的值，本文不涉及rsa编解码运算所以知道证书构成就好啦，毕竟俺也不会...
也有另一种查看方法
`openssl rsa -text -noout -in prikey.pkcs1.pem`  
```example
# cat prikey.pkcs1.pem
Private-Key: (1024 bit)
modulus:
    00:b6:14:a0:94:2e:26:9b:d7:99:f5:04:3e:90:bc:
    5c:f7:f3:69:2d:e0:6b:03:be:e3:8c:e6:d9:98:79:
    90:fb:97:c3:2e:71:2c:8f:a4:f3:91:17:26:96:1a:
    82:88:fa:94:f0:00:a2:9b:0f:2d:9e:a6:aa:bb:5a:
    d6:31:39:fa:80:d4:0c:d4:d6:63:6c:93:a5:d1:4c:
    11:da:d9:7c:ee:48:5f:bf:d2:b5:d8:8f:bf:29:da:
    13:f8:76:76:0f:55:ba:42:64:27:6b:5c:d3:16:97:
    ee:e1:9a:b2:9f:5c:d0:7b:3e:f3:c0:7b:47:d0:72:
    d5:27:a3:b5:84:95:2d:fb:ab
publicExponent: 65537 (0x10001)
privateExponent:
    69:13:26:47:dd:0a:32:cd:0c:ef:b4:6f:56:9f:1d:
    ...
```
大体上输出内容差不多。
#### 公钥
```
# PKCS#1 公钥数据结构
RSAPublicKey ::= SEQUENCE 
{ 
  modulus INTEGER, -- n    //是RSA模数，是一个正整数 
  publicExponent INTEGER -- e    //是RSA公钥幂指数，是一个正整数
}
```
利用openssl从 pkcs1密钥 导出 pkcs1公钥钥
`openssl rsa -in prikey.pkcs1.pem -RSAPublicKey_out -out pubkey.pkcs1.`
```example
# cat pubkey.pkcs1.pem
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBALYUoJQuJpvXmfUEPpC8XPfzaS3gawO+44zm2Zh5kPuXwy5xLI+k85EX
JpYagoj6lPAAopsPLZ6mqrta1jE5+oDUDNTWY2yTpdFMEdrZfO5IX7/StdiPvyna
Eh2dg9VukJkJ2tc0xaX7uGasp9c0Hs+88B7R9By1SejtYSVLfurAgMBAAE=
-----END RSA PUBLIC KEY-----
```
与私钥部分相识，查看各字段的值
`openssl asn1parse -i -in pubkey.pkcs1.pem` 
```example
# cat pubkey.pkcs1.pem
  0:d=0  hl=3 l= 137 cons: SEQUENCE
  3:d=1  hl=3 l= 129 prim:  INTEGER           :B614A0942E269BD799...D527A3B584952DFBA
135:d=1  hl=2 l=   3 prim:  INTEGER           :010001
```
## PKCS#8 格式<span id="60"/>
操作及查看方法与上文相似，简单介绍他们的机构和生成方式 
#### 私钥<span id="70"/>
```example
# PKCS#8 密钥 数据结构
PrivateKeyInfo ::= SEQUENCE 
{ 	
  verion               Version,    // 版本
  privateKeyAlgorithm		PrivateKeyAlgorithmIdentifier ::= SEQUENCE // 私钥算法
  privateKey				      PrivateKey ::= OCTET STRING ,    // 加密后私钥数据，最后一个OCTET STRING数据块 
  attributes           [0] IMPLICIT Attributes OPTIONAL ::= SET OF Attribute 
} 
```
把 pkcs1私钥 转换成 pkcs8私钥  
`openssl pkcs8 -topk8 -in prikey.pkcs1.pem -out prikey.pkcs8.pem -nocrypt`
`openssl asn1parse -i -in prikey.pkcs8.pem`  
```example
# cat prikey.pkcs8.pem
# 要靠缩进开区分是哪一组信息，所以要排好看一点 
 0:d=0 hl=4 l= 710 cons: SEQUENCE 
 4:d=1 hl=2 l= 64  cons:  SEQUENCE  
 6:d=2 hl=2 l= 9   prim:   OBJECT :PBES2  
17:d=2 hl=2 l= 51  cons:  SEQUENCE    
19:d=3 hl=2 l= 27  cons:   SEQUENCE    
21:d=4 hl=2 l= 9   prim:    OBJECT :PBKDF2  
32:d=4 hl=2 l= 14  cons:    SEQUENCE    
34:d=5 hl=2 l= 8   prim:     OCTET STRING [HEX DUMP]:7A61B055165A89CA
44:d=5 hl=2 l= 2   prim:     INTEGER :0800  
48:d=3 hl=2 l= 20  cons:   SEQUENCE  
50:d=4 hl=2 l= 8   prim:    OBJECT :des-ede3-cbc  
60:d=4 hl=2 l= 8   prim:    OCTET STRING [HEX DUMP]:110E8A184EFEAB9C   
70:d=1 hl=4 l= 640 prim:  OCTET STRING [HEX DUMP]:  
C94F34F0CFF56B3E92D437C49559B1BD6 ... 87948FD5C7526D569BB8  
```

#### 公钥<span id="80"/>
从 pkck1私钥 导出 pkcs8公钥
`openssl rsa  -in prikey.pkcs1.pem  -pubout -out pubkey.pkcs8.pem`  
与私钥部分相识，查看各字段的值
`openssl asn1parse -i -in pubkey.pkcs8.pem`
```example
# cat pubkey.pkcs8.pem 
-----BEGIN PUBLIC KEY----- 
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC2FKCULiab15n1BD6QvFz382kt
4GsDvuOM5tmYeZD7l8MucSyPpPORFyaWGoKI+pTwAKKbDy2epqq7WtYxOfqA1AzU 
1mNsk6XRTBHa2XzuSF+/0rXYj78p2hP4dnYPVbpCZCdrXNMWl+7hmrKfXNB7PvPA 
e0fQctUno7WElS37qwIDAQAB
-----END PUBLIC KEY-----
```
`openssl asn1parse -i -in pubkey.pkcs8.pem`  
```example
# cat pubkey.pkcs8.pem
 0:d=0  hl=3 l= 159 cons: SEQUENCE 
 3:d=1  hl=2 l=  13 cons:  SEQUENCE 
 5:d=2  hl=2 l=   9 prim:   OBJECT            :rsaEncryption 
 6:d=2  hl=2 l=   0 prim:   NULL 
18:d=1  hl=3 l= 141 prim:  BIT STRING
```

## PKCS#1/8 公私钥相互转换
```shell
# PKCS#1/8 公私钥相互转换
#生成   #1公：`openssl genrsa -out prikey.pkcs1.pem 1024`  

#1私 转 #8私：`openssl pkcs8 -in prikey.pkcs1.pem -out prikey.pkcs8.pem  -nocrypt `  
#8私 转 #1私：`openssl rsa   -in prikey.pkcs8.pem -out prikey.pkcs1.pem`  

#1私 转 #1公：`openssl rsa -in prikey.pkcs1.pem -out pubkey.pkcs1.pem -RSAPublicKey_out`
#8私 转 #8公：`openssl rsa -in prikey.pkcs8.pem -out pubkey.pkcs8.pem -pubout`

#1公 转 #8公：`openssl rsa -in pubkey.pkcs1.pem -out pubkey.pkcs8.pem -pubout -RSAPublicKey_in`
#8公 转 #1公：`openssl rsa -in pubkey.pkcs8.pem -out pubkey.pkcs1.pem -pubin  -RSAPublicKey_out`

#1私 转 #8公：`openssl rsa -in prikey.pkcs1.pem -out pubkey.pkcs8.pem -pubout`
```

## 参考<span id="100"/>
[# 秘钥/证书/https握手/CA相关概念](https://www.jianshu.com/p/ef06507269c0)  
[# 使用openssl命令剖析RSA私钥文件格式](https://blog.csdn.net/Zhymax/article/details/7683925)  
[# RSA公私钥格式分析及其在Java和Openssl之间的转换方法](https://blog.csdn.net/yaoyuanyylyy/article/details/89739176)  
[# RSA算法原理（一）](http://www.ruanyifeng.com/blog/2013/06/rsa_algorithm_part_one.html)
[# openssl RSA密钥格式PKCS1和PKCS8相互转换](https://www.cnblogs.com/cocoajin/p/10510574.html)
