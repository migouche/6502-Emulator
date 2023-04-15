using System;

namespace CPU_6502;

typealias Byte = uint8;
typealias Word = uint16;

struct Bit
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

	public Word PC; // Program Counter
	public Byte SP; // Stack Pointer // SHOULD BE BYTE

	public Byte A, X, Y; // Registers



	public Bit C, Z, I, D, B, V, N; // Processor status flags

	public Memory* memory;

	// opcodes
	public const Byte
		INS_LDA_IM = 0xA9,   /// Load Accumulator Immediate
		INS_LDA_ZP = 0xA5,   /// Load Accumulator Zero Page
		INS_LDA_ZPX = 0xB5,  /// Load Accumulator Zero Page X
		INS_LDA_ABS = 0xAD,  /// Load Accumulator Absolute
		INS_LDA_ABSX = 0xBD, /// Load Accumulator Absolute X
		INS_LDA_ABSY = 0xB9, /// Load Accumulator Absolute Y
		INS_LDA_INDX = 0xA1,   /// Load Acumulator Indirect X
		INS_LDA_INDY = 0xB1,

		INS_JSR = 0x20;     /// Jump to Subroutine

	/*public this
	{
		this.Reset();
	}

	public this(Memory* mem)
	{

	}*/
	

	public void Reset(ref Memory mem)
	{ // should code this but we emulate for now
		PC = 0xFFFC; // reset vector
		SP = (Byte)0x0100;
		C = Z = I = D = B = V = N = 0;
		A = X = Y = 0;
	}

	public Byte ReadByte(ref int cycles, Word address, ref Memory mem)
	{
		Byte data = mem[address]; 
		cycles--;
		return data;
	}

	public Byte FetchByte(ref int cycles, ref Memory mem) // will rework to work with ReadByte
	{
		Byte data = mem[this.PC]; 
		this.PC++;
		cycles--;
		return data;
	}

	public Word ReadWord(ref int cycles, Word address, ref Memory mem)
	{
		Byte lByte = ReadByte(ref cycles, address, ref mem);
		Byte hByte = ReadByte(ref cycles, address + 1, ref mem);
		return lByte | ((Word)hByte << 8);
	}


	public Word FetchWord(ref int cycles, ref Memory mem)
	{
		// 6502 is little endian
		Word data = mem[this.PC]; // Low byte
		this.PC++;
		cycles--;

		data |= ((Word)mem[this.PC]) << 8; // High byte
		this.PC++;
		cycles--;

		//Console.WriteLine($"Fetched word {data}...");

		return data;
	}


	void SetLDAFlags()
	{
		this.Z = this.A == 0;
		this.N = this.A & 0b10000000;
	}

	public void LoadByteToRegister(Register R, Byte val) // should not take cycles
	{
		switch (R)
		{
		case .A:
			this.A = val;
			this.SetLDAFlags();
		case .X:
			this.X = val;
		case .Y:
			this.Y = val;
		}
	}

	public Word ReadWordFromZeroPage(ref int cycles, Byte addr, ref Memory mem, Byte index = 0)
	{
		var addr;
		addr += index;
		return this.ReadWord(ref cycles, addr, ref mem);
	}

	public void FetchByteToRegister(Register R, ref int cycles, ref Memory mem)
	{
		Byte val = this.FetchByte(ref cycles, ref mem);
		LoadByteToRegister(R, val);

	}

	// will check for page wrap
	public void ReadByteFromZeroPageToRegister(Register R, ref int cycles, ref Memory mem, Byte addr, Byte index = 0)
	{
		if (index > 0)
		cycles--;

		
		Byte fAddr = addr + index; // auto-wrap here we go
		Byte val = ReadByte(ref cycles, fAddr, ref mem);
		LoadByteToRegister(R, val);
	}

	public void ReadByteFromAbsoluteMemoryToRegister(Register R, ref int cycles, ref Memory mem, Word addr, Byte index = 0)
	{
		Word fAddr = addr + index;
		if (fAddr >> 8 != addr >> 8)
			cycles--; // fix high byte
		Byte val = ReadByte(ref cycles, fAddr, ref mem);
		LoadByteToRegister(R, val);

	}

	public Result<int, String> Execute(int cycles, ref Memory mem) // NOTE: if this function returns a negative number, there's a problem
	{
		int startCycles = cycles;
		var cycles;
		while(cycles > 0)
		{
			Byte instruction = this.FetchByte(ref cycles, ref mem);

			switch(instruction)
			{
			case INS_LDA_IM:
			do {
				FetchByteToRegister(.A, ref cycles, ref mem);
			}

			case INS_LDA_ZP:
			do{
				ReadByteFromZeroPageToRegister(.A, ref cycles, ref mem, this.FetchByte(ref cycles, ref mem));
			}

			case INS_LDA_ZPX:
			do {
				ReadByteFromZeroPageToRegister(.A, ref cycles, ref mem, this.FetchByte(ref cycles, ref mem), this.X);
				//cycles--; // cause of previous addition + wrap around Zero Page
			}

			case INS_LDA_ABS:
			do{
				this.ReadByteFromAbsoluteMemoryToRegister(.A, ref cycles, ref mem, FetchWord(ref cycles, ref mem));
			}

			case INS_LDA_ABSX: // please use some functions later
			do {
				this.ReadByteFromAbsoluteMemoryToRegister(.A, ref cycles, ref mem, FetchWord(ref cycles, ref mem), this.X);
			}

			case INS_LDA_ABSY:
			do {
				this.ReadByteFromAbsoluteMemoryToRegister(.A, ref cycles, ref mem, FetchWord(ref cycles, ref mem), this.Y);
			}

			case INS_LDA_INDX:
			do {
				this.ReadByteFromAbsoluteMemoryToRegister(.A, ref cycles, ref mem,
					this.ReadWordFromZeroPage(ref cycles, this.FetchByte(ref cycles, ref mem), ref mem, this.X));
			}

			case INS_LDA_INDY:
			do {
				this.ReadByteFromAbsoluteMemoryToRegister(.A, ref cycles, ref mem,
					this.ReadWordFromZeroPage(ref cycles, this.FetchByte(ref cycles, ref mem), ref mem), this.Y);
			}


			case INS_JSR:
			do{ // absolute mode, so need 16 bits
				Word jumpAddr = FetchWord(ref cycles, ref mem);
				mem.WriteWord(this.PC - 1, this.SP, ref cycles);
				this.PC = jumpAddr;
				this.SP += 2; // cause we wrote a word
				cycles--;
			}

			default:
				return .Err("Unknown Instruction");
			}

		}
		return startCycles - cycles;
	}
}