using System;

namespace CPU_6502.Tests;

class M6502STXTests
{
	// no flags checks
	[Test]
	public static void STXZeroPage()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.X = 0x37;

		mem[0xFFFC] = CPU.INS_STX_ZP;
		mem[0xFFFD] = 0x15;

		int cyclesNeeded = 3;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == mem[0x15]);
		Test.Assert(cyclesNeeded == c);
	}

	[Test]
	public static void STXZeroPageY()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.X = 0x37;
		cpu.Y = 0x07;

		mem[0xFFFC] = CPU.INS_STX_ZPY;
		mem[0xFFFD] = 0x15;

		int cyclesNeeded = 4;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == mem[0x15 + cpu.Y]);
		Test.Assert(cyclesNeeded == c);
	}

	[Test]
	public static void STXAbsolute()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.X = 0x37;

		mem[0xFFFC] = CPU.INS_STX_ABS;
		mem[0xFFFD] = 0x42;
		mem[0xFFFE] = 0x43; //0x4342

		int cyclesNeeded = 4;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == mem[0x4342]);
		Test.Assert(c == cyclesNeeded);
	}

}