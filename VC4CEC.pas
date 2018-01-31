unit VC4CEC;

{$mode delphi}
{$H+}
{$inline on}

interface

uses
  Classes, SysUtils, VC4;
const

// Broadcast address and TV logical address
  CEC_BROADCAST_ADDR                             = $0F;
  CEC_TV_ADDRESS                                 = $00;

// Maximum transmit length excluding the header byte
  CEC_MAX_XMIT_LENGTH                            = 15;  // + 1 for CEC Header Length
// Invalid physical address
  CEC_CLEAR_ADDR                                 = $FFFF;  // packed 16 bits of F.F.F.F

(* ----------------------------------------------------------------------
 * general CEC defines
 * -------------------------------------------------------------------- *)
// Maximum transmission length and invalid physical address are now in vc_cec.h
  CEC_VERSION                                    = $04;    // HDMI 1.3a
//This OUI ID is registered at the current HQ address in Irvine
  CEC_VENDOR_ID_BROADCOM                         = $18C086; // 24 bit OUI company id from IEEE. = Broadcom
// These three OUI IDs are registered with the old address of Irvine office in case you need them
// #define CEC_VENDOR_ID_BROADCOM   (0x000AF7L)
// #define CEC_VENDOR_ID_BROADCOM   (0x001018L)
// #define CEC_VENDOR_ID_BROADCOM   (0x001BE9L)
  CEC_VENDOR_ID_ONKYO                            = $0009B0;
  CEC_VENDOR_ID_PANASONIC_EUROPE                 = $000F12;

// If we want to "pretend" to be somebody else use a different company id
  CEC_VENDOR_ID                                  = $000000; // We should set the vendor id

  CEC_BLOCKING                                   = 1;
  CEC_NONBLOCKING                                = 0;

// CEC_DEVICE_TYPE_T
  CEC_DeviceType_TV                              = 0;  // TV only
  CEC_DeviceType_Rec                             = 1;  // Recording device
  CEC_DeviceType_Reserved                        = 2;  // Reserved
  CEC_DeviceType_Tuner                           = 3;  // STB
  CEC_DeviceType_Playback                        = 4;  // DVD player
  CEC_DeviceType_Audio                           = 5;  // AV receiver
  CEC_DeviceType_Switch                          = 6;  // CEC switch
  CEC_DeviceType_VidProc                         = 7;  // Video processor
  CEC_DeviceType_Invalid                         = $F; // RESERVED - DO NOT USE

