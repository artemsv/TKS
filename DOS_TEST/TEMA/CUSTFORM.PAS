{ TCustomForm }

constructor TCustomForm.Create(AOwner: TComponent);
begin
  GlobalNameSpace.BeginWrite;
  try
    CreateNew(AOwner);
    if (ClassType <> TForm) and not (csDesigning in ComponentState) then
    begin
      Include(FFormState, fsCreating);
      try
        if not InitInheritedComponent(Self, TForm) then
          raise EResNotFound.CreateFmt(SResNotFound, [ClassName]);
      finally
        Exclude(FFormState, fsCreating);
      end;
      if OldCreateOrder then DoCreate;
    end;
  finally
    GlobalNameSpace.EndWrite;
  end;
end;

procedure TCustomForm.AfterConstruction;
begin
  if not OldCreateOrder then DoCreate;
  if fsActivated in FFormState then
  begin
    Activate;
    Exclude(FFormState, fsActivated);
  end;
end;

constructor TCustomForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csDoubleClicks];
  Left := 0;
  Top := 0;
  Width := 320;
  Height := 240;
  Visible := False;
  ParentColor := False;
  ParentFont := False;
  Ctl3D := True;
  FBorderIcons := [biSystemMenu, biMinimize, biMaximize];
  FBorderStyle := bsSizeable;
  FWindowState := wsNormal;
  FDefaultMonitor := dmActiveForm;
  FIcon := TIcon.Create;
  FIcon.Width := GetSystemMetrics(SM_CXSMICON);
  FIcon.Height := GetSystemMetrics(SM_CYSMICON);
  FIcon.OnChange := IconChanged;
  FInCMParentBiDiModeChanged := False;
  FCanvas := TControlCanvas.Create;
  FCanvas.Control := Self;
  FPixelsPerInch := Screen.PixelsPerInch;
  FPrintScale := poProportional;
  FloatingDockSiteClass := TWinControlClass(ClassType);
  Screen.AddForm(Self);
end;

procedure TCustomForm.BeforeDestruction;
begin
  GlobalNameSpace.BeginWrite;
  Destroying;
  Screen.FSaveFocusedList.Remove(Self);
  RemoveFixupReferences(Self, '');
  if FOleForm <> nil then FOleForm.OnDestroy;
  if FormStyle <> fsMDIChild then Hide;
  if not OldCreateOrder then DoDestroy;
end;

destructor TCustomForm.Destroy;
begin
  if not (csDestroying in ComponentState) then GlobalNameSpace.BeginWrite;
  try
    if OldCreateOrder then DoDestroy;
    MergeMenu(False);
    if HandleAllocated then DestroyWindowHandle;
    Screen.RemoveForm(Self);
    FCanvas.Free;
    FIcon.Free;
    FreeAndNil(FActionLists);
    inherited Destroy;
  finally
    GlobalNameSpace.EndWrite;
  end;
end;

procedure TCustomForm.DoCreate;
begin
  if Assigned(FOnCreate) then
  try
    FOnCreate(Self);
  except
    Application.HandleException(Self);
  end;
  if fsVisible in FFormState then Visible := True;
end;

procedure TCustomForm.DoDestroy;
begin
  if Assigned(FOnDestroy) then
  try
    FOnDestroy(Self);
  except
    Application.HandleException(Self);
  end;
end;

procedure TCustomForm.Loaded;
var
  Control: TWinControl;
begin
  inherited Loaded;
  if ActiveControl <> nil then
  begin
    Control := ActiveControl;
    FActiveControl := nil;
    if Control.CanFocus then SetActiveControl(Control);
  end;
end;

procedure TCustomForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  case Operation of
    opInsert:
      begin
        if AComponent is TCustomActionList then
        begin
          if FActionLists = nil then FActionLists := TList.Create;
          FActionLists.Add(AComponent);
        end
        else if not (csLoading in ComponentState) and (Menu = nil) and
          (AComponent.Owner = Self) and (AComponent is TMainMenu) then
          Menu := TMainMenu(AComponent);
      end;
    opRemove:
      begin
        if (FActionLists <> nil) and (AComponent is TCustomActionList) then
          FActionLists.Remove(AComponent)
        else
        begin
          if Menu = AComponent then Menu := nil;
          if WindowMenu = AComponent then WindowMenu := nil;
          if ObjectMenuItem = AComponent then ObjectMenuItem := nil;
        end;
      end;
  end;
  if FDesigner <> nil then
    FDesigner.Notification(AComponent, Operation);
end;

procedure TCustomForm.ReadState(Reader: TReader);
var
  NewTextHeight: Integer;
  Scaled: Boolean;
begin
  DisableAlign;
  try
    FClientWidth := 0;
    FClientHeight := 0;
    FTextHeight := 0;
    Scaled := False;
    FOldCreateOrder := not ModuleIsCpp;
    inherited ReadState(Reader);
    if (FPixelsPerInch <> 0) and (FTextHeight > 0) then
    begin
      if (sfFont in ScalingFlags) and (FPixelsPerInch <> Screen.PixelsPerInch) then
        Font.Height := MulDiv(Font.Height, Screen.PixelsPerInch, FPixelsPerInch);
      FPixelsPerInch := Screen.PixelsPerInch;
      NewTextHeight := GetTextHeight;
      if FTextHeight <> NewTextHeight then
      begin
        Scaled := True;
        ScaleScrollBars(NewTextHeight, FTextHeight);
        ScaleControls(NewTextHeight, FTextHeight);
        if sfWidth in ScalingFlags then
          FClientWidth := MulDiv(FClientWidth, NewTextHeight, FTextHeight);
        if sfHeight in ScalingFlags then
          FClientHeight := MulDiv(FClientHeight, NewTextHeight, FTextHeight);
      end;
    end;
    if FClientWidth > 0 then inherited ClientWidth := FClientWidth;
    if FClientHeight > 0 then inherited ClientHeight := FClientHeight;
    ScalingFlags := [];
    if not Scaled then
    begin
      { Forces all ScalingFlags to [] }
      ScaleScrollBars(1, 1);
      ScaleControls(1, 1);
    end;
    Perform(CM_PARENTBIDIMODECHANGED, 0, 0);
  finally
    EnableAlign;
  end;
end;

procedure TCustomForm.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('PixelsPerInch', nil, WritePixelsPerInch, not IsControl);
  Filer.DefineProperty('TextHeight', ReadTextHeight, WriteTextHeight, not IsControl);
  Filer.DefineProperty('IgnoreFontProperty', ReadIgnoreFontProperty, nil, False);
end;

procedure TCustomForm.ReadIgnoreFontProperty(Reader: TReader);
begin   // reroute BCB IgnoreFontProperty to use VCL locale font solution
  if Reader.ReadBoolean then
    ParentFont := True;
end;

procedure TCustomForm.ReadTextHeight(Reader: TReader);
begin
  FTextHeight := Reader.ReadInteger;
end;

procedure TCustomForm.WriteTextHeight(Writer: TWriter);
begin
  Writer.WriteInteger(GetTextHeight);
end;

procedure TCustomForm.WritePixelsPerInch(Writer: TWriter);
begin
  Writer.WriteInteger(GetPixelsPerInch);
end;

function TCustomForm.GetTextHeight: Integer;
begin
  Result := Canvas.TextHeight('0');
end;

procedure TCustomForm.BeginAutoDrag;
begin
  { Do nothing }
end;

procedure TCustomForm.ChangeScale(M, D: Integer);
var
  PriorHeight: Integer;
begin
  ScaleScrollBars(M, D);
  ScaleControls(M, D);
  if IsClientSizeStored then
  begin
    PriorHeight := ClientHeight;
    ClientWidth := MulDiv(ClientWidth, M, D);
    ClientHeight := MulDiv(PriorHeight, M, D);
  end;
  Font.Size := MulDiv(Font.Size, M, D);
end;

procedure TCustomForm.IconChanged(Sender: TObject);
begin
  if NewStyleControls then
  begin
    if HandleAllocated and (BorderStyle <> bsDialog) then
      SendMessage(Handle, WM_SETICON, 1, GetIconHandle);
  end else
    if IsIconic(Handle) then Invalidate;
end;

function TCustomForm.IsClientSizeStored: Boolean;
begin
  Result := not IsFormSizeStored;
end;

function TCustomForm.IsFormSizeStored: Boolean;
begin
  Result := AutoScroll or (HorzScrollBar.Range <> 0) or
    (VertScrollBar.Range <> 0);
end;

function TCustomForm.IsAutoScrollStored: Boolean;
begin
  Result := IsForm and
    (AutoScroll <> (BorderStyle in [bsSizeable, bsSizeToolWin]));
end;

procedure TCustomForm.DoClose(var Action: TCloseAction);
begin
  if Assigned(FOnClose) then FOnClose(Self, Action);
end;

procedure TCustomForm.DoHide;
begin
  if Assigned(FOnHide) then FOnHide(Self);
end;

procedure TCustomForm.DoShow;
begin
  if Assigned(FOnShow) then FOnShow(Self);
end;

function TCustomForm.GetClientRect: TRect;
begin
  if IsIconic(Handle) then
  begin
    SetRect(Result, 0, 0, 0, 0);
    AdjustWindowRectEx(Result, GetWindowLong(Handle, GWL_STYLE),
      Menu <> nil, GetWindowLong(Handle, GWL_EXSTYLE));
    SetRect(Result, 0, 0,
      Width - Result.Right + Result.Left,
      Height - Result.Bottom + Result.Top);
  end else
    Result := inherited GetClientRect;
