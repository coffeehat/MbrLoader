# x86 Mbr磁盘程序加载器

一个简单的x86 Mbr实模式程序。该程序将读取磁盘中以LBA=100扇区为起始存储的代码，然后将其加载到内存地址0x10000处，最后跳转至程序入口执行该代码。