// CEC_OPCODE_T
  CEC_Opcode_FeatureAbort 	                     = $00;
  CEC_Opcode_ImageViewOn 	                       = $04;
  CEC_Opcode_TunerStepIncrement    	             = $05;
  CEC_Opcode_TunerStepDecrement    	             = $06;
  CEC_Opcode_TunerDeviceStatus 	                 = $07;
  CEC_Opcode_GiveTunerDeviceStatus 	             = $08;
  CEC_Opcode_RecordOn 	                         = $09;
  CEC_Opcode_RecordStatus 	                     = $0A;
  CEC_Opcode_RecordOff 	                         = $0B;
  CEC_Opcode_TextViewOn 	                       = $0D;
  CEC_Opcode_RecordTVScreen                      = $0F;
  CEC_Opcode_GiveDeckStatus        	             = $1A;
  CEC_Opcode_DeckStatus 	                       = $1B;
  CEC_Opcode_SetMenuLanguage                     = $32;
  CEC_Opcode_ClearAnalogTimer                    = $33;
  CEC_Opcode_SetAnalogTimer                      = $34;
  CEC_Opcode_TimerStatus                         = $35;
  CEC_Opcode_Standby 	                           = $36;
  CEC_Opcode_Play                  	             = $41;
  CEC_Opcode_DeckControl 	                       = $42;
  CEC_Opcode_TimerClearedStatus                  = $43;
  CEC_Opcode_UserControlPressed 	               = $44;
  CEC_Opcode_UserControlReleased 	               = $45;
  CEC_Opcode_GiveOSDName           	             = $46;
  CEC_Opcode_SetOSDName 	                       = $47;
  CEC_Opcode_SetOSDString 	                     = $64;
  CEC_Opcode_SetTimerProgramTitle                = $67;
  CEC_Opcode_SystemAudioModeRequest              = $70;
  CEC_Opcode_GiveAudioStatus                     = $71;
  CEC_Opcode_SetSystemAudioMode                  = $72;
  CEC_Opcode_ReportAudioStatus                   = $7A;
  CEC_Opcode_GiveSystemAudioModeStatus           = $7D;
  CEC_Opcode_SystemAudioModeStatus               = $7E;
  CEC_Opcode_RoutingChange 	                     = $80;
  CEC_Opcode_RoutingInformation 	               = $81;
  CEC_Opcode_ActiveSource 	                     = $82;
  CEC_Opcode_GivePhysicalAddress                 = $83;
  CEC_Opcode_ReportPhysicalAddress               = $84;
  CEC_Opcode_RequestActiveSource 	               = $85;
  CEC_Opcode_SetStreamPath 	                     = $86;
  CEC_Opcode_DeviceVendorID 	                   = $87;
  CEC_Opcode_VendorCommand         	             = $89;
  CEC_Opcode_VendorRemoteButtonDown 	           = $8A;
  CEC_Opcode_VendorRemoteButtonUp    	           = $8B;
  CEC_Opcode_GiveDeviceVendorID    	             = $8C;
  CEC_Opcode_MenuRequest 	                       = $8D;
  CEC_Opcode_MenuStatus 	                       = $8E;
  CEC_Opcode_GiveDevicePowerStatus 	             = $8F;
  CEC_Opcode_ReportPowerStatus 	                 = $90;
  CEC_Opcode_GetMenuLanguage                     = $91;
  CEC_Opcode_SelectAnalogService                 = $92;
  CEC_Opcode_SelectDigitalService   	           = $93;
  CEC_Opcode_SetDigitalTimer                     = $97;
  CEC_Opcode_ClearDigitalTimer                   = $99;
  CEC_Opcode_SetAudioRate                        = $9A;
  CEC_Opcode_InactiveSource        	             = $9D;
  CEC_Opcode_CECVersion                          = $9E;
  CEC_Opcode_GetCECVersion                       = $9F;
  CEC_Opcode_VendorCommandWithID                 = $A0;
  CEC_Opcode_ClearExternalTimer                  = $A1;
  CEC_Opcode_SetExternalTimer                    = $A2;
  CEC_Opcode_ReportShortAudioDescriptor          = $A3;
  CEC_Opcode_RequestShortAudioDescriptor         = $A4;
  CEC_Opcode_InitARC                             = $C0;
  CEC_Opcode_ReportARCInited                     = $C1;
  CEC_Opcode_ReportARCTerminated                 = $C2;
  CEC_Opcode_RequestARCInit                      = $C3;
  CEC_Opcode_RequestARCTermination               = $C4;
  CEC_Opcode_TerminateARC                        = $C5;
  CEC_Opcode_CDC                                 = $F8;
  CEC_Opcode_Abort        	                     = $FF;

  // CEC_ABORT_REASON_T
  CEC_Abort_Reason_Unrecognised_Opcode           = 0;
  CEC_Abort_Reason_Wrong_Mode                    = 1;
  CEC_Abort_Reason_Cannot_Provide_Source         = 2;
  CEC_Abort_Reason_Invalid_Operand               = 3;
  CEC_Abort_Reason_Refused                       = 4;
  CEC_Abort_Reason_Undetermined                  = 5;

  // CEC_DISPLAY_CONTROL_T
  CEC_DISPLAY_CONTROL_DEFAULT_TIME               = 0;
  CEC_DISPLAY_CONTROL_UNTIL_CLEARED              = 1 shl 6;
  CEC_DISPLAY_CONTROL_CLEAR_PREV_MSG             = 1 shl 7;

  // CEC_POWER_STATUS_T
  CEC_POWER_STATUS_ON                            = 0;
  CEC_POWER_STATUS_STANDBY                       = 1;
  CEC_POWER_STATUS_ON_PENDING                    = 2;
  CEC_POWER_STATUS_STANDBY_PENDING               = 3;

// CEC_MENU_STATE_T
  CEC_MENU_STATE_ACTIVATED                       = 0;
  CEC_MENU_STATE_DEACTIVATED                     = 1;
  CEC_MENU_STATE_QUERY                           = 2;

// CEC_DECK_INFO_T;
  CEC_DECK_INFO_PLAY                             = $11;
  CEC_DECK_INFO_RECORD                           = $12;
  CEC_DECK_INFO_PLAY_REVERSE                     = $13;
  CEC_DECK_INFO_STILL                            = $14;
  CEC_DECK_INFO_SLOW                             = $15;
  CEC_DECK_INFO_SLOW_REVERSE                     = $16;
  CEC_DECK_INFO_SEARCH_FORWARD                   = $17;
  CEC_DECK_INFO_SEARCH_REVERSE                   = $18;
  CEC_DECK_INFO_NO_MEDIA                         = $19;
  CEC_DECK_INFO_STOP                             = $1A;
  CEC_DECK_INFO_WIND                             = $1B;
  CEC_DECK_INFO_REWIND                           = $1C;
  CEC_DECK_IDX_SEARCH_FORWARD                    = $1D;
  CEC_DECK_IDX_SEARCH_REVERSE                    = $1E;
  CEC_DECK_OTHER_STATUS                          = $1F;

