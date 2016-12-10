{*******************************************************}
{                                                       }
{       FMX UI Frame ����Ԫ                           }
{                                                       }
{       ��Ȩ���� (C) 2016 YangYxd                       }
{                                                       }
{*******************************************************}

unit UI.Frame;

interface

uses
  UI.Base, UI.Toast, UI.Dialog,
  System.NetEncoding,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Generics.Collections, System.Rtti, System.SyncObjs,
  {$IFDEF ANDROID}
  FMX.Platform.Android,
  FMX.VirtualKeyboard.Android,
  {$ENDIF}
  {$IFDEF POSIX}Posix.Signal, {$ENDIF}
  FMX.Ani, FMX.VirtualKeyboard,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Platform, IOUtils;

type
  TFrameView = class;
  TFrameViewClass = class of TFrameView;

  /// <summary>
  /// Frame ����
  /// </summary>
  TFrameParams = class(TDictionary<string, TValue>);

  TFrameDataType = (fdt_Integer, fdt_Long, fdt_Int64, fdt_Float, fdt_String,
    fdt_DateTime, fdt_Number, fdt_Boolean);

  TFrameDataValue = record
    DataType: TFrameDataType;
    Value: TValue;
  end;

  /// <summary>
  /// Frame ״̬����
  /// </summary>
  TFrameStateData = class(TDictionary<string, TFrameDataValue>);

  TFrameStateDataHelper = class helper for TFrameStateData
    function GetDataValue(DataType: TFrameDataType; const Value: TValue): TFrameDataValue;
    function GetString(const Key: string): string;
    function GetInt(const Key: string; const DefaultValue: Integer = 0): Integer;
    function GetLong(const Key: string; const DefaultValue: Cardinal = 0): Cardinal;
    function GetInt64(const Key: string; const DefaultValue: Int64 = 0): Int64;
    function GetFloat(const Key: string; const DefaultValue: Double = 0): Double;
    function GetDateTime(const Key: string; const DefaultValue: TDateTime = 0): TDateTime;
    function GetNumber(const Key: string; const DefaultValue: NativeUInt = 0): NativeUInt;
    function GetPointer(const Key: string): Pointer;
    function GetBoolean(const Key: string; const DefaultValue: Boolean = False): Boolean;

    procedure Put(const Key: string; const Value: string); overload; inline;
    procedure Put(const Key: string; const Value: Integer); overload; inline;
    procedure Put(const Key: string; const Value: Cardinal); overload; inline;
    procedure Put(const Key: string; const Value: Int64); overload; inline;
    procedure Put(const Key: string; const Value: Double); overload; inline;
    procedure Put(const Key: string; const Value: NativeUInt); overload; inline;
    procedure Put(const Key: string; const Value: Boolean); overload; inline;
    procedure PutDateTime(const Key: string; const Value: TDateTime); inline;
  end;

  TFrameParamsHelper = class helper for TFrameParams
    function GetString(const Key: string): string;
    function GetInt(const Key: string; const DefaultValue: Integer = 0): Integer;
    function GetLong(const Key: string; const DefaultValue: Cardinal = 0): Cardinal;
    function GetInt64(const Key: string; const DefaultValue: Int64 = 0): Int64;
    function GetFloat(const Key: string; const DefaultValue: Double = 0): Double;
    function GetDateTime(const Key: string; const DefaultValue: TDateTime = 0): TDateTime;
    function GetNumber(const Key: string; const DefaultValue: NativeUInt = 0): NativeUInt;
    function GetPointer(const Key: string): Pointer;
    function GetBoolean(const Key: string; const DefaultValue: Boolean = False): Boolean;

    procedure Put(const Key: string; const Value: string); overload;
    procedure Put(const Key: string; const Value: Integer); overload;
    procedure Put(const Key: string; const Value: Cardinal); overload;
    procedure Put(const Key: string; const Value: Int64); overload;
    procedure Put(const Key: string; const Value: Double); overload;
    procedure Put(const Key: string; const Value: NativeUInt); overload;
    procedure Put(const Key: string; const Value: Boolean); overload;
    procedure PutDateTime(const Key: string; const Value: TDateTime);
  end;

  /// <summary>
  /// Frame ״̬
  /// </summary>
  TFrameState = class(TObject)
  private
    [Weak] FOwner: TComponent;
    FData: TFrameStateData;
    FIsChange: Boolean;
    FIsPublic: Boolean;
    FIsLoad: Boolean;
    FLocker: TCriticalSection;
    function GetCount: Integer;
    function GetStoragePath: string;
    procedure SetStoragePath(const Value: string);
  protected
    procedure InitData;
    procedure DoValueNotify(Sender: TObject; const Item: TFrameDataValue;
      Action: TCollectionNotification);
    function GetUniqueName: string;
    procedure Load();
  public
    constructor Create(AOwner: TComponent; IsPublic: Boolean);
    destructor Destroy; override;

    procedure Clear();
    procedure Save();

    function Exist(const Key: string): Boolean;
    function ContainsKey(const Key: string): Boolean;

    function GetString(const Key: string): string;
    function GetInt(const Key: string; const DefaultValue: Integer = 0): Integer;
    function GetLong(const Key: string; const DefaultValue: Cardinal = 0): Cardinal;
    function GetInt64(const Key: string; const DefaultValue: Int64 = 0): Int64;
    function GetFloat(const Key: string; const DefaultValue: Double = 0): Double;
    function GetDateTime(const Key: string; const DefaultValue: TDateTime = 0): TDateTime;
    function GetNumber(const Key: string; const DefaultValue: NativeUInt = 0): NativeUInt;
    function GetBoolean(const Key: string; const DefaultValue: Boolean = False): Boolean;

    procedure Put(const Key: string; const Value: string); overload;
    procedure Put(const Key: string; const Value: Integer); overload;
    procedure Put(const Key: string; const Value: Cardinal); overload;
    procedure Put(const Key: string; const Value: Int64); overload;
    procedure Put(const Key: string; const Value: Double); overload;
    procedure Put(const Key: string; const Value: NativeUInt); overload;
    procedure Put(const Key: string; const Value: Boolean); overload;
    procedure PutDateTime(const Key: string; const Value: TDateTime);

    property Data: TFrameStateData read FData;
    property Count: Integer read GetCount;
    property StoragePath: string read GetStoragePath write SetStoragePath;
  end;

  /// <summary>
  /// ��������
  /// </summary>
  TFrameAniType = (None, DefaultAni {Ĭ��}, FadeInOut {���뵭��});

  TNotifyEventA = reference to procedure (Sender: TObject);

  TDelayExecute = class(TAnimation)
  protected
    procedure ProcessAnimation; override;
    procedure FirstFrame; override;
  public
    procedure Start; override;
    procedure Stop; override;
  end;

  TFrameAnimator = class
  private type
    TFrameAnimatorEvent = record
      OnFinish: TNotifyEvent;
      OnFinishA: TNotifyEventA;
    end;
    TAnimationDestroyer = class
    private
      FOnFinishs: TDictionary<Integer, TFrameAnimatorEvent>;
      procedure DoAniFinished(Sender: TObject);
      procedure DoAniFinishedEx(Sender: TObject; FreeSender: Boolean);
    public
      constructor Create();
      destructor Destroy; override;
      procedure Add(Sender: TObject; AOnFinish: TNotifyEvent); overload;
      procedure Add(Sender: TObject; AOnFinish: TNotifyEventA); overload;
    end;
  private class var
    FDestroyer: TAnimationDestroyer;
  private
    class procedure CreateDestroyer;
    class procedure Uninitialize;
  public
    /// <summary>
    /// ��ʱִ������
    /// </summary>
    class procedure DelayExecute(const Owner: TFmxObject; AOnFinish: TNotifyEventA; Delay: Single = 1.0);

    class procedure AnimateFloat(const Target: TFmxObject;
      const APropertyName: string; const NewValue: Single;
      AOnFinish: TNotifyEvent = nil; Duration: Single = 0.2;
      Delay: Single = 0.0; AType: TAnimationType = TAnimationType.In;
      AInterpolation: TInterpolationType = TInterpolationType.Linear); overload;
    class procedure AnimateFloat(const Target: TFmxObject;
      const APropertyName: string; const NewValue: Single;
      AOnFinish: TNotifyEventA; Duration: Single = 0.2;
      Delay: Single = 0.0; AType: TAnimationType = TAnimationType.In;
      AInterpolation: TInterpolationType = TInterpolationType.Linear); overload;

    class procedure AnimateInt(const Target: TFmxObject;
      const APropertyName: string; const NewValue: Integer;
      AOnFinish: TNotifyEvent = nil; Duration: Single = 0.2;
      Delay: Single = 0.0; AType: TAnimationType = TAnimationType.In;
      AInterpolation: TInterpolationType = TInterpolationType.Linear); overload;
    class procedure AnimateInt(const Target: TFmxObject;
      const APropertyName: string; const NewValue: Integer;
      AOnFinish: TNotifyEventA; Duration: Single = 0.2;
      Delay: Single = 0.0; AType: TAnimationType = TAnimationType.In;
      AInterpolation: TInterpolationType = TInterpolationType.Linear); overload;

    class procedure AnimateColor(const Target: TFmxObject;
      const APropertyName: string; NewValue: TAlphaColor;
      AOnFinish: TNotifyEvent = nil; Duration: Single = 0.2;
      Delay: Single = 0.0; AType: TAnimationType = TAnimationType.In;
      AInterpolation: TInterpolationType = TInterpolationType.Linear); overload;
    class procedure AnimateColor(const Target: TFmxObject;
      const APropertyName: string; NewValue: TAlphaColor;
      AOnFinish: TNotifyEventA; Duration: Single = 0.2;
      Delay: Single = 0.0; AType: TAnimationType = TAnimationType.In;
      AInterpolation: TInterpolationType = TInterpolationType.Linear); overload;
  end;

  TCustomFormHelper = class Helper for TCustomForm
  public
    procedure SetFocus();
  end;

  /// <summary>
  /// Frame ��ͼ, Frame �л�����
  /// </summary>
  [ComponentPlatformsAttribute(AllCurrentPlatforms)]
  TFrameView = class(FMX.Forms.TFrame)
  private
    FParams: TFrameParams;
    FPrivateState: TFrameState;
    FBackColor: TAlphaColor;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    FOnFinish: TNotifyEvent;
    FOnReStart: TNotifyEvent;
    FWaitDialog: TProgressDialog;
    FShowing: Boolean;    // ������ʾ��
    FHideing: Boolean;    // ����������
    FAnimateing: Boolean; // ����ִ����
    FNeedFree: Boolean;   // ��Ҫ�ͷ�
    FNeedHide: Boolean;   // ��Ҫ����
    procedure SetParams(const Value: TFrameParams);
    function GetTitle: string;
    procedure SetTitle(const Value: string);
    function GetPreferences: TFrameState;
    function GetSharedPreferences: TFrameState;
    function GetParams: TFrameParams;
    function GetDataAsPointer: Pointer;
    function GetIsWaitDismiss: Boolean;
    function GetStatusColor: TAlphaColor;
    procedure SetStatusColor(const Value: TAlphaColor);
    function GetParentForm: TCustomForm;
    procedure SetBackColor(const Value: TAlphaColor);
  protected
    [Weak] FLastView: TFrameView;
    [Weak] FNextView: TFrameView;
    function MakeFrame(FrameClass: TFrameViewClass): TFrameView; overload;

    procedure DoCreate(); virtual;
    procedure DoShow(); virtual;
    procedure DoHide(); virtual;
    procedure DoFinish(); virtual;
    procedure DoReStart(); virtual;
    procedure DoFree(); virtual;

    function GetData: TValue; override;
    procedure SetData(const Value: TValue); override;

    function FinishIsFreeApp: Boolean;

    // ����Ƿ���Ҫ�ͷţ������Ҫ�����ͷŵ�
    function CheckFree(): Boolean;
    // �ڲ� Show ʵ��
    procedure InternalShow(TriggerOnShow: Boolean;
      AOnFinish: TNotifyEventA = nil; Ani: TFrameAniType = TFrameAniType.DefaultAni);
    procedure InternalHide();
  protected
    procedure Paint; override;
    procedure AfterDialogKey(var Key: Word; Shift: TShiftState); override;
  protected
    /// <summary>
    /// ���Ŷ���
    /// </summary>
    procedure AnimatePlay(Ani: TFrameAniType; IsIn: Boolean; AEvent: TNotifyEventA);

    procedure OnFinishOrClose(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>
    /// ���� Frame Ĭ�ϱ�����ɫ
    /// </summary>
    class procedure SetDefaultBackColor(const Value: TAlphaColor);

    /// <summary>
    /// ���� Frame Ĭ��״̬����ɫ
    /// </summary>
    class procedure SetDefaultStatusColor(const Value: TAlphaColor);

    /// <summary>
    /// ��ת��Ϊ string
    /// </summary>
    function StreamToString(SrcStream: TStream; const CharSet: string = ''): string;

    /// <summary>
    /// ��ʾ�ȴ��Ի���
    /// </summary>
    procedure ShowWaitDialog(const AMsg: string; ACancelable: Boolean = True); overload;
    procedure ShowWaitDialog(const AMsg: string; OnDismissListener: TOnDialogListener; ACancelable: Boolean = True); overload;
    procedure ShowWaitDialog(const AMsg: string; OnDismissListener: TOnDialogListenerA; ACancelable: Boolean = True); overload;
    /// <summary>
    /// ���صȴ��Ի���
    /// </summary>
    procedure HideWaitDialog();

    /// <summary>
    /// ��ʾ Frame
    /// </summary>
    class function ShowFrame(Parent: TFmxObject; Params: TFrameParams): TFrameView; overload;
    /// <summary>
    /// ��ʾ Frame
    /// </summary>
    class function ShowFrame(Parent: TFmxObject; const Title: string = ''): TFrameView; overload;
    /// <summary>
    /// ��ʾ Frame
    /// </summary>
    class function CreateFrame(Parent: TFmxObject; Params: TFrameParams): TFrameView; overload;
    /// <summary>
    /// ��ʾ Frame
    /// </summary>
    class function CreateFrame(Parent: TFmxObject; const Title: string = ''): TFrameView; overload;

    /// <summary>
    /// ��ʼһ����ͼ�������ص�ǰ��ͼ
    /// </summary>
    function StartFrame(FrameClass: TFrameViewClass; Ani: TFrameAniType = TFrameAniType.DefaultAni): TFrameView; overload;
    /// <summary>
    /// ��ʼһ����ͼ�������ص�ǰ��ͼ
    /// </summary>
    function StartFrame(FrameClass: TFrameViewClass; Params: TFrameParams; Ani: TFrameAniType = TFrameAniType.DefaultAni): TFrameView; overload;
    /// <summary>
    /// ��ʼһ����ͼ�������ص�ǰ��ͼ
    /// </summary>
    function StartFrame(FrameClass: TFrameViewClass; const Title: string; Ani: TFrameAniType = TFrameAniType.DefaultAni): TFrameView; overload;
    /// <summary>
    /// ��ʼһ����ͼ�������ص�ǰ��ͼ
    /// </summary>
    function StartFrame(FrameClass: TFrameViewClass; const Title: string; const Data: Pointer; Ani: TFrameAniType = TFrameAniType.DefaultAni): TFrameView; overload;

    /// <summary>
    /// ��ʾһ����ʾ��Ϣ
    /// </summary>
    procedure Hint(const Msg: string); overload;
    procedure Hint(const Msg: Double); overload;
    procedure Hint(const Msg: Int64); overload;
    procedure Hint(const AFormat: string; const Args: array of const); overload;

    /// <summary>
    /// ��ʱִ������
    /// </summary>
    procedure DelayExecute(ADelay: Single; AExecute: TNotifyEventA);

    /// <summary>
    /// ��ʾ Frame
    /// </summary>
    procedure Show(); overload; override;
    procedure Show(Ani: TFrameAniType; AOnFinish: TNotifyEventA); reintroduce; overload;
    /// <summary>
    /// �ر� Frame
    /// </summary>
    procedure Close(); overload;
    procedure Close(Ani: TFrameAniType); overload; virtual;
    /// <summary>
    /// ���� Frame
    /// </summary>
    procedure Hide(); overload; override;
    procedure Hide(Ani: TFrameAniType); reintroduce; overload;
    /// <summary>
    /// ��ɵ�ǰ Frame (������һ�� Frame �� �ر�)
    /// </summary>
    procedure Finish(); overload; virtual;
    procedure Finish(Ani: TFrameAniType); overload; virtual;

    /// <summary>
    /// ����ʱ�Ĳ���
    /// </summary>
    property Params: TFrameParams read GetParams write SetParams;
    /// <summary>
    /// ������Frame��Frame
    /// </summary>
    property Last: TFrameView read FLastView;

    /// <summary>
    /// ˽��Ԥ����� (˽�У����̰߳�ȫ)
    /// </summary>
    property Preferences: TFrameState read GetPreferences;
    /// <summary>
    /// ����Ԥ����� (ȫ�֣����̰߳�ȫ)
    /// </summary>
    property SharedPreferences: TFrameState read GetSharedPreferences;
    /// <summary>
    /// �Ƿ�����Show
    /// </summary>
    property Showing: Boolean read FShowing;

    property DataAsPointer: Pointer read GetDataAsPointer;

    /// <summary>
    /// ��ǰ Frame ���󶨵� Form ����
    /// </summary>
    property ParentForm: TCustomForm read GetParentForm;

    /// <summary>
    /// �ȴ��Ի����Ƿ�ȡ����
    /// </summary>
    property IsWaitDismiss: Boolean read GetIsWaitDismiss;
  published
    property Title: string read GetTitle write SetTitle;
    /// <summary>
    /// ������ɫ
    /// </summary>
    property BackColor: TAlphaColor read FBackColor write SetBackColor;
    /// <summary>
    /// APP ����״̬����ɫ
    /// </summary>
    property StatusColor: TAlphaColor read GetStatusColor write SetStatusColor;

    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnFinish: TNotifyEvent read FOnFinish write FOnFinish;
    property OnReStart: TNotifyEvent read FOnReStart write FOnReStart;
  end;

type
  TFrame = class(TFrameView);

var
  MainFormMinChildren: Integer = 1;
  /// <summary>
  /// Ĭ�Ϲ�������
  /// </summary>
  DefaultAnimate: TFrameAniType = TFrameAniType.FadeInOut;

implementation

{$IFDEF ANDROID}
uses
  Androidapi.Helpers,
  Androidapi.Jni,
  //Androidapi.JNI.Media,
  //Androidapi.JNIBridge,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Util,
  Androidapi.JNI.App,
  Androidapi.JNI.Os,
  FMX.Helpers.Android;
{$ENDIF}

const
  CS_Title = 'cs_p_title';
  CS_Data = 'cs_p_data';

var
  /// <summary>
  /// ����״̬����
  /// </summary>
  FPublicState: TFrameState = nil;

  FDefaultBackColor: TAlphaColor = 0;
  FDefaultStatusColor: TAlphaColor = 0;

{$IFDEF ANDROID}

// �����ʱ���ؼ�ʧЧ����
var
  FVKState: PByte = nil;

procedure UpdateAndroidKeyboardServiceState;
var
  ASvc: IFMXVirtualKeyboardService;
  AContext: TRttiContext;
  AType: TRttiType;
  AField: TRttiField;
  AInst: TVirtualKeyboardAndroid;
begin
  Exit;
  if not Assigned(FVKState) then begin
    if (not Assigned(Screen.FocusControl)) and
      TPlatformServices.Current.SupportsPlatformService
      (IFMXVirtualKeyboardService, ASvc) then
    begin
      AInst := ASvc as TVirtualKeyboardAndroid;
      AContext := TRttiContext.Create;
      AType := AContext.GetType(TVirtualKeyboardAndroid);
      AField := AType.GetField('FState');
      if AField.GetValue(AInst).AsOrdinal <> 0 then
      begin
        FVKState := PByte(AInst);
        Inc(FVKState, AField.Offset);
      end;
    end;
  end;
  if Assigned(FVKState) and (FVKState^ <> 0) then
    FVKState^ := 0;
end;
{$ENDIF}

{ TFrameView }

procedure TFrameView.AfterDialogKey(var Key: Word; Shift: TShiftState);
begin
  // ��������˷��ؼ���������ȡ���Ի�����رնԻ���
  if Assigned(Self) and (Key in [vkEscape, vkHardwareBack]) then begin
    Key := 0;
    Finish;
  end else
    inherited AfterDialogKey(Key, Shift);
end;

procedure TFrameView.AnimatePlay(Ani: TFrameAniType; IsIn: Boolean;
  AEvent: TNotifyEventA);

  procedure FadeIntOut();
  var
    NewValue: Single;
  begin
    if IsIn then begin
      Self.Opacity := 0;
      NewValue := 1;
    end else begin
      NewValue := 0;
      if FinishIsFreeApp then begin
        if Assigned(AEvent) then
          AEvent(Self);
        Exit;
      end;
    end;
    TFrameAnimator.AnimateFloat(Self, 'Opacity', NewValue, AEvent);
  end;

begin
  case Ani of
    None:
      begin
        if Assigned(AEvent) then
          AEvent(Self);
        if IsIn then
          Opacity := 1
        else
          Opacity := 0;
      end;
    DefaultAni:
      if not (DefaultAnimate in [TFrameAniType.None, TFrameAniType.DefaultAni]) then
        AnimatePlay(DefaultAnimate, IsIn, AEvent)
      else if Assigned(AEvent) then
        AEvent(Self);
    FadeInOut:
      FadeIntOut;
  end;
end;

function TFrameView.CheckFree: Boolean;

  function CheckChildern(): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 0 to Parent.ChildrenCount - 1 do begin
      if Parent.Children[I] is FMX.Forms.TFrame then begin
        Result := False;
        Exit;
      end;
    end;
  end;

begin
  Result := False;
  if Assigned(Parent) then begin
    if not Assigned(Parent.Parent) then begin
      if (Parent is TForm) then begin
        if (Parent.ChildrenCount <= MainFormMinChildren + 1) or (CheckChildern()) then begin
          {$IFDEF POSIX}
            {$IFDEF DEBUG}
            (Parent as TForm).Close;
            {$ELSE}
            Kill(0, SIGKILL);
            {$ENDIF}
          {$ELSE}
          (Parent as TForm).Close;
          {$ENDIF}
          Result := True;
          Exit;
        end;
      end;
    end;
    Parent.RemoveObject(Self);
    {$IFDEF ANDROID}
    if (not Assigned(Screen.FocusControl)) and (Assigned(ParentForm)) then
      ParentForm.SetFocus;
    {$ENDIF}
    {$IFDEF MSWINDOWS}
    Self.Free;
    {$ELSE}
    Self.DisposeOf;
    {$ENDIF}
  end;
end;

procedure TFrameView.Close;
begin
  Close(TFrameAniType.DefaultAni);
end;

procedure TFrameView.Close(Ani: TFrameAniType);
begin
  // ����ִ���У� ������Ҫ�رյı�ʶ
  if FAnimateing then
    FNeedFree := True
  else begin
    FAnimateing := True;
    AnimatePlay(Ani, False, OnFinishOrClose);
    FAnimateing := False;
  end;
end;

class function TFrameView.CreateFrame(Parent: TFmxObject;
  Params: TFrameParams): TFrameView;
var
  Dlg: IDialog;
begin
  Result := nil;
  if (Assigned(Parent)) then begin
    try
      // ����Ƿ��Ǵ���Dialog
      if Parent is TControl then begin
        Dlg := TDialog.GetDialog(Parent as TControl);
        if Assigned(Dlg) then begin
          Parent := Dlg.View;
          while Parent <> nil do begin
            if (Parent is TFrameView) or (Parent is TCustomForm) then begin
              ShowFrame(Parent, Params);
              Break;
            end;
            Parent := Parent.Parent;
          end;
          Dlg.Dismiss;
          Exit;
        end;
      end;

      Result := Create(Parent);
      Result.Name := '';
      Result.Parent := Parent;
      Result.Align := TAlignLayout.Client;
      Result.FLastView := nil;
      Result.TagObject := Params;
    except
      if Assigned(Params) then
        Params.Free;
      raise;
    end;
  end else if Assigned(Params) then
    Params.Free;
end;

constructor TFrameView.Create(AOwner: TComponent);
begin
  try
    inherited Create(AOwner);
  except
    Width := 200;
    Height := 400;
  end;
  FBackColor := FDefaultBackColor;
  DoCreate();
end;

class function TFrameView.CreateFrame(Parent: TFmxObject;
  const Title: string): TFrameView;
begin
  Result := CreateFrame(Parent, nil);
  if Result <> nil then
    Result.Title := Title;
end;

function TFrameView.MakeFrame(FrameClass: TFrameViewClass): TFrameView;
begin
  Result := FrameClass.Create(Parent);
  Result.Name := '';
  Result.Parent := Parent;
  Result.Align := TAlignLayout.Client;
  Result.FLastView := Self;
  FNextView := Result;
end;

procedure TFrameView.OnFinishOrClose(Sender: TObject);
begin
  if FNeedHide then
    InternalHide;
  if CheckFree then Exit;
end;

procedure TFrameView.Paint;
var
  R: TRectF;
begin
  inherited Paint;
  if (FBackColor and $FF000000 > 0) then
  begin
    R := LocalRect;
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := FBackColor;
    Canvas.FillRect(R, 0, 0, AllCorners, AbsoluteOpacity);
  end;
end;

procedure TFrameView.DelayExecute(ADelay: Single; AExecute: TNotifyEventA);
begin
  if not Assigned(AExecute) then
    Exit;
  TFrameAnimator.DelayExecute(Self, AExecute, ADelay);
end;

destructor TFrameView.Destroy;
var
  Obj: TObject;
begin
  DoFree();
  Obj := TagObject;
  if Assigned(Obj) then
    FreeAndNil(Obj);
  if Assigned(FNextView) then
    FNextView.FLastView := nil;
  FLastView := nil;
  FNextView := nil;
  FreeAndNil(FParams);
  FreeAndNil(FPrivateState);
  inherited;
end;

procedure TFrameView.DoCreate;
begin
end;

procedure TFrameView.DoFinish;
begin
  if Assigned(FOnFinish) then
    FOnFinish(Self);
end;

procedure TFrameView.DoFree;
begin
end;

procedure TFrameView.DoHide;
begin
  if Assigned(FOnHide) then
    FOnHide(Self);
end;

procedure TFrameView.DoReStart;
begin
  if Assigned(FOnReStart) then
    FOnReStart(Self);
end;

procedure TFrameView.DoShow;
begin
  if FDefaultStatusColor <> 0 then
    StatusColor := FDefaultStatusColor;
  if Assigned(FOnShow) then
    FOnShow(Self);
end;

procedure TFrameView.Finish(Ani: TFrameAniType);
begin
  DoFinish();
  if Assigned(FNextView) then begin
    FNextView.FLastView := FLastView;
    FLastView := nil;
    FNextView := nil;
  end else if Assigned(FLastView) then begin
    FLastView.InternalShow(False);
    FLastView.FNextView := nil;
    FLastView := nil;
  end;
  Close(Ani);
end;

procedure TFrameView.Finish;
begin
  Finish(TFrameAniType.DefaultAni);
end;

function TFrameView.GetData: TValue;
begin
  if (FParams = nil) or (not FParams.ContainsKey(CS_Data)) then
    Result := nil
  else
    Result := FParams.Items[CS_Data];
end;

function TFrameView.GetDataAsPointer: Pointer;
var
  V: TValue;
begin
  V := Data;
  if V.IsEmpty then
    Result := nil
  else
    Result := V.AsVarRec.VPointer;
end;

function TFrameView.GetIsWaitDismiss: Boolean;
begin
  Result := Assigned(FWaitDialog) and (FWaitDialog.IsDismiss);
end;

function TFrameView.GetParams: TFrameParams;
begin
  if FParams = nil then begin
    if (TagObject <> nil) and (TagObject is TFrameParams) then begin
      FParams := TagObject as TFrameParams;
      TagObject := nil;
    end else
      FParams := TFrameParams.Create(9);
  end;
  Result := FParams;
end;

function TFrameView.GetParentForm: TCustomForm;
var
  V: TFmxObject;
begin
  Result := nil;
  V := Parent;
  while Assigned(V) do begin
    if V is TCustomForm then begin
      Result := V as TCustomForm;
      Break;
    end;
    V := V.Parent;
  end;
end;

function TFrameView.GetPreferences: TFrameState;
begin
  if not Assigned(FPrivateState) then begin
    FPrivateState := TFrameState.Create(Self, False);
    FPrivateState.Load;
  end;
  Result := FPrivateState;
end;

function TFrameView.GetSharedPreferences: TFrameState;
begin
  Result := FPublicState;
end;

function TFrameView.GetStatusColor: TAlphaColor;

  {$IFDEF IOS}
  function ExecuteIOS(): TAlphaColor;
  var
    F: TCustomForm;
  begin
    F := ParentForm;
    if not Assigned(F) then
      Result := 0
    else
      Result := F.Fill.Color;
  end;
  {$ENDIF}
  
  {$IFDEF ANDROID}
  function ExecuteAndroid(): TAlphaColor;
  var
    wnd: JWindow;
  begin
    if TJBuild_VERSION.JavaClass.SDK_INT < 21 then
      Result := 0
    else begin
      wnd := TAndroidHelper.Activity.getWindow();
      if Assigned(wnd) then 
        Result := wnd.getStatusBarColor()
      else
        Result := 0;
    end;
  end;
  {$ENDIF}

begin
  {$IFDEF IOS}
  Result := ExecuteIOS();
  Exit;
  {$ENDIF}
  {$IFDEF ANDROID}
  Result := ExecuteAndroid();
  Exit;
  {$ENDIF}
  Result := 0;
end;

function TFrameView.GetTitle: string;
begin
  if (FParams = nil) or (not FParams.ContainsKey(CS_Title)) then
    Result := ''
  else
    Result := FParams.Items[CS_Title].ToString;
end;

procedure TFrameView.Hide;
begin
  if FHideing then
    Exit;
  Hide(TFrameAniType.DefaultAni);
end;

procedure TFrameView.Hide(Ani: TFrameAniType);
begin
  if FAnimateing then
    FNeedHide := True
  else begin
    FAnimateing := True;
    AnimatePlay(Ani, False,
      procedure (Sender: TObject) begin
        InternalHide;
        if FNeedFree then
          OnFinishOrClose(Sender);
        FAnimateing := False;
      end
    );
  end;
end;

procedure TFrameView.HideWaitDialog;
begin
  if Assigned(Self) and Assigned(FWaitDialog) then begin
    FWaitDialog.Dismiss;
    FWaitDialog := nil;
  end;
end;

procedure TFrameView.Hint(const AFormat: string; const Args: array of const);
begin
  Toast(Format(AFormat, Args));
end;

procedure TFrameView.Hint(const Msg: Double);
begin
  Toast(FloatToStr(Msg));
end;

procedure TFrameView.Hint(const Msg: Int64);
begin
  Toast(IntToStr(Msg));
end;

procedure TFrameView.InternalHide;
begin
  DoHide;
  FHideing := True;
  Visible := False;
  FHideing := False;
  FNeedHide := False;
end;

procedure TFrameView.InternalShow(TriggerOnShow: Boolean; AOnFinish: TNotifyEventA; Ani: TFrameAniType);
begin
  if FShowing then Exit;  
  FShowing := True;
  if Title <> '' then begin
    Application.Title := Title;
    if Assigned(Parent) and (Parent is TCustomForm) then
      TCustomForm(Parent).Caption := Title;
  end;
  if TriggerOnShow then
    DoShow()
  else
    DoReStart();
  {$IFDEF ANDROID}
  if (not Assigned(Screen.FocusControl)) and (Assigned(ParentForm)) then
    ParentForm.SetFocus;
  {$ENDIF}
  Opacity := 0;
  FHideing := True;
  Visible := True;
  FHideing := False;
  AnimatePlay(Ani, True, AOnFinish);
  FShowing := False;
  FNeedFree := False;
  FNeedHide := False;
end;

function TFrameView.FinishIsFreeApp: Boolean;
begin
  Result := Assigned(Parent) and (not Assigned(Parent.Parent)) and
    (Parent is TForm) and (Parent.ChildrenCount <= MainFormMinChildren + 1);
end;

procedure TFrameView.Hint(const Msg: string);
begin
  Toast(Msg);
end;

procedure TFrameView.SetBackColor(const Value: TAlphaColor);
begin
  if FBackColor <> Value then begin
    FBackColor := Value;
    //Repaint;
  end;
end;

procedure TFrameView.SetData(const Value: TValue);
begin
  if Params.ContainsKey(CS_Data) then
    Params.Items[CS_Data] := Value
  else
    Params.Add(CS_Data, Value);
end;

class procedure TFrameView.SetDefaultBackColor(const Value: TAlphaColor);
begin
  FDefaultBackColor := Value;
end;

class procedure TFrameView.SetDefaultStatusColor(const Value: TAlphaColor);
begin
  FDefaultStatusColor := Value;
end;

procedure TFrameView.SetParams(const Value: TFrameParams);
begin
  if Assigned(FParams) then
    FParams.Free;
  FParams := Value;
end;

procedure TFrameView.SetStatusColor(const Value: TAlphaColor);
  {$IFDEF IOS}
  procedure ExecuteIOS();
  var
    F: TCustomForm;
  begin
    F := ParentForm;
    if not Assigned(F) then
      Exit;
    F.Fill.Color := Value;
  end;
  {$ENDIF}
  
  {$IFDEF ANDROID}
  procedure ExecuteAndroid();   
  begin
    if TJBuild_VERSION.JavaClass.SDK_INT < 21 then
      Exit;
    CallInUiThread(
    procedure
    var
      wnd: JWindow;
    begin
      wnd := TAndroidHelper.Activity.getWindow;
      if (not Assigned(wnd)) then Exit;      
      // ȡ������͸��״̬��,ʹ ContentView ���ݲ��ٸ���״̬��  
      wnd.clearFlags($04000000); // FLAG_TRANSLUCENT_STATUS
      //wnd.getDecorView().setSystemUiVisibility($00000400 or $00000100);
      // ��Ҫ������� flag ���ܵ��� setStatusBarColor ������״̬����ɫ  
      wnd.addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS); // FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS
      // ������ɫ
      wnd.setStatusBarColor(Value);
    end);
  end;
  {$ENDIF}