end;

procedure TCustomForm.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
  OwnedComponent: TComponent;
begin
  inherited GetChildren(Proc, Root);
  if Root = Self then
    for I := 0 to ComponentCount - 1 do
    begin
      OwnedComponent := Components[I];
      if not OwnedComponent.HasParent then Proc(OwnedComponent);
    end;
end;

function TCustomForm.GetFloating: Boolean;
begin
  Result := (HostDockSite = nil) and (FloatingDockSiteClass = ClassType);
end;

procedure TCustomForm.SetChildOrder(Child: TComponent; Order: Integer);
var
  I, J: Integer;
begin
  if Child is TControl then
    inherited SetChildOrder(Child, Order)
  else
  begin
    Dec(Order, ControlCount);
    J := -1;
    for I := 0 to ComponentCount - 1 do
      if not Components[I].HasParent then
      begin
        Inc(J);
        if J = Order then
        begin
          Child.ComponentIndex := I;
          Exit;
        end;
      end;
  end;
end;

procedure TCustomForm.SetParentBiDiMode(Value: Boolean);
begin
  if ParentBiDiMode <> Value then
  begin
    inherited;
    { if there is no parent, then the parent is Application }
    if Parent = nil then
      Perform(CM_PARENTBIDIMODECHANGED, 0, 0);
  end;  
end;

procedure TCustomForm.SetClientWidth(Value: Integer);
begin
  if csReadingState in ControlState then
  begin
    FClientWidth := Value;
    ScalingFlags := ScalingFlags + [sfWidth];
  end else inherited ClientWidth := Value;
end;

procedure TCustomForm.SetClientHeight(Value: Integer);
begin
  if csReadingState in ControlState then
  begin
    FClientHeight := Value;
    ScalingFlags := ScalingFlags + [sfHeight];
  end else inherited ClientHeight := Value;
end;

procedure TCustomForm.SetVisible(Value: Boolean);
begin
  if fsCreating in FFormState then
    if Value then
      Include(FFormState, fsVisible) else
      Exclude(FFormState, fsVisible)
  else
  begin
    if Value and (Visible <> Value) then SetWindowToMonitor;
    inherited Visible := Value;
  end;
end;

procedure TCustomForm.VisibleChanging;
begin
  if (FormStyle = fsMDIChild) and Visible then
    raise EInvalidOperation.Create(SMDIChildNotVisible);
end;

function TCustomForm.WantChildKey(Child: TControl; var Message: TMessage): Boolean;
begin
  Result := False;
end;

procedure TCustomForm.SetParent(AParent: TWinControl);
begin
  if (Parent <> AParent) and (AParent <> Self) then
  begin
    if Parent = nil then DestroyHandle;
    inherited SetParent(AParent);
    if Parent = nil then UpdateControlState;
  end;
end;

procedure TCustomForm.ValidateRename(AComponent: TComponent;
  const CurName, NewName: string);
begin
  inherited ValidateRename(AComponent, CurName, NewName);
  if FDesigner <> nil then
    FDesigner.ValidateRename(AComponent, CurName, NewName);
end;

type
  TMenuItemAccess = class(TMenuItem);

procedure TCustomForm.WndProc(var Message: TMessage);
var
  FocusHandle: HWND;
  SaveIndex: Integer;
  MenuItem: TMenuItem;
  Canvas: TCanvas;
  DC: HDC;
begin
  with Message do
    case Msg of
      WM_ACTIVATE, WM_SETFOCUS, WM_KILLFOCUS:
        begin
          if not FocusMessages then Exit;
          if (Msg = WM_SETFOCUS) and not (csDesigning in ComponentState) then
          begin
            FocusHandle := 0;
            if FormStyle = fsMDIForm then
            begin
              if ActiveMDIChild <> nil then FocusHandle := ActiveMDIChild.Handle;
            end
            else if (FActiveControl <> nil) and (FActiveControl <> Self) then
              FocusHandle := FActiveControl.Handle;
            if FocusHandle <> 0 then
            begin
              Windows.SetFocus(FocusHandle);
              Exit;
            end;
          end;
        end;
      CM_EXIT:
        if HostDockSite <> nil then DeActivate;
      CM_ENTER:
        if HostDockSite <> nil then Activate;
      WM_WINDOWPOSCHANGING:
        if ([csLoading, csDesigning] * ComponentState = [csLoading]) then
        begin
          if (Position in [poDefault, poDefaultPosOnly]) and
            (WindowState <> wsMaximized) then
            with PWindowPos(Message.lParam)^ do flags := flags or SWP_NOMOVE;
          if (Position in [poDefault, poDefaultSizeOnly]) and
            (BorderStyle in [bsSizeable, bsSizeToolWin]) then
            with PWindowPos(Message.lParam)^ do flags := flags or SWP_NOSIZE;
        end;
      WM_DRAWITEM:
        with PDrawItemStruct(Message.LParam)^ do
          if (CtlType = ODT_MENU) and Assigned(Menu) then
          begin
            MenuItem := Menu.FindItem(itemID, fkCommand);
            if MenuItem <> nil then
            begin
              Canvas := TControlCanvas.Create;
              with Canvas do
              try
                SaveIndex := SaveDC(hDC);
                try
                  Handle := hDC;
                  Font := Screen.MenuFont;
                  Menus.DrawMenuItem(MenuItem, Canvas, rcItem,
                    TOwnerDrawState(LongRec(itemState).Lo));
                finally
                  Handle := 0;
                  RestoreDC(hDC, SaveIndex)
                end;
              finally
                Free;
              end;
              Exit;
            end;
          end;
      WM_MEASUREITEM:
        with PMeasureItemStruct(Message.LParam)^ do
          if (CtlType = ODT_MENU) and Assigned(Menu) then
          begin
            MenuItem := Menu.FindItem(itemID, fkCommand);
            if MenuItem <> nil then
            begin
              DC := GetWindowDC(Handle);
              try
                Canvas := TControlCanvas.Create;
                with Canvas do
                try
                  SaveIndex := SaveDC(DC);
                  try
                    Handle := DC;
                    Font := Screen.MenuFont;
                    TMenuItemAccess(MenuItem).MeasureItem(Canvas,
                      Integer(itemWidth), Integer(itemHeight));
                  finally
                    Handle := 0;
                    RestoreDC(DC, SaveIndex);
                  end;
                finally
                  Canvas.Free;
                end;
              finally
                ReleaseDC(Handle, DC);
              end;
              Exit;
            end;
          end;
    end;
  inherited WndProc(Message);
end;

procedure TCustomForm.ClientWndProc(var Message: TMessage);

  procedure Default;
  begin
    with Message do
      Result := CallWindowProc(FDefClientProc, ClientHandle, Msg, wParam, lParam);
  end;

  function MaximizedChildren: Boolean;
  var
    I: Integer;
  begin
    for I := 0 to MDIChildCount - 1 do
      if MDIChildren[I].WindowState = wsMaximized then
      begin
        Result := True;
        Exit;
      end;
    Result := False;
  end;

begin
  with Message do
    case Msg of
      WM_NCHITTEST:
        begin
          Default;
          if Result = HTCLIENT then Result := HTTRANSPARENT;
        end;
      WM_ERASEBKGND:
        begin
          FillRect(TWMEraseBkGnd(Message).DC, ClientRect, Brush.Handle);
          Result := 1;
        end;
      $3F://!
        begin
          Default;
          if FFormStyle = fsMDIForm then
            ShowMDIClientEdge(FClientHandle, (MDIChildCount = 0) or
            not MaximizedChildren);
        end;
    else
      Default;
    end;
end;

procedure TCustomForm.AlignControls(AControl: TControl; var Rect: TRect);
begin
  inherited AlignControls(AControl, Rect);
  if ClientHandle <> 0 then
    with Rect do
      SetWindowPos(FClientHandle, HWND_BOTTOM, Left, Top, Right - Left,
        Bottom - Top, SWP_NOZORDER + SWP_NOACTIVATE);
end;

procedure TCustomForm.CMBiDiModeChanged(var Message: TMessage);
var
  ExStyle: DWORD;
  Loop: Integer;
begin
  inherited;
  { inherited does not call RecreateWnd, so we need to call SetWindowLong }
  if HandleAllocated then
  begin
    ExStyle := DWORD(GetWindowLong(Handle, GWL_EXSTYLE))and (not WS_EX_RIGHT) and
      (not WS_EX_RTLREADING) and (not WS_EX_LEFTSCROLLBAR);
    AddBiDiModeExStyle(ExStyle);
    SetWindowLong(Handle, GWL_EXSTYLE, ExStyle);
  end;
  { Menus derive from TComponent, so we need to update them here. We cannot
    use FMenu because forms can have many menus. }
  for Loop := 0 to ComponentCount - 1 do
    if Components[Loop] is TMenu then
      TMenu(Components[Loop]).ParentBiDiModeChanged;
end;