// CEC_DECK_CTRL_MODE_T
  CEC_DECK_CTRL_FORWARD                          = 1;
  CEC_DECK_CTRL_BACKWARD                         = 2;
  CEC_DECK_CTRL_STOP                             = 3;
  CEC_DECK_CTRL_EJECT                            = 4;

// CEC_PLAY_MODE_T;
  CEC_PLAY_FORWARD                               = $24;
  CEC_PLAY_REVERSE                               = $20;
  CEC_PLAY_STILL                                 = $25;
  CEC_PLAY_SCAN_FORWARD_MIN_SPEED                = $05;
  CEC_PLAY_SCAN_FORWARD_MED_SPEED                = $06;
  CEC_PLAY_SCAN_FORWARD_MAX_SPEED                = $07;
  CEC_PLAY_SCAN_REVERSE_MIN_SPEED                = $09;
  CEC_PLAY_SCAN_REVERSE_MED_SPEED                = $0A;
  CEC_PLAY_SCAN_REVERSE_MAX_SPEED                = $0B;
  CEC_PLAY_SLOW_FORWARD_MIN_SPEED                = $15;
  CEC_PLAY_SLOW_FORWARD_MED_SPEED                = $16;
  CEC_PLAY_SLOW_FORWARD_MAX_SPEED                = $17;
  CEC_PLAY_SLOW_REVERSE_MIN_SPEED                = $19;
  CEC_PLAY_SLOW_REVERSE_MED_SPEED                = $1A;
  CEC_PLAY_SLOW_REVERSE_MAX_SPEED                = $1B;

// CEC_DECK_STATUS_REQUEST_T
  CEC_DECK_STATUS_ON                             = 1;
  CEC_DECK_STATUS_OFF                            = 2;
  CEC_DECK_STATUS_ONCE                           = 3;

// CEC_USER_CONTROL_T
  CEC_User_Control_Select                        = $00;
  CEC_User_Control_Up                            = $01;
  CEC_User_Control_Down                          = $02;
  CEC_User_Control_Left                          = $03;
  CEC_User_Control_Right                         = $04;
  CEC_User_Control_RightUp                       = $05;
  CEC_User_Control_RightDown                     = $06;
  CEC_User_Control_LeftUp                        = $07;
  CEC_User_Control_LeftDown                      = $08;
  CEC_User_Control_RootMenu                      = $09;
  CEC_User_Control_SetupMenu                     = $0A;
  CEC_User_Control_ContentsMenu                  = $0B;
  CEC_User_Control_FavoriteMenu                  = $0C;
  CEC_User_Control_Exit                          = $0D;
  CEC_User_Control_Number0                       = $20;
  CEC_User_Control_Number1                       = $21;
  CEC_User_Control_Number2                       = $22;
  CEC_User_Control_Number3                       = $23;
  CEC_User_Control_Number4                       = $24;
  CEC_User_Control_Number5                       = $25;
  CEC_User_Control_Number6                       = $26;
  CEC_User_Control_Number7                       = $27;
  CEC_User_Control_Number8                       = $28;
  CEC_User_Control_Number9                       = $29;
  CEC_User_Control_Dot                           = $2A;
  CEC_User_Control_Enter                         = $2B;
  CEC_User_Control_Clear                         = $2C;
  CEC_User_Control_ChannelUp                     = $30;
  CEC_User_Control_ChannelDown                   = $31;
  CEC_User_Control_PreviousChannel               = $32;
  CEC_User_Control_SoundSelect                   = $33;
  CEC_User_Control_InputSelect                   = $34;
  CEC_User_Control_DisplayInformation            = $35;
  CEC_User_Control_Help                          = $36;
  CEC_User_Control_PageUp                        = $37;
  CEC_User_Control_PageDown                      = $38;
  CEC_User_Control_Power                         = $40;
  CEC_User_Control_VolumeUp                      = $41;
  CEC_User_Control_VolumeDown                    = $42;
  CEC_User_Control_Mute                          = $43;
  CEC_User_Control_Play                          = $44;
  CEC_User_Control_Stop                          = $45;
  CEC_User_Control_Pause                         = $46;
  CEC_User_Control_Record                        = $47;
  CEC_User_Control_Rewind                        = $48;
  CEC_User_Control_FastForward                   = $49;
  CEC_User_Control_Eject                         = $4A;
  CEC_User_Control_Forward                       = $4B;
  CEC_User_Control_Backward                      = $4C;
  CEC_User_Control_Angle                         = $50;
  CEC_User_Control_Subpicture                    = $51;
  CEC_User_Control_VideoOnDemand                 = $52;
  CEC_User_Control_EPG                           = $53;
  CEC_User_Control_TimerProgramming              = $54;
  CEC_User_Control_InitialConfig                 = $55;
  CEC_User_Control_PlayFunction                  = $60;
  CEC_User_Control_PausePlayFunction             = $61;
  CEC_User_Control_RecordFunction                = $62;
  CEC_User_Control_PauseRecordFunction           = $63;
  CEC_User_Control_StopFunction                  = $64;
  CEC_User_Control_MuteFunction                  = $65;
  CEC_User_Control_RestoreVolumeFunction         = $66;
  CEC_User_Control_TuneFunction                  = $67;
  CEC_User_Control_SelectDiskFunction            = $68;
  CEC_User_Control_SelectAVInputFunction         = $69;
  CEC_User_Control_SelectAudioInputFunction      = $6A;
  CEC_User_Control_F1Blue                        = $71;
  CEC_User_Control_F2Red                         = $72;
  CEC_User_Control_F3Green                       = $73;
  CEC_User_Control_F4Yellow                      = $74;
  CEC_User_Control_F5                            = $75;

