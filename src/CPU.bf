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

	public void Initialize() mut
	{
		for (uint32 i = 0; i < MAX_MEM; i++)
			this.data[i] = 0;
	}

	public Byte this[uint32 i]
	{
		get => data[i];
		set mut => data[i] = value;
	}

	public void WriteWord(Word val, uint32 addr, ref int cycles) mut
	{
		//Console.WriteLine($"Writing word {val} at address {addr}...");
		this.WriteWord(val, addr);
		cycles -= 2;
	}

	public void WriteWord(Word val, uint32 addr) mut // Should not be used
	{
		//Console.WriteLine($"Writing word {val} at address {addr}...");
		this[addr] = (Byte)val;
		this[addr + 1] = (Byte)(val >> 8);
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


	public Word PC; // Program Counter
	public Byte SP; // Stack Pointer // SHOULD BE BYTE

	public Byte A, X, Y; // Registers



	public Bit C, Z, I, D, B, V, N; // Processor status flags

	public Memory* memory;
	public int cycles;


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

		INS_AND_IM = 0x29,   /// Logical AND Immediate
		INS_AND_ZP = 0x25,   /// Logical AND Zero Page
		INS_AND_ZPX = 0x35,  /// Logical AND Zero Page X
		INS_AND_ABS = 0x2D,  /// Logical AND Absolute
		INS_AND_ABSX = 0x3D, /// Logical AND Absolute X
		INS_AND_ABSY = 0x39, /// Logical AND Absolute Y
		INS_AND_INDX = 0x21, /// Logical AND Indirect X
		INS_AND_INDY = 0x21, /// Logical AND Indirect Y

		INS_JSR = 0x20;     /// Jump to Subroutine

	public function Result<void, String>(CPU)[] instructions = new function Result<void, String>(CPU)[0xFF];



	public this
	{
		this.Reset();


		for (int i < 0xFF)
		{
			instructions[i] =  (_) => .Err("Unknown Instruction");
		}



		instructions[INS_LDA_IM] = (c) => { return c.FetchByteToRegister(.A, .Immediate, (a, m) => m); };
		instructions[INS_LDA_ZP] = (c) => { return c.FetchByteToRegister(.A, .ZeroPage(0), (a, m) => m); };
		instructions[INS_LDA_ZPX] = (c) => { return c.FetchByteToRegister(.A, .ZeroPage(c.X), (a, m) => m); };
		instructions[INS_LDA_ABS] = (c) => { return c.FetchByteToRegister(.A, .Absolute(0), (a, m) => m); };
		instructions[INS_LDA_ABSX] = (c) => { return c.FetchByteToRegister(.A, .Absolute(c.X), (a, m) => m); };
		instructions[INS_LDA_ABSY] = (c) => { return c.FetchByteToRegister(.A, .Absolute(c.Y), (a, m) => m); };
		instructions[INS_LDA_INDX] = (c) => { return c.FetchByteToRegister(.A, .IndirectX, (a, m) => m); };
		instructions[INS_LDA_INDY] = (c) => { return c.FetchByteToRegister(.A, .IndirectY, (a, m) => m); };

		instructions[INS_LDX_IM] = (c) => { return c.FetchByteToRegister(.X, .Immediate, (a, m) => m); };
		instructions[INS_LDX_ZP] = (c) => { return c.FetchByteToRegister(.X, .ZeroPage(0), (a, m) => m); };
		instructions[INS_LDX_ZPY] = (c) => { return c.FetchByteToRegister(.X, .ZeroPage(c.Y), (a, m) => m); };
		instructions[INS_LDX_ABS] = (c) => { return c.FetchByteToRegister(.X, .Absolute(0), (a, m) => m); };
		instructions[INS_LDX_ABSY] = (c) => { return c.FetchByteToRegister(.X, .Absolute(c.Y), (a, m) => m); };

		instructions[INS_LDY_IM] = (c) => { return c.FetchByteToRegister(.Y, .Immediate, (a, m) => m); };
		instructions[INS_LDY_ZP] = (c) => { return c.FetchByteToRegister(.Y, .ZeroPage(0), (a, m) => m); };
		instructions[INS_LDY_ZPX] = (c) => { return c.FetchByteToRegister(.Y, .ZeroPage(c.X), (a, m) => m); };
		instructions[INS_LDY_ABS] = (c) => { return c.FetchByteToRegister(.Y, .Absolute(0), (a, m) => m); };
		instructions[INS_LDY_ABSX] = (c) => { return c.FetchByteToRegister(.Y, .Absolute(c.X), (a, m) => m); };

		instructions[INS_STA_ZP] = (c) => { return c.StoreRegisterToMemory(.A, .ZeroPage(0)); };
		instructions[INS_STA_ZPX] = (c) => { return c.StoreRegisterToMemory(.A, .ZeroPage(c.X)); };
		instructions[INS_STA_ABS] = (c) => { return c.StoreRegisterToMemory(.A, .Absolute(0)); };
		instructions[INS_STA_ABSX] = (c) => { return c.StoreRegisterToMemory(.A, .Absolute(c.X)); };
		instructions[INS_STA_ABSY] = (c) => { return c.StoreRegisterToMemory(.A, .Absolute(c.Y)); };
		instructions[INS_STA_INDX] = (c) => { return c.StoreRegisterToMemory(.A, .IndirectX); };
		instructions[INS_STA_INDY] = (c) => { return c.StoreRegisterToMemory(.A, .IndirectY); };

		instructions[INS_STX_ZP] = (c) => { return c.StoreRegisterToMemory(.X, .ZeroPage(0)); };
		instructions[INS_STX_ZPY] = (c) => { return c.StoreRegisterToMemory(.X, .ZeroPage(c.Y)); };
		instructions[INS_STX_ABS] = (c) => { return c.StoreRegisterToMemory(.X, .Absolute(0)); };

		instructions[INS_STY_ZP] = (c) => { return c.StoreRegisterToMemory(.Y, .ZeroPage(0)); };
		instructions[INS_STY_ZPX] = (c) => { return c.StoreRegisterToMemory(.Y, .ZeroPage(c.X)); };
		instructions[INS_STY_ABS] = (c) => { return c.StoreRegisterToMemory(.Y, .Absolute(0)); };

		instructions[INS_TAX] = (c) => { c.X = c.A; c.cycles--; return c.SetLoadFlags(.X); };
		instructions[INS_TXA] = (c) => { c.A = c.X; c.cycles--; return c.SetLoadFlags(.A); };
		instructions[INS_TAY] = (c) => { c.Y = c.A; c.cycles--; return c.SetLoadFlags(.Y); };
		instructions[INS_TYA] = (c) => { c.A = c.Y; c.cycles--; return c.SetLoadFlags(.A); };
		instructions[INS_TXS] = (c) => { c.SP = c.X; c.cycles--; return (void)0; };
		instructions[INS_TSX] = (c) => { c.X = c.SP; c.cycles--; return c.SetLoadFlags(.X); };

		instructions[INS_AND_IM] = (c) => { return c.FetchByteToRegister(.A, .Immediate, (a, m) => a & m); };
		instructions[INS_AND_ZP] = (c) => { return c.FetchByteToRegister(.A, .ZeroPage(0), (a, m) => a & m); };
		instructions[INS_AND_ZPX] = (c) => { return c.FetchByteToRegister(.A, .ZeroPage(c.X), (a, m) => a & m); };
		instructions[INS_AND_ABS] = (c) => { return c.FetchByteToRegister(.A, .Absolute(0), (a, m) => a & m); };
		instructions[INS_AND_ABSX] = (c) => { return c.FetchByteToRegister(.A, .Absolute(c.X), (a, m) => a & m); };
		instructions[INS_AND_ABSY] = (c) => { return c.FetchByteToRegister(.A, .Absolute(c.Y), (a, m) => a & m); };
		instructions[INS_AND_INDX] = (c) => { return c.FetchByteToRegister(.A, .IndirectX, (a, m) => 4); };
		instructions[INS_AND_INDY] = (c) => { return c.FetchByteToRegister(.A, .IndirectY, (a, m) => a & m); };
	}

	public this(Memory* mem)
	{
		this.memory = mem;

	}

	public ~this()
	{
		delete this.instructions;
	}

	public void Reset()
	{ // should code this but we emulate for now
		PC = 0xFFFC; // reset vector
		SP = (Byte)0x0100; // 0x100 = 0x0 in 8-bit right?? gotta check this
		C = Z = I = D = B = V = N = 0;
		A = X = Y = 0;
	}

	public Byte ReadByte(Word address)
	{
		Byte data = (*this.memory)[address]; 
		this.cycles--;
		return data;
	}

	public Byte FetchByte() // will rework to work with ReadByte
	{
		Byte data = (*this.memory)[this.PC]; 
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


	public Word FetchWord()
	{
		// 6502 is little endian
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

	
	public Byte ReadByte(Word addr, LoadAdressingMode L) // no cycle consumption, just for coding purposes
	{
		switch(L)
		{
		case .Immediate: return (Byte)addr;
		case .ZeroPage(let index): return (*this.memory)[(Byte)(addr + index)]; // adding might promote to Word too soon
		case .Absolute(let index): return (*this.memory)[index + addr];
		case .IndirectX: return (*this.memory)[ReadByte(addr, .ZeroPage(this.X))];
		case .IndirectY: return (*this.memory)[ReadByte(addr, .ZeroPage(0)) + this.Y]; 
		}

	}

	public void FetchByteToRegister(Register R, LoadAdressingMode L, function Byte(Byte a, Byte m) op)
	{
		Console.WriteLine("hey");
		Word addr;
		Byte val;
		switch(L)
		{
		case .Immediate: addr = FetchByte(); Console.WriteLine("imm");
		case .ZeroPage(let index):
			addr = (Byte)(FetchByte() + index); if (index > 0) {this.cycles--;} Console.WriteLine("zp");
		case .Absolute(let index):
			Word temp = FetchWord();
			Console.WriteLine("abs");
			addr = temp + index;
			if (addr >> 8 != temp >> 8)
				this.cycles--;
			
		case .IndirectX:
			addr = ReadWordFromZeroPage(FetchByte(), this.X);
			Console.WriteLine("indx");
		case .IndirectY:
			Word temp = ReadWordFromZeroPage(FetchByte());
			addr = temp + this.Y;
			if (addr >> 8 != temp >> 8)
				this.cycles--;
			Console.WriteLine("indy");
		}
		Console.WriteLine("end");

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
}