procedure TCustomForm.CMParentBiDiModeChanged(var Message: TMessage);
begin
  { Prevent needless recursion }
  if FInCMParentBiDiModeChanged then Exit;
  FInCMParentBiDiModeChanged := True;
  try
    if ParentBiDiMode then
    begin
      { if there is no parent, then the parent is Application }
      if Parent = nil then
        BiDiMode := Application.BiDiMode
      else
        BiDiMode := Parent.BiDiMode;
      ParentBiDiMode := True;
    end;
  finally
    FInCMParentBiDiModeChanged := False;
  end;
end;

procedure TCustomForm.SetDesigner(ADesigner: IDesigner);
begin
  FDesigner := ADesigner;
end;

procedure TCustomForm.SetBorderIcons(Value: TBorderIcons);
begin
  if FBorderIcons <> Value then
  begin
    FBorderIcons := Value;
    if not (csDesigning in ComponentState) then RecreateWnd;
  end;
end;

procedure TCustomForm.SetBorderStyle(Value: TFormBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    AutoScroll := FBorderStyle in [bsSizeable, bsSizeToolWin];
    if not (csDesigning in ComponentState) then RecreateWnd;
  end;
end;

procedure TCustomForm.Dock(NewDockSite: TWinControl; ARect: TRect);
var
  PrevDockSite, PrevParent: TWinControl;
begin
  PrevParent := Parent;
  PrevDockSite := HostDockSite;
  inherited Dock(NewDockSite, ARect);
  if (Parent <> nil) and (Parent = PrevParent) and
    (PrevDockSite <> HostDockSite) then RecreateWnd;
end;

procedure TCustomForm.DoDock(NewDockSite: TWinControl; var ARect: TRect);
begin
  if (NewDockSite <> HostDockSite) and
    ((NewDockSite = nil) or Floating) then
    if NewDockSite = nil then
      FBorderStyle := FSavedBorderStyle
    else begin
      FSavedBorderStyle := BorderStyle;
      FBorderStyle := bsNone;
    end;
  inherited DoDock(NewDockSite, ARect);
end;

function TCustomForm.GetActiveMDIChild: TForm;
begin
  Result := nil;
  if (FormStyle = fsMDIForm) and (FClientHandle <> 0) then
    Result := TForm(FindControl(SendMessage(FClientHandle, WM_MDIGETACTIVE, 0,
      0)));
end;

function TCustomForm.GetMDIChildCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  if (FormStyle = fsMDIForm) and (FClientHandle <> 0) then
    for I := 0 to Screen.FormCount - 1 do
      if Screen.Forms[I].FormStyle = fsMDIChild then Inc(Result);
end;

function TCustomForm.GetMDIChildren(I: Integer): TForm;
var
  J: Integer;
begin
  if (FormStyle = fsMDIForm) and (FClientHandle <> 0) then
    for J := 0 to Screen.FormCount - 1 do
    begin
      Result := Screen.Forms[J];
      if Result.FormStyle = fsMDIChild then
      begin
        Dec(I);
        if I < 0 then Exit;
      end;
    end;
  Result := nil;
end;

function TCustomForm.GetMonitor: TMonitor;
var
  HM: HMonitor;
  I: Integer;
begin
  Result := nil;
  HM := MonitorFromWindow(Handle, MONITOR_DEFAULTTONEAREST);
  for I := 0 to Screen.MonitorCount - 1 do
    if Screen.Monitors[I].Handle = HM then
    begin
      Result := Screen.Monitors[I];
      Exit;
    end;
end;

function TCustomForm.GetCanvas: TCanvas;
begin
  Result := FCanvas;
end;

procedure TCustomForm.SetIcon(Value: TIcon);
begin
  FIcon.Assign(Value);
end;

function TCustomForm.IsForm: Boolean;
begin
  Result := not IsControl;
end;

function TCustomForm.IsIconStored: Boolean;
begin
  Result := IsForm and (Icon.Handle <> 0);
end;

procedure TCustomForm.SetFormStyle(Value: TFormStyle);
var
  OldStyle: TFormStyle;
begin
  if FFormStyle <> Value then
  begin
    if (Value = fsMDIChild) and (Position = poDesigned) then
      Position := poDefault;
    if not (csDesigning in ComponentState) then DestroyHandle;
    OldStyle := FFormStyle;
    FFormStyle := Value;
    if ((Value = fsMDIForm) or (OldStyle = fsMDIForm)) and not Ctl3d then
      Color := NormalColor;
    if not (csDesigning in ComponentState) then UpdateControlState;
    if Value = fsMDIChild then Visible := True;
  end;
end;

procedure TCustomForm.RefreshMDIMenu;
var
  MenuHandle, WindowMenuHandle: HMenu;
  Redraw: Boolean;
begin
  if (FormStyle = fsMDIForm) and (ClientHandle <> 0) then
  begin
    MenuHandle := 0;
    if Menu <> nil then MenuHandle := Menu.Handle;
    WindowMenuHandle := 0;
    if WindowMenu <> nil then WindowMenuHandle := WindowMenu.Handle;
    Redraw := Windows.GetMenu(Handle) <> MenuHandle;
    SendMessage(ClientHandle, WM_MDISETMENU, MenuHandle, WindowMenuHandle);
    if Redraw then DrawMenuBar(Handle);
  end;
end;

procedure TCustomForm.SetObjectMenuItem(Value: TMenuItem);
begin
  FObjectMenuItem := Value;
  if Value <> nil then
  begin
    Value.FreeNotification(Self);
    Value.Enabled := False;
  end;
end;

procedure TCustomForm.SetWindowMenu(Value: TMenuItem);
begin
  if FWindowMenu <> Value then
  begin
    FWindowMenu := Value;
    if Value <> nil then Value.FreeNotification(Self);
    RefreshMDIMenu;
  end;
end;

procedure TCustomForm.SetMenu(Value: TMainMenu);
var
  I: Integer;
begin
  if Value <> nil then
    for I := 0 to Screen.FormCount - 1 do
      if (Screen.Forms[I].Menu = Value) and (Screen.Forms[I] <> Self) then
        raise EInvalidOperation.CreateFmt(sDuplicateMenus, [Value.Name]);
  if FMenu <> nil then FMenu.WindowHandle := 0;
  FMenu := Value;
  if Value <> nil then Value.FreeNotification(Self);
  if (Value <> nil) and ((csDesigning in ComponentState) or
   (BorderStyle <> bsDialog)) then
  begin
    if not (Menu.AutoMerge or (FormStyle = fsMDIChild)) or
      (csDesigning in ComponentState) then
    begin
      if HandleAllocated then
      begin
        if Windows.GetMenu(Handle) <> Menu.Handle then
          Windows.SetMenu(Handle, Menu.Handle);
        Value.WindowHandle := Handle;
      end;
    end
    else if FormStyle <> fsMDIChild then
      if HandleAllocated then Windows.SetMenu(Handle, 0);
  end
  else if HandleAllocated then Windows.SetMenu(Handle, 0);
  if Active then MergeMenu(True);
  RefreshMDIMenu;
end;

function TCustomForm.GetPixelsPerInch: Integer;
begin
  Result := FPixelsPerInch;
  if Result = 0 then Result := Screen.PixelsPerInch;
end;

procedure TCustomForm.SetPixelsPerInch(Value: Integer);
begin
  if (Value <> GetPixelsPerInch) and ((Value = 0) or (Value >= 36))
    and (not (csLoading in ComponentState) or (FPixelsPerInch <> 0)) then
    FPixelsPerInch := Value;
end;

procedure TCustomForm.SetPosition(Value: TPosition);
begin
  if FPosition <> Value then
  begin
    FPosition := Value;
    if not (csDesigning in ComponentState) then RecreateWnd;
  end;
end;

function TCustomForm.GetScaled: Boolean;
begin
  Result := FPixelsPerInch <> 0;
end;

procedure TCustomForm.SetScaled(Value: Boolean);
begin
  if Value <> GetScaled then
  begin
    FPixelsPerInch := 0;
    if Value then FPixelsPerInch := Screen.PixelsPerInch;
  end;
end;

procedure TCustomForm.CMColorChanged(var Message: TMessage);
begin
  inherited;
  if FCanvas <> nil then FCanvas.Brush.Color := Color;
end;

function TCustomForm.NormalColor: TColor;
begin
  Result := clWindow;
  if FormStyle = fsMDIForm then Result := clAppWorkSpace;
end;

procedure TCustomForm.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
  if Ctl3D then
  begin
     if Color = NormalColor then Color := clBtnFace
  end
  else if Color = clBtnFace then Color := NormalColor;
end;

procedure TCustomForm.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FCanvas <> nil then FCanvas.Font := Font;
end;

procedure TCustomForm.CMMenuChanged(var Message: TMessage);
begin
  RefreshMDIMenu;
  SetMenu(FMenu);
end;

procedure TCustomForm.SetWindowState(Value: TWindowState);
const
  ShowCommands: array[TWindowState] of Integer =
    (SW_SHOWNORMAL, SW_MINIMIZE, SW_SHOWMAXIMIZED);
begin
  if FWindowState <> Value then
  begin
    FWindowState := Value;
    if not (csDesigning in ComponentState) and Showing then
      ShowWindow(Handle, ShowCommands[Value]);
  end;
end;

procedure TCustomForm.SetWindowToMonitor;
var
  AppMon, WinMon: HMONITOR;
  I, J: Integer;
  ALeft, ATop: Integer;
begin
    if (FDefaultMonitor <> dmDesktop) and (Application.MainForm <> nil) then
    begin
      AppMon := 0;
      if FDefaultMonitor = dmMainForm then
        AppMon := Application.MainForm.Monitor.Handle
      else if (FDefaultMonitor = dmActiveForm) and (Screen.ActiveCustomForm <> nil) then
        AppMon := Screen.ActiveCustomForm.Monitor.Handle
      else if FDefaultMonitor = dmPrimary then
        AppMon := Screen.Monitors[0].Handle;
      WinMon := Monitor.Handle;
      for I := 0 to Screen.MonitorCount - 1 do
        if (Screen.Monitors[I].Handle = AppMon) then
          if (AppMon <> WinMon) then
            for J := 0 to Screen.MonitorCount - 1 do
              if (Screen.Monitors[J].Handle = WinMon) then
              begin
                if FPosition = poScreenCenter then
                  SetBounds(Screen.Monitors[I].Left + ((Screen.Monitors[I].Width - Width) div 2),
                    Screen.Monitors[I].Top + ((Screen.Monitors[I].Height - Height) div 2),
                     Width, Height)
                else
                if FPosition = poMainFormCenter then
                begin
                  SetBounds(Screen.Monitors[I].Left + ((Screen.Monitors[I].Width - Width) div 2),
                    Screen.Monitors[I].Top + ((Screen.Monitors[I].Height - Height) div 2),
                     Width, Height)
                end
                else
                begin
                  ALeft := Screen.Monitors[I].Left + Left - Screen.Monitors[J].Left;
                  if ALeft + Width > Screen.Monitors[I].Left + Screen.Monitors[I].Width then
                    ALeft := Screen.Monitors[I].Left + Screen.Monitors[I].Width - Width;
                  ATop := Screen.Monitors[I].Top + Top - Screen.Monitors[J].Top;
                  if ATop + Height > Screen.Monitors[I].Top + Screen.Monitors[I].Height then
                    ATop := Screen.Monitors[I].Top + Screen.Monitors[I].Height - Height;
                  SetBounds(ALeft, ATop, Width, Height);
                end;
              end;
    end;
end;

procedure TCustomForm.CreateParams(var Params: TCreateParams);
var
  Icons: TBorderIcons;
  CreateStyle: TFormBorderStyle;
begin
  inherited CreateParams(Params);
  with Params do
  begin
    if (Parent = nil) and (ParentWindow = 0) then
    begin
      WndParent := Application.Handle;
      Style := Style and not (WS_CHILD or WS_GROUP or WS_TABSTOP);
    end;
    WindowClass.style := CS_DBLCLKS;
    if (csDesigning in ComponentState) and (Parent = nil) then
      Style := Style or (WS_CAPTION or WS_THICKFRAME or WS_MINIMIZEBOX or
        WS_MAXIMIZEBOX or WS_SYSMENU)
    else
    begin
      if FPosition in [poDefault, poDefaultPosOnly] then
      begin
        X := Integer(CW_USEDEFAULT);
        Y := Integer(CW_USEDEFAULT);
      end;
      Icons := FBorderIcons;
      CreateStyle := FBorderStyle;
      if (FormStyle = fsMDIChild) and (CreateStyle in [bsNone, bsDialog]) then
        CreateStyle := bsSizeable;
      case CreateStyle of
        bsNone:
          begin
            if (Parent = nil) and (ParentWindow = 0) then
              Style := Style or WS_POPUP;
            Icons := [];
          end;
        bsSingle, bsToolWindow:
          Style := Style or (WS_CAPTION or WS_BORDER);
        bsSizeable, bsSizeToolWin:
          begin
            Style := Style or (WS_CAPTION or WS_THICKFRAME);
            if FPosition in [poDefault, poDefaultSizeOnly] then
            begin
              Width := Integer(CW_USEDEFAULT);
              Height := Integer(CW_USEDEFAULT);
            end;
          end;
        bsDialog:
          begin
            Style := Style or WS_POPUP or WS_CAPTION;
            ExStyle := WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE;
            AddBiDiModeExStyle(ExStyle);
            if not NewStyleControls then
              Style := Style or WS_DLGFRAME or DS_MODALFRAME;
            Icons := Icons * [biSystemMenu, biHelp];
            WindowClass.style := CS_DBLCLKS or CS_SAVEBITS or
              CS_BYTEALIGNWINDOW;
          end;
      end;
      if CreateStyle in [bsToolWindow, bsSizeToolWin] then
      begin
        ExStyle := WS_EX_TOOLWINDOW;
        AddBiDiModeExStyle(ExStyle);
        Icons := Icons * [biSystemMenu];
      end;
      if CreateStyle in [bsSingle, bsSizeable, bsNone] then
      begin
        if (FormStyle <> fsMDIChild) or (biSystemMenu in Icons) then
        begin
          if biMinimize in Icons then Style := Style or WS_MINIMIZEBOX;
          if biMaximize in Icons then Style := Style or WS_MAXIMIZEBOX;
        end;
        if FWindowState = wsMinimized then Style := Style or WS_MINIMIZE else
          if FWindowState = wsMaximized then Style := Style or WS_MAXIMIZE;
      end else FWindowState := wsNormal;
      if biSystemMenu in Icons then Style := Style or WS_SYSMENU;
      if (biHelp in Icons) then ExStyle := ExStyle or WS_EX_CONTEXTHELP;
      if csInline in ComponentState then
        Style := Style and not WS_CAPTION;
      if FormStyle = fsMDIChild then WindowClass.lpfnWndProc := @DefMDIChildProc;
    end;
  end;
end;

procedure TCustomForm.CreateWnd;
var
  ClientCreateStruct: TClientCreateStruct;
begin
  inherited CreateWnd;
  if NewStyleControls then
    if BorderStyle <> bsDialog then
      SendMessage(Handle, WM_SETICON, 1, GetIconHandle) else
      SendMessage(Handle, WM_SETICON, 1, 0);
  if not (csDesigning in ComponentState) then
    case FormStyle of
      fsMDIForm:
        begin
          with ClientCreateStruct do
          begin
            idFirstChild := $FF00;
            hWindowMenu := 0;
            if FWindowMenu <> nil then hWindowMenu := FWindowMenu.Handle;
          end;
          FClientHandle := Windows.CreateWindowEx(WS_EX_CLIENTEDGE, 'MDICLIENT',
            nil, WS_CHILD or WS_VISIBLE or WS_GROUP or WS_TABSTOP or
            WS_CLIPCHILDREN or WS_HSCROLL or WS_VSCROLL or WS_CLIPSIBLINGS or
            MDIS_ALLCHILDSTYLES, 0, 0, ClientWidth, ClientHeight, Handle, 0,
            HInstance, @ClientCreateStruct);
          FClientInstance := MakeObjectInstance(ClientWndProc);
          FDefClientProc := Pointer(GetWindowLong(FClientHandle, GWL_WNDPROC));
          SetWindowLong(FClientHandle, GWL_WNDPROC, Longint(FClientInstance));
        end;
      fsStayOnTop:
        SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or
          SWP_NOSIZE or SWP_NOACTIVATE);
    end;
