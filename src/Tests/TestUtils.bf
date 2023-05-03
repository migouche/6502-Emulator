using System;

namespace CPU_6502.Tests;

///A class for automating CPU Instruction tests
class TestUtils
{
	private static void TestFlags(CPU cpu,
		bool C, bool Z, bool I, bool D, bool B, bool V, bool N)
	{
		Test.AssertEq(cpu.C, C);
		Test.AssertEq(cpu.Z, Z);
		Test.AssertEq(cpu.I, I);
		Test.AssertEq(cpu.D, D);
		Test.AssertEq(cpu.B, B);
		Test.AssertEq(cpu.V, V);
		Test.AssertEq(cpu.N, N);
	}

	public static void TestFlagsValues<TCount>(
		(Word addr, Byte val)[TCount] values,
		(Byte a, Byte x, Byte y) registers, Byte inst,
		int expectedCycles,
		bool C = false, bool Z = false,
		bool I = false, bool D = false, bool B = false,
		bool V = false, bool N = false) where TCount: const int
	{
		Memory mem = .();
		CPU cpu = scope .(&mem);

		(cpu.A, cpu.X, cpu.Y) = registers;
		mem[0xFFFC] = inst;
		for(let val in values)
		{
			let addr = val.addr;
			let byte = val.val;
			mem[addr] = byte;
		}
		int cyclesConsumed = cpu.Execute(expectedCycles);

		Test.AssertEq(cyclesConsumed, expectedCycles);
		TestFlags(cpu, C, Z, I, D, B, V, N);

	}

	public static void TestMemoryValue<TCount>(
		(Word addr, Byte val)[TCount] values,
		(Byte a, Byte x, Byte y) registers, Byte inst,
		(Word expectedAddres, Byte expectedVal) expectedVals,
		int expectedCycles,
		bool C = false, bool Z = false,
		bool I = false, bool D = false, bool B = false,
		bool V = false, bool N = false) where TCount: const int
	{
		//Console.WriteLine("Testing things");
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		(cpu.A, cpu.X, cpu.Y) = registers;
		mem[0xFFFC] = inst;
		for(let val in values)
		{
			let addr = val.addr;
			let byte = val.val;
			mem[addr] = byte;
		}
		int cyclesConsumed = cpu.Execute(expectedCycles);
		Test.AssertEq(mem[expectedVals.expectedAddres],
						expectedVals.expectedVal);
		Test.AssertEq(cyclesConsumed, expectedCycles);
		TestFlags(cpu, C, Z, I, D, B, V, N);
	}

	public static void TestRegisters(CPU cpu, Byte A, Byte X, Byte Y)
	{
		Test.AssertEq(cpu.A, A);
		Test.AssertEq(cpu.X, X);
		Test.AssertEq(cpu.Y, Y);
	}

	/// not working yet
	public static void TestRegisterValue<TCount>(
		(Word addr, Byte val)[TCount] values,
		(Byte a, Byte x, Byte y) registers, Byte inst,
		int expectedCycles,
		Byte A = 0, Byte X = 0, Byte Y = 0,
		bool C = false, bool Z = false,
		bool I = false, bool D = false, bool B = false,
		bool V = false, bool N = false) where TCount: const int
	{
		//Console.WriteLine("Testing things");
		Memory mem = .();
		CPU cpu = scope CPU(&mem);
		(cpu.A, cpu.X, cpu.Y) = registers;
		mem[0xFFFC] = inst;
		for(let val in values)
		{
			let addr = val.addr;
			let byte = val.val;
			mem[addr] = byte;
		}
		int cyclesConsumed = cpu.Execute(expectedCycles);
		Test.AssertEq(cyclesConsumed, expectedCycles);
		TestFlags(cpu, C, Z, I, D, B, V, N);
		TestRegisters(cpu, A, X, Y);
	}

}