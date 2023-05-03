using System;

namespace CPU_6502;	

class Program
{

	static void Main()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;
		cpu.X = 0x04;

		mem[0xFFFC] = CPU.INS_AND_INDY;
		mem[0xFFFD] = 0x02;

		mem[0x0006] = 0x00; //0x2 + 0x4
		mem[0x0007] = 0x80; //8000

		mem[0x8000] = 0x37;


		int cyclesNeeded = 5;

		Console.WriteLine($"memory: {mem[0x8000]}, a: {cpu.A}, op: {mem[0x8000] & cpu.A}");

		cpu.Execute(cyclesNeeded);

		Console.WriteLine($"memory: {mem[0x8000]}, a: {cpu.A}");
		Console.WriteLine("hey");

		/*Byte b = 54;
		Byte r = b - 55;
		Console.WriteLine($"resul is: {r}");*/ // overflow works correctly
	}
}