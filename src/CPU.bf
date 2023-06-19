using System;


namespace CPU_6502;

typealias Byte = uint8;
typealias Word = uint16;

struct Bit: IFormattable
{
	public bool bit;

	public this(bool a) => this.bit = a;
	

	public this(uint8 a)
	{
		if (a == 0)
			this.bit = false;
		else
			this.bit = true;
	}

	public static operator Bit (uint8 a) => .(a);

	public static operator Bit(bool b) => .(b);

	public static operator bool(Bit b) => b.bit;

	public static operator Byte(Bit b) => b.bit ? 1: 0;

	public void ToString(String outString, String format, IFormatProvider formatProvider)
	{
		uint8 v = bit ? 1: 0;
		v.ToString(outString, format, formatProvider);
	}
}

struct Memory
{
	const uint32 MAX_MEM = 64 * 1024; // 64 Kb
	public Byte[MAX_MEM] data;
	public this
	{
		Initialize();
	}
	public void Initialize() mut
	{
		for (uint32 i = 0; i < MAX_MEM; i++)
			this.data[i] = 0;
	}

	public Byte Get(Word i)
	{
		return this.data[i];
	}


	public Byte this[Word i]
	{
		get => data[i];
		set mut => data[i] = value;
	}

	public void WriteWord(Word val, Word addr, ref int cycles) mut
	{
		//Console.WriteLine($"Writing word {val} at address {addr}...");
		this.WriteWord(val, addr);
		cycles -= 2;
	}

	public void WriteWord(Word val, Word addr) mut // Should not be used
	{
		//Console.WriteLine($"Writing word {val} at address {addr}...");
		this[addr] = (Byte)val;
		this[addr + 1] = (Byte)(val >> 8);
	}

	public Word GetWord(Word address)
	{
		Byte lByte = this[address];
		Byte hByte = this[address + 1];
		return lByte | ((Word)hByte << 8);
	}

	public void HardLoadProgram(Byte[MAX_MEM] m) mut
	{
		this.data = m;
	}
}



class CPU
{

	//typealias Bit = bool; // sorry, no bits in beef
	// 64Kb memory | 16-bit address bus | 256 byte (0x0000-0x00FF) Zero Page | System Stack (0x0100-0x01FF)
	// 0xFFFA/B -> non-maskable interrupt handler | 0xFFFC/D -> power on reset | 0xFFFE/F BRK/interrupt request handler

	public enum Register { A, X, Y }
	public enum LoadAdressingMode {
		case Immediate;
		case ZeroPage(Byte index);
		case Absolute(Byte index);
		case IndirectX;
		case IndirectY;
		 }

	public enum StoreAdressingMode {
		case ZeroPage(Byte index);
		case Absolute(Byte index);
		case IndirectX;
		case IndirectY;
	 }

	public enum OpAdressingMode {
		case ZeroPage(Byte index);
		case Absolute(Byte index);
	}

	public enum CompareValue {
		case A;
		case X;
		case Y;
		case M(Word addr, LoadAdressingMode l);
	}

	public Word PC; // Program Counter
	public Byte SP; // Stack Pointer // SHOULD BE BYTE // Starts at 0xFF and goes down when branching // its a byte and lets assume 0x01XX

	public Byte A, X, Y; // Registers



	public Bit C, Z, I, D, B, V, N; // Processor status flags

	public Memory* memory;
	public int cycles;

	public const Word resetVector = 0xFFFC;

	public bool exit;


	// opcodes
	public const Byte


		INS_LDA_IM = 0xA9,   /// Load Accumulator Immediate
		INS_LDA_ZP = 0xA5,   /// Load Accumulator Zero Page
		INS_LDA_ZPX = 0xB5,  /// Load Accumulator Zero Page X
		INS_LDA_ABS = 0xAD,  /// Load Accumulator Absolute
		INS_LDA_ABSX = 0xBD, /// Load Accumulator Absolute X
		INS_LDA_ABSY = 0xB9, /// Load Accumulator Absolute Y
		INS_LDA_INDX = 0xA1, /// Load Accumulator Indirect X
		INS_LDA_INDY = 0xB1, /// Load Accumulator Indirect Y

		INS_LDX_IM = 0xA2,   /// Load X Immediate
		INS_LDX_ZP = 0xA6,   /// Load X Zero Page
		INS_LDX_ZPY = 0xB6,  /// Load X Zero Page Y
		INS_LDX_ABS = 0xAE,  /// Load X Absolute
		INS_LDX_ABSY = 0xBE, /// Load X Absolute Y

