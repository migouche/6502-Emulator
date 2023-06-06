namespace CPU_6502.Assembler;
using System;
using System.Collections;

enum OpMode
{
	case Implied; // i
	case Immediate; // #
	case Absolute; // a
	case ZeroPage; // zp
	case Relative;; // r
	case AbsoluteIndirect; // a (only used by jump expressions)
	case AbsoluteX; // a,x
	case AbsoluteY; // a,y
	case ZeroPageX; // zp,x
	case ZeroPageY; // zp,y
	case ZeroPageIndirectX; // (zp,x)
	case ZeroPageInirectY; // (zp),y

	public int GetHashCode()
	{
		return (int)this;
	}
}

enum Argument: IHashable
{
	case None;
	case Byte(Byte b);
	case Word(Word w);

	public int GetHashCode()
	{
		switch(this)
		{
		case None:
			return 0;
		case Byte(let b):
			 return 0xff + b;
		case Word(let w):
			return 0xffff + w;
		}
	}
}

struct Instruction: IHashable
{
	String instruction;
	OpMode mode;
	public this(String inst, OpMode mode)
	{
		this.instruction = inst;
		this.mode = mode;

	}

	public int GetHashCode()
	{
		return instruction.GetHashCode() + mode.GetHashCode();
	}

	public static bool operator==(Instruction lhs, Instruction rhs) => lhs.instruction == rhs.instruction && lhs.mode == rhs.mode;

}


struct ASTNode
{
	public Byte instruction;
	public Argument argument = .None;

	public this(Byte i)
	{
		this.instruction = i;
	}

	public this(Byte i, Argument a)
	{
		this.instruction = i;
		this.argument = a;
	}

}


static class AST
{
	public static Dictionary<Instruction, ASTNode> codes;

