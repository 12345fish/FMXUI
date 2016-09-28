unit uFrameListViewTest;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UI.Frame, UI.Base, UI.Standard, UI.ListView;

type
  TFrameListViewTest = class(TFrame)
    ListViewEx1: TListViewEx;
    TextView1: TTextView;
    procedure ListViewEx1ItemClick(Sender: TObject; ItemIndex: Integer;
      const ItemView: TControl);
    procedure ListViewEx1ScrollChange(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure DoShow(); override;
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses
  UI.Dialog;

procedure TFrameListViewTest.DoShow;
var
  I: Integer;
  Adapter: TStringsListAdapter;
begin
  inherited;

  Adapter := TStringsListCheckAdapter.Create(nil);
  Adapter.SetArrayLength(1000000);
  for I := 0 to Adapter.Count - 1 do
    Adapter.Items[I] := Format('�б����б����б����б����б����б����б����б����б����б������б����б������б����б����б��� %d', [I]);
  ListViewEx1.Adapter := Adapter;
end;

procedure TFrameListViewTest.ListViewEx1ItemClick(Sender: TObject;
  ItemIndex: Integer; const ItemView: TControl);
begin
  TDialogBuilder.Create(Self)
    .SetTitle('ɾ����ʾ')
    .SetMessage(TStringsListAdapter(ListViewEx1.Adapter).Items[ItemIndex])
    .SetNegativeButton('ɾ��',
      procedure (Dialog: IDialog; Which: Integer)
      begin
        TStringsListAdapter(ListViewEx1.Adapter).Delete(ItemIndex);
        ListViewEx1.Adapter.NotifyDataChanged;
      end
    )
    .SetPositiveButton('ȡ��')
    .Show();
end;

procedure TFrameListViewTest.ListViewEx1ScrollChange(Sender: TObject);
begin
  //TCustomForm(Parent).Caption := IntToStr(ListViewEx1.FirstRowIndex)
end;

end.
