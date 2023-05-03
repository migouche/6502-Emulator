using System;

namespace CPU_6502.Tests;

class M6502BITTests
{
	[Test]
	public static void BITZZP() => TestUtils.TestFlagsValues<1>(
		.((0xFFFD, 0x75)), (0xFF, 0, 0), CPU.INS_BIT_ZP, 3, Z:true);

	[Test]
	public static void BITNZP() => TestUtils.TestFlagsValues<2>(
		.((0xFFFD, 0x75), (0x75, 0b10000000)), (0xFF, 0, 0),
		CPU.INS_BIT_ZP, 3, N:true);

	[Test]
	public static void BITVZP() => TestUtils.TestFlagsValues<2>(
		.((0xFFFD, 0x75), (0x75, 0b01000000)), (0xFF, 0, 0),
		CPU.INS_BIT_ZP, 3, V:true);

	[Test]
	public static void BITNVABS() => TestUtils.TestFlagsValues<3>(
		.((0xFFFD, 0x75),(0x0FFFE, 0x20), (0x2075, 0b11000000)),
		(0xFF, 0, 0), CPU.INS_BIT_ABS, 4, V:true, N:true);
}