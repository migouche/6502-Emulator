using System;
using System.Collections;
namespace CPU_6502;
using CPU_6502.Assembler;	

class Program
{


	static mixin HardLoadProgram(Memory* mem, String path)
	{
		var r = mem.HardLoadProgram(path);
		if(r case .Err (let err))
		{
			Console.WriteLine(err);
			return;
		}
	}

	static mixin HexDump(String input, String output)
	{
		var r = Memory.DisassembleToHex(input, output);
		if(r case .Err(let err))
		{
			Console.WriteLine(err);
			return;
		}
	}

	static void Main()
	{
		//Parser.ReadLines("test.asm");

		//Assembly a = scope .("asm/testsuite-2.15/bin/ror_test.asm", true);

		//Console.WriteLine("assembly read");


		Memory mem = Memory();

		//mem.HardLoadProgram(a.Export(true));
		HardLoadProgram!(&mem, "asm/6502_65C02_functional_tests/bin_files/6502_functional_test.bin");

		//HexDump!("asm/6502_65C02_functional_tests/bin_files6502_functional_test.bin", "disasm/big_test.hex");


		//Console.WriteLine("memory copied");
		CPU cpu = scope CPU(&mem);
		//Console.WriteLine("cpu created");
		cpu.Run(0x400, true);
		//Console.WriteLine(mem.Get(0));

		//Console.WriteLine($"A: {cpu.A}");
		//Console.WriteLine($"$0200: {mem[0x0200]}, $0201: {mem[0x0201]}, $0202: {mem[0x0202]}");
		//Console.Write($"Status: {cpu.Status}");
		Console.WriteLine($"A: {cpu.A} X: {cpu.X} Y: {cpu.Y}");
		Console.WriteLine($"C: {cpu.C}, N: {cpu.N}");
		Console.WriteLine($"$2021: {cpu.memory.Get(0x2021)}");
	}
}