		INS_LDY_IM = 0xA0,   /// Load Y Immediate
		INS_LDY_ZP = 0xA4,   /// Load Y Zero Page
		INS_LDY_ZPX = 0xB4,  /// Load Y Zero Page X
		INS_LDY_ABS = 0xAC,  /// Load Y Absolute
		INS_LDY_ABSX = 0xBC, /// Load Y Absolute X

		INS_STA_ZP = 0x85,   /// Store Accumulator Zero Page
		INS_STA_ZPX = 0x95,  /// Store Accumulator Zero Page X
		INS_STA_ABS = 0x8D,  /// Store Accumulator Absolute
		INS_STA_ABSX = 0x9D, /// Store Accumulator Absolute X
		INS_STA_ABSY = 0x99, /// Store Accumulator Absolute Y
		INS_STA_INDX = 0x81, /// Store Accumulator Indirect X
		INS_STA_INDY = 0x91, /// Store Accumulator Indirect Y

		INS_STX_ZP = 0x86,   /// Store X Zero Page
		INS_STX_ZPY = 0x96,  /// Store X Zero Page Y
		INS_STX_ABS = 0x8E,  /// Store X Absolute

		INS_STY_ZP = 0x84,   /// Store Y Zero Page
		INS_STY_ZPX = 0x94,  /// Store Y Zero Page X
		INS_STY_ABS = 0x8C,  /// Store Y Absolute

		INS_TAX = 0xAA,      /// Transfer A to X
		INS_TXA = 0x8A,      /// Transfer X to A
		INS_TAY = 0xA8,      /// Transfer A to Y
		INS_TYA = 0x98,		 /// Transfer Y to A
		INS_TXS = 0x9A,		 /// Transfer X to Stack Pointer
		INS_TSX = 0xBA,		 /// Transfer Stack Pointer to A

		INS_PHA = 0X48,      /// Push Accumulator
		INS_PHP = 0X08,      /// Push Processor Status
		INS_PLA = 0X68,      /// Pull Accumulator
		INS_PLP = 0X28,      /// Pull Processor Status

		INS_AND_IM = 0x29,   /// Logical AND Immediate
		INS_AND_ZP = 0x25,   /// Logical AND Zero Page
		INS_AND_ZPX = 0x35,  /// Logical AND Zero Page X
		INS_AND_ABS = 0x2D,  /// Logical AND Absolute
		INS_AND_ABSX = 0x3D, /// Logical AND Absolute X
		INS_AND_ABSY = 0x39, /// Logical AND Absolute Y
		INS_AND_INDX = 0x21, /// Logical AND Indirect X
		INS_AND_INDY = 0x31, /// Logical AND Indirect Y

		INS_EOR_IM = 0x49,   /// Logical XOR Immediate
		INS_EOR_ZP = 0x45,   /// Logical XOR Zero Page
		INS_EOR_ZPX = 0x55,  /// Logical XOR Zero Page X
		INS_EOR_ABS = 0x4D,  /// Logical XOR Absolute
		INS_EOR_ABSX = 0x5D, /// Logical XOR Absolute X
		INS_EOR_ABSY = 0x59, /// Logical XOR Absolute Y
		INS_EOR_INDX = 0x41, /// Logical XOR Indirect X
		INS_EOR_INDY = 0x51, /// Logical XOR Indirect Y
	
		INS_ORA_IM = 0x09,   /// Logical OR Immediate
		INS_ORA_ZP = 0x05,   /// Logical OR Zero Page
		INS_ORA_ZPX = 0x15,  /// Logical OR Zero Page X
		INS_ORA_ABS = 0x0D,  /// Logical OR Absolute
		INS_ORA_ABSX = 0x1D, /// Logical OR Absolute X
		INS_ORA_ABSY = 0x19, /// Logical OR Absolute Y
		INS_ORA_INDX = 0x01, /// Logical OR Indirect X
		INS_ORA_INDY = 0x11, /// Logical OR Indirect Y

		INS_DEC_ZP = 0xC6,   /// Decrement Memory Zero Page
		INS_DEC_ZPX = 0xD6,	 /// Decrement Memory Zero Page X
		INS_DEC_ABS = 0xCE,  /// Decrement Memory Absolute
		INS_DEC_ABSX = 0xDE, /// Decrement Memory Absolute X
		INS_DEX = 0xCA,      /// Decrement X Register
		INS_DEY = 0x88,      /// Decrement Y Register

