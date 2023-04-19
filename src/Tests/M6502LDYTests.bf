using System;

namespace CPU_6502.Tests;

class M6502LDYTests
{
	public static void AssertFlags (CPU cpu, bool Z, bool N)
	{
		Test.AssertEq(cpu.Z, Z);
		Test.AssertEq(cpu.N, N);
		// all other should be zero
		Test.Assert(!(cpu.C || cpu.I || cpu.D || cpu.B || cpu.V));
	}


	[Test]
	public static void LDAImmediate()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);


		mem[0xFFFC] = CPU.INS_LDY_IM;
		mem[0xFFFD] = 0x84;

		int cyclesNeeded = 2;

		int cycles = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.Y, 0x84);
		AssertFlags(cpu, false, true);
		Test.AssertEq(cyclesNeeded, cycles);

		mem[0xFFFE] = CPU.INS_LDY_IM;
		mem[0xFFFF] = 0;


		cycles = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.Y, 0);
		AssertFlags(cpu, true, false);
		Test.AssertEq(cyclesNeeded, cycles);
	}

	[Test]
	public static void LDYZero()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);


		mem[0xFFFC] = CPU.INS_LDY_ZP;
		mem[0xFFFD] = 0x42;
		mem[0x0042] = 0x37;

		int cyclesNeeded = 3;
		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.Y, 0x37);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDYZeroY()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.X = 5;

		mem[0xFFFC] = CPU.INS_LDY_ZPX;
		mem[0xFFFD] = 0x42;
		mem[0x0047] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.Y, 0x37);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDYZeroXWrap()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.X = 0xFF;

		mem[0xFFFC] = CPU.INS_LDY_ZPX;
		mem[0xFFFD] = 0x80;
		mem[0x007F] = 0x37;

		int cyclesNeeded = 4;

		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.Y, 0x37);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDYAbs()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);



		mem[0xFFFC] = CPU.INS_LDY_ABS;
		mem[0xFFFD] = 0x80;
		mem[0xFFFE] = 0x44; // 0x4480
		mem[0x4480] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.Y, 0x37);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDYAbsX()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.X = 0x92;
		
		mem[0xFFFC] = CPU.INS_LDY_ABSX;
		mem[0xFFFD] = 0x00;
		mem[0xFFFE] = 0x20; // 0x2000
		mem[0x2092] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.Y, 0x37);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDYAbsXWrap()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.X = 0xFF;
		
		mem[0xFFFC] = CPU.INS_LDY_ABSX;
		mem[0xFFFD] = 0x02;
		mem[0xFFFE] = 0x44; // 0x4402
		mem[0x4501] = 0x37;

		int cyclesNeeded = 5;


		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.Y, 0x37);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}
}