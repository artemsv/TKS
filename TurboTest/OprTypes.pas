unit OprTypes;

interface

uses WIndows;

const OtchetFile='report.dat';BackColor=$C4D3D8;

type
  TCharArr=array[0..255] of char;
  
  RPerson=record
    name:string[20];
    date:string[8];
    gruppa:string[7];
    kTem:byte;
    oc:byte;
    prav:byte;
  end;

  PInfo=^RInfo;
  RInfo=record
    date:string;
    gr:string;
    kGr:byte;
    fnt:string;
    tema:string;
    teacher:string;
    colVopr:integer;
    tim:integer;
    j5,j4,j3:byte;
    eraseOtchetFile:boolean;

    canList:boolean;                            //  запрет листания
    showOC:boolean;                             //  показывать еценку
    colorBack:COLORREF;                         //  цвет фона
    addToOtchetFile:boolean;                    //  добавлять резальтат в ~~
    
  end;

implementation

end.