// CEC_AllDevices_T
  CEC_AllDevices_eTV                             = 0;  // TV only
  CEC_AllDevices_eRec1                           = 1;  // Address for 1st Recording Device
  CEC_AllDevices_eRec2                           = 2;  // Address for 2nd Recording Device
  CEC_AllDevices_eSTB1                           = 3;  // Address for 1st SetTop Box Device
  CEC_AllDevices_eDVD1                           = 4;  // Address for 1st DVD Device
  CEC_AllDevices_eAudioSystem                    = 5;  // Address for Audio Device
  CEC_AllDevices_eSTB2                           = 6;  // Address for 2nd SetTop Box Device
  CEC_AllDevices_eSTB3                           = 7;  // Address for 3rd SetTop Box Device
  CEC_AllDevices_eDVD2                           = 8;  // Address for 2nd DVD Device
  CEC_AllDevices_eRec3                           = 9;  // Address for 3rd Recording Device
  CEC_AllDevices_eSTB4                           = 10; // Address for 4th Tuner Device
  CEC_AllDevices_eDVD3                           = 11; // Address for 3rd DVD Device
  CEC_AllDevices_eRsvd3                          = 12; // Reserved and cannot be used
  CEC_AllDevices_eRsvd4                          = 13; // Reserved and cannot be used
  CEC_AllDevices_eFreeUse                        = 14; // Free Address, use for any device
  CEC_AllDevices_eUnRegistered                   = 15; // UnRegistered Devices

// VC_CEC_NOTIFY_T  // aka Reason Codes from Callback
  VC_CEC_NOTIFY_NONE                             = 0;        // Reserved - NOT TO BE USED
  VC_CEC_TX                                      = 1 shl 0;  // A message has been transmitted
  VC_CEC_RX                                      = 1 shl 1;  // A message has arrived (only for registered commands)
  VC_CEC_BUTTON_PRESSED                          = 1 shl 2;  // User Control Pressed
  VC_CEC_BUTTON_RELEASE                          = 1 shl 3;  // User Control Release
  VC_CEC_REMOTE_PRESSED                          = 1 shl 4;  // Vendor Remote Button Down
  VC_CEC_REMOTE_RELEASE                          = 1 shl 5;  // Vendor Remote Button Up
  VC_CEC_LOGICAL_ADDR                            = 1 shl 6;  // New logical address allocated or released
  VC_CEC_TOPOLOGY                                = 1 shl 7;  // Topology is available
  VC_CEC_LOGICAL_ADDR_LOST                       = 1 shl 15; // Only for passive mode, if the logical address is lost for whatever reason, this will be triggered */

// VC_CEC_ERROR_T CEC service return code
  VC_CEC_SUCCESS                                 = 0; // OK
  VC_CEC_ERROR_NO_ACK                            = 1; // No acknowledgement
  VC_CEC_ERROR_SHUTDOWN                          = 2; // In the process of shutting down
  VC_CEC_ERROR_BUSY                              = 3; // block is busy
  VC_CEC_ERROR_NO_LA                             = 4; // No logical address
  VC_CEC_ERROR_NO_PA                             = 5; // No physical address
  VC_CEC_ERROR_NO_TOPO                           = 6; // No topology
  VC_CEC_ERROR_INVALID_FOLLOWER                  = 7; // Invalid follower
  VC_CEC_ERROR_INVALID_ARGUMENT                  = 8; // Invalid arguments

