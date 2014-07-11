unit MPicture;                 {Є т  сЎЇЄ ­Јя ЌЎЄуЋя: 25.10.01}

interface

uses Dialogs,Objects,Views,Drivers,MyLib;

type
  PPicture=^TPicture;
  TPicture=object(TDialog)
    constructor Init;
    procedure HandleEvent(var Event:TEvent);virtual;
  end;

implementation

const
  mNstr:array[1..7]of string=
  ('  лллллллл    лллллл    ллллллл    лллллллл  ',
  '      лл       лл        лл   пп       лл      ',
  '      лл       лл        лл            лл      ',
  '      лл       ллллл     лл            лл      ',
  '      лл       лл        лл            лл      ',
  '      лл       лл        лл   мм       лл      ',
  '      лл       лллллл    ллллллл       лл      ');

constructor TPicture.Init;
var
  R:TRect;
  st1,st2:string;
begin
  R.Assign(5,4,75,20);
  inherited Init(R,'');
  st1:='Turbo Test Version 4.34';
  st2:='Copyright (c) 1999,2001 by Sokol International,Inc ';
  R.Assign(13, 2, Size.X - 2,3);
  Insert(New(PStaticText, Init(R,mNstr[1])));
  R.Assign(12, 3, Size.X - 2, 4);
  Insert(New(PStaticText, Init(R,mNstr[2])));
  R.Assign(12, 4, Size.X - 2, 5);
  Insert(New(PStaticText, Init(R,mNstr[3])));
  R.Assign(12, 5, Size.X - 2, 6);
  Insert(New(PStaticText, Init(R,mNstr[4])));
  R.Assign(12, 6, Size.X - 2, 7);
  Insert(New(PStaticText, Init(R,mNstr[5])));
  R.Assign(12, 7, Size.X - 2, 8);
  Insert(New(PStaticText, Init(R,mNstr[6])));
  R.Assign(12, 8, Size.X - 2, 9);
  Insert(New(PStaticText, Init(R,mNstr[7])));
  R.Assign(24, 12, Size.X - 2, 13);
  Insert(New(PStaticText, Init(R,st1)));
  R.Assign(12, 14, Size.X - 2, 15);
  Insert(New(PStaticText, Init(R,st2)));
end;

procedure TPicture.HandleEvent;
begin
  if Event.What=evKeyDown then
    case Event.KeyCode of
      kbEsc:EndModal(cmDefault);
      kbCtrlEnter:EndModal(cmOk);
      kbF10:EndModal(cmCancel);
    end;
end;
end.