	public static void Start()
	{
		codes = new .();
		codes.Add(.("LDA", .Immediate), .(CPU.INS_LDA_IM));
		codes.Add(.("LDA", .ZeroPage), .(CPU.INS_LDA_ZP));
		codes.Add(.("LDA", .ZeroPageX), .(CPU.INS_LDA_ZPX));
		codes.Add(.("LDA", .Absolute), .(CPU.INS_LDA_ABS));
		codes.Add(.("LDA", .AbsoluteX), .(CPU.INS_LDA_ABSX));
		codes.Add(.("LDA", .AbsoluteY), .(CPU.INS_LDA_ABSY));
		codes.Add(.("LDA", .ZeroPageIndirectX), .(CPU.INS_LDA_INDX));
		codes.Add(.("LDA", .ZeroPageInirectY), .(CPU.INS_LDA_INDY));

		codes.Add(.("LDX", .Immediate), .(CPU.INS_LDX_IM));
		codes.Add(.("LDX", .ZeroPage), .(CPU.INS_LDX_ZP));
		codes.Add(.("LDX", .ZeroPageY), .(CPU.INS_LDX_ZPY));
		codes.Add(.("LDX", .Absolute), .(CPU.INS_LDX_ABS));
		codes.Add(.("LDX", .AbsoluteY), .(CPU.INS_LDX_ABSY));

		codes.Add(.("LDY", .Immediate), .(CPU.INS_LDY_IM));
		codes.Add(.("LDY", .ZeroPage), .(CPU.INS_LDY_ZP));
		codes.Add(.("LDY", .ZeroPageX), .(CPU.INS_LDY_ZPX));
		codes.Add(.("LDY", .Absolute), .(CPU.INS_LDY_ABS));
		codes.Add(.("LDY", .AbsoluteX), .(CPU.INS_LDY_ABSX));

		codes.Add(.("STA", .ZeroPage), .(CPU.INS_STA_ZP));
		codes.Add(.("STA", .ZeroPageX), .(CPU.INS_STA_ZPX));
		codes.Add(.("STA", .Absolute), .(CPU.INS_STA_ABS));
		codes.Add(.("STA", .AbsoluteX), .(CPU.INS_STA_ABSX));
		codes.Add(.("STA", .AbsoluteY), .(CPU.INS_STA_ABSY));
		codes.Add(.("STA", .ZeroPageIndirectX), .(CPU.INS_STA_INDX));
		codes.Add(.("STA", .ZeroPageInirectY), .(CPU.INS_STA_INDY));

		codes.Add(.("STX", .ZeroPage), .(CPU.INS_STX_ZP));
		codes.Add(.("STX", .ZeroPageY), .(CPU.INS_STX_ZPY));
		codes.Add(.("STX", .Absolute), .(CPU.INS_STX_ABS));

		codes.Add(.("STY", .ZeroPage), .(CPU.INS_STY_ZP));
		codes.Add(.("STY", .ZeroPageX), .(CPU.INS_STY_ZPX));
		codes.Add(.("STY", .Absolute), .(CPU.INS_STY_ABS));

		codes.Add(.("TAX", .Implied), .(CPU.INS_TAX));
		codes.Add(.("TXA", .Implied), .(CPU.INS_TXA));
		codes.Add(.("TAY", .Implied), .(CPU.INS_TAY));
		codes.Add(.("TYA", .Implied), .(CPU.INS_TYA));
		codes.Add(.("TSX", .Implied), .(CPU.INS_TSX));
		codes.Add(.("TXS", .Implied), .(CPU.INS_TXS));

		codes.Add(.("AND", .Immediate), .(CPU.INS_AND_IM));
		codes.Add(.("AND", .ZeroPage), .(CPU.INS_AND_ZP));
		codes.Add(.("AND", .ZeroPageX), .(CPU.INS_AND_ZPX));
		codes.Add(.("AND", .Absolute), .(CPU.INS_AND_ABS));
		codes.Add(.("AND", .AbsoluteX), .(CPU.INS_AND_ABSX));
		codes.Add(.("AND", .AbsoluteY), .(CPU.INS_AND_ABSY));
		codes.Add(.("AND", .ZeroPageIndirectX), .(CPU.INS_AND_INDX));
		codes.Add(.("AND", .ZeroPageInirectY), .(CPU.INS_AND_INDY));

		codes.Add(.("EOR", .Immediate), .(CPU.INS_EOR_IM));
		codes.Add(.("EOR", .ZeroPage), .(CPU.INS_EOR_ZP));
		codes.Add(.("EOR", .ZeroPageX), .(CPU.INS_EOR_ZPX));
		codes.Add(.("EOR", .Absolute), .(CPU.INS_EOR_ABS));
		codes.Add(.("EOR", .AbsoluteX), .(CPU.INS_EOR_ABSX));
		codes.Add(.("EOR", .AbsoluteY), .(CPU.INS_EOR_ABSY));
		codes.Add(.("EOR", .ZeroPageIndirectX), .(CPU.INS_EOR_INDX));
		codes.Add(.("EOR", .ZeroPageInirectY), .(CPU.INS_EOR_INDY));

		codes.Add(.("ORA", .Immediate), .(CPU.INS_ORA_IM));
		codes.Add(.("ORA", .ZeroPage), .(CPU.INS_ORA_ZP));
		codes.Add(.("ORA", .ZeroPageX), .(CPU.INS_ORA_ZPX));
		codes.Add(.("ORA", .Absolute), .(CPU.INS_ORA_ABS));
		codes.Add(.("ORA", .AbsoluteX), .(CPU.INS_ORA_ABSX));
		codes.Add(.("ORA", .AbsoluteY), .(CPU.INS_ORA_ABSY));
		codes.Add(.("ORA", .ZeroPageIndirectX), .(CPU.INS_ORA_INDX));
		codes.Add(.("ORA", .ZeroPageInirectY), .(CPU.INS_ORA_INDY));

		codes.Add(.("DEC", .ZeroPage), .(CPU.INS_DEC_ZP));
		codes.Add(.("DEC", .ZeroPageX), .(CPU.INS_DEC_ZPX));
		codes.Add(.("DEC", .Absolute), .(CPU.INS_DEC_ABS));
		codes.Add(.("DEC", .AbsoluteX), .(CPU.INS_DEC_ABSX));
		codes.Add(.("DEX", .Implied), .(CPU.INS_DEX));
		codes.Add(.("DEY", .Implied), .(CPU.INS_DEY));

		codes.Add(.("CMP", .Immediate), .(CPU.INS_CMP_IM));
		codes.Add(.("CMP", .ZeroPage), .(CPU.INS_CMP_ZP));
		codes.Add(.("CMP", .ZeroPageX), .(CPU.INS_CMP_ZPX));
		codes.Add(.("CMP", .Absolute), .(CPU.INS_CMP_ABS));
		codes.Add(.("CMP", .AbsoluteX), .(CPU.INS_CMP_ABSX));
		codes.Add(.("CMP", .AbsoluteY), .(CPU.INS_CMP_ABSY));
		codes.Add(.("CMP", .ZeroPageIndirectX), .(CPU.INS_CMP_INDX));
		codes.Add(.("CMP", .ZeroPageInirectY), .(CPU.INS_CMP_INDY));

		codes.Add(.("CPX", .Immediate), .(CPU.INS_CPX_IM));
		codes.Add(.("CPX", .ZeroPage), .(CPU.INS_CPX_ZP));
		codes.Add(.("CPX", .Absolute), .(CPU.INS_CPX_ABS));
		codes.Add(.("CPY", .Immediate), .(CPU.INS_CPY_IM));
		codes.Add(.("CPY", .ZeroPage), .(CPU.INS_CPY_ZP));
		codes.Add(.("CPY", .Absolute), .(CPU.INS_CPY_ABS));

		codes.Add(.("CLC", .Implied), .(CPU.INS_CLC));
		codes.Add(.("CLD", .Implied), .(CPU.INS_CLD));
		codes.Add(.("CLI", .Implied), .(CPU.INS_CLI));
		codes.Add(.("CLV", .Implied), .(CPU.INS_CLV));
		codes.Add(.("SEC", .Implied), .(CPU.INS_SEC));
		codes.Add(.("SED", .Implied), .(CPU.INS_SED));
		codes.Add(.("SEI", .Implied), .(CPU.INS_SEI));

		codes.Add(.("ADC", .Immediate), .(CPU.INS_ADC_IM));
		codes.Add(.("ADC", .ZeroPage), .(CPU.INS_ADC_ZP));
		codes.Add(.("ADC", .ZeroPageX), .(CPU.INS_ADC_ZPX));
		codes.Add(.("ADC", .Absolute), .(CPU.INS_ADC_ABS));
		codes.Add(.("ADC", .AbsoluteX), .(CPU.INS_ADC_ABSX));
		codes.Add(.("ADC", .AbsoluteY), .(CPU.INS_ADC_ABSY));
		codes.Add(.("ADC", .ZeroPageIndirectX), .(CPU.INS_ADC_INDX));
		codes.Add(.("ADC", .ZeroPageInirectY), .(CPU.INS_ADC_INDY));

		codes.Add(.("BIT", .ZeroPage), .(CPU.INS_BIT_ZP));
		codes.Add(.("BIT", .Absolute), .(CPU.INS_BIT_ABS));
	}

	public static void Stop()
	{
		delete codes;
	}
}