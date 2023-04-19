using System;

namespace CPU_6502.Tests;


class M5302ANDTests
{

	public static void AssertFlags (CPU cpu, bool Z, bool N)
	{
		Test.AssertEq(cpu.Z, Z);
		Test.AssertEq(cpu.N, N);
		// all other should be zero
		Test.Assert(!(cpu.C || cpu.I || cpu.D || cpu.B || cpu.V));
	}

	[Test]
	public static void ANDImmediate()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;


		mem[0xFFFC] = CPU.INS_AND_IM;
		mem[0xFFFD] = 0x84;

		int cyclesNeeded = 2;

		int cycles = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.A, 0x84 & 0xD7);
		AssertFlags(cpu, false, true);
		Test.AssertEq(cyclesNeeded, cycles);

		mem[0xFFFE] = CPU.INS_AND_IM;
		mem[0xFFFF] = 0;


		cycles = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.A, 0);
		AssertFlags(cpu, true, false);
		Test.AssertEq(cyclesNeeded, cycles);
	}

	[Test]
	public static void ANDZero()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;

		mem[0xFFFC] = CPU.INS_AND_ZP;
		mem[0xFFFD] = 0x42;
		mem[0x0042] = 0x37;

		int cyclesNeeded = 3;
		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.A, 0x37 & 0xD7);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
		
	}

	[Test]
	public static void ANDZeroX()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;
		cpu.X = 5;

		mem[0xFFFC] = CPU.INS_AND_ZPX;
		mem[0xFFFD] = 0x42;
		mem[0x0047] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.A, 0x37 & 0xD7);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
		
	}

	[Test]
	public static void ANDZeroXWrap()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;
		cpu.X = 0xFF;

		mem[0xFFFC] = CPU.INS_AND_ZPX;
		mem[0xFFFD] = 0x80;
		mem[0x007F] = 0x37;

		int cyclesNeeded = 4;

		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.A, 0x37 & 0xD7);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void ANDAbs()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;

		mem[0xFFFC] = CPU.INS_AND_ABS;
		mem[0xFFFD] = 0x80;
		mem[0xFFFE] = 0x44; // 0x4480
		mem[0x4480] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.A, 0x37 & 0xD7);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void ANDAbsX()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;
		cpu.X = 0x92;
		
		mem[0xFFFC] = CPU.INS_AND_ABSX;
		mem[0xFFFD] = 0x00;
		mem[0xFFFE] = 0x20; // 0x2000
		mem[0x2092] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded);


		Test.AssertEq(cpu.A, 0x37 & 0xD7);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void ANDAbsXWrap()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;
		cpu.X = 0xFF;
		
		mem[0xFFFC] = CPU.INS_AND_ABSX;
		mem[0xFFFD] = 0x02;
		mem[0xFFFE] = 0x44; // 0x4402
		mem[0x4501] = 0x37;

		int cyclesNeeded = 5;


		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.A, 0x37 & 0xD7);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void ANDAbyX()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;
		cpu.Y = 0x92;
		
		mem[0xFFFC] = CPU.INS_AND_ABSY;
		mem[0xFFFD] = 0x00;
		mem[0xFFFE] = 0x20; // 0x2000
		mem[0x2092] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.A, 0x37 & 0xD7);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void ANDAbsYWrap()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;
		cpu.Y = 0xFF;
		
		mem[0xFFFC] = CPU.INS_AND_ABSY;
		mem[0xFFFD] = 0x02;
		mem[0xFFFE] = 0x44; // 0x4402
		mem[0x4501] = 0x37;

		int cyclesNeeded = 5;


		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.A, 0x37 & 0xD7);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void ANDIndirectX()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;
		cpu.X = 0x04;
		
		mem[0xFFFC] = CPU.INS_AND_INDX;
		mem[0xFFFD] = 0x02;

		mem[0x0006] = 0x00; //0x2 + 0x4
		mem[0x0007] = 0x80; //8000

		mem[0x8000] = 0x37;


		int cyclesNeeded = 5;

		Console.WriteLine($"memory: {mem[0x8000]}, a: {cpu.A}, op: {mem[0x8000] & cpu.A}");

		int c = cpu.Execute(cyclesNeeded);

		Console.WriteLine($"memory: {mem[0x8000]}, a: {cpu.A}");

		Test.AssertEq(cpu.A, 0x37);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void ANDIndirectY()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;
		cpu.Y = 0x04;
		
		mem[0xFFFC] = CPU.INS_AND_INDY;
		mem[0xFFFD] = 0x02;

		mem[0x0002] = 0x00; 
		mem[0x0003] = 0x80; // 0x8000
		mem[0x8004] = 0x37; // 0x8000 + 0x04

		int cyclesNeeded = 5;


		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.A, 0x37 & 0xD7);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void ANDIndirectYWrap()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		cpu.A = 0xD7;
		cpu.Y = 0xff;

		mem[0xFFFC] = CPU.INS_AND_INDY;
		mem[0xFFFD] = 0x02;

		mem[0x0002] = 0x02; 
		mem[0x0003] = 0x80; // 0x8002

		mem[0x8101] = 0x37; // 0x8000 + 0x04

		int cyclesNeeded = 6;


		int c = cpu.Execute(cyclesNeeded);

		Test.AssertEq(cpu.A, 0x37 & 0xD7);
		Test.AssertEq(c, cyclesNeeded);
		AssertFlags(cpu, false, false);
	}
}