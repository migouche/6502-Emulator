using System;
using System.Collections;
namespace CPU_6502;
using CPU_6502.Assembler;	

class Program
{

	static void Main()
	{
		//Parser.ReadLines("test.asm");

		Assembly a = scope .("asm/tests/shifts/rol_test.asm", true);

		//Console.WriteLine("assembly read");


		Memory mem = Memory();

		mem.HardLoadProgram(a.Export(true));

		//Console.WriteLine("memory copied");
		CPU cpu = scope CPU(&mem);
		//Console.WriteLine("cpu created");
		cpu.Run(true);
		//Console.WriteLine(mem.Get(0));

		//Console.WriteLine($"A: {cpu.A}");
		//Console.WriteLine($"$0200: {mem[0x0200]}, $0201: {mem[0x0201]}, $0202: {mem[0x0202]}");
		//Console.Write($"Status: {cpu.Status}");
		Console.WriteLine($"A: {cpu.A} X: {cpu.X} Y: {cpu.Y}");
		Console.WriteLine($"C: {cpu.C}, N: {cpu.N}");
		Console.WriteLine($"mem: {cpu.memory.Get(0x2021)}");
	}
}