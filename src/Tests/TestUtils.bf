using System;

namespace CPU_6502.Tests;

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


	public static void TestMemoryValue<TCount>(
		(Word addr, Byte val)[TCount] values,
		(Byte a, Byte x, Byte y) registers, Byte inst,
		(Word expectedAddres, Byte expectedVal) expectedVals,
		int expectedCycles,
		bool C = false, bool Z = false,
		bool I = false, bool D = false, bool B = false,
		bool V = false, bool N = false) where TCount: const int
	{
		Console.WriteLine("Testing things");
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

	public static void TestRegisterValue<TCount>(
		(Word addr, Byte val)[TCount] values,
		(Byte a, Byte x, Byte y) registers, Byte inst,
		(Word expectedAddres, Byte expectedVal) expectedVals,
		int expectedCycles,
		bool C = false, bool Z = false,
		bool I = false, bool D = false, bool B = false,
		bool V = false, bool N = false) where TCount: const int
	{
		Console.WriteLine("Testing things");
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

}