end;

procedure TCustomForm.CreateWindowHandle(const Params: TCreateParams);
var
  CreateStruct: TMDICreateStruct;
begin
  if (FormStyle = fsMDIChild) and not (csDesigning in ComponentState) then
  begin
    if (Application.MainForm = nil) or
      (Application.MainForm.ClientHandle = 0) then
      raise EInvalidOperation.Create(SNoMDIForm);
    with CreateStruct do
    begin
      szClass := Params.WinClassName;
      szTitle := Params.Caption;
      hOwner := HInstance;
      X := Params.X;
      Y := Params.Y;
      cX := Params.Width;
      cY := Params.Height;
      style := Params.Style;
      lParam := Longint(Params.Param);
    end;
    WindowHandle := SendMessage(Application.MainForm.ClientHandle,
      WM_MDICREATE, 0, Longint(@CreateStruct));
    Include(FFormState, fsCreatedMDIChild);
  end else
  begin
    inherited CreateWindowHandle(Params);
    Exclude(FFormState, fsCreatedMDIChild);
  end;
end;

procedure TCustomForm.DestroyWindowHandle;
begin
  if fsCreatedMDIChild in FFormState then
    SendMessage(Application.MainForm.ClientHandle, WM_MDIDESTROY, Handle, 0)
  else
    inherited DestroyWindowHandle;
  FClientHandle := 0;
end;

procedure TCustomForm.DefaultHandler(var Message);
begin
  if ClientHandle <> 0 then
    with TMessage(Message) do
      if Msg = WM_SIZE then
        Result := DefWindowProc(Handle, Msg, wParam, lParam) else
        Result := DefFrameProc(Handle, ClientHandle, Msg, wParam, lParam)
  else
    inherited DefaultHandler(Message)
end;

procedure TCustomForm.SetActiveControl(Control: TWinControl);
begin
  if FActiveControl <> Control then
  begin
    if not ((Control = nil) or (Control <> Self) and
      (GetParentForm(Control) = Self) and ((csLoading in ComponentState) or
        Control.CanFocus)) then
      raise EInvalidOperation.Create(SCannotFocus);
    FActiveControl := Control;
    if not (csLoading in ComponentState) then
    begin
      if FActive then SetWindowFocus;
      ActiveChanged;
    end;
  end;
end;

