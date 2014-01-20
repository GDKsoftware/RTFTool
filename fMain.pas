unit fMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TFrmMain = class(TForm)
    edFileContents: TRichEdit;
    edTempContents: TRichEdit;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FListMode: boolean;
  public
    { Public declarations }
    procedure LoadFromFile(const sFilename: string);
    procedure AppendText(const s: string);
    procedure SaveToFile(const sFilename: string);
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  StrUtils;

{$R *.dfm}

procedure TFrmMain.FormShow(Sender: TObject);
var
  sFileName: string;
  sParam: string;
  i, c: integer;
  iMode: integer;
  s: string;
  sFull: string;
  iSize: integer;
  iIndent: integer;
begin
  iIndent := 10;

  if ParamCount > 0 then
  begin
    sFilename := ParamStr(1);

    if FileExists(sFilename) then
    begin
      LoadFromFile(sFilename);
    end;

    FListMode := False;

    if ParamCount > 1 then
    begin
      c := ParamCount;
      i := 2;
      while i <= c do
      begin
        sParam := ParamStr(i);

        iMode := 0;
        if SameText(sParam, '-al') then
        begin
          iMode := 1;
          FListMode := True;
        end
        else if SameText(sParam, '-a') then
        begin
          iMode := 1;
          FListMode := False;
        end
        else if SameText(sParam, '-in') then
        begin
          iIndent := StrToIntDef(ParamStr(i+1), iIndent);
          Inc(i);
        end
        else if SameText(sParam, '-sz') then
        begin
          iSize := StrToIntDef(ParamStr(i+1), edTempContents.Font.Size);
          Inc(i);

          edTempContents.Font.Size := iSize;
        end
        else if SameText(sParam, '-fn') then
        begin
          edTempContents.Font.Name := ParamStr(i+1);
          Inc(i);
        end
        else if SameText(sParam, '+b') then
        begin
          edTempContents.Font.Style := edTempContents.Font.Style + [fsBold];
        end
        else if SameText(sParam, '+i') then
        begin
          edTempContents.Font.Style := edTempContents.Font.Style + [fsItalic];
        end
        else if SameText(sParam, '-b') then
        begin
          edTempContents.Font.Style := edTempContents.Font.Style - [fsBold];
        end
        else if SameText(sParam, '-i') then
        begin
          edTempContents.Font.Style := edTempContents.Font.Style - [fsItalic];
        end;

        Inc(i);

        if iMode <> 0 then
        begin
          sParam := ParamStr(i);

          if FListMode then
          begin
            edTempContents.Paragraph.Numbering := nsBullet;
            edTempContents.Paragraph.FirstIndent := iIndent;
          end;

          s := ParamStr(i);
          s := ReplaceStr(s, '&quot;', '"');

          if iMode = 1 then
          begin
            AppendText(s);
          end;

          if FListMode then
          begin
            edTempContents.Paragraph.Numbering := nsNone;
            edTempContents.Paragraph.FirstIndent := 0;
          end;
        end;
      end;

      edTempContents.SelectAll;
      edTempContents.CopyToClipboard;

      edFileContents.PasteFromClipboard;

      SaveToFile(sFileName);

      Application.Terminate;
    end;

  end;
end;

procedure TFrmMain.LoadFromFile(const sFilename: string);
begin
  edFileContents.Lines.LoadFromFile(sFilename);

  edTempContents.Font.Name := edFileContents.Font.Name;
  edTempContents.Font.Size := edFileContents.Font.Size;
end;

procedure TFrmMain.AppendText(const s: string);
begin
  if StartsStr('* ', s) and FListMode then
  begin
    edTempContents.Lines.Add(Copy(s,3));
  end
  else
  begin
    edTempContents.Lines.Add(s);
  end;
end;

procedure TFrmMain.SaveToFile(const sFilename: string);
begin
  edFileContents.Lines.SaveToFile(sFilename);
end;

end.
