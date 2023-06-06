using System;
using System.Collections;
namespace CPU_6502;
using CPU_6502.Assembler;	

class Program
{

	static void Main()
	{
		AST.Start();
		//Parser.ReadLines("test.asm");

		Assembly a = scope .("test.asm");


		Memory mem = .();
		mem.HardLoadProgram(a.Export());
		CPU cpu = scope CPU(&mem);
		cpu.Run(a.startAddress);

		Console.WriteLine($"A: {cpu.A}");
		Console.WriteLine($"$0200: {mem[0x0200]}, $0201: {mem[0x0201]}, $0202: {mem[0x0202]}");
		AST.Stop();

	}
}