begin
  {$IFDEF IOS}
  ExecuteIOS();
  {$ENDIF}
  {$IFDEF ANDROID}
  // ExecuteAndroid();  // û��Ч��������
  {$ENDIF}
end;

procedure TFrameView.SetTitle(const Value: string);
begin
  if Params.ContainsKey(CS_Title) then
    Params.Items[CS_Title] := Value
  else if Value <> '' then
    Params.Add(CS_Title, Value);
end;

procedure TFrameView.Show(Ani: TFrameAniType; AOnFinish: TNotifyEventA);
begin
  InternalShow(True, AOnFinish, Ani);
end;

procedure TFrameView.Show;
begin
  if FHideing then
    Exit;
  Show(TFrameAniType.DefaultAni, nil);
end;

class function TFrameView.ShowFrame(Parent: TFmxObject;
  const Title: string): TFrameView;
begin
  Result := CreateFrame(Parent, Title);
  if Result <> nil then
    Result.Show(TFrameAniType.None, nil);
end;

procedure TFrameView.ShowWaitDialog(const AMsg: string;
  OnDismissListener: TOnDialogListener; ACancelable: Boolean);
begin
  ShowWaitDialog(AMsg, ACancelable);
  if Assigned(FWaitDialog) then
    FWaitDialog.OnDismissListener := OnDismissListener;