type
  TCECServiceCallback = procedure (Data : pointer; Reason, Param1, Param2, Param3, Param4 : LongWord); cdecl;

  CEC_DEVICE_TYPE_T               = byte; // enum
  CEC_DISPLAY_CONTROL_T           = byte; // enum
  CEC_USER_CONTROL_T              = byte; // enum
  CEC_AllDevices_T                = byte; // enum
  bool                            = boolean;

  PCEC_AllDevices_T               = ^CEC_AllDevices_T;

{$PACKRECORDS C}
  TVC_CEC_MESSAGE = record
    len : Longword;
    initiator : CEC_AllDevices_T;      // me
    follower : CEC_AllDevices_T;       // destination
    payload : array [0 .. CEC_MAX_XMIT_LENGTH] of byte;
  end;

  PVC_CEC_MESSAGE = ^TVC_CEC_MESSAGE;

 (*
     Meaning of device_attr is as follows (one per active logical device)
     bit 3-0 logical address (see CEC_AllDevices_T above)
     bit 7-4 device type (see CEC_DEVICE_TYPE_T above)
     bit 11-8 index to upstream device
     bit 15-12 number of downstream device
     bit 31-16 index of first 4 downstream devices
     To keep life simple we only show the first 4 connected downstream devices
 *)

  VC_CEC_TOPOLOGY_T = record
    active_mask : word;
    num_devices : word;
    device_attr : array [0 .. 15] of LongWord;
  end;
  PVC_CEC_TOPOLOGY_T = ^VC_CEC_TOPOLOGY_T;
{$PACKRECORDS DEFAULT}

// API calls
procedure vc_vchi_cec_init (instance : PVCHI_INSTANCE_T; connections : PPVCHI_CONNECTION_T; num_connections : Longword); cdecl; external libvchostif name 'vc_vchi_cec_init';
procedure vc_vchi_cec_stop; cdecl; external libvchostif name 'vc_vchi_cec_stop';
procedure vc_cec_register_callback (callback : TCECServiceCallback; Data : pointer); cdecl; external libvchostif name 'vc_cec_register_callback';
function vc_cec_register_command (opcode : byte) : integer; cdecl; external libvchostif name 'vc_cec_register_command';
function vc_cec_register_all : integer; cdecl; external libvchostif name 'vc_cec_register_all';
function vc_cec_deregister_command (opcode : byte) : integer; cdecl; external libvchostif name 'vc_cec_deregister_command';
function vc_cec_deregister_all : integer; cdecl; external libvchostif name 'vc_cec_deregister_all';
function vc_cec_send_message (const follower : LongWord; var payload : byte; len : Longword; is_replay : bool) : integer; cdecl; external libvchostif name 'vc_cec_send_message';
function vc_cec_get_logical_address (var logical_address : CEC_AllDevices_T) : integer; cdecl; external libvchostif name 'vc_cec_get_logical_address';
function vc_cec_alloc_logical_address : integer; cdecl; external libvchostif name 'vc_cec_alloc_logical_address';
function vc_cec_release_logical_address : integer; cdecl; external libvchostif name 'vc_cec_release_logical_address';
function vc_cec_get_topology (var topology : VC_CEC_TOPOLOGY_T) : integer; cdecl; external libvchostif name 'vc_cec_get_topology';
function vc_cec_set_vendor_id (id : LongWord) : integer; cdecl; external libvchostif name 'vc_cec_set_vendor_id';
function vc_cec_set_osd_name (const name : PChar) : integer; cdecl; external libvchostif name 'vc_cec_set_osd_name';
function vc_cec_get_physical_address (var physical_address: Word) : integer; cdecl; external libvchostif name 'vc_cec_get_physical_address';
function vc_cec_get_vendor_id (const logical_address : CEC_AllDevices_T; var vendor_id : Longword) : integer; cdecl; external libvchostif name 'vc_cec_get_vendor_id';
function vc_cec_device_type (const logical_address : CEC_AllDevices_T) : byte; cdecl; external libvchostif name 'vc_cec_device_type';
function vc_cec_send_message2 (var message : TVC_CEC_MESSAGE) : integer; cdecl; external libvchostif name 'vc_cec_send_message2';
function vc_cec_param2message (const reason, param1, param2, param3, param4 : Longword;
                               var message : TVC_CEC_MESSAGE) : integer; cdecl; external libvchostif name 'vc_cec_param2message';
