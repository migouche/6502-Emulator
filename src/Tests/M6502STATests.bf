using System;

namespace CPU_6502.Tests;

class M6502STATests
{
	// no flags checks
	[Test]
	public static void STAZeroPage()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0x37;

		mem[0xFFFC] = CPU.INS_STA_ZP;
		mem[0xFFFD] = 0x15;

		int cyclesNeeded = 3;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.A == mem[0x15]);
		Test.Assert(cyclesNeeded == c);
	}

	[Test]
	public static void STAZeroPageX()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0x37;
		cpu.X = 0x07;

		mem[0xFFFC] = CPU.INS_STA_ZPX;
		mem[0xFFFD] = 0x15;

		int cyclesNeeded = 4;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.A == mem[0x15 + cpu.X]);
		Test.Assert(cyclesNeeded == c);
	}

	[Test]
	public static void STAAbsolute()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0x37;

		mem[0xFFFC] = CPU.INS_STA_ABS;
		mem[0xFFFD] = 0x42;
		mem[0xFFFE] = 0x43; //0x4342

		int cyclesNeeded = 4;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.A == mem[0x4342]);
		Test.Assert(c == cyclesNeeded);
	}

	[Test]
	public static void STAAbsoluteX()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0x37;
		cpu.X = 0x07;

		mem[0xFFFC] = CPU.INS_STA_ABSX;
		mem[0xFFFD] = 0x42;
		mem[0xFFFE] = 0x43; //0x4342

		int cyclesNeeded = 5;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.A == mem[0x4342 + cpu.X]);
		Test.Assert(c == cyclesNeeded);
	}

	[Test]
	public static void STAAbsoluteY()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0x37;
		cpu.Y = 0x07;

		mem[0xFFFC] = CPU.INS_STA_ABSY;
		mem[0xFFFD] = 0x42;
		mem[0xFFFE] = 0x43; //0x4342

		int cyclesNeeded = 5;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.A == mem[0x4342 + cpu.Y]);
		Test.Assert(c == cyclesNeeded);
	}

	[Test]
	public static void STAIndirectX()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0x37;
		cpu.X  = 0x07;

		mem[0xFFFC] = CPU.INS_STA_INDX;
		mem[0xFFFD] = 0x27;
		mem[0x27 + cpu.X] = 0x23;
		mem[0x27 + cpu.X + 1] = 0x83; // 0x8323

		int cyclesNeeded = 6;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.A == mem[0x8323]);
		Test.Assert(c == cyclesNeeded);
	}

	[Test]
	public static void STAIndirectY()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0x37;
		cpu.Y  = 0x07;

		mem[0xFFFC] = CPU.INS_STA_INDY;
		mem[0xFFFD] = 0x27;
		mem[0x27] = 0x23;
		mem[0x28] = 0x83; // 0x8323

		int cyclesNeeded = 6;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.A == mem[0x8323 + cpu.Y]);
		Test.Assert(c == cyclesNeeded);
	}

}