		INS_CMP_IM = 0xC9,   /// Compare Accumulator Immediate
		INS_CMP_ZP = 0xC5,   /// Compare Accumulator Zero Page
		INS_CMP_ZPX = 0xD5,  /// Compare Accumulator Zero Page X
		INS_CMP_ABS = 0xCD,  /// Compare Accumulator Absolute
		INS_CMP_ABSX = 0xDD, /// Compare Accumulator Absolute X
		INS_CMP_ABSY = 0xD9, /// Compare Accumulator Absolute Y
		INS_CMP_INDX = 0xC1, /// Compare Accumulator Indirect X
		INS_CMP_INDY = 0xD1, /// Compare Accumulator Indirect Y

		INS_CPX_IM = 0xE0,   /// Compare X Register Immediate
		INS_CPX_ZP = 0xE4,   /// Compare X Register ZeroPage
		INS_CPX_ABS = 0xEC,  /// Compare X Register Absolute
		INS_CPY_IM = 0xC0,   /// Compare Y Register Immediate
		INS_CPY_ZP = 0xC4,   /// Compare Y Register ZeroPge
		INS_CPY_ABS = 0xCC,  /// Compare Y Register Absolute

		INS_CLC = 0x18,      /// Clear Carry Flag
		INS_CLD = 0xD8,      /// Clear Decimal Flag
		INS_CLI = 0x58,      /// Clear Interrupt Disable Flag
		INS_CLV = 0xB8,      /// Clear Overflow Flag
		INS_SEC = 0x38,      /// Set Carry Flag
		INS_SED = 0xF8,      /// Set Decimal Flag
		INS_SEI = 0x78,      /// Set Interrupt Disable Flag

		INS_ADC_IM = 0x69,   /// Add with Carry Immediate
		INS_ADC_ZP = 0x65,   /// Add with Carry Zero Page
		INS_ADC_ZPX = 0x75,  /// Add with Carry Zero Page X
		INS_ADC_ABS = 0x6D,  /// Add with Carry Absolute
		INS_ADC_ABSX = 0x7D, /// Add with Carry Absolute X
		INS_ADC_ABSY = 0x79, /// Add with Carry Absolute Y
		INS_ADC_INDX = 0x61, /// Add with Carry Indirect X
		INS_ADC_INDY = 0x71, /// Add with Carry Indirect Y

		INS_BIT_ZP = 0x24,   /// Bit Test Zero Page
		INS_BIT_ABS = 0x2C,  /// Bit Test Zero Page

		INS_JMP_ABS =  0x4C,
		INS_JMP_IND  = 0x6C,

		INS_NOP = 0xEA, // noop

		INS_JSR = 0x20;     /// Jump to Subroutine

	public function Result<void, String>(CPU)[] instructions = new function Result<void, String>(CPU)[0xFF];


