unit Types;				{версия 2.01 от 21.01.02}

interface

const
  maxVoprsInVar   =  255;           {максим.количество вопросов в варианте}
  maxVoprsInTema  =  255;           {максим.кол-во вопросов по одной теме}
  maxTemInVar     =  maxVoprsInVar; {максим.кол-во вопросов по одной теме}
  maxVarInTema    =  255;           {максим.кол-во вариантов по одной теме}
  maxWrongAnswer  =  18;            {максим.кол-во неправ.ответов в вопросе}
  maxTime         =  300;           {максим.кол-во времени на один вопрос}

const
  path	 :string = '';              {указывает путь к каталогу TEST}

  mfOk   = $402;         {mfOkButton}
  sym    :word=  0;
  syl    :word=  0;
  syn    :word=  0;
  syv    :word=  0;
  sym32  :word=  0;
  syn32  :word=  0;
  symM   :byte=  0;
  synM   :byte=  0;
  syvM   :byte=  0;
const
  cmNew       =   200;
  cmOld       =   201;
  cmHeaderEdit=   202;
  cmShowLast  =   203;
  cmDelVar    =   204;
  cmList      =   205;
  cmBAK       =   206;
  cmShowBuf   =   207;
  cmMyHelp    =   208;
  cmLive      =   209;
  cmFont      =   210;
  cmRed       =   211;
  cmMyClose   =   212;
  cmTemasDat  =   213;
  cmCalk      =   214;
  cmVar       =   215;
  cmXXXXX     =   216;
  cmOpros     =   217;
  cmChangeBAK =   218;
  cmAbout     =   219;
  cmDirTree   =   220;
  cmFilter    =   221;
  cmNewColor  =   222;
  oldX        =   2;
  x1          =   0;
  x2          =   77;
  xE          =   x2-1;
  y1          =   0;
  y2          =   20;

const
  kbCtrlA=7681;
  kbCtrlF=8454;
  kbCtrlW=4375;
  kbCtrlL=9740;
  kbCtrlR=4882;
  kbCtrlQ=4113;
  kbCtrlT=5140;
  kbCtrlY=5401;
  kbSpace=14624;
  kbBlock=21040;

const
  cmPrint  =  230;
  cmForm1  =  231;
  cmForm2  =  232;
  cmForm3  =  233;
  cmForm4  =  234;
  cmEdit   =  306;
  cmBase   =  307;
  cmnature =  308;
  cmCalc   =  309;

type
  TBadStr=array[1..20] of byte;
  TBuffer=array[0..x2] of word;
  TChars=array[0..y2] of TBuffer;               {массив копия экрана}
  PChars=^TChars;
  tmCharDim=array[0..15] of byte;
  tmTableDim=array[0..255] of tmCharDim;

type
  macroKey=set of byte;

const
  macroShift:macroKey=[$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D];
  macroCtrl :macroKey=[$5F,$60,$61,$62,$63,$64,$65,$66,$67];
  macroAlt  :macroKey=[$69,$6A,$6B,$6C,$6D,$6E,$6F,$70,$71];

type
  st3    = string[3];
  st8    = string[8];
  st12   = string[12];
  st15   = string[15];
  st79   = string[79];
  tfc    = file of char;
  tfb    = file of byte;
  tft    = text;
  tmLin  = array[0..x2]of byte;
  pm1    = ^tm1;
  tm1    = array[0..1800] of char;
  pm2    = ^tm2;
  tm2    = array[0..y2,0..x2] of byte;

type
  PHeader=^THeader;
  tHeader=record
    fName:st79;
    tema:st12;
    index:st3;
    kTem:byte;
    colv:byte;
    nn,ckolko,tim:integer;
    j5,j4,j3:byte;
    d:integer;
  end;

type
  pHead=^tHead;
  tHead=record
     tema:st12;
     index:st3;
     kTem:byte;
  end;

  tfh  = file of tHead;

type
  ResultData=record
    date:st8;
    name:st15;
    gruppa:st8;
    kodGr:byte;
    numVar:byte;
    oc:byte;
    ball:byte;
    tema:st12;
    kTem:byte;
    handle:word;
    flag:byte;
    badM:TBadStr;
  end;

  tfr  =  file of ResultData;
  pRD  =  ^Resultdata;

var
  pf   :  pointer;                       {указатель на файловый тип}
  w    :  word;                          {в ней возвращается результат}
                                         {работы окон-функций}
implementation
end.