procedure TCustomForm.DefocusControl(Control: TWinControl; Removing: Boolean);
begin
  if Removing and Control.ContainsControl(FFocusedControl) then
    FFocusedControl := Control.Parent;
  if Control.ContainsControl(FActiveControl) then SetActiveControl(nil);
end;

procedure TCustomForm.FocusControl(Control: TWinControl);
var
  WasActive: Boolean;
begin
  WasActive := FActive;
  SetActiveControl(Control);
  if not WasActive then SetFocus;
end;

function TCustomForm.SetFocusedControl(Control: TWinControl): Boolean;
var
  FocusHandle: HWnd;
  TempControl: TWinControl;
begin
  Result := False;
  Inc(FocusCount);
  if FDesigner = nil then
    if Control <> Self then
      FActiveControl := Control else
      FActiveControl := nil;
  Screen.FActiveControl := Control;
  Screen.FActiveCustomForm := Self;
  Screen.FCustomForms.Remove(Self);
  Screen.FCustomForms.Insert(0, Self);
  if Self is TForm then
  begin
    Screen.FActiveForm := TForm(Self);
    Screen.FForms.Remove(Self);
    Screen.FForms.Insert(0, Self);
  end
  else Screen.FActiveForm := nil;
  if not (csFocusing in Control.ControlState) then
  begin
    Control.ControlState := Control.ControlState + [csFocusing];
    try
      if Screen.FFocusedForm <> Self then
      begin
        if Screen.FFocusedForm <> nil then
        begin
          FocusHandle := Screen.FFocusedForm.Handle;
          Screen.FFocusedForm := nil;
          if not SendFocusMessage(FocusHandle, CM_DEACTIVATE) then Exit;
        end;
        Screen.FFocusedForm := Self;
        if not SendFocusMessage(Handle, CM_ACTIVATE) then Exit;
      end;
      if FFocusedControl = nil then FFocusedControl := Self;
      if FFocusedControl <> Control then
      begin
        while (FFocusedControl <> nil) and not
          FFocusedControl.ContainsControl(Control) do
        begin
          FocusHandle := FFocusedControl.Handle;
          FFocusedControl := FFocusedControl.Parent;
          if not SendFocusMessage(FocusHandle, CM_EXIT) then Exit;
        end;
        while FFocusedControl <> Control do
        begin
          TempControl := Control;
          while TempControl.Parent <> FFocusedControl do
            TempControl := TempControl.Parent;
          FFocusedControl := TempControl;
          if not SendFocusMessage(TempControl.Handle, CM_ENTER) then Exit;
        end;
        TempControl := Control.Parent;
        while TempControl <> nil do
        begin
          if TempControl is TScrollingWinControl then
            TScrollingWinControl(TempControl).AutoScrollInView(Control);
          TempControl := TempControl.Parent;
        end;
        Perform(CM_FOCUSCHANGED, 0, Longint(Control));
        if (FActiveOleControl <> nil) and (FActiveOleControl <> Control) then
          FActiveOleControl.Perform(CM_UIDEACTIVATE, 0, 0);
      end;
    finally
      Control.ControlState := Control.ControlState - [csFocusing];
    end;
    Screen.UpdateLastActive;
    Result := True;
  end;
end;

procedure TCustomForm.ActiveChanged;
begin
end;

procedure TCustomForm.SetWindowFocus;
var
  FocusControl: TWinControl;
begin
  if (FActiveControl <> nil) and (FDesigner = nil) then
    FocusControl := FActiveControl else
    FocusControl := Self;
  Windows.SetFocus(FocusControl.Handle);
  if GetFocus = FocusControl.Handle then
    FocusControl.Perform(CM_UIACTIVATE, 0, 0);
end;

procedure TCustomForm.SetActive(Value: Boolean);
begin
  FActive := Value;
  if FActiveOleControl <> nil then
    FActiveOleControl.Perform(CM_DOCWINDOWACTIVATE, Ord(Value), 0);
  if Value then
  begin
    if (ActiveControl = nil) and not (csDesigning in ComponentState) then
      ActiveControl := FindNextControl(nil, True, True, False);
    MergeMenu(True);
    SetWindowFocus;
  end;
end;

procedure TCustomForm.SendCancelMode(Sender: TControl);
begin
  if Active and (ActiveControl <> nil) then
    ActiveControl.Perform(CM_CANCELMODE, 0, Longint(Sender));
  if (FormStyle = fsMDIForm) and (ActiveMDIChild <> nil) then
    ActiveMDIChild.SendCancelMode(Sender);
end;

procedure TCustomForm.MergeMenu(MergeState: Boolean);
var
  AMergeMenu: TMainMenu;
begin
  if not (fsModal in FFormState) and
    (Application.MainForm <> nil) and
    (Application.MainForm.Menu <> nil) and
    (Application.MainForm <> Self) and
    ((FormStyle = fsMDIChild) or (Application.MainForm.FormStyle <> fsMDIForm)) then
  begin
    AMergeMenu := nil;
    if not (csDesigning in ComponentState) and (Menu <> nil) and
      (Menu.AutoMerge or (FormStyle = fsMDIChild)) then AMergeMenu := Menu;
    with Application.MainForm.Menu do
      if MergeState then Merge(AMergeMenu) else Unmerge(AMergeMenu);
  end;
end;

procedure DoNestedActivation(Msg: Cardinal; Control: TWinControl; Form: TCustomForm);
begin
  if Control = nil then Exit;
  { Find the closest parent which is a form }
  while (Control.Parent <> nil) and not (Control is TCustomForm) do
    Control := Control.Parent;
  if Assigned(Control) and (Control <> Form) then
    SendMessage(Control.Handle, Msg, 0, 0)
end;

procedure TCustomForm.Activate;
begin
  DoNestedActivation(CM_ACTIVATE, ActiveControl, Self);
  if Assigned(FOnActivate) then FOnActivate(Self);
end;

procedure TCustomForm.Deactivate;
begin
  DoNestedActivation(CM_DEACTIVATE, ActiveControl, Self);
  if Assigned(FOnDeactivate) then FOnDeactivate(Self);
end;

procedure TCustomForm.Paint;
begin
  if Assigned(FOnPaint) then FOnPaint(Self);
end;

function TCustomForm.GetIconHandle: HICON;
begin
  Result := FIcon.Handle;
  if Result = 0 then Result := Application.GetIconHandle;
end;

procedure TCustomForm.PaintWindow(DC: HDC);
begin
  FCanvas.Lock;
  try
    FCanvas.Handle := DC;
    try
      if FDesigner <> nil then FDesigner.PaintGrid else Paint;
    finally
      FCanvas.Handle := 0;
    end;
  finally
    FCanvas.Unlock;
  end;
end;

function TCustomForm.PaletteChanged(Foreground: Boolean): Boolean;
var
  I: Integer;
  Active, Child: TForm;
begin
  Result := False;
  Active := ActiveMDIChild;
  if Assigned(Active) then
    Result := Active.PaletteChanged(Foreground);
  for I := 0 to MDIChildCount-1 do
  begin
    if Foreground and Result then Exit;
    Child := MDIChildren[I];
    if Active = Child then Continue;
    Result := Child.PaletteChanged(Foreground) or Result;
  end;
  if Foreground and Result then Exit;
  Result := inherited PaletteChanged(Foreground);
end;

procedure TCustomForm.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  PS: TPaintStruct;
begin
  if not IsIconic(Handle) then
  begin
    ControlState := ControlState + [csCustomPaint];
    inherited;
    ControlState := ControlState - [csCustomPaint];
  end
  else
  begin
    DC := BeginPaint(Handle, PS);
    DrawIcon(DC, 0, 0, GetIconHandle);
    EndPaint(Handle, PS);
  end;
end;

procedure TCustomForm.WMIconEraseBkgnd(var Message: TWMIconEraseBkgnd);
begin
  if FormStyle = fsMDIChild then
  if (FormStyle = fsMDIChild) and not (csDesigning in ComponentState) then
    FillRect(Message.DC, ClientRect, Application.MainForm.Brush.Handle)
  else inherited;
end;

procedure TCustomForm.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  if not IsIconic(Handle) then inherited else
  begin
    Message.Msg := WM_ICONERASEBKGND;
    DefaultHandler(Message);
  end;
end;

procedure TCustomForm.WMQueryDragIcon(var Message: TWMQueryDragIcon);
begin
  Message.Result := GetIconHandle;
end;

procedure TCustomForm.WMNCCreate(var Message: TWMNCCreate);

  procedure ModifySystemMenu;
  var
    SysMenu: HMENU;
  begin
    if (FBorderStyle <> bsNone) and (biSystemMenu in FBorderIcons) and
      (FormStyle <> fsMDIChild) then
    begin
      { Modify the system menu to look more like it's s'pose to }
      SysMenu := GetSystemMenu(Handle, False);
      if FBorderStyle = bsDialog then
      begin
        { Make the system menu look like a dialog which has only
          Move and Close }
        DeleteMenu(SysMenu, SC_TASKLIST, MF_BYCOMMAND);
        DeleteMenu(SysMenu, 7, MF_BYPOSITION);
        DeleteMenu(SysMenu, 5, MF_BYPOSITION);
        DeleteMenu(SysMenu, SC_MAXIMIZE, MF_BYCOMMAND);
        DeleteMenu(SysMenu, SC_MINIMIZE, MF_BYCOMMAND);
        DeleteMenu(SysMenu, SC_SIZE, MF_BYCOMMAND);
        DeleteMenu(SysMenu, SC_RESTORE, MF_BYCOMMAND);
      end else
      begin
        { Else just disable the Minimize and Maximize items if the
          corresponding FBorderIcon is not present }
        if not (biMinimize in FBorderIcons) then
          EnableMenuItem(SysMenu, SC_MINIMIZE, MF_BYCOMMAND or MF_GRAYED);
        if not (biMaximize in FBorderIcons) then
          EnableMenuItem(SysMenu, SC_MAXIMIZE, MF_BYCOMMAND or MF_GRAYED);
      end;
    end;
  end;