function vc_cec_poll_address (const logical_address : CEC_AllDevices_T) : integer; cdecl; external libvchostif name 'vc_cec_poll_address';
function vc_cec_set_logical_address (const logical_address : CEC_AllDevices_T;
                                     const device_type : CEC_DEVICE_TYPE_T;
                                     const vendor_id : LongWord) : integer; cdecl; external libvchostif name 'vc_cec_set_logical_address';
function vc_cec_add_device (const  logical_address : CEC_AllDevices_T;
                            const physical_address : Word;
                            const device_type : CEC_DEVICE_TYPE_T;
                            last_device : bool) : integer; cdecl; external libvchostif name 'vc_cec_add_device';
function vc_cec_set_passive (enabled : bool) : integer; cdecl; external libvchostif name 'vc_cec_set_passive';
function vc_cec_send_FeatureAbort (follower : LongWord;
                                   opcode : byte;
                                   reason : byte) : integer; cdecl; external libvchostif name 'vc_cec_send_FeatureAbort';
function vc_cec_send_ActiveSource (physical_address : Word; is_reply : bool) : integer; cdecl; external libvchostif name 'vc_cec_send_ActiveSource';
function vc_cec_send_ImageViewOn (follower : LongWord; is_reply : bool) : integer; cdecl; external libvchostif name 'vc_cec_send_ImageViewOn';
function vc_cec_send_SetOSDString (follower : LongWord;
                                   disp_ctrl : CEC_DISPLAY_CONTROL_T;
                                   const string_ : PChar;
                                   is_reply : bool) : integer; cdecl; external libvchostif name 'vc_cec_send_SetOSDString';
function vc_cec_send_Standby (follower : Longword; is_reply : bool) : integer; cdecl; external libvchostif name 'vc_cec_send_Standby';
function vc_cec_send_MenuStatus (follower : LongWord;
                                 menu_state : byte;
                                 is_reply : bool) : integer; cdecl; external libvchostif name 'vc_cec_send_MenuStatus';
function vc_cec_send_ReportPhysicalAddress (physical_address : word;
                                            device_type : CEC_DEVICE_TYPE_T;
                                            is_reply : bool) : integer; cdecl; external libvchostif name 'vc_cec_send_ReportPhysicalAddress';

// helpers
function SendCECMessage (i, f, msg : byte) : boolean;
function LogAddrToString (addr : byte) : string;
function PhysAddrToString (addr : Word) : string;
function DevTypeToString (dev : byte) : string;
function CECErrToString (err : integer) : string;
function ReasonToString (r : Word) : string;
function OpcodeToString (op : byte) : string;

implementation

function SendCECMessage (i, f, msg : byte) : boolean;
var
  m : TVC_CEC_MESSAGE;
begin
  m.initiator := i;
  m.follower := f;
  m.len := 1;            // command has 1 byte
  m.payload[0] := msg;
  result := vc_cec_send_message2 (m) = VC_CEC_SUCCESS ;
end;

function LogAddrToString (addr : byte) : string;
begin
  case addr of
    CEC_AllDevices_eTV           : Result := 'TV Only';
    CEC_AllDevices_eRec1         : Result := '1st Recording Device';
    CEC_AllDevices_eRec2         : Result := '2nd Recording Device';
    CEC_AllDevices_eSTB1         : Result := '1st SetTop Box Device';
    CEC_AllDevices_eDVD1         : Result := '1st DVD Device';
    CEC_AllDevices_eAudioSystem  : Result := 'Audio Device';
    CEC_AllDevices_eSTB2         : Result := '2nd SetTop Box Device';
    CEC_AllDevices_eSTB3         : Result := '3rd SetTop Box Device';
    CEC_AllDevices_eDVD2         : Result := '2nd DVD Device';
    CEC_AllDevices_eRec3         : Result := '3rd Recording Device';
    CEC_AllDevices_eSTB4         : Result := '4th Tuner Device';
    CEC_AllDevices_eDVD3         : Result := '3rd DVD Device';
    CEC_AllDevices_eRsvd3        : Result := 'Reserved3';
    CEC_AllDevices_eRsvd4        : Result := 'Reserved4';
    CEC_AllDevices_eFreeUse      : Result := 'Free Address';
    CEC_AllDevices_eUnRegistered : Result := 'UnRegistered';
    else                           Result := 'Unknown (' + addr.ToString + ')';
    end;
end;

function PhysAddrToString (addr : Word) : string;
var
  h, l : byte;
begin
  l := Lo (addr);
  h := Hi (addr);
  Result := format ('%x.%x.%x.%x', [h div $10, h mod $10, l div $10, l mod $10]);
