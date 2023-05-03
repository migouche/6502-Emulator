using System;

namespace CPU_6502.Tests;

static class M6502ADCTests
{
	[Test]
	public static void AddImNothing() => TestUtils.TestRegisterValue<1>(
		.((0xFFFD, 5)), (5, 0, 0), CPU.INS_ADC_IM, 2, A: 10);


	[Test]
	public static void AddImZero() => TestUtils.TestRegisterValue<1>(
		.((0xFFFD, 0)), (0, 0, 0), CPU.INS_ADC_IM, 2, A: 0, Z: true);

	[Test]
	public static void AddImNegOverflow() => TestUtils.TestRegisterValue<1>(
		.((0xFFFD, 0b01000000)), (0b01000000, 0, 0),
		CPU.INS_ADC_IM, 2, A: 0b10000000, N: true, V:true);

	[Test]
	public static void AddImPosOverflow() => TestUtils.TestRegisterValue<1>(
		.((0xFFFD, 0b10000000)), (0b10000001, 0, 0),
		CPU.INS_ADC_IM, 2, A: 0b00000001, C: true, V:true); 
}