program prjRESTLight;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {frmMain},
  uAppSettings in 'uAppSettings.pas',
  FMX.RESTLight.Types in 'comps\FMX.RESTLight.Types.pas',
  FMX.RESTLight in 'comps\FMX.RESTLight.pas',
  XSuperJSON in 'comps\XSO\XSuperJSON.pas',
  XSuperObject in 'comps\XSO\XSuperObject.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
