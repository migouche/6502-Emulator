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

	public static Dictionary<Instruction, ASTNode> codes = new Dictionary<Instruction, ASTNode>(){
		//codes = new .();
		(.("LDA", .Immediate), .(CPU.INS_LDA_IM)),
		(.("LDA", .ZeroPage), .(CPU.INS_LDA_ZP)),
		(.("LDA", .ZeroPageX), .(CPU.INS_LDA_ZPX)),
		(.("LDA", .Absolute), .(CPU.INS_LDA_ABS)),
		(.("LDA", .AbsoluteX), .(CPU.INS_LDA_ABSX)),
		(.("LDA", .AbsoluteY), .(CPU.INS_LDA_ABSY)),
		(.("LDA", .ZeroPageIndirectX), .(CPU.INS_LDA_INDX)),
		(.("LDA", .ZeroPageInirectY), .(CPU.INS_LDA_INDY)),

		(.("LDX", .Immediate), .(CPU.INS_LDX_IM)),
		(.("LDX", .ZeroPage), .(CPU.INS_LDX_ZP)),
		(.("LDX", .ZeroPageY), .(CPU.INS_LDX_ZPY)),
		(.("LDX", .Absolute), .(CPU.INS_LDX_ABS)),
		(.("LDX", .AbsoluteY), .(CPU.INS_LDX_ABSY)),

		(.("LDY", .Immediate), .(CPU.INS_LDY_IM)),
		(.("LDY", .ZeroPage), .(CPU.INS_LDY_ZP)),
		(.("LDY", .ZeroPageX), .(CPU.INS_LDY_ZPX)),
		(.("LDY", .Absolute), .(CPU.INS_LDY_ABS)),
		(.("LDY", .AbsoluteX), .(CPU.INS_LDY_ABSX)),

		(.("STA", .ZeroPage), .(CPU.INS_STA_ZP)),
		(.("STA", .ZeroPageX), .(CPU.INS_STA_ZPX)),
		(.("STA", .Absolute), .(CPU.INS_STA_ABS)),
		(.("STA", .AbsoluteX), .(CPU.INS_STA_ABSX)),
		(.("STA", .AbsoluteY), .(CPU.INS_STA_ABSY)),
		(.("STA", .ZeroPageIndirectX), .(CPU.INS_STA_INDX)),
		(.("STA", .ZeroPageInirectY), .(CPU.INS_STA_INDY)),

		(.("STX", .ZeroPage), .(CPU.INS_STX_ZP)),
		(.("STX", .ZeroPageY), .(CPU.INS_STX_ZPY)),
		(.("STX", .Absolute), .(CPU.INS_STX_ABS)),

		(.("STY", .ZeroPage), .(CPU.INS_STY_ZP)),
		(.("STY", .ZeroPageX), .(CPU.INS_STY_ZPX)),
		(.("STY", .Absolute), .(CPU.INS_STY_ABS)),

		(.("TAX", .Implied), .(CPU.INS_TAX)),
		(.("TXA", .Implied), .(CPU.INS_TXA)),
		(.("TAY", .Implied), .(CPU.INS_TAY)),
		(.("TYA", .Implied), .(CPU.INS_TYA)),
		(.("TSX", .Implied), .(CPU.INS_TSX)),
		(.("TXS", .Implied), .(CPU.INS_TXS)),

		(.("AND", .Immediate), .(CPU.INS_AND_IM)),
		(.("AND", .ZeroPage), .(CPU.INS_AND_ZP)),
		(.("AND", .ZeroPageX), .(CPU.INS_AND_ZPX)),
		(.("AND", .Absolute), .(CPU.INS_AND_ABS)),
		(.("AND", .AbsoluteX), .(CPU.INS_AND_ABSX)),
		(.("AND", .AbsoluteY), .(CPU.INS_AND_ABSY)),
		(.("AND", .ZeroPageIndirectX), .(CPU.INS_AND_INDX)),
		(.("AND", .ZeroPageInirectY), .(CPU.INS_AND_INDY)),

		(.("EOR", .Immediate), .(CPU.INS_EOR_IM)),
		(.("EOR", .ZeroPage), .(CPU.INS_EOR_ZP)),
		(.("EOR", .ZeroPageX), .(CPU.INS_EOR_ZPX)),
		(.("EOR", .Absolute), .(CPU.INS_EOR_ABS)),
		(.("EOR", .AbsoluteX), .(CPU.INS_EOR_ABSX)),
		(.("EOR", .AbsoluteY), .(CPU.INS_EOR_ABSY)),
		(.("EOR", .ZeroPageIndirectX), .(CPU.INS_EOR_INDX)),
		(.("EOR", .ZeroPageInirectY), .(CPU.INS_EOR_INDY)),

		(.("ORA", .Immediate), .(CPU.INS_ORA_IM)),
		(.("ORA", .ZeroPage), .(CPU.INS_ORA_ZP)),
		(.("ORA", .ZeroPageX), .(CPU.INS_ORA_ZPX)),
		(.("ORA", .Absolute), .(CPU.INS_ORA_ABS)),
		(.("ORA", .AbsoluteX), .(CPU.INS_ORA_ABSX)),
		(.("ORA", .AbsoluteY), .(CPU.INS_ORA_ABSY)),
		(.("ORA", .ZeroPageIndirectX), .(CPU.INS_ORA_INDX)),
		(.("ORA", .ZeroPageInirectY), .(CPU.INS_ORA_INDY)),

		(.("DEC", .ZeroPage), .(CPU.INS_DEC_ZP)),
		(.("DEC", .ZeroPageX), .(CPU.INS_DEC_ZPX)),
		(.("DEC", .Absolute), .(CPU.INS_DEC_ABS)),
		(.("DEC", .AbsoluteX), .(CPU.INS_DEC_ABSX)),

		(.("DEX", .Implied), .(CPU.INS_DEX)),
		(.("DEY", .Implied), .(CPU.INS_DEY)),

		(.("CMP", .Immediate), .(CPU.INS_CMP_IM)),
		(.("CMP", .ZeroPage), .(CPU.INS_CMP_ZP)),
		(.("CMP", .ZeroPageX), .(CPU.INS_CMP_ZPX)),
		(.("CMP", .Absolute), .(CPU.INS_CMP_ABS)),
		(.("CMP", .AbsoluteX), .(CPU.INS_CMP_ABSX)),
		(.("CMP", .AbsoluteY), .(CPU.INS_CMP_ABSY)),
		(.("CMP", .ZeroPageIndirectX), .(CPU.INS_CMP_INDX)),
		(.("CMP", .ZeroPageInirectY), .(CPU.INS_CMP_INDY)),

		(.("CPX", .Immediate), .(CPU.INS_CPX_IM)),
		(.("CPX", .ZeroPage), .(CPU.INS_CPX_ZP)),
		(.("CPX", .Absolute), .(CPU.INS_CPX_ABS)),

		(.("CPY", .Immediate), .(CPU.INS_CPY_IM)),
		(.("CPY", .ZeroPage), .(CPU.INS_CPY_ZP)),
		(.("CPY", .Absolute), .(CPU.INS_CPY_ABS)),

		(.("CLC", .Implied), .(CPU.INS_CLC)),
		(.("CLD", .Implied), .(CPU.INS_CLD)),
		(.("CLI", .Implied), .(CPU.INS_CLI)),
		(.("CLV", .Implied), .(CPU.INS_CLV)),

		(.("SEC", .Implied), .(CPU.INS_SEC)),
		(.("SED", .Implied), .(CPU.INS_SED)),
		(.("SEI", .Implied), .(CPU.INS_SEI)),

		(.("ADC", .Immediate), .(CPU.INS_ADC_IM)),
		(.("ADC", .ZeroPage), .(CPU.INS_ADC_ZP)),
		(.("ADC", .ZeroPageX), .(CPU.INS_ADC_ZPX)),
		(.("ADC", .Absolute), .(CPU.INS_ADC_ABS)),
		(.("ADC", .AbsoluteX), .(CPU.INS_ADC_ABSX)),
		(.("ADC", .AbsoluteY), .(CPU.INS_ADC_ABSY)),
		(.("ADC", .ZeroPageIndirectX), .(CPU.INS_ADC_INDX)),
		(.("ADC", .ZeroPageInirectY), .(CPU.INS_ADC_INDY)),

		(.("BIT", .ZeroPage), .(CPU.INS_BIT_ZP)),
		(.("BIT", .Absolute), .(CPU.INS_BIT_ABS))
	};

	public static void Stop()
	{
		delete codes;
	}

	public static ~this()
	{
		delete codes;
	}
}