end;

procedure TFrameView.ShowWaitDialog(const AMsg: string;
  OnDismissListener: TOnDialogListenerA; ACancelable: Boolean);
begin
  ShowWaitDialog(AMsg, ACancelable);
  if Assigned(FWaitDialog) then
    FWaitDialog.OnDismissListenerA := OnDismissListener;
end;

procedure TFrameView.ShowWaitDialog(const AMsg: string; ACancelable: Boolean);
begin
  if (not Assigned(FWaitDialog)) or (FWaitDialog.IsDismiss) then begin
    FWaitDialog := nil;
    FWaitDialog := TProgressDialog.Create(Self);
  end;
  FWaitDialog.Cancelable := ACancelable;
  if not Assigned(FWaitDialog.RootView) then
    FWaitDialog.InitView(AMsg)
  else
    FWaitDialog.Message := AMsg;
  TDialog(FWaitDialog).Show();
end;

function TFrameView.StartFrame(FrameClass: TFrameViewClass;
  const Title: string; Ani: TFrameAniType): TFrameView;
begin
  Result := MakeFrame(FrameClass);
  Result.Title := Title;
  Hide(Ani);
  Result.Show(Ani, nil);
end;

function TFrameView.StartFrame(FrameClass: TFrameViewClass; const Title: string;
  const Data: Pointer; Ani: TFrameAniType): TFrameView;
