program CECTest;

{$mode objfpc}{$H+}
{$define use_tftp}
uses
  RaspberryPi3,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  SysUtils,
  Classes,
  Ultibo, Console,
{$ifdef use_tftp}
  uTFTP, Winsock2,
{$endif}
  VC4, VC4CEC
  { Add additional units here };

var
  Console1 : TWindowHandle;
{$ifdef use_tftp}
  IPAddress : string;
{$endif}
  Top : VC_CEC_TOPOLOGY_T;
  res : integer;
  ch : char;
  i : integer;
  la : byte;    // local address
  pa : word;    // physical address
  s : string;
  cecmsg : TVC_CEC_MESSAGE;

const
  MY_VENDOR_ID = $0102;

procedure Log (s : string);
begin
  ConsoleWindowWriteLn (Console1, s);
end;

procedure Msg (Sender : TObject; s : string);
begin
  Log ('TFTP : ' + s);
end;

{$ifdef use_tftp}
function WaitForIPComplete : string;
var
  TCP : TWinsock2TCPClient;
begin
  TCP := TWinsock2TCPClient.Create;
  Result := TCP.LocalAddress;
  if (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') then
    begin
      while (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') do
        begin
          sleep (1000);
          Result := TCP.LocalAddress;
        end;
    end;
  TCP.Free;
end;
{$endif}

procedure WaitForSDDrive;
begin
  while not DirectoryExists ('C:\') do sleep (500);
end;

procedure CECCallback (Data : pointer; Reason, Param1, Param2, Param3, Param4 : LongWord); cdecl;
var
  RxMsg, TxMsg : TVC_CEC_MESSAGE;
  res : integer;
begin
  if Data = nil then begin end; // prevent not used warning
  Log (ReasonToString (Reason and $ffff));
 // Log (format ('Params %.8x %.8x %.8x %.8x', [Param1, Param2, Param3, Param4]));
  case Reason and $ffff of
    VC_CEC_TX :
      begin
        RxMsg.len := 0;
        res := vc_cec_param2message (Reason, Param1, Param2, Param3, Param4, RxMsg);
        if res = VC_CEC_SUCCESS then
          begin
            s := 'Initiator : (' + RxMsg.initiator.ToHexString(1) + ')-' + LogAddrToString(RxMsg.initiator) +
                 ', Follower : (' + RxMsg.follower.ToHexString(1) + ')-' + LogAddrToString(RxMsg.follower);
            if RxMsg.len > 0 then s := s + ', OpCode : ' + OpCodeToString (RxMsg.payload[0]);
            if RxMsg.len > 1 then
              begin
                s := s + ', Playload :';
                for i := 1 to RxMsg.len - 1 do s := s + ' ' + RxMsg.payload[i].ToHexString (2);
              end;
            Log (s);
          end
        else
          Log ('Invalid message ' + CECErrToString (res));
      end;
    VC_CEC_RX :
      begin
        RxMsg.len := 0;
        res := vc_cec_param2message (Reason, Param1, Param2, Param3, Param4, RxMsg);
        if res = VC_CEC_SUCCESS then
          begin
            s := 'Initiator : (' + RxMsg.initiator.ToHexString(1) + ')-' + LogAddrToString(RxMsg.initiator) +
                 ', Follower : (' + RxMsg.follower.ToHexString(1) + ')-' + LogAddrToString(RxMsg.follower);
            if RxMsg.len > 0 then s := s + ', OpCode : ' + OpCodeToString (RxMsg.payload[0]);
            if RxMsg.len > 1 then
              begin
                s := s + ', Playload :';
                for i := 1 to RxMsg.len - 1 do s := s + ' ' + RxMsg.payload[i].ToHexString (2);
              end;
            Log (s);
            Log ('Payload length ' + RxMsg.len.ToString);
            case RxMsg.payload[0] of
              CEC_Opcode_CECVersion :
                if RxMsg.len = 2 then
                  case RxMsg.payload[1] of
                    $00 : Log ('Version 1.1');
                    $01 : Log ('Version 1.2');
                    $02 : Log ('Version 1.2a');
                    $03 : Log ('Version 1.3');
                    $04 : Log ('Version 1.3a');
                    else  Log ('Unknown Version ' + RxMsg.payload[1].ToString);
                  end;
              CEC_Opcode_SetMenuLanguage :
                begin
                  s := '';
                  for i := 1 to RxMsg.len - 1 do s := s + char (RxMsg.payload[i]);
                  Log ('Set Menu Language ' + s);
                end;
              CEC_Opcode_DeviceVendorID :
                begin

                end;
              CEC_Opcode_GiveDeviceVendorID :
                begin

                end;
              CEC_Opcode_GivePhysicalAddress :
                begin
                  if RxMsg.follower = la then   // is me so respond
                    begin
                      TxMsg.initiator := la;
                      TxMsg.follower := RxMsg.initiator;
                      TxMsg.len := 3;
                      TxMsg.payload[0] := CEC_Opcode_ReportPhysicalAddress;
                      TxMsg.payload[1] := hi (pa);
                      TxMsg.payload[2] := low (pa);
                      vc_cec_send_message2 (TxMsg);
                    end;
                end;
              CEC_Opcode_ReportPowerStatus :
                begin
                  if RxMsg.len = 2 then
                    case RxMsg.payload[1] of
                      $00 : Log ('Device in ON');
                      $01 : Log ('Device is in STANDBY');
                      $02 : Log ('Device is in transistion from STANDBY to ON');
                      $03 : Log ('Device is in transistion from ON to STANDBY');
                      else  Log ('Unknown Device Status ' + RxMsg.payload[1].ToHexString (2));
                    end;
                end;
              end; // case
          end
        else
          Log ('Invalid message ' + CECErrToString (res));
      end;
    VC_CEC_BUTTON_PRESSED : ;
    VC_CEC_BUTTON_RELEASE : ;
    VC_CEC_REMOTE_PRESSED : ;
    VC_CEC_REMOTE_RELEASE : ;
    VC_CEC_LOGICAL_ADDR : ;
    VC_CEC_TOPOLOGY : ;
    VC_CEC_LOGICAL_ADDR_LOST : ;
    end;
  Log ('');
end;

begin
  Console1 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_FULLSCREEN, true);
  WaitForSDDrive;
  Log ('CEC Test');
{$ifdef use_tftp}
  IPAddress := WaitForIPComplete;
  Log ('TFTP : Usage tftp -i ' + IPAddress + ' put kernel7.img');
  SetOnMsg (@Msg);
  Log ('');
{$endif}
  ch := #0;
  Top.num_devices := 0;
  BCMHostInit;
  vc_cec_set_passive (true);
  vc_cec_register_callback (@CECCallback,  nil);
  vc_cec_register_all;
  vc_cec_set_vendor_id (MY_VENDOR_ID);
  la := 0;
  pa := 0;
  vc_cec_get_logical_address (la);
  vc_cec_get_physical_address (pa);
  Log ('I am (' + la.ToHexString (1) + ')-' + LogAddrToString (la) + ' at ' + PhysAddrToString (pa));
  SendCECMessage ($f, 0, CEC_Opcode_GetCECVersion);
  while true do
    begin
      if ConsoleGetKey (ch, nil) then
        case (UpperCase (ch)) of
          '1' :
            begin
              FillChar (Top, SizeOf (Top), 0);
              res := vc_cec_get_topology (Top);
              Log ('Topology - Result ' + CECErrToString (res));
              Log ('Num Devices ' + Top.num_devices.ToString);
              for i := 0 to Top.num_devices - 1 do
                begin
                  Log ('Device ' + i.ToString);
                  Log ('  Logical Address          : ' + LogAddrToString (Top.device_attr[i] and $0f));
                  Log ('  Device Type              : ' + DevTypeToString ((Top.device_attr[i] shr 4) and $0f));
                  Log ('  Index to upstream device : ' + IntToStr ((Top.device_attr[i] shr 8) and $0f));
                  Log ('  No. downstream devices   : ' + IntToStr ((Top.device_attr[i] shr 12) and $0f));
                end;
            end;
          '4' :   // this currently doesn't work
            begin
              cecmsg.initiator := $1;     // me
              cecmsg.follower := 0;       // tv
              cecmsg.len := 3;            // command has 3 bytes
              cecmsg.payload[0] := CEC_Opcode_ActiveSource;
              cecmsg.payload[1] := $10;
              cecmsg.payload[2] := $00;
              res := vc_cec_send_message2 (cecmsg);
              log ('Send Message - Result ' + CECErrToString (res));
            end;
            '5' :   // this currently doesn't work
            begin
              cecmsg.initiator := $1;     // me
              cecmsg.follower := 0;       // tv
              cecmsg.len := 3;            // command has 3 bytes
              cecmsg.payload[0] := CEC_Opcode_ActiveSource;
              cecmsg.payload[1] := $20;
              cecmsg.payload[2] := $00;
              res := vc_cec_send_message2 (cecmsg);
              log ('Send Message - Result ' + CECErrToString (res));
            end;

          '6' :
            begin
              res := vc_cec_send_Standby ($f, true);  // send all to standby
              Log ('All standby - Result ' + CECErrToString (res));
            end;
          '7' :
            begin
              for i := CEC_AllDevices_eTV to CEC_AllDevices_eUnRegistered do
                begin
                  res := vc_cec_poll_address (i);
                  Log (LogAddrToString (i) + ' - Result ' + CECErrToString (res));
                  sleep (500);
                end;
            end;
          '8' :   // this currently doesn't work
            begin
              cecmsg.initiator := $1;     // me
              cecmsg.follower := 0;       // tv
              cecmsg.len := 3;            // command has 3 bytes
              cecmsg.payload[0] := CEC_Opcode_ActiveSource;
              cecmsg.payload[1] := $00;
              cecmsg.payload[2] := $00;
              res := vc_cec_send_message2 (cecmsg);
              log ('Send Message - Result ' + CECErrToString (res));
            end;
          '9' : SendCECMessage ($f, 0, CEC_Opcode_Standby);
          '0' : SendCECMessage ($f, 0, CEC_Opcode_ImageViewOn);
          'S' :
            begin
              Res := vc_cec_set_vendor_id ($1234);
              Log ('Set Vendor ID - Result ' + CECErrToString (res));
            end;

          'V' : SendCECMessage ($f, 0, CEC_Opcode_GetCECVersion);
          'R' : SendCECMessage ($f, 0, CEC_Opcode_RequestActiveSource);
          'Q' : SendCECMessage ($f, 0, CEC_Opcode_GiveOSDName);
          'M' : SendCECMessage ($f, 0, CEC_Opcode_GetMenuLanguage);
          'P' : SendCECMessage ($f, 0, CEC_Opcode_GiveDevicePowerStatus);
          'C' : ConsoleWindowClear (Console1);
          'Z' :
            begin
              cecmsg.initiator := $1;     // me
              cecmsg.follower := 0;       // tv
              cecmsg.len := 3;            // command has 3 bytes
              cecmsg.payload[0] := CEC_Opcode_SetOSDString;
              cecmsg.payload[1] := ord ('h');
              cecmsg.payload[2] := ord ('i');
              res := vc_cec_send_message2 (cecmsg);
              log ('Send Message - Result ' + CECErrToString (res));
            end;
          'I' :
            begin
              cecmsg.initiator := $f;     // me
              cecmsg.follower := 0;       // tv
              cecmsg.len := 2;            // command has 2 bytes
              cecmsg.payload[0] := CEC_Opcode_UserControlPressed;
              cecmsg.payload[1] := CEC_User_Control_InputSelect;
              cecmsg.payload[2] := 1;
              res := vc_cec_send_message2 (cecmsg);
              log ('Send Message - Result ' + CECErrToString (res));
            end;

           ';' :
            begin
              cecmsg.initiator := $f;     // me
              cecmsg.follower := 0;       // tv
              cecmsg.len := 2;            // command has 2 bytes
              cecmsg.payload[0] := CEC_Opcode_UserControlPressed;
              cecmsg.payload[1] := CEC_User_Control_VolumeDown;
              cecmsg.payload[2] := 1;
              res := vc_cec_send_message2 (cecmsg);
              log ('Send Message - Result ' + CECErrToString (res));
            end;
          '''' :
            begin
              cecmsg.initiator := $f;     // me
              cecmsg.follower := 0;       // tv
              cecmsg.len := 2;            // command has 2 bytes
              cecmsg.payload[0] := CEC_Opcode_UserControlReleased;
              cecmsg.payload[1] := CEC_User_Control_VolumeDown;
              cecmsg.payload[2] := 1;
              res := vc_cec_send_message2 (cecmsg);
              log ('Send Message - Result ' + CECErrToString (res));
            end;
          'B' :
            begin
              cecmsg.initiator := $f;     // me
              cecmsg.follower := 0;       // tv
              cecmsg.len := 3;            // command has 3 bytes
              cecmsg.payload[0] := CEC_Opcode_SetStreamPath;
              cecmsg.payload[1] := $10;
              cecmsg.payload[2] := $00;
              res := vc_cec_send_message2 (cecmsg);
              log ('Send Message - Result ' + CECErrToString (res));
            end;
          'N' :
            begin
              cecmsg.initiator := $f;     // me
              cecmsg.follower := 0;       // tv
              cecmsg.len := 3;            // command has 3 bytes
              cecmsg.payload[0] := CEC_Opcode_SetStreamPath;
              cecmsg.payload[1] := $20;
              cecmsg.payload[2] := $00;
              res := vc_cec_send_message2 (cecmsg);
              log ('Send Message - Result ' + CECErrToString (res));
            end;
         end;
    end;
  ThreadHalt (0);
end.