begin
  inherited;
  SetMenu(FMenu);
  if not (csDesigning in ComponentState) then ModifySystemMenu;
end;

procedure TCustomForm.WMNCLButtonDown(var Message: TWMNCLButtonDown);
begin
  if (Message.HitTest = HTCAPTION) and (DragKind = dkDock) and not
    (csDesigning in ComponentState) and not IsIconic(Handle) then
  begin
    { Activate window since we override WM_NCLBUTTON behavior }
    SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or SWP_NOMOVE or
      SWP_NOSIZE);
    PostMessage(Handle, WM_NCLBUTTONUP, TMessage(Message).WParam,
      TMessage(Message).LParam);
    if Active then BeginDrag(not Floating);
  end
  else
    inherited;
end;

procedure TCustomForm.WMDestroy(var Message: TWMDestroy);
begin
  if NewStyleControls then SendMessage(Handle, WM_SETICON, 1, 0);
  if (FMenu <> nil) and (FormStyle <> fsMDIChild) then
  begin
    Windows.SetMenu(Handle, 0);
    FMenu.WindowHandle := 0;
  end;
  inherited;
end;

procedure TCustomForm.WMCommand(var Message: TWMCommand);
begin
  with Message do
    if (Ctl <> 0) or (Menu = nil) or not Menu.DispatchCommand(ItemID) then
      inherited;
end;

procedure TCustomForm.WMInitMenuPopup(var Message: TWMInitMenuPopup);
begin
  if FMenu <> nil then FMenu.DispatchPopup(Message.MenuPopup);
end;

procedure TCustomForm.WMMenuChar(var Message: TWMMenuChar);
begin
  if (Menu <> nil) then
  begin
    Menu.ProcessMenuChar(Message);
    if Message.Result = MNC_IGNORE then
      // if we don't know what to do with it, give the default handler a try
      // Specifically, this covers odd MDI system hotkeys, like Alt+Minus
      inherited;
  end
  else
    inherited;
end;

procedure TCustomForm.WMMenuSelect(var Message: TWMMenuSelect);
var
  MenuItem: TMenuItem;
  ID: Integer;
  FindKind: TFindItemKind;
begin
  if FMenu <> nil then
    with Message do
    begin
      MenuItem := nil;
      if (MenuFlag <> $FFFF) or (IDItem <> 0) then
      begin
        FindKind := fkCommand;
        ID := IDItem;
        if MenuFlag and MF_POPUP <> 0 then
        begin
          FindKind := fkHandle;
          ID := GetSubMenu(Menu, ID);
        end;
        MenuItem := FMenu.FindItem(ID, FindKind);
      end;
      if MenuItem <> nil then
        Application.Hint := GetLongHint(MenuItem.Hint) else
        Application.Hint := '';
    end;
end;

procedure TCustomForm.WMActivate(var Message: TWMActivate);
begin
  if (FormStyle <> fsMDIForm) or (csDesigning in ComponentState) then
    SetActive(Message.Active <> WA_INACTIVE);
end;

procedure TCustomForm.Resizing(State: TWindowState);
begin
  if not (csDesigning in ComponentState) then
    FWindowState := State;
  if State <> wsMinimized then
    RequestAlign;
  if FOleForm <> nil then FOleForm.OnResize;
end;

procedure TCustomForm.WMClose(var Message: TWMClose);
begin
  Close;
end;

procedure TCustomForm.WMQueryEndSession(var Message: TWMQueryEndSession);
begin
  Message.Result := Integer(CloseQuery and CallTerminateProcs);
end;

procedure TCustomForm.CMAppSysCommand(var Message: TMessage);
type
  PWMSysCommand = ^TWMSysCommand;
begin
  Message.Result := 0;
  if (csDesigning in ComponentState) or (FormStyle = fsMDIChild) or
   (Menu = nil) or Menu.AutoMerge then
    with PWMSysCommand(Message.lParam)^ do
    begin
      SendCancelMode(nil);
      if SendAppMessage(CM_APPSYSCOMMAND, CmdType, Key) <> 0 then
        Message.Result := 1;;
    end;
end;

procedure TCustomForm.WMSysCommand(var Message: TWMSysCommand);
begin
  with Message do
  begin
    if (CmdType and $FFF0 = SC_MINIMIZE) and (Application.MainForm = Self) then
      Application.WndProc(TMessage(Message))
    else if (CmdType and $FFF0 <> SC_MOVE) or (csDesigning in ComponentState) or
      (Align = alNone) or (WindowState = wsMinimized) then
      inherited;
    if ((CmdType and $FFF0 = SC_MINIMIZE) or (CmdType and $FFF0 = SC_RESTORE)) and
      not (csDesigning in ComponentState) and (Align <> alNone) then
      RequestAlign;
  end;
end;

procedure TCustomForm.WMShowWindow(var Message: TWMShowWindow);
const
  ShowCommands: array[saRestore..saMaximize] of Integer =
    (SW_SHOWNOACTIVATE, SW_SHOWMINNOACTIVE, SW_SHOWMAXIMIZED);
begin
  with Message do
    case Status of
      SW_PARENTCLOSING:
        begin
          if IsIconic(Handle) then FShowAction := saMinimize else
            if IsZoomed(Handle) then FShowAction := saMaximize else
              FShowAction := saRestore;
          inherited;
        end;
      SW_PARENTOPENING:
        if FShowAction <> saIgnore then
        begin
          ShowWindow(Handle, ShowCommands[FShowAction]);
          FShowAction := saIgnore;
        end;
    else
      inherited;
    end;
end;

procedure TCustomForm.WMMDIActivate(var Message: TWMMDIActivate);
var
  IsActive: Boolean;
begin
  inherited;
  if FormStyle = fsMDIChild then
  begin
    IsActive := Message.ActiveWnd = Handle;
    SetActive(IsActive);
    if IsActive and (csPalette in Application.MainForm.ControlState) then
      Application.MainForm.PaletteChanged(True);
  end;
end;

procedure TCustomForm.WMNextDlgCtl(var Message: TWMNextDlgCtl);
begin
  with Message do
    if Handle then
      Windows.SetFocus(Message.CtlFocus) else
      SelectNext(FActiveControl, not BOOL(CtlFocus), True);
end;

procedure TCustomForm.WMEnterMenuLoop(var Message: TMessage);
begin
  SendCancelMode(nil);
  inherited;
end;

procedure TCustomForm.WMHelp(var Message: TWMHelp);

  function GetMenuHelpContext(Menu: TMenu): Integer;
  begin
    Result := 0;
    if Menu = nil then Exit;
    Result := Menu.GetHelpContext(Message.HelpInfo.iCtrlID, True);
    if Result = 0 then
      Result := Menu.GetHelpContext(Message.HelpInfo.hItemHandle, False);
  end;

var
  Control: TWinControl;
  ContextID: Integer;
  Pt: TSmallPoint;
begin
  if csDesigning in ComponentState then
    inherited
  else
  begin
    with Message.HelpInfo^ do
    begin
      if iContextType = HELPINFO_WINDOW then
      begin
        Control := FindControl(hItemHandle);
        while (Control <> nil) and (Control.HelpContext = 0) do
          Control := Control.Parent;
        if Control = nil then Exit;
        ContextID := Control.HelpContext;
        Pt := PointToSmallPoint(Control.ClientToScreen(Point(0, 0)));
      end
      else  { Message.HelpInfo.iContextType = HELPINFO_MENUITEM }
      begin
        ContextID := GetMenuHelpContext(FMenu);
        if ContextID = 0 then
          ContextID := GetMenuHelpContext(PopupMenu);
        Pt := PointToSmallPoint(ClientToScreen(Point(0,0)));
      end;
    end;
    if (biHelp in BorderIcons) then
    begin
      Application.HelpCommand(HELP_SETPOPUP_POS, Longint(Pt));
      Application.HelpCommand(HELP_CONTEXTPOPUP, ContextID);
    end
    else
      Application.HelpContext(ContextID);
  end;
end;

procedure TCustomForm.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
begin
  if not (csReading in ComponentState) and FSizeChanging then
    with Message.MinMaxInfo^, Constraints do
    begin
      with ptMinTrackSize do
      begin
        if MinWidth > 0 then X := MinWidth;
        if MinHeight > 0 then Y := MinHeight;
      end;
      with ptMaxTrackSize do
      begin
        if MaxWidth > 0 then X := MaxWidth;
        if MaxHeight > 0 then Y := MaxHeight;
      end;
      ConstrainedResize(ptMinTrackSize.X, ptMinTrackSize.Y, ptMaxTrackSize.X,
        ptMaxTrackSize.Y);
    end;
  inherited;