begin
  Result := MakeFrame(FrameClass);
  Result.Title := Title;
  Result.Data := Data;
  Hide(Ani);
  Result.Show(Ani, nil);
end;

function TFrameView.StreamToString(SrcStream: TStream; const CharSet: string): string;
var
  LReader: TStringStream;
begin
  if (CharSet <> '') and (string.CompareText(CharSet, 'utf-8') <> 0) then  // do not translate
    LReader := TStringStream.Create('', System.SysUtils.TEncoding.GetEncoding(CharSet), True)
  else
    LReader := TStringStream.Create('', System.SysUtils.TEncoding.UTF8, False);
  try
    LReader.CopyFrom(SrcStream, 0);
    Result := LReader.DataString;
  finally
    LReader.Free;
  end;
end;

function TFrameView.StartFrame(FrameClass: TFrameViewClass;
  Params: TFrameParams; Ani: TFrameAniType): TFrameView;
begin
  Result := MakeFrame(FrameClass);
  Result.Params := Params;
  Hide(Ani);
  Result.Show(Ani, nil);
end;

function TFrameView.StartFrame(FrameClass: TFrameViewClass; Ani: TFrameAniType): TFrameView;
begin
  Result := MakeFrame(FrameClass);
  Hide(Ani);
  Result.Show(Ani, nil);
