namespace CPU_6502.Assembler;
using System;
using System.Collections;

enum OpMode
{
	case Implied; // i
	case Immediate; // #
	case Absolute; // a
	//case Label; // works like absolute may work if we leave it at absolute
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
	case Label(String s);

	public int GetHashCode()
	{
		switch(this)
		{
		case None:
			return 0;
		case Byte(let b):
			 return b.GetHashCode();
		case Word(let w):
			return w.GetHashCode();
		case Label(let s):
			return s.GetHashCode();
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


class ASTNode
{
	
	public Byte instruction;
	public Argument argument = .None;
	public String label;

	public this(Byte i)
	{
		this.instruction = i;
		this.label = new .("");
	}

	public this(Byte i, Argument a, String l, bool verbose = false)
	{
		this.instruction = i;
		this.argument = a;
		this.label = new .(l);
		if (verbose)
			Console.WriteLine($"got label: {l} / {this.label}");

	}

	public this(Byte i, String label1, String label2)
	{
		this.instruction = i;
		this.label = new .(label1); 
		this.argument = .Label(new .(label2));
	}

	public void Debug()
	{
		Console.WriteLine($"label size: {label.Length}");
		if(!label.IsEmpty)
			Console.WriteLine($"label: {label}");
	}

	public ~this()
	{
		delete label;
		if(this.argument case .Label(let s))
			delete s;
	}
}


static class AST
{

	public static Dictionary<Instruction, ASTNode> codes = new Dictionary<Instruction, ASTNode>(){
		//codes = new .();
		(.("LDA", .Immediate), new .(CPU.INS_LDA_IM)),
		(.("LDA", .ZeroPage), new .(CPU.INS_LDA_ZP)),
		(.("LDA", .ZeroPageX), new .(CPU.INS_LDA_ZPX)),
		(.("LDA", .Absolute), new .(CPU.INS_LDA_ABS)),
		(.("LDA", .AbsoluteX), new .(CPU.INS_LDA_ABSX)),
		(.("LDA", .AbsoluteY), new .(CPU.INS_LDA_ABSY)),
		(.("LDA", .ZeroPageIndirectX), new .(CPU.INS_LDA_INDX)),
		(.("LDA", .ZeroPageInirectY), new .(CPU.INS_LDA_INDY)),

		(.("LDX", .Immediate), new .(CPU.INS_LDX_IM)),
		(.("LDX", .ZeroPage), new .(CPU.INS_LDX_ZP)),
		(.("LDX", .ZeroPageY), new  .(CPU.INS_LDX_ZPY)),
		(.("LDX", .Absolute), new .(CPU.INS_LDX_ABS)),
		(.("LDX", .AbsoluteY), new .(CPU.INS_LDX_ABSY)),

		(.("LDY", .Immediate), new .(CPU.INS_LDY_IM)),
		(.("LDY", .ZeroPage), new .(CPU.INS_LDY_ZP)),
		(.("LDY", .ZeroPageX), new .(CPU.INS_LDY_ZPX)),
		(.("LDY", .Absolute), new .(CPU.INS_LDY_ABS)),
		(.("LDY", .AbsoluteX), new .(CPU.INS_LDY_ABSX)),

		(.("STA", .ZeroPage), new .(CPU.INS_STA_ZP)),
		(.("STA", .ZeroPageX), new .(CPU.INS_STA_ZPX)),
		(.("STA", .Absolute),new .(CPU.INS_STA_ABS)),
		(.("STA", .AbsoluteX),new .(CPU.INS_STA_ABSX)),
		(.("STA", .AbsoluteY),new .(CPU.INS_STA_ABSY)),
		(.("STA", .ZeroPageIndirectX),new .(CPU.INS_STA_INDX)),
		(.("STA", .ZeroPageInirectY),new .(CPU.INS_STA_INDY)),

		(.("STX", .ZeroPage),new .(CPU.INS_STX_ZP)),
		(.("STX", .ZeroPageY),new .(CPU.INS_STX_ZPY)),
		(.("STX", .Absolute),new .(CPU.INS_STX_ABS)),

		(.("STY", .ZeroPage),new .(CPU.INS_STY_ZP)),
		(.("STY", .ZeroPageX),new .(CPU.INS_STY_ZPX)),
		(.("STY", .Absolute),new .(CPU.INS_STY_ABS)),

		(.("TAX", .Implied),new .(CPU.INS_TAX)),
		(.("TXA", .Implied),new .(CPU.INS_TXA)),
		(.("TAY", .Implied),new .(CPU.INS_TAY)),
		(.("TYA", .Implied),new .(CPU.INS_TYA)),
		(.("TSX", .Implied),new .(CPU.INS_TSX)),
		(.("TXS", .Implied),new .(CPU.INS_TXS)),

		(.("AND", .Immediate),new .(CPU.INS_AND_IM)),
		(.("AND", .ZeroPage),new .(CPU.INS_AND_ZP)),
		(.("AND", .ZeroPageX),new .(CPU.INS_AND_ZPX)),
		(.("AND", .Absolute),new .(CPU.INS_AND_ABS)),
		(.("AND", .AbsoluteX),new .(CPU.INS_AND_ABSX)),
		(.("AND", .AbsoluteY),new .(CPU.INS_AND_ABSY)),
		(.("AND", .ZeroPageIndirectX),new .(CPU.INS_AND_INDX)),
		(.("AND", .ZeroPageInirectY),new .(CPU.INS_AND_INDY)),

		(.("EOR", .Immediate),new .(CPU.INS_EOR_IM)),
		(.("EOR", .ZeroPage),new .(CPU.INS_EOR_ZP)),
		(.("EOR", .ZeroPageX),new .(CPU.INS_EOR_ZPX)),
		(.("EOR", .Absolute),new .(CPU.INS_EOR_ABS)),
		(.("EOR", .AbsoluteX),new .(CPU.INS_EOR_ABSX)),
		(.("EOR", .AbsoluteY),new .(CPU.INS_EOR_ABSY)),
		(.("EOR", .ZeroPageIndirectX),new .(CPU.INS_EOR_INDX)),
		(.("EOR", .ZeroPageInirectY),new .(CPU.INS_EOR_INDY)),

		(.("ORA", .Immediate),new .(CPU.INS_ORA_IM)),
		(.("ORA", .ZeroPage),new .(CPU.INS_ORA_ZP)),
		(.("ORA", .ZeroPageX),new .(CPU.INS_ORA_ZPX)),
		(.("ORA", .Absolute),new .(CPU.INS_ORA_ABS)),
		(.("ORA", .AbsoluteX),new .(CPU.INS_ORA_ABSX)),
		(.("ORA", .AbsoluteY),new .(CPU.INS_ORA_ABSY)),
		(.("ORA", .ZeroPageIndirectX),new .(CPU.INS_ORA_INDX)),
		(.("ORA", .ZeroPageInirectY),new .(CPU.INS_ORA_INDY)),

		(.("DEC", .ZeroPage),new .(CPU.INS_DEC_ZP)),
		(.("DEC", .ZeroPageX),new .(CPU.INS_DEC_ZPX)),
		(.("DEC", .Absolute),new .(CPU.INS_DEC_ABS)),
		(.("DEC", .AbsoluteX),new .(CPU.INS_DEC_ABSX)),

		(.("DEX", .Implied),new .(CPU.INS_DEX)),
		(.("DEY", .Implied),new .(CPU.INS_DEY)),

		(.("CMP", .Immediate),new .(CPU.INS_CMP_IM)),
		(.("CMP", .ZeroPage),new .(CPU.INS_CMP_ZP)),
		(.("CMP", .ZeroPageX),new .(CPU.INS_CMP_ZPX)),
		(.("CMP", .Absolute),new .(CPU.INS_CMP_ABS)),
		(.("CMP", .AbsoluteX),new .(CPU.INS_CMP_ABSX)),
		(.("CMP", .AbsoluteY),new .(CPU.INS_CMP_ABSY)),
		(.("CMP", .ZeroPageIndirectX),new .(CPU.INS_CMP_INDX)),
		(.("CMP", .ZeroPageInirectY),new .(CPU.INS_CMP_INDY)),

		(.("CPX", .Immediate),new .(CPU.INS_CPX_IM)),
		(.("CPX", .ZeroPage),new .(CPU.INS_CPX_ZP)),
		(.("CPX", .Absolute),new .(CPU.INS_CPX_ABS)),

		(.("CPY", .Immediate),new .(CPU.INS_CPY_IM)),
		(.("CPY", .ZeroPage),new .(CPU.INS_CPY_ZP)),
		(.("CPY", .Absolute),new .(CPU.INS_CPY_ABS)),

		(.("CLC", .Implied),new .(CPU.INS_CLC)),
		(.("CLD", .Implied),new .(CPU.INS_CLD)),
		(.("CLI", .Implied),new .(CPU.INS_CLI)),
		(.("CLV", .Implied),new .(CPU.INS_CLV)),

		(.("SEC", .Implied),new .(CPU.INS_SEC)),
		(.("SED", .Implied),new .(CPU.INS_SED)),
		(.("SEI", .Implied),new .(CPU.INS_SEI)),

		(.("ADC", .Immediate),new .(CPU.INS_ADC_IM)),
		(.("ADC", .ZeroPage),new .(CPU.INS_ADC_ZP)),
		(.("ADC", .ZeroPageX),new .(CPU.INS_ADC_ZPX)),
		(.("ADC", .Absolute),new .(CPU.INS_ADC_ABS)),
		(.("ADC", .AbsoluteX),new .(CPU.INS_ADC_ABSX)),
		(.("ADC", .AbsoluteY),new .(CPU.INS_ADC_ABSY)),
		(.("ADC", .ZeroPageIndirectX),new .(CPU.INS_ADC_INDX)),
		(.("ADC", .ZeroPageInirectY),new .(CPU.INS_ADC_INDY)),

		(.("BIT", .ZeroPage),new .(CPU.INS_BIT_ZP)),
		(.("BIT", .Absolute),new .(CPU.INS_BIT_ABS)),

		(.("JMP", .Absolute), new .(CPU.INS_JMP_ABS)),

		(.("NOP", .Implied), new .(CPU.INS_NOP)),

		(.("PHA", .Implied), new .(CPU.INS_PHA)),
		(.("PHP", .Implied), new .(CPU.INS_PHP)),
		(.("PLA", .Implied), new .(CPU.INS_PLA)),
		(.("PLP", .Implied), new .(CPU.INS_PLP)),

	};

	public static void Stop()
	{
		delete codes;
	}

	public static ~this()
	{
		for (var k in codes)
			delete k.value;
		
		delete codes;
	}
}