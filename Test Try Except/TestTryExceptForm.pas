unit TestTryExceptForm;

interface

// Logic From
// https://github.com/pmcgee69/Exceptions-Cost-in-Delphi/blob/master/Project1.dpr#L10
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Diagnostics,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo;

type
  fn = function(i, j: integer): single;

  TExceptionTstForm = class(TForm)
    BthActionExceptions: TButton;
    MmoRslts1: TMemo;
    MmoRslts2: TMemo;
    BtnTryExceptImpact: TButton;
    procedure BthActionExceptionsClick(Sender: TObject);
    procedure BtnTryExceptImpactClick(Sender: TObject);
  private
    function RunTestSeries1(f: fn; AHeading: String): integer;
    function RunTestSeries2(f: fn; AHeading: String): integer;
    { Private declarations }
  public
    { Public declarations }
  end;

const
  exception_freq = 5000;
  repeat_freq = 10000000 div exception_freq;

var
  arr: array [1 .. exception_freq] of integer; // Random Array
  ExceptionTstForm: TExceptionTstForm;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

function divexcept(i, j: integer): single;
begin
//{$IFDEF MSWINDOWS}
  if j = 0 then
    raise Exception.Create('Div by Zero');
//{$ENDIF}
  result := i / j;
end;

function divnoexcept(i, j: integer): single;
begin
  if j <> 0 then
    result := i / j
  else
    result := -1;
end;

function DivWithNoExceptReporting(i, j: integer): single;
Var
  d: single;
begin
  d := divexcept(i, j);
  if j = 0 then
    result := -1
  Else
  Begin
    d := i / j;
    result := d;
    i := Trunc(d * j);
    d := i / j;
    if (d <> result) then
      result := d
    else
      result := i / j;
  End;
end;

function DivWithExceptReporting(i, j: integer): single;
Var
  d: single;
begin
  Try
    Try
      d := divexcept(i, j);
    Except
      On E: Exception Do
      Begin
        raise Exception.Create('Error in divexcept ' + E.message);
      End;
    End;

    Try
      if j = 0 then
        Try
          result := -1;
        Except
          On E: Exception Do
          Begin
            raise Exception.Create('Error in j=0 ' + E.message);
          End;
        End
      Else
        try
          d := i / j;
        Except
          On E: Exception Do
          Begin
            raise Exception.Create('Error in j<>0 ' + E.message);
          End;
        End;
      Try
        result := d;
        i := Trunc(d * j);
        d := i / j;
      Except
        On E: Exception Do
        Begin
          raise Exception.Create('Error in Trunc ' + E.message);
        End;
      End;
      try
        if (d <> result) then
          try
            result := d
          Except
            On E: Exception Do
            Begin
              raise Exception.Create('Error in result<>d ' + E.message);
            End;
          End

        else
          try
            result := i / j;
          Except
            On E: Exception Do
            Begin
              raise Exception.Create('Error in i/j ' + E.message);
            End;
          End

      Except
        On E: Exception Do
        Begin
          raise Exception.Create('Error in last block ::' + E.message);
        End;
      End;
    Except
      On E: Exception Do
      Begin
        raise Exception.Create('Error in big block ::' + E.message);
      End;
    End;

  Except
    result := -1;
  End;
end;

procedure TExceptionTstForm.BthActionExceptionsClick(Sender: TObject);
const
  No_runs = 6;
var
  time_nox, time_exc, i, z: integer;
begin
  MmoRslts1.Lines.clear;
  time_nox := 0;
  time_exc := 0;
  for i := 1 to exception_freq do
    arr[i] := Trunc(random(1000));

  for z := 1 to No_runs do
  begin
    time_nox := time_nox + RunTestSeries1(divnoexcept, 'No exceptions');
    time_exc := time_exc + RunTestSeries1(divexcept, 'Throw exceptions - 1 in '
      + (exception_freq).ToString);
  end;

  MmoRslts1.Lines.add('av Nox : ' + FormatFloat('0.0##', time_nox / No_runs) +
    '  av Exc : ' + FormatFloat('0.0##', time_exc / No_runs));
end;

procedure TExceptionTstForm.BtnTryExceptImpactClick(Sender: TObject);
const
  No_runs = 6;
var
  time_nox, time_exc, i, z: integer;
begin
  MmoRslts2.Lines.clear;
  time_nox := 0;
  time_exc := 0;
  for i := 1 to exception_freq do
    arr[i] := Trunc(random(1000));

  for z := 1 to No_runs do
  begin
    time_nox := time_nox + RunTestSeries2(DivWithNoExceptReporting,
      'No Try Except Blocks');
    time_exc := time_exc + RunTestSeries2(DivWithExceptReporting,
      'Many Try Except Blocks' + (exception_freq).ToString);
  end;

  MmoRslts2.Lines.add('av No Blk : ' + FormatFloat('0.0##', time_nox / No_runs)
    + '  av Try Exc Block: ' + FormatFloat('0.0##', time_exc / No_runs));
end;

function TExceptionTstForm.RunTestSeries1(f: fn; AHeading: String): integer;
var
  i, j, num_ok, num_ex: integer;
  Stopwatch: TStopwatch;
begin
  MmoRslts1.Lines.add(AHeading);

  num_ok := 0;
  num_ex := 0;
  Stopwatch := TStopwatch.StartNew;
  for j := 1 to repeat_freq do
    for i := 1 to exception_freq do
      try
        if f(arr[i], i - 1) <> -1 then
          inc(num_ok)
        else
          inc(num_ex);
      except
        on E: Exception do
          // Writeln(E.ClassName, ': ', E.Message);
          inc(num_ex);
      end;
  result := Stopwatch.ElapsedMilliseconds;

  MmoRslts1.Lines.add('Total ' + IntToStr(exception_freq * repeat_freq) +
    '  Num_OK=' + IntToStr(num_ok) + '  Num Div Zero=' + IntToStr(num_ex));
  MmoRslts1.Lines.add('time: ' + IntToStr(result) + ' ms');
  MmoRslts1.Lines.add('');
  Application.ProcessMessages;
end;

function TExceptionTstForm.RunTestSeries2(f: fn; AHeading: String): integer;
var
  i, j, num_ok, num_ex: integer;
  Stopwatch: TStopwatch;
begin
  MmoRslts2.Lines.add(AHeading);

  num_ok := 0;
  num_ex := 0;
  Stopwatch := TStopwatch.StartNew;
  for j := 1 to repeat_freq do
    for i := 1 to exception_freq do
      if f(arr[i], i) <> -1 then // i never 0 so no exceptions
        inc(num_ok)
      else
        inc(num_ex);

  result := Stopwatch.ElapsedMilliseconds;
  MmoRslts2.Lines.add('Total ' + IntToStr(exception_freq * repeat_freq) +
    '  Num_OK=' + IntToStr(num_ok) + '  Num Div Zero=' + IntToStr(num_ex));
  MmoRslts2.Lines.add('time: ' + IntToStr(result) + ' ms');
  MmoRslts2.Lines.add('');
  Application.ProcessMessages;
end;

end.