end;

class function TFrameView.ShowFrame(Parent: TFmxObject;
  Params: TFrameParams): TFrameView;
begin
  Result := CreateFrame(Parent, Params);
  if Result <> nil then
    Result.Show(TFrameAniType.None, nil);
end;

{ TFrameState }

procedure TFrameState.Clear;
begin
  FLocker.Enter;
  if FData <> nil then
    FData.Clear;
  FLocker.Leave;
end;

function TFrameState.ContainsKey(const Key: string): Boolean;
begin
  FLocker.Enter;
  Result := FData.ContainsKey(Key);
  FLocker.Leave;
end;

constructor TFrameState.Create(AOwner: TComponent; IsPublic: Boolean);
begin
  FOwner := AOwner;
  FData := nil;
  FIsChange := False;
  FIsPublic := IsPublic;
  FLocker := TCriticalSection.Create;
  InitData;
  {$IFNDEF MSWINDOWS}
  StoragePath := TPath.GetDocumentsPath;
  {$ENDIF}
end;

destructor TFrameState.Destroy;
begin
  Save();
  FreeAndNil(FData);
  FreeAndNil(FLocker);
  inherited;
end;

procedure TFrameState.DoValueNotify(Sender: TObject; const Item: TFrameDataValue;
  Action: TCollectionNotification);
begin
  if Action <> TCollectionNotification.cnExtracted then
    FIsChange := True;
end;

function TFrameState.Exist(const Key: string): Boolean;
begin
  FLocker.Enter;
  Result := FData.ContainsKey(Key);
  FLocker.Leave;
end;

function TFrameState.GetBoolean(const Key: string;
  const DefaultValue: Boolean): Boolean;
begin
  FLocker.Enter;
  Result := FData.GetBoolean(Key, DefaultValue);
  FLocker.Leave;
end;

function TFrameState.GetCount: Integer;
begin
  if Assigned(FData) then
    Result := FData.Count
  else
    Result := 0;
end;

function TFrameState.GetDateTime(const Key: string;
  const DefaultValue: TDateTime): TDateTime;
begin
  FLocker.Enter;
  Result := FData.GetDateTime(Key, DefaultValue);
  FLocker.Leave;
end;

function TFrameState.GetFloat(const Key: string;
  const DefaultValue: Double): Double;
begin
  FLocker.Enter;
  Result := FData.GetFloat(Key, DefaultValue);
  FLocker.Leave;
end;

function TFrameState.GetInt(const Key: string;
  const DefaultValue: Integer): Integer;
begin
  FLocker.Enter;
  Result := FData.GetInt(Key, DefaultValue);
  FLocker.Leave;
