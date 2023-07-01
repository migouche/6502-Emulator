namespace System;

extension UInt16
{
	public uint8 LowByte { get => (uint8)this; };
	public uint8 HighByte{ get => (uint8)(this >> 8); };
}