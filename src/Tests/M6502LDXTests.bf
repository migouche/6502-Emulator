using System;

namespace CPU_6502.Tests;

class M6502LDXTests
{
	public static void AssertFlags (CPU cpu, bool Z, bool N)
	{
		Test.Assert(cpu.Z == Z);
		Test.Assert(cpu.N == N);
		// all other should be zero
		Test.Assert(!(cpu.C || cpu.I || cpu.D || cpu.B || cpu.V));
	}


	[Test]
	public static void LDAImmediate()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);


		mem[0xFFFC] = CPU.INS_LDX_IM;
		mem[0xFFFD] = 0x84;

		int cyclesNeeded = 2;

		int cycles = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == 0x84);
		AssertFlags(cpu, false, true);
		Test.Assert(cyclesNeeded == cycles);

		mem[0xFFFE] = CPU.INS_LDX_IM;
		mem[0xFFFF] = 0;


		cycles = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == 0);
		AssertFlags(cpu, true, false);
		Test.Assert(cyclesNeeded == cycles);
	}

	[Test]
	public static void LDXZero()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);


		mem[0xFFFC] = CPU.INS_LDX_ZP;
		mem[0xFFFD] = 0x42;
		mem[0x0042] = 0x37;

		int cyclesNeeded = 3;
		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDAZeroY()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.Y = 5;

		mem[0xFFFC] = CPU.INS_LDX_ZPY;
		mem[0xFFFD] = 0x42;
		mem[0x0047] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDXZeroYWrap()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.Y = 0xFF;

		mem[0xFFFC] = CPU.INS_LDX_ZPY;
		mem[0xFFFD] = 0x80;
		mem[0x007F] = 0x37;

		int cyclesNeeded = 4;

		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDXAbs()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);



		mem[0xFFFC] = CPU.INS_LDX_ABS;
		mem[0xFFFD] = 0x80;
		mem[0xFFFE] = 0x44; // 0x4480
		mem[0x4480] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDXAbsY()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.Y = 0x92;
		
		mem[0xFFFC] = CPU.INS_LDX_ABSY;
		mem[0xFFFD] = 0x00;
		mem[0xFFFE] = 0x20; // 0x2000
		mem[0x2092] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDXAbsYWrap()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		cpu.Y = 0xFF;
		
		mem[0xFFFC] = CPU.INS_LDX_ABSY;
		mem[0xFFFD] = 0x02;
		mem[0xFFFE] = 0x44; // 0x4402
		mem[0x4501] = 0x37;

		int cyclesNeeded = 5;


		int c = cpu.Execute(cyclesNeeded);

		Test.Assert(cpu.X == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}
}