end;

procedure TCustomForm.WMWindowPosChanging(var Message: TWMWindowPosChanging);
begin
  with Message.WindowPos^ do
    FSizeChanging := (ComponentState * [csReading, csDestroying] = []) and
      (flags and SWP_NOSIZE = 0) and ((cx <> Width) or (cy <> Height));
  try
    inherited;
  finally
    FSizeChanging := False;
  end;
end;

procedure TCustomForm.CMActivate(var Message: TCMActivate);
begin
  if not (csReading in ComponentState) then
    Activate else
    Include(FFormState, fsActivated);
end;

procedure TCustomForm.CMDeactivate(var Message: TCMDeactivate);
begin
  if not (csReading in ComponentState) then
    Deactivate else
    Exclude(FFormState, fsActivated);
end;

procedure TCustomForm.CMDialogKey(var Message: TCMDialogKey);
begin
  if GetKeyState(VK_MENU) >= 0 then
    with Message do
      case CharCode of
        VK_TAB:
          if GetKeyState(VK_CONTROL) >= 0 then
          begin
            SelectNext(FActiveControl, GetKeyState(VK_SHIFT) >= 0, True);
            Result := 1;
            Exit;
          end;
        VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN:
          begin
            if FActiveControl <> nil then
            begin
              TForm(FActiveControl.Parent).SelectNext(FActiveControl,
                (CharCode = VK_RIGHT) or (CharCode = VK_DOWN), False);
              Result := 1;
            end;
            Exit;
          end;
      end;
  inherited;
end;

procedure TCustomForm.CMShowingChanged(var Message: TMessage);
const
  ShowCommands: array[TWindowState] of Integer =
    (SW_SHOWNORMAL, SW_SHOWMINNOACTIVE, SW_SHOWMAXIMIZED);
var
  X, Y: Integer;
  NewActiveWindow: HWnd;
  CenterForm: TCustomForm;
begin
  if not (csDesigning in ComponentState) and (fsShowing in FFormState) then
    raise EInvalidOperation.Create(SVisibleChanged);
  Application.UpdateVisible;
  Include(FFormState, fsShowing);
  try
    if not (csDesigning in ComponentState) then
      if Showing then
      begin
        try
          DoShow;
        except
          Application.HandleException(Self);
        end;
        if (FPosition = poScreenCenter) or
           ((FPosition = poMainFormCenter) and (FormStyle = fsMDIChild)) then
        begin
          if FormStyle = fsMDIChild then
          begin
            X := (Application.MainForm.ClientWidth - Width) div 2;
            Y := (Application.MainForm.ClientHeight - Height) div 2;
          end else
          begin
            X := (Screen.Width - Width) div 2;
            Y := (Screen.Height - Height) div 2;
          end;
          if X < 0 then X := 0;
          if Y < 0 then Y := 0;
          SetBounds(X, Y, Width, Height);
          if Visible then SetWindowToMonitor;
        end
        else if FPosition in [poMainFormCenter, poOwnerFormCenter] then
        begin
          CenterForm := Application.MainForm;
          if (FPosition = poOwnerFormCenter) and (Owner is TCustomForm) then
            CenterForm := TCustomForm(Owner);
          if Assigned(CenterForm) then
          begin
            X := ((CenterForm.Width - Width) div 2) + CenterForm.Left;
            Y := ((CenterForm.Height - Height) div 2) + CenterForm.Top;
          end else
          begin
            X := (Screen.Width - Width) div 2;
            Y := (Screen.Height - Height) div 2;
          end;
          if X < 0 then X := 0;
          if Y < 0 then Y := 0;
          SetBounds(X, Y, Width, Height);
          if Visible then SetWindowToMonitor;
        end
        else if FPosition = poDesktopCenter then
        begin
          if FormStyle = fsMDIChild then
          begin
            X := (Application.MainForm.ClientWidth - Width) div 2;
            Y := (Application.MainForm.ClientHeight - Height) div 2;
          end else
          begin
            X := (Screen.DesktopWidth - Width) div 2;
            Y := (Screen.DesktopHeight - Height) div 2;
          end;
          if X < 0 then X := 0;
          if Y < 0 then Y := 0;
          SetBounds(X, Y, Width, Height);
        end;
        FPosition := poDesigned;
        if FormStyle = fsMDIChild then
        begin
          { Fake a size message to get MDI to behave }
          if FWindowState = wsMaximized then
          begin
            SendMessage(Application.MainForm.ClientHandle, WM_MDIRESTORE, Handle, 0);
            ShowWindow(Handle, SW_SHOWMAXIMIZED);
          end
          else
          begin
            ShowWindow(Handle, ShowCommands[FWindowState]);
            CallWindowProc(@DefMDIChildProc, Handle, WM_SIZE, SIZE_RESTORED,
              Width or (Height shl 16));
            BringToFront;
          end;
          SendMessage(Application.MainForm.ClientHandle,
            WM_MDIREFRESHMENU, 0, 0);
        end
        else
          ShowWindow(Handle, ShowCommands[FWindowState]);
      end else
      begin
        try
          DoHide;
        except
          Application.HandleException(Self);
        end;
        if Screen.ActiveForm = Self then
          MergeMenu(False);
        if FormStyle = fsMDIChild then
          DestroyHandle
        else if fsModal in FFormState then
          SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_HIDEWINDOW or
            SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE)
        else
        begin
          NewActiveWindow := 0;
          if (GetActiveWindow = Handle) and not IsIconic(Handle) then
            NewActiveWindow := FindTopMostWindow(Handle);
          if NewActiveWindow <> 0 then
          begin
            SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_HIDEWINDOW or
              SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE);
            SetActiveWindow(NewActiveWindow);
          end else
            ShowWindow(Handle, SW_HIDE);
        end;
      end;
  finally
    Exclude(FFormState, fsShowing);
  end;
end;

procedure TCustomForm.CMIconChanged(var Message: TMessage);
begin
  if FIcon.Handle = 0 then IconChanged(nil);
end;

procedure TCustomForm.CMRelease;
begin
  Free;
end;

procedure TCustomForm.CMTextChanged(var Message: TMessage);
begin
  inherited;
  if (FormStyle = fsMDIChild) and (Application.MainForm <> nil) and
    (Application.MainForm.ClientHandle <> 0) then
    SendMessage(Application.MainForm.ClientHandle, WM_MDIREFRESHMENU, 0, 0);
end;

procedure TCustomForm.CMUIActivate(var Message);
begin
  inherited;
end;

procedure TCustomForm.CMParentFontChanged(var Message: TMessage);
var
  F: TFont;
begin
  if ParentFont then
    if Message.wParam <> 0 then
      Font.Assign(TFont(Message.lParam))
    else
    begin
      F := TFont.Create;  // get locale defaults
      try
        Font.Assign(F);
      finally
        F.Free
      end;
    end;
end;

procedure TCustomForm.Close;
var
  CloseAction: TCloseAction;
begin
  if fsModal in FFormState then
    ModalResult := mrCancel
  else
    if CloseQuery then
    begin
      if FormStyle = fsMDIChild then
        if biMinimize in BorderIcons then
          CloseAction := caMinimize else
          CloseAction := caNone
      else
        CloseAction := caHide;
      DoClose(CloseAction);
      if CloseAction <> caNone then
        if Application.MainForm = Self then Application.Terminate
        else if CloseAction = caHide then Hide
        else if CloseAction = caMinimize then WindowState := wsMinimized
        else Release;
    end;
end;

function TCustomForm.CloseQuery: Boolean;
var
  I: Integer;
begin
  if FormStyle = fsMDIForm then
  begin
    Result := False;
    for I := 0 to MDIChildCount - 1 do
      if not MDIChildren[I].CloseQuery then Exit;
  end;
  Result := True;
  if Assigned(FOnCloseQuery) then FOnCloseQuery(Self, Result);
end;

procedure TCustomForm.CloseModal;
var
  CloseAction: TCloseAction;
begin
  try
    CloseAction := caNone;
    if CloseQuery then
    begin
      CloseAction := caHide;
      if Assigned(FOnClose) then FOnClose(Self, CloseAction);
    end;
    case CloseAction of
      caNone: ModalResult := 0;
      caFree: Release;
    end;
  except
    ModalResult := 0;
    Application.HandleException(Self);
  end;
end;

function TCustomForm.GetFormImage: TBitmap;
var
  Ofs: Integer;
begin
  Result := TBitmap.Create;
  try
    Result.Width := ClientWidth;
    Result.Height := ClientHeight;
    Result.Canvas.Brush := Brush;
    Result.Canvas.FillRect(ClientRect);
    Result.Canvas.Lock;
    try
      if GetWindowLong(Handle, GWL_STYLE) and WS_BORDER <> 0 then
        Ofs := -1  // Don't draw form border
      else
        Ofs := 0;  // There is no border
      PaintTo(Result.Canvas.Handle, Ofs, Ofs);
    finally
      Result.Canvas.Unlock;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TCustomForm.Print;
var
  FormImage: TBitmap;
  Info: PBitmapInfo;
  InfoSize: DWORD;
  Image: Pointer;
  ImageSize: DWORD;
  Bits: HBITMAP;
  DIBWidth, DIBHeight: Longint;
  PrintWidth, PrintHeight: Longint;