end;

function TFrameState.GetInt64(const Key: string;
  const DefaultValue: Int64): Int64;
begin
  FLocker.Enter;
  Result := FData.GetInt64(Key, DefaultValue);
  FLocker.Leave;
end;

function TFrameState.GetLong(const Key: string;
  const DefaultValue: Cardinal): Cardinal;
begin
  FLocker.Enter;
  Result := FData.GetLong(Key, DefaultValue);
  FLocker.Leave;
end;

function TFrameState.GetNumber(const Key: string;
  const DefaultValue: NativeUInt): NativeUInt;
begin
  FLocker.Enter;
  Result := FData.GetNumber(Key, DefaultValue);
  FLocker.Leave;
end;

function TFrameState.GetStoragePath: string;
var
  SaveStateService: IFMXSaveStateService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXSaveStateService, SaveStateService) then
    Result := SaveStateService.GetStoragePath
  else
    Result := '';
end;

function TFrameState.GetString(const Key: string): string;
begin
  FLocker.Enter;
  Result := FData.GetString(Key);
  FLocker.Leave;
end;

function TFrameState.GetUniqueName: string;
const
  UniqueNameSeparator = '_';
  UniqueNamePrefix = 'FM';
  UniqueNameExtension = '.Data';
var
  B: TStringBuilder;
begin
  if FIsPublic then
    Result := 'AppPublicState.Data'
  else begin
    B := TStringBuilder.Create(Length(UniqueNamePrefix) + FOwner.ClassName.Length +
      Length(UniqueNameSeparator) + Length(UniqueNameExtension));
    try
      B.Append(UniqueNamePrefix);
      B.Append(UniqueNameSeparator);
      B.Append(FOwner.ClassName);
      B.Append(UniqueNameExtension);
      Result := B.ToString;
    finally
      B.Free;
    end;
  end;
end;

procedure TFrameState.InitData;
begin
  if FData <> nil then
    FData.Clear
  else begin
    if FIsPublic then
      FData := TFrameStateData.Create(97)
    else
      FData := TFrameStateData.Create(29);
    FData.OnValueNotify := DoValueNotify;
  end;
end;

procedure TFrameState.Load;
var
  AStream: TMemoryStream;
  SaveStateService: IFMXSaveStateService;
  Reader: TBinaryReader;
  ACount, I: Integer;
  ASize: Int64;
  AKey: string;
  AType: TFrameDataType;
begin
  FLocker.Enter;
  if FIsLoad then begin
    FLocker.Leave;
    Exit;
  end;
  try
    FData.Clear;
    AStream := TMemoryStream.Create;
    if TPlatformServices.Current.SupportsPlatformService(IFMXSaveStateService, SaveStateService) then
      SaveStateService.GetBlock(GetUniqueName, AStream);
    ASize := AStream.Size;
    Reader := nil;
    if AStream.Size > 0 then begin
      AStream.Position := 0;
      Reader := TBinaryReader.Create(AStream);
      ACount := Reader.ReadInteger;
      for I := 0 to ACount - 1 do begin
        if AStream.Position >= ASize then
          Break;
        AType := TFrameDataType(Reader.ReadShortInt);
        AKey := Reader.ReadString;
        case AType of
          fdt_Integer: FData.Put(AKey, Reader.ReadInt32);
          fdt_Long: FData.Put(AKey, Reader.ReadCardinal);
          fdt_Int64: FData.Put(AKey, Reader.ReadInt64);
          fdt_Float: FData.Put(AKey, Reader.ReadDouble);
          fdt_String: FData.Put(AKey, Reader.ReadString);
          fdt_DateTime: FData.PutDateTime(AKey, Reader.ReadDouble);
          fdt_Number: FData.Put(AKey, NativeUInt(Reader.ReadUInt64));
          fdt_Boolean: FData.Put(AKey, Reader.ReadBoolean);
        else
          Break;
        end;
      end;
    end;
  finally
    FreeAndNil(AStream);
    FreeAndNil(Reader);
    FIsChange := False;
    FIsLoad := True;
    FLocker.Leave;
  end;
end;

procedure TFrameState.Put(const Key: string; const Value: Cardinal);
begin
  FLocker.Enter;
  FData.Put(Key, Value);
  FLocker.Leave;
end;

procedure TFrameState.Put(const Key: string; const Value: Integer);
begin
  FLocker.Enter;
  FData.Put(Key, Value);
  FLocker.Leave;
end;

procedure TFrameState.Put(const Key, Value: string);
begin
  FLocker.Enter;
  FData.Put(Key, Value);
  FLocker.Leave;
end;

procedure TFrameState.Put(const Key: string; const Value: NativeUInt);
begin
  FLocker.Enter;
  FData.Put(Key, Value);
  FLocker.Leave;
end;

procedure TFrameState.Put(const Key: string; const Value: Boolean);
begin
  FLocker.Enter;
  FData.Put(Key, Value);
  FLocker.Leave;
end;

procedure TFrameState.Put(const Key: string; const Value: Int64);
begin
  FLocker.Enter;
  FData.Put(Key, Value);
  FLocker.Leave;
end;

procedure TFrameState.Put(const Key: string; const Value: Double);
begin
  FLocker.Enter;
  FData.Put(Key, Value);
  FLocker.Leave;
end;

procedure TFrameState.PutDateTime(const Key: string; const Value: TDateTime);
begin
  FLocker.Enter;
  FData.PutDateTime(Key, Value);
  FLocker.Leave;
end;

procedure TFrameState.Save;
var
  SaveStateService: IFMXSaveStateService;
  AStream: TMemoryStream;
  Writer: TBinaryWriter;
  ACount: Integer;
  Item: TPair<string, TFrameDataValue>;
  ADoubleValue: Double;
begin
  FLocker.Enter;
  if not FIsChange then begin
    FLocker.Leave;
    Exit;
  end;
  try
    AStream := TMemoryStream.Create;
    Writer := TBinaryWriter.Create(AStream);
    ACount := Count;
    Writer.Write(ACount);
    for Item in FData do begin
      Writer.Write(ShortInt(Ord(Item.Value.DataType)));
      Writer.Write(Item.Key);
      case Item.Value.DataType of
        fdt_Integer: Writer.Write(Item.Value.Value.AsInteger);
        fdt_Long: Writer.Write(Cardinal(Item.Value.Value.AsInteger));
        fdt_Int64: Writer.Write(Item.Value.Value.AsInt64);
        fdt_Float, fdt_DateTime:
          begin
            ADoubleValue := Item.Value.Value.AsExtended;
            Writer.Write(ADoubleValue);
          end;
        fdt_String: Writer.Write(Item.Value.Value.AsString);
        fdt_Number: Writer.Write(Item.Value.Value.AsUInt64);
        fdt_Boolean: Writer.Write(Item.Value.Value.AsBoolean);
      end;
    end;
    if TPlatformServices.Current.SupportsPlatformService(IFMXSaveStateService, SaveStateService) then
      SaveStateService.SetBlock(GetUniqueName, AStream);
  finally
    FreeAndNil(AStream);
    FreeAndNil(Writer);
    FIsChange := False;
    FLocker.Leave;
  end;
end;

procedure TFrameState.SetStoragePath(const Value: string);
var
  SaveStateService: IFMXSaveStateService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXSaveStateService, SaveStateService) then
    SaveStateService.SetStoragePath(Value);
end;

{ TFrameStateDataHelper }

function TFrameStateDataHelper.GetBoolean(const Key: string;
  const DefaultValue: Boolean): Boolean;
begin
  if ContainsKey(Key) then
    Result := Items[Key].Value.AsBoolean
  else
    Result := DefaultValue;
end;

function TFrameStateDataHelper.GetDataValue(DataType: TFrameDataType;
  const Value: TValue): TFrameDataValue;
begin
  Result.DataType := DataType;
  Result.Value := Value;
end;

function TFrameStateDataHelper.GetDateTime(const Key: string;
  const DefaultValue: TDateTime): TDateTime;
begin
  if ContainsKey(Key) then
    Result := Items[Key].Value.AsExtended
  else
    Result := DefaultValue;
end;

function TFrameStateDataHelper.GetFloat(const Key: string;
  const DefaultValue: Double): Double;
begin
  if ContainsKey(Key) then
    Result := Items[Key].Value.AsExtended
  else
    Result := DefaultValue;
