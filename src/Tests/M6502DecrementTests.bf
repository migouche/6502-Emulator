using System;

namespace CPU_6502.Tests;

class M6502DecrementTests
{

	public static void AssertFlags (CPU cpu, bool Z, bool N)
	{
		Test.AssertEq(cpu.Z, Z);
		Test.AssertEq(cpu.N, N);
		// all other should be zero
		Test.Assert(!(cpu.C || cpu.I || cpu.D || cpu.B || cpu.V));
	}

	[Test]
	public static void DEXTest()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.X = 4;

		mem[0xFFFC] = CPU.INS_DEX;

		int cyclesNeeded = 2;
		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.X, 3);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	
	[Test]
	public static void DEYTest()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.Y = 4;

		mem[0xFFFC] = CPU.INS_DEY;

		int cyclesNeeded = 2;
		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.Y, 3);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void DECZeroPage() => TestUtils.TestMemoryValue<2>(
		.((0xFFFD, 0x75), (0x75, 7)), (0, 0, 0), CPU.INS_DEC_ZP,
		(0x75, 6), 5);

	[Test]
	public static void DECZeroPageX() => TestUtils.TestMemoryValue<2>(
		.((0xFFFD, 0x75), (0x75+4, 7)), (0, 4, 0), CPU.INS_DEC_ZPX,
		(0x75+4, 6), 6);


	[Test]
	public static void DecAbs() => TestUtils.TestMemoryValue<3>(
    .((0xFFFD, 0x23), (0xFFFE, 0x84), (0x8423, 0x08)),
    (0, 0, 0), CPU.INS_DEC_ABS, (0x8423, 0x07), 6);


	[Test]
	public static void DecAbsX() => TestUtils.TestMemoryValue<3>(
		.((0xFFFD, 0x23), (0xFFFE, 0x84), (0x8423 + 7, 0xFF)),
		(0, 7, 0), CPU.INS_DEC_ABSX, (0x8423+7, 0xFE), 7, N:true);
}