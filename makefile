make:
	aarch64-linux-gnu-as main.s -o main.o
	aarch64-linux-gnu-as float.s -o float.o
	aarch64-linux-gnu-as float2.s -o float2.o
	aarch64-linux-gnu-ld -static main.o float.o float2.o -o main.x

divide:
	aarch64-linux-gnu-as main.s -o main.o
	aarch64-linux-gnu-as float2.s -o float2.o
	aarch64-linux-gnu-ld -static main.o float2.o -o maindiv.x