	public this
	{
		for (int i < 0xFF)
		{
			instructions[i] =  (_) => .Err("Unknown Instruction");
		}



		instructions[INS_LDA_IM] = (c) => c.FetchByteToRegister(.A, .Immediate, (a, m) => m);
		instructions[INS_LDA_ZP] = (c) => c.FetchByteToRegister(.A, .ZeroPage(0), (a, m) => m);
		instructions[INS_LDA_ZPX] = (c) =>c.FetchByteToRegister(.A, .ZeroPage(c.X), (a, m) => m);
		instructions[INS_LDA_ABS] = (c) => c.FetchByteToRegister(.A, .Absolute(0), (a, m) => m);
		instructions[INS_LDA_ABSX] = (c) => c.FetchByteToRegister(.A, .Absolute(c.X), (a, m) => m);
		instructions[INS_LDA_ABSY] = (c) => c.FetchByteToRegister(.A, .Absolute(c.Y), (a, m) => m);
		instructions[INS_LDA_INDX] = (c) => c.FetchByteToRegister(.A, .IndirectX, (a, m) => m);
		instructions[INS_LDA_INDY] = (c) => c.FetchByteToRegister(.A, .IndirectY, (a, m) => m);

		instructions[INS_LDX_IM] = (c) => c.FetchByteToRegister(.X, .Immediate, (a, m) => m);
		instructions[INS_LDX_ZP] = (c) => c.FetchByteToRegister(.X, .ZeroPage(0), (a, m) => m);
		instructions[INS_LDX_ZPY] = (c) => c.FetchByteToRegister(.X, .ZeroPage(c.Y), (a, m) => m);
		instructions[INS_LDX_ABS] = (c) => c.FetchByteToRegister(.X, .Absolute(0), (a, m) => m);
		instructions[INS_LDX_ABSY] = (c) => c.FetchByteToRegister(.X, .Absolute(c.Y), (a, m) => m);

		instructions[INS_LDY_IM] = (c) => c.FetchByteToRegister(.Y, .Immediate, (a, m) => m);
		instructions[INS_LDY_ZP] = (c) => c.FetchByteToRegister(.Y, .ZeroPage(0), (a, m) => m);
		instructions[INS_LDY_ZPX] = (c) => c.FetchByteToRegister(.Y, .ZeroPage(c.X), (a, m) => m);
		instructions[INS_LDY_ABS] = (c) => c.FetchByteToRegister(.Y, .Absolute(0), (a, m) => m);
		instructions[INS_LDY_ABSX] = (c) => c.FetchByteToRegister(.Y, .Absolute(c.X), (a, m) => m);

		instructions[INS_STA_ZP] = (c) => c.StoreRegisterToMemory(.A, .ZeroPage(0));
		instructions[INS_STA_ZPX] = (c) => c.StoreRegisterToMemory(.A, .ZeroPage(c.X));
		instructions[INS_STA_ABS] = (c) => c.StoreRegisterToMemory(.A, .Absolute(0));
		instructions[INS_STA_ABSX] = (c) => c.StoreRegisterToMemory(.A, .Absolute(c.X));
		instructions[INS_STA_ABSY] = (c) => c.StoreRegisterToMemory(.A, .Absolute(c.Y));
		instructions[INS_STA_INDX] = (c) => c.StoreRegisterToMemory(.A, .IndirectX);
		instructions[INS_STA_INDY] = (c) => c.StoreRegisterToMemory(.A, .IndirectY);

		instructions[INS_STX_ZP] = (c) => c.StoreRegisterToMemory(.X, .ZeroPage(0));
		instructions[INS_STX_ZPY] = (c) => c.StoreRegisterToMemory(.X, .ZeroPage(c.Y));
		instructions[INS_STX_ABS] = (c) => c.StoreRegisterToMemory(.X, .Absolute(0));

		instructions[INS_STY_ZP] = (c) => c.StoreRegisterToMemory(.Y, .ZeroPage(0));
		instructions[INS_STY_ZPX] = (c) => c.StoreRegisterToMemory(.Y, .ZeroPage(c.X));
		instructions[INS_STY_ABS] = (c) => c.StoreRegisterToMemory(.Y, .Absolute(0));

		instructions[INS_TAX] = (c) => { c.X = c.A; c.cycles--; return c.SetLoadFlags(.X); };
		instructions[INS_TXA] = (c) => { c.A = c.X; c.cycles--; return c.SetLoadFlags(.A); };
		instructions[INS_TAY] = (c) => { c.Y = c.A; c.cycles--; return c.SetLoadFlags(.Y); };
		instructions[INS_TYA] = (c) => { c.A = c.Y; c.cycles--; return c.SetLoadFlags(.A); };
		instructions[INS_TXS] = (c) => { c.SP = c.X; c.cycles--; return (void)0; };
		instructions[INS_TSX] = (c) => { c.X = c.SP; c.cycles--; return c.SetLoadFlags(.X); };

		instructions[INS_AND_IM] = (c) => c.FetchByteToRegister(.A, .Immediate, (a, m) => a & m);
		instructions[INS_AND_ZP] = (c) => c.FetchByteToRegister(.A, .ZeroPage(0), (a, m) => a & m);
		instructions[INS_AND_ZPX] = (c) => c.FetchByteToRegister(.A, .ZeroPage(c.X), (a, m) => a & m);
		instructions[INS_AND_ABS] = (c) => c.FetchByteToRegister(.A, .Absolute(0), (a, m) => a & m);
		instructions[INS_AND_ABSX] = (c) => c.FetchByteToRegister(.A, .Absolute(c.X), (a, m) => a & m);
		instructions[INS_AND_ABSY] = (c) => c.FetchByteToRegister(.A, .Absolute(c.Y), (a, m) => a & m);
		instructions[INS_AND_INDX] = (c) => c.FetchByteToRegister(.A, .IndirectX, (a, m) => a & m);
		instructions[INS_AND_INDY] = (c) => c.FetchByteToRegister(.A, .IndirectY, (a, m) => a & m);

		instructions[INS_EOR_IM] = (c) => c.FetchByteToRegister(.A, .Immediate, (a, m) => a ^ m);
		instructions[INS_EOR_ZP] = (c) => c.FetchByteToRegister(.A, .ZeroPage(0), (a, m) => a ^ m);
		instructions[INS_EOR_ZPX] = (c) => c.FetchByteToRegister(.A, .ZeroPage(c.X), (a, m) => a ^ m);
		instructions[INS_EOR_ABS] = (c) => c.FetchByteToRegister(.A, .Absolute(0), (a, m) => a ^ m);
		instructions[INS_EOR_ABSX] = (c) => c.FetchByteToRegister(.A, .Absolute(c.X), (a, m) => a ^ m);
		instructions[INS_EOR_ABSY] = (c) => c.FetchByteToRegister(.A, .Absolute(c.Y), (a, m) => a ^ m);
		instructions[INS_EOR_INDX] = (c) => c.FetchByteToRegister(.A, .IndirectX, (a, m) => a ^ m);
		instructions[INS_EOR_INDY] = (c) => c.FetchByteToRegister(.A, .IndirectY, (a, m) => a ^ m);

		instructions[INS_ORA_IM] = (c) => c.FetchByteToRegister(.A, .Immediate, (a, m) => a | m);
		instructions[INS_ORA_ZP] = (c) => c.FetchByteToRegister(.A, .ZeroPage(0), (a, m) => a | m);
		instructions[INS_ORA_ZPX] = (c) => c.FetchByteToRegister(.A, .ZeroPage(c.X), (a, m) => a | m);
		instructions[INS_ORA_ABS] = (c) => c.FetchByteToRegister(.A, .Absolute(0), (a, m) => a | m);
		instructions[INS_ORA_ABSX] = (c) => c.FetchByteToRegister(.A, .Absolute(c.X), (a, m) => a | m);
		instructions[INS_ORA_ABSY] = (c) => c.FetchByteToRegister(.A, .Absolute(c.Y), (a, m) => a | m);
		instructions[INS_ORA_INDX] = (c) => c.FetchByteToRegister(.A, .IndirectX, (a, m) => a | m);
		instructions[INS_ORA_INDY] = (c) => c.FetchByteToRegister(.A, .IndirectY, (a, m) => a | m);

		instructions[INS_DEX] = (c) => c.WriteVal(.X, (r) => r - 1);
		instructions[INS_DEY] = (c) => c.WriteVal(.Y, (r) => r - 1);
		instructions[INS_DEC_ZP] = (c) => c.WriteVal(.ZeroPage(0), (r) => r - 1);
		instructions[INS_DEC_ZPX] = (c) => c.WriteVal(.ZeroPage(c.X), (r) => r - 1);
		instructions[INS_DEC_ABS] = (c) => c.WriteVal(.Absolute(0), (r) => r - 1);
		instructions[INS_DEC_ABSX] = (c) => c.WriteVal(.Absolute(c.X), (r) => r - 1);

		instructions[INS_BIT_ZP] = (c) =>
			{
				Byte val = c.ReadByte(c.FetchByte());
				c.Z = c.A & val == 0;
				c.N = val & 0b10000000;
				c.V = val & 0b1000000;
				return .Ok;
			};

		instructions[INS_BIT_ABS] = (c) =>
			{

				Byte val = c.ReadByte(c.FetchWord());
				c.Z = c.A & val == 0;
				c.N = val & 0b10000000;
				c.V = val & 0b1000000;
				return .Ok;
			};

		instructions[INS_CMP_IM] = (c) => c.CompareVals(.A, .M(c.FetchByte(), .Immediate));
		instructions[INS_CMP_ZP] = (c) => c.CompareVals(.A, .M(c.FetchByte(), .ZeroPage(0)));
		instructions[INS_CMP_ZPX] = (c) => c.CompareVals(.A, .M(c.FetchByte(), .ZeroPage(c.X)));
		instructions[INS_CMP_ABS] = (c) => c.CompareVals(.A, .M(c.FetchWord(), .Absolute(0)));
		instructions[INS_CMP_ABSX] = (c) => c.CompareVals(.A, .M(c.FetchWord(), .Absolute(c.X)));
		instructions[INS_CMP_ABSY] = (c) => c.CompareVals(.A, .M(c.FetchWord(), .Absolute(c.Y)));
		instructions[INS_CMP_INDX] = (c) => c.CompareVals(.A, .M(c.FetchWord(), .IndirectX));
		instructions[INS_CMP_INDY] = (c) => c.CompareVals(.A, .M(c.FetchWord(), .IndirectY));

		instructions[INS_CPX_IM] = (c) => c.CompareVals(.X, .M(c.FetchByte(), .Immediate));
		instructions[INS_CPX_ZP] = (c) => c.CompareVals(.X, .M(c.FetchByte(), .ZeroPage(0)));
		instructions[INS_CPX_ABS] = (c) => c.CompareVals(.X, .M(c.FetchWord(), .Absolute(0)));
		instructions[INS_CPY_IM] = (c) => c.CompareVals(.Y, .M(c.FetchByte(), .Immediate));
		instructions[INS_CPY_ZP] = (c) => c.CompareVals(.Y, .M(c.FetchByte(), .ZeroPage(0)));
		instructions[INS_CPY_ABS] = (c) => c.CompareVals(.Y, .M(c.FetchWord(), .Absolute(0)));

		instructions[INS_CLC] = (c) => c.SetFlag(ref c.C, 0);
		instructions[INS_SEC] = (c) => c.SetFlag(ref c.C, 1);
		instructions[INS_CLD] = (c) => c.SetFlag(ref c.D, 0);
		instructions[INS_SED] = (c) => c.SetFlag(ref c.D, 1);
		instructions[INS_CLI] = (c) => c.SetFlag(ref c.I, 0);
		instructions[INS_SEI] = (c) => c.SetFlag(ref c.I, 1);
		instructions[INS_CLV] = (c) => c.SetFlag(ref c.V, 0);

		instructions[INS_PHA] = (c) =>  c.PushToStack(c.A);
		instructions[INS_PHP] = (c) => c.PushToStack(c.Status);
		instructions[INS_PLA] = (c) => c.PullFromStack(ref c.A);
		instructions[INS_PLP] = (c) => (void)(c.Status =  c.PullFromStack());

		instructions[INS_ADC_IM] = (c) => c.AddToAccumulator(.Immediate, c.FetchByte());

		instructions[INS_JMP_ABS] = (c) =>  {c.PC = c.FetchWord(); return (void)(c.cycles -= 2) /* cause we copying 2 bytes */;};
		instructions[INS_JMP_IND] = (c) => (void)(c.PC = c.ReadWord(c.FetchWord())); // TODO fix cycles

		instructions[INS_NOP] = (c) => (void)c.cycles--;
	}


