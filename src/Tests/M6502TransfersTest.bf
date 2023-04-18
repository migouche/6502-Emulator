using System;

namespace CPU_6502.Tests;

class M6502TransfersTest
{
	public static void TestFlags(CPU cpu, bool z, bool n)
	{
		Test.Assert(cpu.Z == z);
		Test.Assert(cpu.N == n);
		// all other should be zero
		Test.Assert(!(cpu.C || cpu.I || cpu.D || cpu.B || cpu.V));

	}

	[Test]
	public static void TestTXA()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.X = 0xFE;

		mem[0xFFFC] = CPU.INS_TXA;

		int cyclesNeeded = 2;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == cpu.A);
		Test.Assert(c == cyclesNeeded);
		TestFlags(cpu, false, true);
	}

	[Test]
	public static void TestTAX()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.A = 0xFE;

		mem[0xFFFC] = CPU.INS_TAX;

		int cyclesNeeded = 2;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == cpu.A);
		Test.Assert(c == cyclesNeeded);
		TestFlags(cpu, false, true);
	}

	[Test]
	public static void TestTYA()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.Y = 0xFE;

		mem[0xFFFC] = CPU.INS_TYA;

		int cyclesNeeded = 2;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.Y == cpu.A);
		Test.Assert(c == cyclesNeeded);
		TestFlags(cpu, false, true);
	}

	[Test]
	public static void TestTAY()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.A = 0xFE;

		mem[0xFFFC] = CPU.INS_TAY;

		int cyclesNeeded = 2;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.Y == cpu.A);
		Test.Assert(c == cyclesNeeded);
		TestFlags(cpu, false, true);
	}

	[Test]
	public static void TestTXS()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.X = 0x37;

		mem[0xFFFC] = CPU.INS_TXS;

		int cyclesNeeded = 2;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == cpu.SP);
		Test.Assert(c == cyclesNeeded);
	}

	
	[Test]
	public static void TestTSX()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.SP = 0x37;

		mem[0xFFFC] = CPU.INS_TSX;

		int cyclesNeeded = 2;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == cpu.SP);
		Test.Assert(c == cyclesNeeded);
		TestFlags(cpu, false, false);
	}
}