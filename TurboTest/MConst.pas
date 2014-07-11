unit MConst;                               //  Дата создания:   01.10.02.

interface

const
  NumTextColor         =                   $FF0067;

  DOM_UPDATECARETPOS   =                   $0EE0;
  DOM_UPDATEINSERTFLAG =                   $0EE1;
  DOM_BLOCK            =                   $0EE2;
  DOM_STATUSINFO       =                   $0EE3;

  DOM_WHOAREYOU        =                   $0EE4;//77877;
  DOM_CANEDITMENU      =                   $0EE5;//60000;
  DOM_CANRTFUNDO       =                   $0EE6;//60001;
  DOM_CANRTFPASTE      =                   $0EE7;//60002;
  DOM_CANEMBED         =                   $0EE8;//60003;

  DOM_CUT	       =		   $0EE9;
  DOM_COPY             =                   DOM_CUT+1;
  DOM_PASTE            =                   DOM_CUT+2;
  DOM_DELETE           =                   DOM_CUT+3;
  DOM_UNDO             =                   DOM_CUT+4;
  DOM_SELECTALL        =                   DOM_CUT+5;
  DOM_ECUAT            =                   DOM_CUT+6;
  DOM_BMP              =                   DOM_CUT+7;
  DOM_REFRESH          =                   DOM_CUT+8;
  DOM_CANSELECTALL     =                   DOM_CUT+9;

  DOM_COPYME           =                   $0EF5;
  DOM_PASTEME          =                   $0EF6;
  

  COLOR_NUM_PASSIVE    =                   $FF0067;
  COLOR_NUM_ACTIVE     =                   $FF;

  maxNumVoprs          =       256;

  CM_NEW                =       1;
  CM_OLD                =       2;
  CM_RED	        =	3;
  CM_FONT              	= 	4;
  CM_UP                 =       5;
  CM_DOWN               =       6;
  CM_MACRO              =       7;
  CM_ECUAT              =       8;
  CM_BMP                =	9;
  CM_REFRESH            =       10;
  CM_EXIT    	        = 	11;
  CM_ABOUT 	        = 	12;

  CM_QADD               =       13;
  CM_QDELETE            =       14;
  CM_QCOPY              =       15;
  CM_QPASTE             =       16;
  CM_PROP               =       17;

  CM_PRINT              =       45;

  CM_STATUSTEXTCLEAR    =   997;
  CM_QUESTION           =       998;

  CM_HELP               =       27;
  CM_TILEH              =       28;
  CM_TILEV              =       29;
  CM_CASCADE            =       30;
  CM_OPTIONS	        =	31;

  ColorDlg              =       $ADD2D5;

  COLOR_LISTNAME_DLG    =       ColorDlg;
  COLOR_LISTNAME_STATIC =       ColorDlg;
  COLOR_INPUT           =       ColorDlg;

  COLOR_NEWTEMA_DLG     =       ColorDlg;

  COLOR_SELTEMA_LST     =       $C3DCC8;
  COLOR_SELTEMA_STATIC  =       ColorDlg;
  COLOR_SELTEMA_DLG     =       ColorDlg;

  COLOR_MACRO_LST       =       $C3DCC8;

implementation

end.
