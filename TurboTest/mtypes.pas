unit MTypes;                           //  Дата создания: Май 2002

interface

uses Messages,Windows;

const
  MSG_CAPTION           =       'Редактор  тестов';
  
type
//  TCharArr=array[0..255] of char;
  
  RPerson=record
    name:string[20];
    date:string[8];
    gruppa:string[7];
    kTem:byte;
    oc:byte;
    prav:byte;
  end;

  RInfo=record
    date:string;
    gr:string;
    kGr:byte;
    fnt:string;
    kolTem:byte;
    tema:string;
    colVopr:integer;
    tim:integer;
    j5,j4,j3:byte;
  end;

  PBuffer=^TBuffer;
  TBuffer=array[0..1000]of char;
  TStr=array [0..79] of char;
  
  TArrs=array[0..23] of integer;
  st8=string[8];
  
  RTem=record
    t:string;
    n:byte;
  end;

  PEnter = ^REnter;      //  характеризует подстроку,передаваемую
  REnter = record        //  родительскому окну при нажатии Enter
    color:COLORREF;
    h:integer;
    y:integer;
    pch:PChar;
    font:HFONT;
  end;

  PHeader = ^Thdr;
  Thdr = record
    nn:byte;
    Ckolko:byte;
    kTem:byte;
    d:byte;
    Tema:PChar;
    fName:PChar;        //  имя файла без расширения
    Comment:PChar;
    DateCreate:PChar;
    DateModified:PChar;
  end;

  PShift = ^RShift;
  RShift = record
    ID:word;
    numLine:word;
    dx:integer;
  end;

  PLDown = ^RLDown;       //  характеризует нажатие левой клавиши мыши
  RLDown = record
    coord:longint;
    obj:pointer;
  end;

  TState = set of (ssShift, ssAlt, ssCtrl,
    ssLeft, ssRight, ssMiddle, ssDouble);

  PKey = ^RKey;
  RKey = record
    WP:DWORD;
    LP:DWORD;
    ST:TState;
  end;

const
  kbBack    =  8;
  kbEnter   =  13;
  kbDel     =  46;
  kbLeft    =  vk_left;
  kbUp      =  vk_up;
  kbDown    =  vk_down;
  kbRight   =  vk_right;
  kbHome    =  vk_home;
  kbEnd     =  vk_end;
  Q:THdr=(nn:9;ckolko:9;kTem:34;d:4;tema:'Новая темафф';fname:'tem.tem';
                                               Comment:'Комментарий');

type
  WArray=array[1..6] of string;

  PArr=^Arr;
  Arr=array[0..10] of integer;

implementation

end.





