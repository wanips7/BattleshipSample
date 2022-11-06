{ This is a sample of a Battleship game }
{ https://github.com/wanips7 }

unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls, bship;

type
  TForm2 = class(TForm)
    StringGrid1: TStringGrid;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    StringGrid4: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure UpdateGrids;
    procedure BeginGame(Sender: TObject; const PlayerAttackFirst: Boolean);
    procedure EndGame(Sender: TObject; const PlayerWon: Boolean);
    procedure PlayerAttack(Sender: TObject; const Point: TPoint; const Result: TAttackResult);
    procedure EnemyPlayerAttack(Sender: TObject; const Point: TPoint; const Result: TAttackResult);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  BattleShip: TBattleShipGame;

implementation

{$R *.dfm}

procedure TForm2.UpdateGrids;
var
  sh: TShipCell;
  x, y: Byte;
  i: Integer;
  k: Integer;
begin
  for x := 0 to GAME_MEMO_WIDTH - 1 do
    for y := 0 to GAME_MEMO_HEIGHT - 1 do
    begin
      StringGrid2.Cells[x, y] := '';
      StringGrid4.Cells[x, y] := '';
    end;

  for i := 0 to BattleShip.Player.Ships.Count - 1 do
    for sh in BattleShip.Player.Ships.List[i].Cells do
    begin
      if sh.Alive then
        StringGrid2.Cells[sh.Point.X, sh.Point.y] := '*'
      else
        StringGrid2.Cells[sh.Point.X, sh.Point.y] := 'X';
    end;

  for i := 0 to BattleShip.EnemyPlayer.Ships.Count - 1 do
    for sh in BattleShip.EnemyPlayer.Ships.List[i].Cells do
    begin
      if sh.Alive then
        StringGrid4.Cells[sh.Point.X, sh.Point.y] := '*'
      else
        StringGrid4.Cells[sh.Point.X, sh.Point.y] := 'X';
    end;

end;

procedure TForm2.BeginGame(Sender: TObject; const PlayerAttackFirst: Boolean);
begin
  if PlayerAttackFirst then
    ShowMessage('you attack first')
  else
    ShowMessage('enemy attack first')
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  sh: TShips;
  x, y: Byte;
begin
  for x := 0 to GAME_MEMO_WIDTH - 1 do
    for y := 0 to GAME_MEMO_HEIGHT - 1 do
    begin
      StringGrid1.Cells[x, y] := '';
      StringGrid3.Cells[x, y] := '';
    end;

  BattleShip.New;  
  UpdateGrids;    
  BattleShip.Start;

end;

procedure TForm2.Button3Click(Sender: TObject);
var
  Target: TPoint;
begin
  // attack
  Target.X := StringGrid1.Selection.Left;
  Target.Y := StringGrid1.Selection.Top;

  BattleShip.Player.Attack(Target);

end;

procedure TForm2.EndGame(Sender: TObject; const PlayerWon: Boolean);
begin
  Application.ProcessMessages;
  UpdateGrids;

  if PlayerWon then
    ShowMessage('you won')
  else
    ShowMessage('you lose')
end;

procedure TForm2.EnemyPlayerAttack(Sender: TObject; const Point: TPoint; const Result: TAttackResult);
begin
  Sleep(1000);

  case Result of
    arOffTarget:
      StringGrid3.Cells[Point.x, Point.y] := 'o';
    arOnTarget:
      StringGrid3.Cells[Point.x, Point.y] := 'x';
    arDestroyed:
      StringGrid3.Cells[Point.x, Point.y] := 'Z';
  end;

  Application.ProcessMessages;
  UpdateGrids;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  BattleShip := TBattleShipGame.Create;

  BattleShip.OnBegin := BeginGame;
  BattleShip.OnEnd := EndGame;
  BattleShip.Player.OnAttack := PlayerAttack;
  BattleShip.EnemyPlayer.OnAttack := EnemyPlayerAttack;

end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  BattleShip.Free;
end;

procedure TForm2.PlayerAttack(Sender: TObject; const Point: TPoint; const Result: TAttackResult);
begin
  case Result of
    arOffTarget:
      StringGrid1.Cells[Point.x, Point.y] := 'o';
    arOnTarget:
      StringGrid1.Cells[Point.x, Point.y] := 'x';
    arDestroyed:
      StringGrid1.Cells[Point.x, Point.y] := 'Z';
  end;

  Application.ProcessMessages;
  UpdateGrids;
end;

end.
