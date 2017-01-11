unit uFrame3;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UI.Standard, UI.Base, UI.Frame;

type
  TFrame3 = class(TFrame)
    LinearLayout1: TLinearLayout;
    TextView17: TTextView;
    tvTitle: TTextView;
    View1: TView;
    ButtonView1: TButtonView;
    procedure TextView17Click(Sender: TObject);
    procedure ButtonView1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation


{$R *.fmx}

{$IFDEF ANDROID}
uses
  FMX.Platform.Android,
  FMX.VirtualKeyboard.Android,
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

procedure TFrame3.ButtonView1Click(Sender: TObject);
{$IFDEF ANDROID}
var
  wnd: JWindow;
begin
  if TJBuild_VERSION.JavaClass.SDK_INT < 21 then begin
    Hint('�汾̫��');
    Exit;
  end;
  wnd := TAndroidHelper.Activity.getWindow;
  if (not Assigned(wnd)) then Exit;
  Hint('0');
  CallInUiThread(
    procedure
    begin
      wnd.getDecorView().setFitsSystemWindows(True);
      // ȡ������͸��״̬��,ʹ ContentView ���ݲ��ٸ���״̬��
      wnd.clearFlags($04000000); // FLAG_TRANSLUCENT_STATUS
      Hint('1');
      wnd.getDecorView().setSystemUiVisibility($00000400 or $00000100);
      Hint('2');
      // ��Ҫ������� flag ���ܵ��� setStatusBarColor ������״̬����ɫ
      wnd.addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS); // FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS
      Hint('3');
      // ������ɫ
      wnd.setStatusBarColor($ff3399ff);
      Hint('4');
    end
  );
{$ELSE}
begin
{$ENDIF}
end;

procedure TFrame3.TextView17Click(Sender: TObject);
begin
  Finish();
end;

end.
