program Labyrinthe3D;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {MainForm},
  uLabyrinthe in 'uLabyrinthe.pas',
  uUtils3D in 'uUtils3D.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape];
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
