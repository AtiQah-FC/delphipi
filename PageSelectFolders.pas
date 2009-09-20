{**
 DelphiPI (Delphi Package Installer)
 Author  : ibrahim dursun (t-hex) thex [at] thexpot ((dot)) net
 License : GNU General Public License 2.0
**}
unit PageSelectFolders;

interface

uses
  CompilationData, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PageBase, StdCtrls, ExtCtrls, WizardIntfs, JclBorlandTools;

type
  TSelectFoldersPage = class(TWizardPage)
    grpPackagePattern: TGroupBox;
    Label3: TLabel;
    cbPattern: TComboBox;
    grpBaseFolder: TGroupBox;
    Label1: TLabel;
    btnSelectFolder: TButton;
    edtBaseFolder: TEdit;
    Label2: TLabel;
    grpDelphiVersion: TGroupBox;
    cbDelphiVersions: TComboBox;
    procedure btnSelectFolderClick(Sender: TObject);
    procedure edtBaseFolderChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure cbDelphiVersionsChange(Sender: TObject);
  private
    FPatternsFileName: string;
    procedure AddDelphiInstallation(const installation: TJclBorRADToolInstallation);
  public
    constructor Create(Owner: TComponent; const compilationData: TCompilationData); override; 
    procedure UpdateWizardState; override;
    function CanShowPage: Boolean; override;
  end;

var
  SelectFoldersPage: TSelectFoldersPage;

implementation
uses FileCtrl, gnugettext, FormWizard, JclSysInfo, JclFileUtils;
{$R *.dfm}
var
  installations : TJclBorRADToolInstallations;
{ TSelectFoldersPage }

procedure TSelectFoldersPage.FormCreate(Sender: TObject);
var 
 i: integer;
 dataFolder: string;
begin
  inherited;
  TranslateComponent(self);
  installations := TJclBorRADToolInstallations.Create;

 dataFolder := PathAppend(PathAddSeparator(GetAppdataFolder), 'DelphiPI');
  if not DirectoryExists(dataFolder) then
    CreateDir(dataFolder);

  FPatternsFileName := PathAppend(PathAddSeparator(dataFolder), 'patterns.txt');


  edtBaseFolder.Text := FCompilationData.BaseFolder;
  cbPattern.Text := FCompilationData.Pattern;

  if (FileExists(FPatternsFileName)) then
    cbPattern.Items.LoadFromFile(FPatternsFileName);

  if installations <> nil then
    installations := TJclBorRADToolInstallations.Create;

  for i := 0 to installations.Count - 1 do begin
    AddDelphiInstallation(installations.Installations[i]);
  end;

  cbDelphiVersionsChange(cbDelphiVersions);
end; 

procedure TSelectFoldersPage.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  if cbPattern.Items.IndexOf(cbPattern.Text) = -1 then
    cbPattern.Items.Add(cbPattern.Text);

  FCompilationData.BaseFolder := edtBaseFolder.Text;
  FCompilationData.Pattern := cbPattern.Text;
  fCompilationData.PackageList.Clear;

  if FileExists(FPatternsFileName) then
     JclFileUtils.CreateEmptyFile(FPatternsFileName);
  cbPattern.Items.SaveToFile(FPatternsFileName);
end;


procedure TSelectFoldersPage.AddDelphiInstallation(const installation: TJclBorRADToolInstallation);
var
  i: integer;
begin
  i := cbDelphiVersions.Items.Add(installation.Description);
  cbDelphiVersions.Items.Objects[i] := installation;
  if not Assigned(fCompilationData.Installation) then
    exit;
  
  if installation.VersionNumber = fCompilationData.Installation.VersionNumber then
    cbDelphiVersions.ItemIndex := i;
end;

procedure TSelectFoldersPage.UpdateWizardState;
var
  button: TButton;
begin
  inherited;
  wizard.SetHeader(_('Select Folders'));
  wizard.SetDescription(_('Please select folders which contains the packages that you want to install'));

  button := wizard.GetButton(wbtNext);
  button.Enabled := edtBaseFolder.Text <> '';
end;

procedure TSelectFoldersPage.btnSelectFolderClick(Sender: TObject);
var
  directory: string;
begin
  inherited;
  directory := edtBaseFolder.Text;
  if SelectDirectory(_('Select the folder where packages are'),'',directory) then begin
    edtBaseFolder.Text := directory;
    UpdateWizardState;
  end;
end;

function TSelectFoldersPage.CanShowPage: Boolean;
begin
  Result := not(fCompilationData.Scripting);
end;

procedure TSelectFoldersPage.cbDelphiVersionsChange(Sender: TObject);
begin
  inherited;
  if (cbDelphiVersions.ItemIndex = -1) and (cbDelphiVersions.Items.Count > 0) then
    cbDelphiVersions.ItemIndex := 0;

  fCompilationData.Installation := cbDelphiVersions.Items.Objects[cbDelphiVersions.ItemIndex] as TJclBorRADToolInstallation;
end;

constructor TSelectFoldersPage.Create(Owner: TComponent;
  const compilationData: TCompilationData);
begin
  inherited;
  fCompilationData := compilationData;
end;

procedure TSelectFoldersPage.edtBaseFolderChange(Sender: TObject);
begin
  inherited;
  UpdateWizardState;
end;



end.
