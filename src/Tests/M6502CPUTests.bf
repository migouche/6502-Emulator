using System;

namespace CPU_6502.Tests;

class M6502CPUTests
{
	[Test]
	public static void Test0Cycles()
	{
		CPU cpu = scope CPU();
		Memory mem = .();
		int cyclesNeeded = 0;
		int c = cpu.Execute(cyclesNeeded, ref mem);
		Test.Assert(c == cyclesNeeded);
	}
}