end;

function DevTypeToString (dev : byte) : string;
begin
  case dev of
    CEC_DeviceType_TV       : Result := 'TV only';
    CEC_DeviceType_Rec      : Result := 'Recording device';
    CEC_DeviceType_Reserved : Result := 'Reserved';
    CEC_DeviceType_Tuner    : Result := 'STB';
    CEC_DeviceType_Playback : Result := 'DVD player';
    CEC_DeviceType_Audio    : Result := 'AV receiver';
    CEC_DeviceType_Switch   : Result := 'CEC switch';
    CEC_DeviceType_VidProc  : Result := 'Video processor';
    CEC_DeviceType_Invalid  : Result := 'RESERVED - DO NOT USE';
    else                      Result := 'Unknown (' + dev.ToString + ')';
    end;
end;

function CECErrToString (err : integer) : string;
begin
  case err of
    VC_CEC_SUCCESS                : Result := 'OK';
    VC_CEC_ERROR_NO_ACK           : Result := 'No acknowledgement';
    VC_CEC_ERROR_SHUTDOWN         : Result := 'In the process of shutting down';
    VC_CEC_ERROR_BUSY             : Result := 'block is busy';
    VC_CEC_ERROR_NO_LA            : Result := 'No logical address';
    VC_CEC_ERROR_NO_PA            : Result := 'No physical address';
    VC_CEC_ERROR_NO_TOPO          : Result := 'No topology';
    VC_CEC_ERROR_INVALID_FOLLOWER : Result := 'Invalid follower';
    VC_CEC_ERROR_INVALID_ARGUMENT : Result := 'Invalid arguments';
    else                            Result := 'Unknown (' + err.ToString + ')';
    end;
end;

function ReasonToString (r : Word) : string;
begin
  case r of
    VC_CEC_NOTIFY_NONE       : Result := 'Reserved - NOT TO BE USED ';
    VC_CEC_TX                : Result := 'A message has been transmitted';
    VC_CEC_RX                : Result := 'A message has arrived';
    VC_CEC_BUTTON_PRESSED    : Result := 'User Control Pressed';
    VC_CEC_BUTTON_RELEASE    : Result := 'User Control Release';
    VC_CEC_REMOTE_PRESSED    : Result := 'Vendor Remote Button Down';
    VC_CEC_REMOTE_RELEASE    : Result := 'Vendor Remote Button Up';
    VC_CEC_LOGICAL_ADDR      : Result := 'New logical address allocated or released';
    VC_CEC_TOPOLOGY          : Result := 'Topology is available';
    VC_CEC_LOGICAL_ADDR_LOST : Result := 'Logical address lost';
    else                       Result := 'Unknown (' + r.ToHexString (8) + ')';
    end;
end;

