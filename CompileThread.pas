unit CompileThread;
interface
uses progressmonitor, PackageInfo, MonitoredPackageCompiler, Classes, JclBorlandTools, CompilationData;

type
  TCompileThread = class(TThread)
  private
    fMonitor : IProgressMonitor;
    fCompilationData: TCompilationData;
    fCancel: boolean;
    fCompiler: TLoggedPackageCompiler;
    procedure SetMonitor(const Value: IProgressMonitor);
    procedure SetCancel(const Value: boolean);
  protected
    procedure Execute; override;
//    procedure UpdateMonitor;
    //procedure PackageEventHandler(const package: TPackageInfo; status: TPackageStatus);
  public
    constructor Create(const compilationData: TCompilationData);
    property Monitor: IProgressMonitor read FMonitor write SetMonitor;
    property Cancel: boolean read fCancel write SetCancel;
  end;

implementation

constructor TCompileThread.Create(const compilationData: TCompilationData);
begin
  inherited Create(true);
  Assert(compilationData <> nil);
  fCompilationData := compilationData;
end;

procedure TCompileThread.Execute;
begin
  inherited;
  fCompiler := TLoggedPackageCompiler.Create(fCompilationData);
  fCompiler.Monitor := Monitor;
  try
    fCompiler.Compile;
  finally
    fCompiler.Free;
  end;
end;


procedure TCompileThread.SetCancel(const Value: boolean);
begin
  fCancel := Value;
  if fCompiler <> nil then
    fCompiler.Cancel := true;
end;

procedure TCompileThread.SetMonitor(const Value: IProgressMonitor);
begin
  FMonitor := Value;
end;
//
//procedure TCompileThread.UpdateMonitor;
//begin
//   if fMonitor <> nil then
//   begin
//     fMonitor.StepNo := fStepNo;
//     fMonitor.PackageName := fPackageName;
//     fMonitor.PackageProcessed(fPackageInfo, fStatus);
//   end;
//end;
end.