begin
  Printer.BeginDoc;
  try
    FormImage := GetFormImage;
    Canvas.Lock;
    try
      { Paint bitmap to the printer }
      with Printer, Canvas do
      begin
        Bits := FormImage.Handle;
        GetDIBSizes(Bits, InfoSize, ImageSize);
        Info := AllocMem(InfoSize);
        try
          Image := AllocMem(ImageSize);
          try
            GetDIB(Bits, 0, Info^, Image^);
            with Info^.bmiHeader do
            begin
              DIBWidth := biWidth;
              DIBHeight := biHeight;
            end;
            case PrintScale of
              poProportional:
                begin
                  PrintWidth := MulDiv(DIBWidth, GetDeviceCaps(Handle,
                    LOGPIXELSX), PixelsPerInch);
                  PrintHeight := MulDiv(DIBHeight, GetDeviceCaps(Handle,
                    LOGPIXELSY), PixelsPerInch);
                end;
              poPrintToFit:
                begin
                  PrintWidth := MulDiv(DIBWidth, PageHeight, DIBHeight);
                  if PrintWidth < PageWidth then
                    PrintHeight := PageHeight
                  else
                  begin
                    PrintWidth := PageWidth;
                    PrintHeight := MulDiv(DIBHeight, PageWidth, DIBWidth);
                  end;
                end;
            else
              PrintWidth := DIBWidth;
              PrintHeight := DIBHeight;
            end;
            StretchDIBits(Canvas.Handle, 0, 0, PrintWidth, PrintHeight, 0, 0,
              DIBWidth, DIBHeight, Image, Info^, DIB_RGB_COLORS, SRCCOPY);
          finally
            FreeMem(Image, ImageSize);
          end;
        finally
          FreeMem(Info, InfoSize);
        end;
      end;
    finally
      Canvas.Unlock;
      FormImage.Free;
    end;
  finally
    Printer.EndDoc;
  end;
end;

procedure TCustomForm.Hide;
begin
  Visible := False;
end;

procedure TCustomForm.Show;
begin
  Visible := True;
  BringToFront;
end;

procedure TCustomForm.SetFocus;
begin
  if not FActive then
  begin
    if not (Visible and Enabled) then
      raise EInvalidOperation.Create(SCannotFocus);
    SetWindowFocus;
  end;
end;

procedure TCustomForm.Release;
begin
  PostMessage(Handle, CM_RELEASE, 0, 0);
end;

function TCustomForm.ShowModal: Integer;
var
  WindowList: Pointer;
  SaveFocusCount: Integer;
  SaveCursor: TCursor;
  SaveCount: Integer;
  ActiveWindow: HWnd;
begin
  CancelDrag;
  if Visible or not Enabled or (fsModal in FFormState) or
    (FormStyle = fsMDIChild) then
    raise EInvalidOperation.Create(SCannotShowModal);
  if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
  ReleaseCapture;
  Include(FFormState, fsModal);
  ActiveWindow := GetActiveWindow;
  SaveFocusCount := FocusCount;
  Screen.FSaveFocusedList.Insert(0, Screen.FFocusedForm);
  Screen.FFocusedForm := Self;
  SaveCursor := Screen.Cursor;
  Screen.Cursor := crDefault;
  SaveCount := Screen.FCursorCount;
  WindowList := DisableTaskWindows(0);
  try
    Show;
    try
      SendMessage(Handle, CM_ACTIVATE, 0, 0);
      ModalResult := 0;
      repeat
        Application.HandleMessage;
        if Application.FTerminate then ModalResult := mrCancel else
          if ModalResult <> 0 then CloseModal;
      until ModalResult <> 0;
      Result := ModalResult;
      SendMessage(Handle, CM_DEACTIVATE, 0, 0);
      if GetActiveWindow <> Handle then ActiveWindow := 0;
    finally
      Hide;
    end;
  finally
    if Screen.FCursorCount = SaveCount then
      Screen.Cursor := SaveCursor
    else Screen.Cursor := crDefault;
    EnableTaskWindows(WindowList);
    if Screen.FSaveFocusedList.Count > 0 then
    begin
      Screen.FFocusedForm := Screen.FSaveFocusedList.First;
      Screen.FSaveFocusedList.Remove(Screen.FFocusedForm);
    end else Screen.FFocusedForm := nil;
    if ActiveWindow <> 0 then SetActiveWindow(ActiveWindow);
    FocusCount := SaveFocusCount;
    Exclude(FFormState, fsModal);
  end;
end;

procedure TCustomForm.UpdateActions;
var
  I: Integer;
  
  procedure TraverseClients(Container: TWinControl);
  var
    I: Integer;
    Control: TControl;
  begin
    if Container.Showing then
      for I := 0 to Container.ControlCount - 1 do
      begin
        Control := Container.Controls[I];
        if (csActionClient in Control.ControlStyle) and Control.Visible then
            Control.InitiateAction;
        if Control is TWinControl then
          TraverseClients(TWinControl(Control));
      end;
  end;

begin
  if (csDesigning in ComponentState) or not Showing then Exit;
  { Update form }
  InitiateAction;
  { Update main menu's top-most items }
  if Menu <> nil then
    for I := 0 to Menu.Items.Count - 1 do
      with Menu.Items[I] do
        if Visible then InitiateAction;
  { Update any controls }
  TraverseClients(Self);
end;

procedure TCustomForm.UpdateWindowState;
var
  Placement: TWindowPlacement;
begin
  if HandleAllocated then
  begin
    Placement.length := SizeOf(TWindowPlacement);
    GetWindowPlacement(Handle, @Placement);
    case Placement.showCmd of
      SW_SHOWMINIMIZED: FWindowState := wsMinimized;
      SW_SHOWMAXIMIZED: FWindowState := wsMaximized;
    else
      FWindowState := wsNormal;
    end;
  end;
end;

procedure TCustomForm.RequestAlign;
begin
  if Parent = nil then
    Screen.AlignForm(Self)
  else
    inherited RequestAlign;
end;

procedure TCustomForm.WMSettingChange(var Message: TMessage);
begin
  inherited;
  if Message.WParam = SPI_SETWORKAREA then
    RequestAlign;
end;

procedure TCustomForm.CMActionExecute(var Message: TMessage);

  function ProcessExecute(Control: TControl): Boolean;
  begin
    Result := (Control <> nil) and
      Control.ExecuteAction(TBasicAction(Message.LParam));
  end;

  function TraverseClients(Container: TWinControl): Boolean;
  var
    I: Integer;
    Control: TControl;
  begin
    if Container.Showing then
      for I := 0 to Container.ControlCount - 1 do
      begin
        Control := Container.Controls[I];
        if Control.Visible and ProcessExecute(Control) or
          (Control is TWinControl) and TraverseClients(TWinControl(Control)) then
        begin
          Result := True;
          Exit;
        end;
      end;
    Result := False;
  end;

begin
  if (csDesigning in ComponentState) or not Showing then Exit;
  { Find a target for given Command (Message.LParam). }
  if ProcessExecute(ActiveControl) or ProcessExecute(Self) or
    TraverseClients(Self) then
    Message.Result := 1;
end;

procedure TCustomForm.CMActionUpdate(var Message: TMessage);

  function ProcessUpdate(Control: TControl): Boolean;
  begin
    Result := (Control <> nil) and
      Control.UpdateAction(TBasicAction(Message.LParam));
  end;

  function TraverseClients(Container: TWinControl): Boolean;
  var
    I: Integer;
    Control: TControl;
  begin
    if Container.Showing then
      for I := 0 to Container.ControlCount - 1 do
      begin
        Control := Container.Controls[I];
        if Control.Visible and ProcessUpdate(Control) or
          (Control is TWinControl) and TraverseClients(TWinControl(Control)) then
        begin
          Result := True;
          Exit;
        end;
      end;
    Result := False;
  end;

begin
  if (csDesigning in ComponentState) or not Showing then Exit;
  { Find a target for given Command (Message.LParam). }
  if ProcessUpdate(ActiveControl) or ProcessUpdate(Self) or
    TraverseClients(Self) then
    Message.Result := 1;
end;

function TCustomForm.IsShortCut(var Message: TWMKey): Boolean;

  function DispatchShortCut: Boolean;
  var
    I: Integer;
  begin
    if FActionLists <> nil then
      for I := 0 to FActionLists.Count - 1 do
        if TCustomActionList(FActionLists[I]).IsShortCut(Message) then
        begin
          Result := True;
          Exit;
        end;
    Result := False;
  end;

begin
  Result := False;
  if Assigned(FOnShortCut) then FOnShortCut(Message, Result);
  Result := Result or (Menu <> nil) and (Menu.WindowHandle <> 0) and
    Menu.IsShortCut(Message) or DispatchShortCut;
end;

function TCustomForm.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if IsEqualIID(IID, IDesignerNotify) or IsEqualIID(IID, IDesigner) then
  begin
    Result := S_OK;
    IUnknown(Obj) := Designer;
  end
  else
    Result := inherited QueryInterface(IID, Obj);
end;

procedure TCustomForm.MouseWheelHandler(var Message: TMessage);
begin
  with Message do
  begin
    if FFocusedControl <> nil then
      Result := FFocusedControl.Perform(CM_MOUSEWHEEL, WParam, LParam)
    else
      inherited MouseWheelHandler(Message);
  end;
end;