end;

function TFrameStateDataHelper.GetInt(const Key: string;
  const DefaultValue: Integer): Integer;
begin
  if ContainsKey(Key) then
    Result := Items[Key].Value.AsInteger
  else
    Result := DefaultValue;
end;

function TFrameStateDataHelper.GetInt64(const Key: string;
  const DefaultValue: Int64): Int64;
begin
  if ContainsKey(Key) then
    Result := Items[Key].Value.AsInt64
  else
    Result := DefaultValue;
end;

function TFrameStateDataHelper.GetLong(const Key: string;
  const DefaultValue: Cardinal): Cardinal;
begin
  if ContainsKey(Key) then
    Result := Items[Key].Value.AsInteger
  else
    Result := DefaultValue;
end;

function TFrameStateDataHelper.GetNumber(const Key: string;
  const DefaultValue: NativeUInt): NativeUInt;
begin
  if ContainsKey(Key) then
    Result := Items[Key].Value.AsOrdinal
  else
    Result := DefaultValue;
end;

function TFrameStateDataHelper.GetPointer(const Key: string): Pointer;
begin
  if ContainsKey(Key) then
    Result := Items[Key].Value.AsVarRec.VPointer
  else
    Result := nil;
end;

function TFrameStateDataHelper.GetString(const Key: string): string;
begin
  if ContainsKey(Key) then
    Result := Items[Key].Value.ToString
  else
    Result := '';
end;

procedure TFrameStateDataHelper.Put(const Key: string; const Value: Cardinal);
begin
  AddOrSetValue(Key, GetDataValue(fdt_Long, Value));
end;

procedure TFrameStateDataHelper.Put(const Key: string; const Value: Integer);
begin
  AddOrSetValue(Key, GetDataValue(fdt_Integer, Value));
end;

procedure TFrameStateDataHelper.Put(const Key, Value: string);
begin
  AddOrSetValue(Key, GetDataValue(fdt_String, Value));
end;

procedure TFrameStateDataHelper.Put(const Key: string; const Value: NativeUInt);
begin
  AddOrSetValue(Key, GetDataValue(fdt_Number, Value));
end;

procedure TFrameStateDataHelper.Put(const Key: string; const Value: Boolean);
begin
  AddOrSetValue(Key, GetDataValue(fdt_Boolean, Value));
end;

procedure TFrameStateDataHelper.Put(const Key: string; const Value: Int64);
begin
  AddOrSetValue(Key, GetDataValue(fdt_Int64, Value));
end;

procedure TFrameStateDataHelper.Put(const Key: string; const Value: Double);
begin
  AddOrSetValue(Key, GetDataValue(fdt_Float, Value));
end;

procedure TFrameStateDataHelper.PutDateTime(const Key: string;
  const Value: TDateTime);
begin
  AddOrSetValue(Key, GetDataValue(fdt_DateTime, Value));
end;

{ TFrameParamsHelper }

function TFrameParamsHelper.GetBoolean(const Key: string;
  const DefaultValue: Boolean): Boolean;
begin
  if ContainsKey(Key) then begin
    Result := Items[Key].AsBoolean
  end else
    Result := DefaultValue;
end;

function TFrameParamsHelper.GetDateTime(const Key: string;
  const DefaultValue: TDateTime): TDateTime;
begin
  if ContainsKey(Key) then begin
    Result := Items[Key].AsExtended
  end else
    Result := DefaultValue;
end;

function TFrameParamsHelper.GetFloat(const Key: string;
  const DefaultValue: Double): Double;
begin
  if ContainsKey(Key) then begin
    Result := Items[Key].AsExtended
  end else
    Result := DefaultValue;
end;

function TFrameParamsHelper.GetInt(const Key: string;
  const DefaultValue: Integer): Integer;
begin
  if ContainsKey(Key) then begin
    Result := Items[Key].AsInteger
  end else
    Result := DefaultValue;
end;

function TFrameParamsHelper.GetInt64(const Key: string;
  const DefaultValue: Int64): Int64;
begin
  if ContainsKey(Key) then begin
    Result := Items[Key].AsInt64
  end else
    Result := DefaultValue;
end;

function TFrameParamsHelper.GetLong(const Key: string;
  const DefaultValue: Cardinal): Cardinal;
begin
  if ContainsKey(Key) then begin
    Result := Items[Key].AsInteger
  end else
    Result := DefaultValue;
end;

function TFrameParamsHelper.GetNumber(const Key: string;
  const DefaultValue: NativeUInt): NativeUInt;
begin
  if ContainsKey(Key) then begin
    Result := Items[Key].AsOrdinal
  end else
    Result := DefaultValue;
end;

function TFrameParamsHelper.GetPointer(const Key: string): Pointer;
begin
  if ContainsKey(Key) then begin
    Result := Items[Key].AsVarRec.VPointer
  end else
    Result := nil;
end;

function TFrameParamsHelper.GetString(const Key: string): string;
begin
  if ContainsKey(Key) then begin
    Result := Items[Key].ToString
  end else
    Result := '';
end;

procedure TFrameParamsHelper.Put(const Key: string; const Value: Integer);
begin
  AddOrSetValue(Key, Value);
end;

procedure TFrameParamsHelper.Put(const Key, Value: string);
begin
  AddOrSetValue(Key, Value);
end;

procedure TFrameParamsHelper.Put(const Key: string; const Value: Cardinal);
begin
  AddOrSetValue(Key, Value);
end;

procedure TFrameParamsHelper.Put(const Key: string; const Value: NativeUInt);
begin
  AddOrSetValue(Key, Value);
end;

procedure TFrameParamsHelper.Put(const Key: string; const Value: Boolean);
begin
  AddOrSetValue(Key, Value);
end;

procedure TFrameParamsHelper.Put(const Key: string; const Value: Int64);
begin
  AddOrSetValue(Key, Value);
end;

procedure TFrameParamsHelper.Put(const Key: string; const Value: Double);
begin
  AddOrSetValue(Key, Value);
end;

procedure TFrameParamsHelper.PutDateTime(const Key: string;
  const Value: TDateTime);
begin
  AddOrSetValue(Key, Value);
end;

{ TFrameAnimator }

class procedure TFrameAnimator.AnimateColor(const Target: TFmxObject;
  const APropertyName: string; NewValue: TAlphaColor; AOnFinish: TNotifyEventA;
  Duration, Delay: Single; AType: TAnimationType; AInterpolation: TInterpolationType);
var
  Animation: TColorAnimation;
begin
  TAnimator.StopPropertyAnimation(Target, APropertyName);

  CreateDestroyer;

  Animation := TColorAnimation.Create(Target);
  FDestroyer.Add(Animation, AOnFinish);
  Animation.Parent := Target;
  Animation.AnimationType := AType;
  Animation.Interpolation := AInterpolation;
  Animation.OnFinish := FDestroyer.DoAniFinished;
  Animation.Duration := Duration;
  Animation.Delay := Delay;
  Animation.PropertyName := APropertyName;
  Animation.StartFromCurrent := True;
  Animation.StopValue := NewValue;
  Animation.Start;

  if not Animation.Enabled then
    FDestroyer.DoAniFinishedEx(Animation, False);
end;

class procedure TFrameAnimator.AnimateColor(const Target: TFmxObject;
  const APropertyName: string; NewValue: TAlphaColor; AOnFinish: TNotifyEvent;
  Duration, Delay: Single; AType: TAnimationType; AInterpolation: TInterpolationType);
var
  Animation: TColorAnimation;
begin
  TAnimator.StopPropertyAnimation(Target, APropertyName);

  CreateDestroyer;

  Animation := TColorAnimation.Create(Target);
  FDestroyer.Add(Animation, AOnFinish);
  Animation.Parent := Target;
  Animation.AnimationType := AType;
  Animation.Interpolation := AInterpolation;
  Animation.OnFinish := FDestroyer.DoAniFinished;
  Animation.Duration := Duration;
  Animation.Delay := Delay;
  Animation.PropertyName := APropertyName;
  Animation.StartFromCurrent := True;
  Animation.StopValue := NewValue;
  Animation.Start;

  if not Animation.Enabled then
    FDestroyer.DoAniFinishedEx(Animation, False);
end;

class procedure TFrameAnimator.AnimateFloat(const Target: TFmxObject;
  const APropertyName: string; const NewValue: Single; AOnFinish: TNotifyEvent;
  Duration, Delay: Single; AType: TAnimationType; AInterpolation: TInterpolationType);
