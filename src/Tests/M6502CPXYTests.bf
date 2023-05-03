using System;

namespace CPU_6502.Tests;

static class M6502CPXYTests
{
	[Test]
	public static void CPXIMZTest() => TestUtils.TestFlagsValues<1>(
		.((0xFFFD, 0x07)), (0, 0x07, 0), CPU.INS_CPX_IM,
		2, Z: true, C: true);

	[Test]
	public static void CPXZPTest() => TestUtils.TestFlagsValues<2>(
		.((0xFFFD, 0x07), (0x07, 0x15)), (0, 0x15, 0), CPU.INS_CPX_ZP,
		3, Z: true, C: true);

	[Test]
	public static void CPXABSTest() => TestUtils.TestFlagsValues<3>(
		.((0xFFFD, 0x07), (0xFFFE, 0x15), (0x1507, 0x15)), (0, 0x15, 0), CPU.INS_CPX_ABS,
		4, Z: true, C: true);
}
