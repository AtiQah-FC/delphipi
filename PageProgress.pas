{**
 DelphiPI (Delphi Package Installer)
 Author  : ibrahim dursun (t-hex) thex [at] thexpot ((dot)) net
 License : GNU General Public License 2.0
**}
unit PageProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PageBase, StdCtrls, ComCtrls, WizardIntfs, CompileThread, ProgressMonitor, PackageInfo;

type
  TProgressPage = class(TWizardPage, IProgressMonitor)
    GroupBox1: TGroupBox;
    ProgressBar: TProgressBar;
    Label1: TLabel;
    lblPackage: TLabel;
    lblCurrentPackageNo: TLabel;
    memo: TRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    compileThreadWorking: Boolean;
    compileThread: TCompileThread;
    fFullLog : TStringList;
  protected
    procedure WriteInfo(const color: TColor; const info: string);
  public
    procedure Compile;
    procedure UpdateWizardState; override;
    procedure Finished;
    procedure Started;
    procedure CompilerOutput(const line: string);
    procedure PackageProcessed(const packageInfo: TPackageInfo;
      status: TPackageStatus);
    procedure Log(const text: string);
      
  end;

var
  ProgressPage: TProgressPage;

implementation
uses  gnugettext, StrUtils;

{$R *.dfm}

{ TProgressPage }

procedure TProgressPage.FormCreate(Sender: TObject);
begin
  inherited;
  TranslateComponent(self);
  lblPackage.Caption := '';
  compileThreadWorking := false;
  fFullLog := TStringList.Create;
  Compile;
end;

procedure TProgressPage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if compileThreadWorking then begin
    compileThread.Cancel := true;
    compileThread.WaitFor;
    compileThread.Terminate;
  end;
  fFullLog.Free;
end;

procedure TProgressPage.UpdateWizardState;
begin
  inherited;
  wizard.SetHeader(_('Compile and Install Packages'));
  wizard.SetDescription(_('Compiling packages that you have selected. Design time packages are going to be installed.'));
  with wizard.GetButton(wbtNext) do
    Enabled := not compileThreadWorking;

  with wizard.GetButton(wbtBack) do
    Enabled := not compileThreadWorking;
end;

procedure TProgressPage.WriteInfo(const color: TColor; const info: string);
var
  oldColor: TColor;
begin
  oldColor := memo.SelAttributes.Color;
  memo.SelAttributes.Color := color;
  memo.Lines.Add(info);
  memo.SelAttributes.Color := oldColor;
end;


procedure TProgressPage.Compile;
begin
  ProgressBar.Max := fCompilationData.PackageList.Count;
  compileThread := TCompileThread.Create(fCompilationData);
  compileThread.Monitor := Self as IProgressMonitor;
  with compileThread do begin
    FreeOnTerminate := true;
    compileThreadWorking := true;
    Resume;
  end;
end;

procedure TProgressPage.Log(const text: string);
begin

end;

procedure TProgressPage.PackageProcessed(const packageInfo: TPackageInfo;
  status: TPackageStatus);
begin
 case status of
    psNone: ;
    psCompiling: begin
      WriteInfo(clBlack, _('Compiling:') + packageInfo.PackageName);
      ProgressBar.StepBy(1);
      lblCurrentPackageNo.Caption := Format('%d/%d',[ProgressBar.Position,ProgressBar.Max]);
    end;
    psInstalling: WriteInfo(clBlue, _('Installing'));
    psSuccess: WriteInfo(clGreen, _('Successful'));
    psError: WriteInfo(clRed,_('Failed'));
  end;
end;

procedure TProgressPage.Started;
begin
  ProgressBar.Position := 0;
  ProgressBar.Max := fCompilationData.PackageList.Count;
end;

procedure TProgressPage.CompilerOutput(const line: string);
var
  S : String;
begin
  S := Trim(line);
  if Pos('Fatal:', S) > 0 then
    WriteInfo(clRed, line)
end;

procedure TProgressPage.Finished;
begin
  lblPackage.Caption :='';
  ProgressBar.Position := 0;
  compileThreadWorking := false;
  WriteInfo(clBlack, _('*** Completed'));
  Wizard.UpdateInterface;
end;


end.
