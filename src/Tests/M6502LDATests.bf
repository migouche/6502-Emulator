using System;

namespace CPU_6502;

class M5302LDATests
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
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);

		mem[0xFFFC] = CPU.INS_LDA_IM;
		mem[0xFFFD] = 0x84;

		int cyclesNeeded = 2;

		int cycles = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x84);
		AssertFlags(cpu, false, true);
		Test.Assert(cyclesNeeded == cycles);

		mem[0xFFFE] = CPU.INS_LDA_IM;
		mem[0xFFFF] = 0;


		cycles = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0);
		AssertFlags(cpu, true, false);
		Test.Assert(cyclesNeeded == cycles);
	}

	[Test]
	public static void LDAZero()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);

		mem[0xFFFC] = CPU.INS_LDA_ZP;
		mem[0xFFFD] = 0x42;
		mem[0x0042] = 0x37;

		int cyclesNeeded = 3;
		int c = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
		
	}

	[Test]
	public static void LDAZeroX()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);
		cpu.X = 5;

		mem[0xFFFC] = CPU.INS_LDA_ZPX;
		mem[0xFFFD] = 0x42;
		mem[0x0047] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
		
	}

	[Test]
	public static void LDAZeroXWrap()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);
		cpu.X = 0xFF;

		mem[0xFFFC] = CPU.INS_LDA_ZPX;
		mem[0xFFFD] = 0x80;
		mem[0x007F] = 0x37;

		int cyclesNeeded = 4;

		int c = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDAAbs()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);


		mem[0xFFFC] = CPU.INS_LDA_ABS;
		mem[0xFFFD] = 0x80;
		mem[0xFFFE] = 0x44; // 0x4480
		mem[0x4480] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDAAbsX()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);
		cpu.X = 0x92;
		
		mem[0xFFFC] = CPU.INS_LDA_ABSX;
		mem[0xFFFD] = 0x00;
		mem[0xFFFE] = 0x20; // 0x2000
		mem[0x2092] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDAAbsXWrap()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);
		cpu.X = 0xFF;
		
		mem[0xFFFC] = CPU.INS_LDA_ABSX;
		mem[0xFFFD] = 0x02;
		mem[0xFFFE] = 0x44; // 0x4402
		mem[0x4501] = 0x37;

		int cyclesNeeded = 5;


		int c = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDAAbyX()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);
		cpu.Y = 0x92;
		
		mem[0xFFFC] = CPU.INS_LDA_ABSY;
		mem[0xFFFD] = 0x00;
		mem[0xFFFE] = 0x20; // 0x2000
		mem[0x2092] = 0x37;

		int cyclesNeeded = 4;


		int c = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDAAbsYWrap()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);
		cpu.Y = 0xFF;
		
		mem[0xFFFC] = CPU.INS_LDA_ABSY;
		mem[0xFFFD] = 0x02;
		mem[0xFFFE] = 0x44; // 0x4402
		mem[0x4501] = 0x37;

		int cyclesNeeded = 5;


		int c = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDAIndirectX()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);
		cpu.X = 0x04;
		
		mem[0xFFFC] = CPU.INS_LDA_INDX;
		mem[0xFFFD] = 0x02;

		mem[0x0006] = 0x00; //0x2 + 0x4
		mem[0x0007] = 0x80; //8000

		mem[0x8000] = 0x37;

		int cyclesNeeded = 5;


		int c = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDAIndirectY()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);
		cpu.Y = 0x04;
		
		mem[0xFFFC] = CPU.INS_LDA_INDY;
		mem[0xFFFD] = 0x02;

		mem[0x0002] = 0x00; 
		mem[0x0003] = 0x80; // 0x8000
		mem[0x8004] = 0x37; // 0x8000 + 0x04

		int cyclesNeeded = 5;


		int c = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}

	[Test]
	public static void LDAIndirectYWrap()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		cpu.Reset(ref mem);
		cpu.Y = 0xff;

		mem[0xFFFC] = CPU.INS_LDA_INDY;
		mem[0xFFFD] = 0x02;

		mem[0x0002] = 0x02; 
		mem[0x0003] = 0x80; // 0x8002

		mem[0x8101] = 0x37; // 0x8000 + 0x04

		int cyclesNeeded = 6;


		int c = cpu.Execute(cyclesNeeded, ref mem);

		Test.Assert(cpu.A == 0x37);
		Test.Assert(c == cyclesNeeded);
		AssertFlags(cpu, false, false);
	}
}