	public this(Memory* mem)
	{
		this.memory = mem;
		//this.memory.Initialize();
		this.Reset();
	}

	public ~this()
	{
		delete this.instructions;
	}



	public void Reset() // should take 7 bytes
	{ // should code this but we emulate for now
		//Console.WriteLine("before pc");
		//Console.WriteLine(memory.Get(resetVector));
		this.PC = this.memory.GetWord(resetVector);
		//Console.WriteLine(this.PC);
		//PC = memory.Get(0xfffc);
		//Console.WriteLine("after pc");
		SP = (Byte)0xFF; // I'm supposing for now that SP = 0x01SP
		C = Z = I = D = B = V = N = 0;
		A = X = Y = 0;

		cycles -= 5; // do better that this :)
	}

	public void SetFlag(ref Bit flag, Bit newVal)
	{
		flag = newVal;
		this.cycles--;
	}

	public Byte ReadByte(Word address)
	{
		Byte data = (*this.memory)[address]; 
		this.cycles--;
		return data;
	}

	public Byte Status
	{
		get{
			Byte r = 0;
			r |= this.C;
			r |= this.Z << 1;
			r |= this.I << 2;
			r |= this.D << 3;
			r |= this.B << 4; // careful with this one
			r |= 1 << 5;
			r |= this.V << 6;
			r |= this.N << 7;
			return r;
		}

		set
		{
			this.C = value & 1;
			this.Z = value & (1 << 1);
			this.I = value & (1 << 2);
			this.D = value & (1 << 3);
			this.B = value & (1 << 4);
			// nothing at bit 5
			this.V = value & (1 << 6);
			this.N = value & (1 << 7);
		}
	}


