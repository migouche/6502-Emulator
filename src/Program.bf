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
		CPU cpu = scope CPU(&mem);

		Console.WriteLine("breakpoint");

		//mem.HardLoadProgram(a.Export(true));
		HardLoadProgram!(&mem, "asm/6502_65C02_functional_tests/bin_files/6502_functional_test.bin");

		//HexDump!("asm/6502_65C02_functional_tests/bin_files6502_functional_test.bin", "disasm/big_test.hex");


		//Console.WriteLine("memory copied");

		//Console.WriteLine("cpu created");
		cpu.Run(0x400, false, true);
		//cpu.LoadSavestate("save.cpu", true);
		//Console.WriteLine(mem.Get(0));

		//Console.WriteLine($"A: {cpu.A}");
		//Console.WriteLine($"$0200: {mem[0x0200]}, $0201: {mem[0x0201]}, $0202: {mem[0x0202]}");
		//Console.Write($"Status: {cpu.Status}");
		Console.WriteLine($"A: {cpu.A} X: {cpu.X} Y: {cpu.Y}");
		Console.WriteLine($"N: {cpu.N}, V: {cpu.V}, 1: 1, B: {cpu.B}, D: {cpu.D}, I: {cpu.I}, Z: {cpu.Z}, C: {cpu.C}");
		Console.WriteLine($"ad1 (0x000d): {mem[0x000d]}, sb2 (0x0012): {mem[0x0012]}, adrl (0x0000): {mem[0x0000]}");
		Console.WriteLine($"$2021: {cpu.memory.Get(0x2021)}");
		Console.ReadLine(.. scope .());
	}
}