function OpcodeToString (op : byte) : string;
begin
  case op of
    CEC_Opcode_FeatureAbort 	             : Result := 'Feature Abort';
    CEC_Opcode_ImageViewOn 	               : Result := 'Image View On';
    CEC_Opcode_TunerStepIncrement    	     : Result := 'Tuner Step Increment';
    CEC_Opcode_TunerStepDecrement    	     : Result := 'Tuner Step Decrement';
    CEC_Opcode_TunerDeviceStatus 	         : Result := 'Tuner Device Status';
    CEC_Opcode_GiveTunerDeviceStatus 	     : Result := 'Give TunerDevice Status';
    CEC_Opcode_RecordOn 	                 : Result := 'Record On';
    CEC_Opcode_RecordStatus 	             : Result := 'Record Status';
    CEC_Opcode_RecordOff 	                 : Result := 'Record Off';
    CEC_Opcode_TextViewOn 	               : Result := 'Text View On';
    CEC_Opcode_RecordTVScreen              : Result := 'Record TV Screen';
    CEC_Opcode_GiveDeckStatus        	     : Result := 'Give Deck Status';
    CEC_Opcode_DeckStatus 	               : Result := 'Deck Status';
    CEC_Opcode_SetMenuLanguage             : Result := 'Set Menu Language';
    CEC_Opcode_ClearAnalogTimer            : Result := 'Clear Analog Timer';
    CEC_Opcode_SetAnalogTimer              : Result := 'Set Analog Timer';
    CEC_Opcode_TimerStatus                 : Result := 'Timer Status';
    CEC_Opcode_Standby 	                   : Result := 'Standby';
    CEC_Opcode_Play                  	     : Result := 'Play';
    CEC_Opcode_DeckControl 	               : Result := 'DeckControl';
    CEC_Opcode_TimerClearedStatus          : Result := 'Timer Cleared Status';
    CEC_Opcode_UserControlPressed 	       : Result := 'User Control Pressed';
    CEC_Opcode_UserControlReleased 	       : Result := 'User Control Released';
    CEC_Opcode_GiveOSDName           	     : Result := 'Give OSD Name';
    CEC_Opcode_SetOSDName 	               : Result := 'Set OSD Name';
    CEC_Opcode_SetOSDString 	             : Result := 'Set OSD String';
    CEC_Opcode_SetTimerProgramTitle        : Result := 'Set Timer Program Title';
    CEC_Opcode_SystemAudioModeRequest      : Result := 'System Audio Mode Request';
    CEC_Opcode_GiveAudioStatus             : Result := 'Give Audio Status';
    CEC_Opcode_SetSystemAudioMode          : Result := 'Set System Audio Mode';
    CEC_Opcode_ReportAudioStatus           : Result := 'Report Audio Status';
    CEC_Opcode_GiveSystemAudioModeStatus   : Result := 'Give System Audio Mode Status';
    CEC_Opcode_SystemAudioModeStatus       : Result := 'System Audio Mode Status';
    CEC_Opcode_RoutingChange 	             : Result := 'Routing Change';
    CEC_Opcode_RoutingInformation 	       : Result := 'Routing Information';
    CEC_Opcode_ActiveSource 	             : Result := 'Active Source';
    CEC_Opcode_GivePhysicalAddress         : Result := 'Give Physical Address';
    CEC_Opcode_ReportPhysicalAddress       : Result := 'Report Physical Address';
    CEC_Opcode_RequestActiveSource 	       : Result := 'Request Active Source';
    CEC_Opcode_SetStreamPath 	             : Result := 'Set Stream Path';
    CEC_Opcode_DeviceVendorID 	           : Result := 'Device Vendor ID';
    CEC_Opcode_VendorCommand         	     : Result := 'Vendor Command';
    CEC_Opcode_VendorRemoteButtonDown 	   : Result := 'Vendor Remote Button Down';
    CEC_Opcode_VendorRemoteButtonUp    	   : Result := 'Vendor Remote Button Up';
    CEC_Opcode_GiveDeviceVendorID    	     : Result := 'Give Device Vendor ID';
    CEC_Opcode_MenuRequest 	               : Result := 'Menu Request';
    CEC_Opcode_MenuStatus 	               : Result := 'Menu Status';
    CEC_Opcode_GiveDevicePowerStatus 	     : Result := 'Give Device Power Status';
    CEC_Opcode_ReportPowerStatus 	         : Result := 'Report Power Status';
    CEC_Opcode_GetMenuLanguage             : Result := 'Get Menu Language';
    CEC_Opcode_SelectAnalogService         : Result := 'Select Analog Service';
    CEC_Opcode_SelectDigitalService   	   : Result := 'Select Digital Service';
    CEC_Opcode_SetDigitalTimer             : Result := 'Set Digital Timer';
    CEC_Opcode_ClearDigitalTimer           : Result := 'Clear Digital Timer';
    CEC_Opcode_SetAudioRate                : Result := 'Set Audio Rate';
    CEC_Opcode_InactiveSource        	     : Result := 'Inactive Source';
    CEC_Opcode_CECVersion                  : Result := 'CEC Version';
    CEC_Opcode_GetCECVersion               : Result := 'Get CEC Version';
    CEC_Opcode_VendorCommandWithID         : Result := 'Vendor Command With ID';
    CEC_Opcode_ClearExternalTimer          : Result := 'Clear External Timer';
    CEC_Opcode_SetExternalTimer            : Result := 'Set External Timer';
    CEC_Opcode_ReportShortAudioDescriptor  : Result := 'Report Short Audio Descriptor';
    CEC_Opcode_RequestShortAudioDescriptor : Result := 'Request Short Audio Descriptor';
    CEC_Opcode_InitARC                     : Result := 'Init ARC';
    CEC_Opcode_ReportARCInited             : Result := 'Report ARC Inited';
    CEC_Opcode_ReportARCTerminated         : Result := 'Report ARC Terminated';
    CEC_Opcode_RequestARCInit              : Result := 'Request ARC Init';
    CEC_Opcode_RequestARCTermination       : Result := 'Request ARC Termination';
    CEC_Opcode_TerminateARC                : Result := 'Terminate ARC';
    CEC_Opcode_CDC                         : Result := 'CDC';
    CEC_Opcode_Abort        	             : Result := 'Abort';
    else                                     Result := 'Unknown (' + op.ToHexString (2) + ')';
    end;
end;

initialization

end.