	// STACK POINTER IS SUPPOSED TO POINT TO THE FIRST FREE MEMORY

	public void PushToStack(Byte b)
	{   // push and decrease sp
		(*this.memory)[0x100 + this.SP] = this.A;
		this.SP--;
		this.cycles -= 2;
	}
	public Byte PullFromStack()
	{
		// increase sp and pull
		this.SP++;
		Byte r = (*this.memory)[0x100 + this.SP];
		//(*this.memory)[0x100 + this.SP] = 0;
		this.SetLoadFlags(r);
		this.cycles -= 3;
		return r;
	}


	public void PrintStack()
	{
		for (Word i = 0x1ff; i > 0x100 + this.SP; i--)
			Console.WriteLine($"{i}: {(*this.memory)[i]}");
	}
	
	public void PullFromStack(ref Byte dest)
	{
		// increase sp and pull
		dest = PullFromStack();
	}

	public void AddToAccumulator(LoadAdressingMode R, Byte addr)
	{
		AddToAccumulator(ReadByte(addr, R, true));
	}

	/// this will add A to the val, and store it to A, will set all flags accordingly
	public void AddToAccumulator(Byte val)
	{
		int sum = (int)this.A + (int)val + (Byte)this.C;
		bool possibleOverflow = val >> 7 == this.A >> 7;
		this.A = (Byte)sum;
		this.SetLoadFlags(.A); // Z and N set
		this.C = sum != this.A;
		this.V = possibleOverflow && val >> 7 !=  this.A >> 7;
	}

