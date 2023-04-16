using System;

namespace CPU_6502;

class Program
{

	static void Main()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.Reset();


		// hard-coding a program
		mem[0xFFFC] = CPU.INS_JSR;
		/*mem[0xFFFD] = 0x42;
		mem[0xFFFE] = 0x42;*/
		mem.WriteWord(0x4242, 0xFFFD);
		mem[0x4242] = CPU.INS_LDA_IM;
		mem[0x4243] = 0x84;
		Console.WriteLine(cpu.A);

		cpu.Execute(8);

		Console.WriteLine(cpu.A);

	}
}