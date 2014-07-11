unit MConsts;                     //  Дата создания: Июнь 2002
interface
const                   //  сообщения,посылаемые объектам TDrawObject

  DOM_KEY               =       $0001;
  DOM_CHAR              =       $0002;
  DOM_HIDECARET         =       $0003;
  DOM_LDOWN             =       $0005;
  DOM_RDOWN             =       $0006;
  DOM_COLOR             =       $0007;
  DOM_SETFONT           =       $0008;  // контейнер-своим объектам
  // на входе-???шрифта;на выходе:сдвиг
  DOM_SCROLL            =       $0009;
  DOM_SETFOCUS          =       $000A;
  DOM_KILLFOCUS         =       $000B;
  DOM_GETDC             =       $000C;
  DOM_GETDX             =       $000D;  // линия-объекту:получить длину DX
  DOM_DRAW              =       $000E;  // Param - Divice Context
  DOM_CLEAR             =       $000F;  // Param - Divice Context
  DOM_SHOWCARET         =       $0010;
  DOM_SETPARENT         =       $0011;
  DOM_HOMEEND           =       $0012;
  DOM_XX                =       $0013;     //  создать и показать каретку
  DOM_CREATECARET       =       $0014;     //  показать спрятанную каретку
  DOM_BLOCK             =       $0015;
  DOM_AFTERBLOCK        =       $0016;

  DOM_ENTER             =       $0017;     // 1.блок-линии: Param-указатель
  //  на новую линию;от текущей линии требуется заполнить новую линию
  //  отрезаемыми объектами.2-линия объекту :возвращается указатель на
  //  структуру REnter,характеризующую возможно отрезаемую подстроку

  DOM_UPDOWN            =       $0018;
  DOM_UPDATEPOS         =       $0019;
  DOM_SETXY             =       $001A;
  DOM_GETXY             =       $001B;
  DOM_NEWANSWER         =       $001C;
  DOM_XXXXXXX           =       $001D;
  DOM_ACTIVATE          =       $001E;//Param - двойное слово: в старшем
  //  слове - DC, в младшем слове: в трех младших байтах - координата Х,
  //  в старшем байте - направление

  DOM_XXXXXXXXXXXXXXXX  =       $001F;
  DOM_NEWBMP            =       $0020;
  DOM_NEWFRAME          =       $0021;
  DOM_ALLCLEAR          =       $0022;
  DOM_SETD              =       $0023;
  DOM_SETNUMS           =       $0024;
  DOM_MISHMACH          =       $0025;
  DOM_CLICKNUMBER       =       $0026;  //от TNumber(по нему кликнули):
  DOM_CHANGEY           =       $0027;  // integer(Param) - разница
  DOM_ENDY              =       $0028;
  DOM_BACK              =       $0029;
  DOM_GETLINE           =       $002A;
  DOM_DELETE            =       $002B;
  DOM_GETH              =       $002C;
  DOM_LR                =       $002D;
  DOM_WHOAREYOU         =       $002E;
  DOM_CTRLDEL           =       $002F;
  DOM_MOUSEMOVE         =       $0030;
  DOM_RESTORE           =       $0031; //   восстановить старые коорд. FY
  DOM_SETBACKCOLOR      =       $0032; //  при перемене фона-перерисовать
  DOM_XXXXXX            =       $0033;
  DOM_CREATEBITMAP      =       $0034;
  DOM_MOUSEUP           =       $0035;
  DOM_MACRO             =       $0036;
  DOM_CREATEECUAT       =       $0037;
  DOM_DRAWALL           =       $0038;
  DOM_CREATEBMP         =       $0039;

  DOM_ACTIVATENEXT      =       $003A;//  TConteiner посылает хозяину -
  //  активизировать,если можно следующий подобный контейнер
  //  Param - двойное слово: в старшем слове - DC, в младшем слове:
  //  в трех младших байтах - координата Х,в старшем байте - направление

  DOM_MYDYNEW           =       $003B;
  DOM_CHANGEX           =       $003C;  // integer(Param) - разница
  DOM_GETLINY           =       $003D;  // линия возвр.свое поле FY
  DOM_SHL               =       $003E;  // сдвиг объекта влево
  DOM_MYDXNEW           =       $003F;  // от объекта-изменилась его DX
  DOM_SHR               =       $0040;  // сдвиг объекта вправо

  DOM_CONCAT            =       $0041;  // блок - линии;Param - указатель
  //  на пристыкуемую линию(нижнию);Возврат:старшее слово - величина,на
  //  которую блоку  нужно сдвинуть вверх нижние линии
  //  младшее- возможный сдвиг вниз текущей линии(отрицат.величина)

  DOM_SETY              =       $0042;  // блок -линиии:установить новое
  //  поле FY(линии и ее объектов)

  DOM_DELOBJECT         =       $0043;  //

  DCM_UPDOWN            =       $DD00;
  DCM_FONT              =       $DD01;
  DCM_COLOR             =       $DD02;

  DM_OK                 =       $0000;
  DM_NEXT               =       $0001;
  DM_MERGE              =       $0002;
  DM_DELME              =       $0003;

  I_AM_QUESTION         =       $CC00;
  I_AM_ANSWER           =       $CC01;
  I_AM_SPLITTER         =       $CC02;
  I_AM_PLAINLINE        =       $CC03;
  I_AM_PLAINALINE       =       $CC04;
  I_AM_NUMLINE          =       $CC05;
  I_AM_PICTURE          =       $CC06;
  I_AM_STRING           =       $CC07;
  I_AM_NUMBER           =       $CC08;

  SF_POSITION           =       $FFF;
  SF_AFTER_FIRST        =       $FFE;
  SF_BEFORE_LAST        =       $FED;
  SF_IGNORE_COORD       =       $FFC;
  SF_BEGIN              =       $FFB;
  SF_END                =       $FFA;

  OLD_POSITION          =       $EEEE;

  POS_END               =       $FF88;
  POS_CUR               =       $FF89;
  POS_BEG               =       $FF8A;

  FROM_LOW              =       $FFEE;

  WM_TOOLW              =       $0400+120;  // WM_USER

const
  maxLineChar   =       100;
  maxNumVoprs   =       256;

const
  CM_NEW        =       1;
  CM_OLD        =       2;
  CM_RED	=	3;  
  CM_FONT    	= 	4;
  CM_REDO       =       5;
  CM_UNDO       =       6;
  CM_PRINT      =       7;
  CM_COLOR   	= 	8;
  CM_UP         =       9;
  CM_DOWN       =       10;
  CM_MACRO      =       11;
  CM_ECUAT      =       12;
  CM_BMP        =	13;

  CM_EXIT    	= 	103;
  CM_ABOUT 	= 	105;
  CM_HELP       =       27;
  CM_TILE       =       28;
  CM_CASCADE    =       29;
  CM_OPTIONS	=	30;

  CPO_ECUAT             =       CM_ECUAT+$100;
  CPO_BMP               =       CM_BMP+$100;

  CM_PIC_DEL        =     120;
  CM_BMP_PASTE      =     121;
  CM_BMP_SIZE       =     122;

  CM_FRML_CHANGE    =     140;
  CM_FRML_01        =     141;
  CM_FRML_02        =     142;
  CM_FRML_03        =     143;
  CM_FRML_04        =     144;
  CM_FRML_05        =     145;
  CM_FRML_AA        =     147;

implementation

end.
