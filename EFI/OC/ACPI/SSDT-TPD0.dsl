// Necessary hotpatch
// Maintained by: stevezhengshiqi
// Rewrite TPD0._INI and TPD0._CRS method to enable trackpad interrupt mode, pair with `Rename TPD0._INI to XINI` and `Rename TPD0._CRS to XCRS`

DefinitionBlock ("", "SSDT", 2, "hack", "_TPD0", 0x00000000)
{
    External (_SB_.GNUM, MethodObj)    // 1 Arguments
    External (_SB_.INUM, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.I2C0.TPD0, DeviceObj)
    External (_SB_.PCI0.I2C0.TPD0._HID, UnknownObj)
    External (_SB_.PCI0.I2C0.TPD0.HID2, UnknownObj)
    External (_SB_.PCI0.I2C0.TPD0.INT1, UnknownObj)
    External (_SB_.PCI0.I2C0.TPD0.INT2, UnknownObj)
    External (_SB_.PCI0.I2C0.TPD0.SBFB, UnknownObj)
    External (_SB_.PCI0.I2C0.TPD0.SBFG, UnknownObj)
    External (_SB_.PCI0.I2C0.TPD0.SBFI, UnknownObj)
    External (_SB_.SHPO, MethodObj)    // 2 Arguments
    External (_SB_.SRXO, MethodObj)    // 2 Arguments
    External (GPDI, FieldUnitObj)
    External (OSYS, FieldUnitObj)
    External (SBFI, IntObj)
    External (SDM0, FieldUnitObj)
    External (SDS0, FieldUnitObj)

    Scope (_SB.PCI0.I2C0.TPD0)
    {
        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            If (_OSI ("Darwin")){}
            ElseIf ((OSYS < 0x07DC))
            {
                SRXO (GPDI, One)
            }

            INT1 = GNUM (GPDI)
            INT2 = INUM (GPDI)
            If ((SDM0 == Zero))
            {
                SHPO (GPDI, One)
            }

            _HID = "ETD2303"
            HID2 = One
            Return (Zero)
            If ((SDS0 == One))
            {
                _HID = "SYNA2393"
                HID2 = 0x20
                Return (Zero)
            }

            If ((SDS0 == 0x02))
            {
                _HID = "06CB2846"
                HID2 = 0x20
                Return (Zero)
            }
        }

        Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
        {
            If (_OSI ("Darwin"))
            {
                Return (ConcatenateResTemplate (SBFB, SBFG))
            }

            If ((OSYS < 0x07DC))
            {
                Return (SBFI) /* External reference */
            }

            If ((SDM0 == Zero))
            {
                Return (ConcatenateResTemplate (SBFB, SBFG))
            }

            Return (ConcatenateResTemplate (SBFB, SBFI))
        }
    }
}

