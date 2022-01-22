program TestTryExcept;

uses
  System.StartUpCopy,
  FMX.Forms,
  TestTryExceptForm in 'TestTryExceptForm.pas' {ExceptionTstForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TExceptionTstForm, ExceptionTstForm);
  Application.Run;
end.
