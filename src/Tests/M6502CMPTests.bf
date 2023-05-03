using System;

namespace CPU_6502.Tests;

static class M6502CMPTests
{
	[Test]
	public static void CMPIMZTest() => TestUtils.TestFlagsValues<1>(
		.((0xFFFD, 0x07)), (0x07, 0, 0), CPU.INS_CMP_IM,
		2, Z: true, C: true);

	[Test]
	public static void CMPIMCTest() => TestUtils.TestFlagsValues<1>(
		.((0xFFFD, 0x07)), (0x08, 0, 0), CPU.INS_CMP_IM,
		2, C: true);

	[Test]
	public static void CMPIMNTest() => TestUtils.TestFlagsValues<1>(
		.((0xFFFD, 0x07)), (0x06, 0, 0), CPU.INS_CMP_IM,
		2, N: true);

	// flags work so now we just check addressing modes

	[Test]
	public static void CMPZPTest() => TestUtils.TestFlagsValues<2>(
		.((0xFFFD, 0x07), (0x07, 0x15)), (0x15, 0, 0), CPU.INS_CMP_ZP,
		3, Z: true, C: true);

	[Test]
	public static void CMPZPXTest() => TestUtils.TestFlagsValues<2>(
		.((0xFFFD, 0x07), (0x07 + 4, 0x15)), (0x15, 4, 0), CPU.INS_CMP_ZPX,
		4, Z: true, C: true);

	[Test]
	public static void CMPABSTest() => TestUtils.TestFlagsValues<3>(
		.((0xFFFD, 0x07), (0xFFFE, 0x15), (0x1507, 0x15)), (0x15, 0, 0), CPU.INS_CMP_ABS,
		4, Z: true, C: true);

	[Test]
	public static void CMPABSXTest() => TestUtils.TestFlagsValues<3>(
		.((0xFFFD, 0x07), (0xFFFE, 0x15), (0x1508, 0x15)), (0x15, 1, 0), CPU.INS_CMP_ABSX,
		4, Z: true, C: true);

	[Test]
	public static void CMPABSXTestWrap() => TestUtils.TestFlagsValues<3>(
		.((0xFFFD, 0x07), (0xFFFE, 0x15), (0x1507 + 0xFF, 0x15)), (0x15, 0xFF, 0), CPU.INS_CMP_ABSX,
		5, Z: true, C: true);

	[Test]
	public static void CMPABSYTest() => TestUtils.TestFlagsValues<3>(
		.((0xFFFD, 0x07), (0xFFFE, 0x15), (0x1508, 0x15)), (0x15, 0, 1), CPU.INS_CMP_ABSY,
		4, Z: true, C: true);

	[Test]
	public static void CMPABSYTestWrap() => TestUtils.TestFlagsValues<3>(
		.((0xFFFD, 0x07), (0xFFFE, 0x15), (0x1507 + 0xFF, 0x15)), (0x15, 0, 0xFF), CPU.INS_CMP_ABSY,
		5, Z: true, C: true);

	[Test]
	public static void CMPINDXTest() => TestUtils.TestFlagsValues<4>(
		.((0xFFFD, 0x07), (0x08, 0x15), (0x09, 0x16), (0x1615, 0x07)),
		(0x07, 1, 0), CPU.INS_CMP_INDX, 6, Z: true, C: true);

	[Test]
	public static void CMPINDYTest() => TestUtils.TestFlagsValues<4>(
		.((0xFFFD, 0x08), (0x08, 0x15), (0x09, 0x16), (0x1616, 0x07)),
		(0x07, 0, 1), CPU.INS_CMP_INDY, 5, Z: true, C: true);

	[Test]
	public static void CMPINDYTestWrap() => TestUtils.TestFlagsValues<4>(
		.((0xFFFD, 0x08), (0x08, 0x15), (0x09, 0x16), (0x1615+0xFF, 0x07)),
		(0x07, 0, 0xFF), CPU.INS_CMP_INDY, 6, Z: true, C: true);

}