namespace System;

extension UInt16
{
	public uint8 LowByte { get => (uint8)this; };
	public uint8 HighByte{ get => (uint8)(this >> 8); };

	public this(uint8 lowByte, uint8 highByte)
	{
		this = (Self)lowByte | ((Self)highByte << 8);
	}
}