var
  Animation: TFloatAnimation;
begin
  TAnimator.StopPropertyAnimation(Target, APropertyName);

  CreateDestroyer;

  Animation := TFloatAnimation.Create(nil);
  FDestroyer.Add(Animation, AOnFinish);
  Animation.Parent := Target;
  Animation.AnimationType := AType;
  Animation.Interpolation := AInterpolation;
  Animation.OnFinish := FDestroyer.DoAniFinished;
  Animation.Duration := Duration;
  Animation.Delay := Delay;
  Animation.PropertyName := APropertyName;
  Animation.StartFromCurrent := True;
  Animation.StopValue := NewValue;
  Animation.Start;

  if not Animation.Enabled then
    FDestroyer.DoAniFinishedEx(Animation, False);
end;

class procedure TFrameAnimator.AnimateFloat(const Target: TFmxObject;
  const APropertyName: string; const NewValue: Single; AOnFinish: TNotifyEventA;
  Duration, Delay: Single; AType: TAnimationType; AInterpolation: TInterpolationType);
var
  Animation: TFloatAnimation;
begin
  TAnimator.StopPropertyAnimation(Target, APropertyName);

  CreateDestroyer;

  Animation := TFloatAnimation.Create(nil);
  FDestroyer.Add(Animation, AOnFinish);
  Animation.Parent := Target;
  Animation.AnimationType := AType;
  Animation.Interpolation := AInterpolation;
  Animation.OnFinish := FDestroyer.DoAniFinished;
  Animation.Duration := Duration;
  Animation.Delay := Delay;
  Animation.PropertyName := APropertyName;
  Animation.StartFromCurrent := True;
  Animation.StopValue := NewValue;
  Animation.Start;

  if not Animation.Enabled then
    FDestroyer.DoAniFinishedEx(Animation, False);
end;

class procedure TFrameAnimator.AnimateInt(const Target: TFmxObject;
  const APropertyName: string; const NewValue: Integer; AOnFinish: TNotifyEvent;
  Duration, Delay: Single; AType: TAnimationType; AInterpolation: TInterpolationType);
var
  Animation: TIntAnimation;
begin
  CreateDestroyer;

  TAnimator.StopPropertyAnimation(Target, APropertyName);

  Animation := TIntAnimation.Create(nil);
  FDestroyer.Add(Animation, AOnFinish);
  Animation.Parent := Target;
  Animation.AnimationType := AType;
  Animation.Interpolation := AInterpolation;
  Animation.OnFinish := FDestroyer.DoAniFinished;
  Animation.Duration := Duration;
  Animation.Delay := Delay;
  Animation.PropertyName := APropertyName;
  Animation.StartFromCurrent := True;
  Animation.StopValue := NewValue;
  Animation.Start;

  if not Animation.Enabled then
    FDestroyer.DoAniFinishedEx(Animation, False);
end;

class procedure TFrameAnimator.AnimateInt(const Target: TFmxObject;
  const APropertyName: string; const NewValue: Integer;
  AOnFinish: TNotifyEventA; Duration, Delay: Single; AType: TAnimationType;
  AInterpolation: TInterpolationType);
var
  Animation: TIntAnimation;
begin
  CreateDestroyer;

  TAnimator.StopPropertyAnimation(Target, APropertyName);

  Animation := TIntAnimation.Create(nil);
  FDestroyer.Add(Animation, AOnFinish);
  Animation.Parent := Target;
  Animation.AnimationType := AType;
  Animation.Interpolation := AInterpolation;
  Animation.OnFinish := FDestroyer.DoAniFinished;
  Animation.Duration := Duration;
  Animation.Delay := Delay;
  Animation.PropertyName := APropertyName;
  Animation.StartFromCurrent := True;
  Animation.StopValue := NewValue;
  Animation.Start;

  if not Animation.Enabled then
    FDestroyer.DoAniFinishedEx(Animation, False);
end;

class procedure TFrameAnimator.CreateDestroyer;
begin
  if FDestroyer = nil then
    FDestroyer := TAnimationDestroyer.Create;
end;

class procedure TFrameAnimator.DelayExecute(const Owner: TFmxObject; AOnFinish: TNotifyEventA;
  Delay: Single);
var
  Animation: TDelayExecute;
begin
  CreateDestroyer;

  Animation := TDelayExecute.Create(nil);
  FDestroyer.Add(Animation, AOnFinish);
  Animation.Parent := Owner;
  Animation.AnimationType := TAnimationType.In;
  Animation.Interpolation := TInterpolationType.Linear;
  Animation.OnFinish := FDestroyer.DoAniFinished;
  Animation.Duration := Delay;
  Animation.Delay := 0;
  Animation.Start;

  if not Animation.Enabled then
    FDestroyer.DoAniFinishedEx(Animation, False);
end;

class procedure TFrameAnimator.Uninitialize;
begin
  FreeAndNil(FDestroyer);
end;

{ TFrameAnimator.TAnimationDestroyer }

procedure TFrameAnimator.TAnimationDestroyer.Add(Sender: TObject;
  AOnFinish: TNotifyEvent);
var
  Item: TFrameAnimatorEvent;
begin
  if not Assigned(AOnFinish) then
    Exit;
  Item.OnFinish := AOnFinish;
  Item.OnFinishA := nil;
  FOnFinishs.Add(Sender.GetHashCode, Item);
end;

procedure TFrameAnimator.TAnimationDestroyer.Add(Sender: TObject;
  AOnFinish: TNotifyEventA);
var
  Item: TFrameAnimatorEvent;
begin
  if not Assigned(AOnFinish) then
    Exit;
  Item.OnFinishA := AOnFinish;
  Item.OnFinish := nil;
  FOnFinishs.Add(Sender.GetHashCode, Item);
end;

constructor TFrameAnimator.TAnimationDestroyer.Create;
begin
  FOnFinishs := TDictionary<Integer, TFrameAnimatorEvent>.Create(13);
end;

destructor TFrameAnimator.TAnimationDestroyer.Destroy;
begin
  FreeAndNil(FOnFinishs);
  inherited;
end;

procedure TFrameAnimator.TAnimationDestroyer.DoAniFinished(Sender: TObject);
begin
  DoAniFinishedEx(Sender, True);
end;   

procedure TFrameAnimator.TAnimationDestroyer.DoAniFinishedEx(Sender: TObject;
  FreeSender: Boolean);
var
  Item: TFrameAnimatorEvent;
  Key: Integer;
begin
  Key := Sender.GetHashCode;
  if FOnFinishs.ContainsKey(Key) then begin
    Item := FOnFinishs[Key];
    FOnFinishs.Remove(Key);  // UI������Ĭ���ǵ��̣߳�����ͬ������
  end else begin
    Item.OnFinish := nil;
    Item.OnFinishA := nil;
  end;
  if FreeSender then
    TAnimation(Sender).DisposeOf;
  try
    if Assigned(Item.OnFinish) then
      Item.OnFinish(Sender);
    if Assigned(Item.OnFinishA) then
      Item.OnFinishA(Sender);
  except
  end;
end;

{ TCustomFormHelper }

procedure TCustomFormHelper.SetFocus;
var
  LControl: IControl;
  Item: TFmxObject;
  Ctrl: TControl;
  I: Integer;
begin
  if Root <> nil then begin
    for I := 0 to Self.ChildrenCount - 1 do begin
      Item := Children.Items[I];
      if (Item is TControl) then begin
        Ctrl := Item as TControl;
        if (Ctrl.Visible) and (Ctrl.CanFocus) then begin
          LControl := Root.NewFocusedControl(Ctrl);
          if LControl <> nil then begin
            Root.SetFocused(LControl);
            Break;
          end;
        end;
      end;
    end;
  end;
end;

{ TDelayExecute }

procedure TDelayExecute.FirstFrame;
begin
end;

procedure TDelayExecute.ProcessAnimation;
begin
end;

procedure TDelayExecute.Start;
begin
  inherited Start;
end;

procedure TDelayExecute.Stop;
begin
  inherited Stop;
end;

initialization
  FPublicState := TFrameState.Create(nil, True);
  FPublicState.Load;

finalization
  FreeAndNil(FPublicState);
  TFrameAnimator.Uninitialize;

end.
