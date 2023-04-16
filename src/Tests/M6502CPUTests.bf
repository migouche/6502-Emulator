using System;

namespace CPU_6502.Tests;

class M6502CPUTests
{
	[Test]
	public static void Test0Cycles()
	{
		Memory mem = .();
		CPU cpu = scope CPU(&mem);

		int cyclesNeeded = 0;
		int c = cpu.Execute(cyclesNeeded);
		Test.Assert(c == cyclesNeeded);
	}
}