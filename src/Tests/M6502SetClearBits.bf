using System;

namespace CPU_6502.Tests;

static class M6502SetClearBits
{
	[Test]
	public static void TestClearCarry() => TestUtils.TestFlagsValues<0>(
		.(), (0, 0, 0), CPU.INS_CLC, 2);

	[Test]
	public static void TestSetCarry() => TestUtils.TestFlagsValues<0>(
		.(), (0, 0, 0), CPU.INS_SEC, 2, C:true);

	[Test]
	public static void TestClearDecimal() => TestUtils.TestFlagsValues<0>(
		.(), (0, 0, 0), CPU.INS_CLD, 2);


	[Test]
	public static void TestSetDecimal() => TestUtils.TestFlagsValues<0>(
		.(), (0, 0, 0), CPU.INS_SED, 2, D:true);


	[Test]
	public static void TestClearInterrupt() => TestUtils.TestFlagsValues<0>(
		.(), (0, 0, 0), CPU.INS_CLI, 2);


	[Test]
	public static void TestSetInterrupt() => TestUtils.TestFlagsValues<0>(
		.(), (0, 0, 0), CPU.INS_SEI, 2, I:true);

	[Test]
	public static void TestClearOverflow() => TestUtils.TestFlagsValues<0>(
		.(), (0, 0, 0), CPU.INS_CLV, 2);
}