	public Result<Byte> FetchByte() // will rework to work with ReadByte (or not xd)
	{
		Byte data = (*this.memory)[this.PC];
		if (this.PC == 0xFF)
		{
			exit = true;
			return .Err;
		}
 			
		this.PC++;
		cycles--;
		return data;
	}

	public Word ReadWord(Word address, Byte index = 0)
	{
		if (index > 0)
			cycles--;

		Byte lByte = ReadByte(address + index);
		Byte hByte = ReadByte(address + index + 1);
		return lByte | ((Word)hByte << 8);
	}


	public Result<Word> FetchWord()
	{
		if(this.PC >= 0xFFFE)
		{
			exit = true;
			return .Err;
		}
		// 6502 is little-endian
		Word data = (*this.memory)[this.PC]; // Low byte
		this.PC++;
		cycles--;

		data |= ((Word)(*this.memory)[this.PC]) << 8; // High byte
		this.PC++;
		cycles--;

		//Console.WriteLine($"Fetched word {data}...");

		return data;
	}


	void SetLoadFlags(Register R)
	{
		Byte val;
		switch(R)
		{
		case .A:
			val = this.A;
		case .X:
			val = this.X;
		case .Y:
			val = this.Y;
		}
		this.Z = val == 0;
		this.N = val & 0b10000000;
	}

	public void SetLoadFlags(Byte val)
	{
		this.Z = val == 0;
		this.N = val & 0b10000000;
	}

	public void CompareVals(CompareValue a, CompareValue b)
	{
		Byte val1;
		switch(a)
		{
		case .X: val1 = this.X;
		case .Y: val1 = this.Y;
		case .A: val1 = this.A;
		case .M(let addr, let l): val1 = this.ReadByte(addr, l, true);
		}

		Byte val2;
		switch(b)
		{
		case .X: val2 = this.X;
		case .Y: val2 = this.Y;
		case .A: val2 = this.A;
		case .M(let addr, let l): val2 = this.ReadByte(addr, l, true);
		}

		this.C = val1 >= val2;
		this.Z = val1 == val2;
		this.N = (val1 - val2) & 0b10000000;
	}

	public void LoadValueToRegister(Register R, Byte val) // should not take cycles
	{
		switch (R)
		{
		case .A:
			this.A = val;
		case .X:
			this.X = val;
		case .Y:
			this.Y = val;
		}
		SetLoadFlags(R);
	}

	public Word ReadWordFromZeroPage(Byte addr, Byte index = 0)
	{
		var addr;
		addr += index;
		return this.ReadWord(addr);
	}

	
	public Byte ReadByte(Word addr, LoadAdressingMode L, bool consume = false) // no cycle consumption, just for coding purposes
	{
		
		switch(L)
		{
		case .Immediate:
			return (Byte)addr;
		case .ZeroPage(let index):
			if(consume) {
				cycles--;
				if (index > 0)
					cycles--;
			}
			return (*this.memory)[(Byte)(addr + index)]; // adding might promote to Word too soon
		case .Absolute(let index):
			Word f = addr + index;
			if(consume)
			{
				cycles--;
				if (f >> 8 != addr >> 8)
					cycles--;
				
			}
			return (*this.memory)[f];
		case .IndirectX:
			Word fAddress = this.ReadByte(addr + this.X, .ZeroPage(0), consume);
			fAddress |= (Word)this.ReadByte(addr + this.X + 1, .ZeroPage(0), consume) << 8; 
			//if(consume) cycles-=5; gotta take 3
			return this.ReadByte(fAddress, .Absolute(0), consume);
		case .IndirectY:
			Word fAddres = this.ReadByte(addr, .ZeroPage(0), consume);
			fAddres |= (Word)this.ReadByte(addr + 1, .ZeroPage(0), consume) << 8;
			this.cycles++; // to fix a double sum (this originates from fixing zp with pre sum)
			return this.ReadByte(fAddres, .Absolute(this.Y), consume);

		}
	}

	public void WriteVal(Register R, function Byte(Byte r) op)
	{
		Byte val;

		switch (R)
		{
		case .A: val = this.A;
		case .X: val = this.X;
		case .Y: val = this.Y;
		}
		cycles--;

		LoadValueToRegister(R, op(val));
	}

	public void WriteVal(OpAdressingMode O, function Byte(Byte r) op)
 	{
		Word addr;
		switch(O)
		{
		case .ZeroPage(let index): addr = (Byte)(this.FetchByte() + index); if (index > 0) cycles--;
		case .Absolute(let index): addr = this.FetchWord() + (Word)index; if (index > 0) cycles--;
		}
		 Byte val = this.ReadByte(addr, .Absolute(0));
		 (*this.memory)[addr] = op(val);
		 SetLoadFlags(val);
		 cycles-=3;
	}

	public void FetchByteToRegister(Register R, LoadAdressingMode L, function Byte(Byte a, Byte m) op)
	{
		Word addr;
		Byte val;
		switch(L)
		{
		case .Immediate: addr = FetchByte();
		case .ZeroPage(let index):
			addr = (Byte)(FetchByte() + index); if (index > 0) {this.cycles--;}
		case .Absolute(let index):
			Word temp = FetchWord();
			addr = temp + index;
			if (addr >> 8 != temp >> 8)
				this.cycles--;
			
		case .IndirectX:
			addr = ReadWordFromZeroPage(FetchByte(), this.X);
			
		case .IndirectY:
			Word temp = ReadWordFromZeroPage(FetchByte());
			addr = temp + this.Y;
			if (addr >> 8 != temp >> 8)
				this.cycles--;
			
		}


		if (L case .Immediate)
			val = (Byte)addr;
		else
		{
			val = (*this.memory)[addr];
			cycles--;

		}
		this.LoadValueToRegister(R, op(this.A, val));
	}

	public void StoreRegisterToMemory(Register R, StoreAdressingMode S)
	{
		switch (S)
		{
		case .ZeroPage(let index): this.StoreRegisterToZeroPage(R, this.FetchByte(), index);
		case .Absolute(let index): this.StoreRegisterToMemory(R, this.FetchWord(), index);
		case .IndirectX: this.StoreRegisterToMemory(R, this.ReadWordFromZeroPage(this.FetchByte(), this.X)); cycles--; // yeah
		case .IndirectY: this.StoreRegisterToMemory(R, this.ReadWordFromZeroPage(this.FetchByte()), this.Y);
		}
	}

	// will check for page wrap
	public void LoadByteFromZeroPageToRegister(Register R, Byte addr, Byte index = 0)
	{
		if (index > 0)
		cycles--;

		
		Byte fAddr = addr + index; // auto-wrap here we go
		Byte val = ReadByte(fAddr);
		LoadValueToRegister(R, val);
	}

	public void LoadByteFromAbsoluteMemoryToRegister(Register R, Word addr, Byte index = 0)
	{
		Word fAddr = addr + index;
		if (fAddr >> 8 != addr >> 8)
			cycles--; // fix high byte
		Byte val = ReadByte(fAddr);
		LoadValueToRegister(R, val);
	}



	public void StoreRegisterToZeroPage(Register R, Byte addr, Byte index = 0)
	{
		if (index > 0)
			this.cycles--;
		Byte finalAddr = addr + index; // wraps automatically

		switch(R)
		{
		case .A:
			(*this.memory)[finalAddr] = this.A;
		case .X:
			(*this.memory)[finalAddr] = this.X;
		case .Y:
			(*this.memory)[finalAddr] = this.Y;
		}
		this.cycles--;
	}

	public void StoreRegisterToMemory(Register R, Word addr, Byte index = 0)
	{
		if (index > 0)
			this.cycles--; // this one is for the sum
		Word finalAddr = addr + index;
		switch(R)
		{
		case .A:
			(*this.memory)[finalAddr] = this.A;
		case .X:
			(*this.memory)[finalAddr] = this.X;
		case .Y:
			(*this.memory)[finalAddr] = this.Y;
		}
		this.cycles--; // this one is for the write
	}

	public Result<int, String> Execute(int cycles) // NOTE: if this function returns a negative number, there's a problem
	{
		int startCycles = cycles;
		this.cycles = cycles;
		while(this.cycles > 0)
		{
			Byte instruction = this.FetchByte();
			this.instructions[instruction](this);


		}
		return startCycles - this.cycles;
	}

	public void Run(bool verbose = false)
	{
		if(verbose)
			Console.WriteLine($"starting at PC = {this.PC}");
		//this.PC = resetVector; // may wanna call reset or something
		while((*this.memory)[this.PC] != 0) // be better than that and add break
		{
			this.Tick(verbose);
		}
	}

	public void RunNextInstruction(bool verbose = false)
	{
		Byte instruction = this.FetchByte();
		if (verbose)
			Console.WriteLine($"Running instruction {instruction}");
		this.instructions[instruction](this);
	}



	public void Tick(bool verbose = false)
	{
		if(verbose)
			Console.WriteLine("Tick");
		this.cycles++;
		if (this.cycles >= 0)
			this.RunNextInstruction(verbose);
	}
	
}