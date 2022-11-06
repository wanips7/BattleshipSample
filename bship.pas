{ This is a sample of a Battleship game }
{ https://github.com/wanips7 }

unit bship;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.SyncObjs;

const
  GAME_MEMO_WIDTH = 10;
  GAME_MEMO_HEIGHT = GAME_MEMO_WIDTH;
  CELLS_COUNT = GAME_MEMO_WIDTH * GAME_MEMO_HEIGHT;
  SHIP_MIN_LEN = 1;
  SHIP_MAX_LEN = 4;

type
  TAttackResult = (arOffTarget, arOnTarget, arDestroyed);
  TSide = (sdUp, sdRight, sdDown, sdLeft);
  TPointCondition = (pcLowestX, pcLowestY, pcHighestX, pcHighestY);
  TShipInfo = (siOneCell, siVertical, siHorizontal);
  TShipStatus = (ssFull, ssDamaged, ssDestroyed);

type
  TNumList = array of Byte;
  TPointList = array of TPoint;

type
  TOnBeginEvent = procedure(Sender: TObject; const PlayerAttackFirst: Boolean) of object;
  TOnEndEvent = procedure(Sender: TObject; const PlayerWon: Boolean) of object;
  TOnAttackEvent = procedure(Sender: TObject; const Point: TPoint; const Result: TAttackResult) of object;

type
  TStat = record
    SecElapsed: Cardinal;
    Progress: Byte;
  end;

type
  EBattleShipGameError = class(Exception);

type
  PCellsList = ^TCellsList;
  TCellsList = record
  private
    FList: TPointList;
    function GetCount: Byte;
  public
    property Count: Byte read GetCount;
    property List: TPointList read FList;
    function GetRandom: TPoint;
    function Contains(const Point: TPoint): Boolean; overload;
    function Contains(const Point: TPoint; out Index: Integer): Boolean; overload;
    procedure New;
    procedure Remove(const Point: TPoint);
  end;

type
  TShipCell = record
    Point: TPoint;
    Alive: Boolean;
  end;

type
  TShipCells = array of TShipCell;

type
  TOnShipDestroy = procedure(Sender: TObject; const Cells: TShipCells) of object;

type
  PShip = ^TShip;
  TShip = record
  private
    FFreeCells: PCellsList;
    FCells: TShipCells;
    function GetStatus: TShipStatus;
    function GetLen: Integer;
  public
   // property OnDestroy: TShipStatus read GetStatus;
    property Status: TShipStatus read GetStatus;
    property Len: Integer read GetLen;
    property Cells: TShipCells read FCells;
    procedure New(Len: Byte; const FreeCells: PCellsList);
    function CanPlaceTo(const StartPos: TPoint; Side: TSide): Boolean;
    procedure PlaceTo(StartPos: TPoint; Side: TSide);
    function ApplyAttack(const Point: TPoint): TAttackResult;
    function ContainsPoint(const Point: TPoint; out Index: Integer): Boolean; overload;
    function ContainsPoint(const Point: TPoint): Boolean; overload;
  end;

type
  TShipList = array of TShip;

type
  TShips = class
  private
    FOnShipDestroy: TOnShipDestroy;
    FFreeCells: TCellsList;
    FList: TShipList;
    procedure DoShipDestroy(const Cells: TShipCells);
    procedure Clear;
    procedure Add(const Ship: TShip);
    function GetCount: Integer;
    function GetAliveCount: Integer;
  public
    property OnShipDestroy: TOnShipDestroy read FOnShipDestroy write FOnShipDestroy;
    property Count: Integer read GetCount;
    property AliveCount: Integer read GetAliveCount;
    property List: TShipList read FList;
    constructor Create;
    procedure New;
    function ApplyAttack(const Point: TPoint): TAttackResult;
    function GetMatchShip(const Point: TPoint; out Ship: PShip): Boolean;
  end;

type
  TPlayer = class
  strict private
    FOnAttack: TOnAttackEvent;
    FOnOffTarget: TNotifyEvent;
    FIsLose: Boolean;
    FOnGiveUp: TNotifyEvent;
    FEnemy: TPlayer;
    FShips: TShips;
    FCellsForAttack: TCellsList;
    procedure DoAttack(const Point: TPoint; AttackResult: TAttackResult);
    procedure DoOffTarget;
    procedure DoGiveUp;
  protected
    property OnOffTarget: TNotifyEvent read FOnOffTarget write FOnOffTarget;
    property CellsForAttack: TCellsList read FCellsForAttack;
    function IsEndGame: Boolean;
  public
    property OnAttack: TOnAttackEvent read FOnAttack write FOnAttack;
    property OnGiveUp: TNotifyEvent read FOnGiveUp write FOnGiveUp;
    property Ships: TShips read FShips;
    property IsLose: Boolean read FIsLose;
    constructor Create;
    destructor Destroy; override;
    function ApplyAttack(const Point: TPoint): TAttackResult;
    function Attack(const Point: TPoint): TAttackResult;
    function CanAttackCell(const Point: TPoint): Boolean;
    procedure Prepare;
    procedure SetEnemy(Value: TPlayer);

  end;

type
  TLastDamagedCells = record
  private
    FCellsForAttack: PCellsList;
    FList: TPointList;
    function GetCount: Integer;
  public
    property Count: Integer read GetCount;
    property List: TPointList read FList;
    function GetShipInfo: TShipInfo;
    procedure Clear;
    procedure Add(const Point: TPoint);
    procedure RemoveCellsAround;
    procedure SetCellsForAttack(Value: PCellsList);
  end;

type
  TEnemyPlayer = class (TPlayer)
  private
    FLastAttackPos: TPoint;
    FLastDamagedCells: TLastDamagedCells;
    function IsShipFound: Boolean;
    procedure Attack(const Point: TPoint); overload;
    function TryAttack(const Point: TPoint): Boolean;
  public
    constructor Create;
    procedure Attack; overload;
    procedure Prepare;
  end;

type
  TBattleShipGame = class
  private
    FOnBegin: TOnBeginEvent;
    FOnEnd: TOnEndEvent;
    FPlayerAttackFirst: Boolean;
    FPlayer: TPlayer;
    FEnemyPlayer: TEnemyPlayer;
    FStat: TStat;
    procedure DoBegin;
    procedure DoEnd(Sender: TObject);
    procedure ProcessPlayerAttack(Sender: TObject);
  public
    property OnBegin: TOnBeginEvent read FOnBegin write FOnBegin;
    property OnEnd: TOnEndEvent read FOnEnd write FOnEnd;
    property Player: TPlayer read FPlayer;
    property EnemyPlayer: TEnemyPlayer read FEnemyPlayer;
    property Stat: TStat read FStat;
    constructor Create;
    destructor Destroy; override;
    procedure New;
    procedure Start;
  end;


implementation

function Pos(const Row, Col: Integer): TPoint;
begin
  Result.X := Row;
  Result.Y := Col;
end;

function PosToIndex(const Row, Col: Integer): Integer;
begin
  Result := Row + Col * GAME_MEMO_HEIGHT;
end;

function IndexToPos(const Value: Integer): TPoint;
begin
  Result.X := Value mod GAME_MEMO_WIDTH;
  Result.Y := Value div GAME_MEMO_HEIGHT;
end;

function InRange(const Value, Min, Max: Integer): Boolean;
begin
  Result := (Value >= Min) and (Value <= Max)
end;

function IsValidCell(const Point: TPoint): Boolean;
begin
  Result := InRange(Point.X, 0, GAME_MEMO_WIDTH - 1) and InRange(Point.Y, 0, GAME_MEMO_HEIGHT - 1);
end;

function GetPoint(const PointList: TPointList; Condition: TPointCondition): TPoint;
var
  i: Integer;
begin
  Result := PointList[0];
  case Condition of
    pcLowestX:
      begin
        for i := 1 to High(PointList) do
          if Result.X > PointList[I].X then
            Result := PointList[I];
      end;

    pcLowestY:
      begin
        for i := 1 to High(PointList) do
          if Result.Y > PointList[I].Y then
            Result := PointList[I];
      end;

    pcHighestX:
      begin
        for i := 1 to High(PointList) do
          if Result.X < PointList[I].X then
            Result := PointList[I];
      end;

    pcHighestY:
      begin
        for i := 1 to High(PointList) do
          if Result.Y < PointList[I].Y then
            Result := PointList[I];
      end;
  end;

end;

function GetCellsAroundShip(StartPos, EndPos: TPoint): TPointList;
var
  i: ShortInt;
  TempPoint: TPoint;

  procedure AddToResult(const X, Y: ShortInt);
  begin
    Result := Result + [Point(X, Y)];
  end;

begin
  Result := [];

  if (EndPos.X < StartPos.X) or (EndPos.Y < StartPos.Y) then
  begin
    TempPoint := StartPos;
    StartPos := EndPos;
    EndPos := TempPoint;
  end;

  for i := StartPos.X - 1 to EndPos.X + 1 do
  begin
    AddToResult(i, StartPos.Y - 1);
    AddToResult(i, EndPos.Y + 1);
  end;

  for i := StartPos.Y to EndPos.Y do
  begin
    AddToResult(StartPos.X - 1, i);
    AddToResult(EndPos.X + 1, i);
  end;

end;

{ TCellsList }

function TCellsList.Contains(const Point: TPoint): Boolean;
var
  i: Integer;
begin
  Result := Contains(Point, i);
end;

function TCellsList.Contains(const Point: TPoint; out Index: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  Index := -1;

  if GetCount > 0 then
    for i := 0 to GetCount - 1 do
      if Point = FList[i] then
      begin
        Result := True;
        Index := i;
        Break;
      end;

end;

function TCellsList.GetCount: Byte;
begin
  Result := Length(FList)
end;

function TCellsList.GetRandom: TPoint;
var
  i: Integer;
begin
  if Length(FList) > 0 then
  begin
    i := Random(GetCount);
    Result := FList[i];
  end
    else
  raise EBattleShipGameError.Create('List is empty');
end;

procedure TCellsList.New;
var
  i: Byte;
begin
  SetLength(FList, CELLS_COUNT);

  for i := 0 to CELLS_COUNT - 1 do
    FList[i] := IndexToPos(i);

end;

procedure TCellsList.Remove(const Point: TPoint);
var
  i: Integer;
begin
  if Contains(Point, i) then
    Delete(FList, i, 1);
end;

{ TShips }

procedure TShips.Clear;
begin
  FList := [];
end;

constructor TShips.Create;
begin
  FOnShipDestroy := nil;
end;

procedure TShips.DoShipDestroy(const Cells: TShipCells);
begin
  if Assigned(FOnShipDestroy) then
    FOnShipDestroy(Self, Cells);
end;

function TShips.GetAliveCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  if Length(FList) > 0 then
    for i := 0 to High(FList) do
      if FList[i].Status <> ssDestroyed then
        Inc(Result);
end;

function TShips.GetCount: Integer;
begin
  Result := Length(FList);
end;

function TShips.GetMatchShip(const Point: TPoint; out Ship: PShip): Boolean;
var
  i: Integer;
begin
  Result := False;

  if Length(FList) > 0 then
    for i := 0 to High(FList) do
    if FList[i].ContainsPoint(Point) then
    begin
      Result := True;
      Ship := @FList[i];
      Exit;
    end;
end;

procedure TShips.Add(const Ship: TShip);
begin
  FList := FList + [Ship];
end;

function TShips.ApplyAttack(const Point: TPoint): TAttackResult;
var
  Ship: PShip;
begin
  if GetMatchShip(Point, Ship) then
  begin
    Result := Ship.ApplyAttack(Point);

    if Result = arDestroyed then
      DoShipDestroy(Ship.Cells);
  end
    else
  Result := arOffTarget;
end;

procedure TShips.New;
var
  Len: Byte;
  c: Byte;
  Sides: array of TSide;
  Side: TSide;
  Cell: TPoint;
  Count: Byte;
  Ship: TShip;
  PFreeCells: PCellsList;
begin
  Clear;
  FFreeCells.New;
  PFreeCells := @FFreeCells;

  Count := 0;
  for Len := SHIP_MAX_LEN downto SHIP_MIN_LEN do
  begin
    Inc(Count);

    for c := 1 to Count do
    begin
      Ship.New(Len, PFreeCells);

      while True do
      begin
        Cell := FFreeCells.GetRandom;

        Sides := [];
        for Side := Low(TSide) to High(TSide) do
          if Ship.CanPlaceTo(Cell, Side) then
            Sides := Sides + [Side];

        if Length(Sides) > 0 then
        begin
          Side := Sides[Random(Length(Sides))];
          Ship.PlaceTo(Cell, Side);

          Break;
        end;;

      end;

      Add(Ship);
    end;
  end;

end;

{ TPlayer }

function TPlayer.ApplyAttack(const Point: TPoint): TAttackResult;
begin
  Result := FShips.ApplyAttack(Point);

  if FShips.GetAliveCount = 0 then
    DoGiveUp;
end;

function TPlayer.Attack(const Point: TPoint): TAttackResult;
begin
  if not IsEndGame then
    if CanAttackCell(Point) then
    begin
      FCellsForAttack.Remove(Point);

      Result := FEnemy.ApplyAttack(Point);

      DoAttack(Point, Result);

      if Result = arOffTarget then
        DoOffTarget;

    end
      else
    raise EBattleShipGameError.Create('You can''t attack this point ');

end;

function TPlayer.CanAttackCell(const Point: TPoint): Boolean;
begin
  Result := IsValidCell(Point) and FCellsForAttack.Contains(Point);
end;

constructor TPlayer.Create;
begin
  FShips := TShips.Create;
  FOnAttack := nil;
  FOnOffTarget := nil;
  FOnGiveUp := nil;
  FEnemy := nil;
  FIsLose := False;
end;

destructor TPlayer.Destroy;
begin
  FShips.Free;
  inherited;
end;

procedure TPlayer.DoAttack(const Point: TPoint; AttackResult: TAttackResult);
begin
  if Assigned(FOnAttack) then
    FOnAttack(Self, Point, AttackResult);
end;

procedure TPlayer.DoGiveUp;
begin
  FIsLose := True;

  if Assigned(FOnGiveUp) then
    FOnGiveUp(Self);
end;

procedure TPlayer.DoOffTarget;
begin
  if Assigned(FOnOffTarget) then
    FOnOffTarget(Self);
end;

function TPlayer.IsEndGame: Boolean;
begin
  Result := FIsLose or FEnemy.IsLose;
end;

procedure TPlayer.Prepare;
begin
  FShips.New;
  FCellsForAttack.New;



end;

procedure TPlayer.SetEnemy(Value: TPlayer);
begin
  FEnemy := Value;

end;

{ TEnemyPlayer }

procedure TEnemyPlayer.Attack;

  procedure CrossAttack(const Point: TPoint);
  var
    Side: TSide;
    TempPoint: TPoint;
  begin
    for Side := Low(TSide) to High(TSide) do
    begin
      TempPoint := Point;

      case Side of
        sdUp:
          Dec(TempPoint.Y);
        sdRight:
          Inc(TempPoint.X);
        sdDown:
          Inc(TempPoint.Y);
        sdLeft:
          Dec(TempPoint.X);
      end;

      if TryAttack(TempPoint) then
        Break;
    end;
  end;

var
  Target: TPoint;
begin

  if IsShipFound then
  begin
    if FLastDamagedCells.GetShipInfo = siOneCell then
    begin
      CrossAttack(FLastDamagedCells.FList[0]);
    end
      else
    begin

      if FLastDamagedCells.GetShipInfo = siVertical then
      begin
        Target := GetPoint(FLastDamagedCells.List, pcLowestY);
        Dec(Target.Y);

        if CanAttackCell(Target) then
        begin
          Attack(Target);
        end
          else
        begin
          Target := GetPoint(FLastDamagedCells.List, pcHighestY);
          Inc(Target.Y);

          Attack(Target);
        end;

      end
        else
      { horizontal }
      begin
        Target := GetPoint(FLastDamagedCells.List, pcLowestX);
        Dec(Target.X);

        if CanAttackCell(Target) then
        begin
          Attack(Target);
        end
          else
        begin
          Target := GetPoint(FLastDamagedCells.List, pcHighestX);
          Inc(Target.X);

          Attack(Target);
        end;

      end;

    end;

  end
    else
  begin
    { random attack }

    Target := CellsForAttack.GetRandom;

    Attack(Target);
  end;

end;

constructor TEnemyPlayer.Create;
var
  PCellsForAtack: PCellsList;
begin
  inherited;
  PCellsForAtack := @CellsForAttack;
  FLastDamagedCells.SetCellsForAttack(PCellsForAtack);
end;

function TEnemyPlayer.IsShipFound: Boolean;
begin
  Result := FLastDamagedCells.Count > 0;
end;

procedure TEnemyPlayer.Attack(const Point: TPoint);
begin
  if not IsEndGame then
    case inherited Attack(Point) of
      arOnTarget:
        begin
          FLastDamagedCells.Add(Point);
          Attack;
        end;

      arDestroyed:
        begin
          FLastDamagedCells.Add(Point);
          FLastDamagedCells.RemoveCellsAround;
          FLastDamagedCells.Clear;
          Attack;
        end;

    end;
end;

function TEnemyPlayer.TryAttack(const Point: TPoint): Boolean;
begin
  Result := CanAttackCell(Point);
  if Result then
    Attack(Point);
end;

procedure TEnemyPlayer.Prepare;
begin
  inherited;
  FLastDamagedCells.Clear;
end;

{ TBattleShipGame }

constructor TBattleShipGame.Create;
begin
  Randomize;

  FOnBegin := nil;
  FOnEnd := nil;
  FPlayer := TPlayer.Create;
  FPlayer.OnGiveUp := DoEnd;
  FPlayer.OnOffTarget := ProcessPlayerAttack;
  FEnemyPlayer := TEnemyPlayer.Create;
  FEnemyPlayer.OnGiveUp := DoEnd;

  FPlayer.SetEnemy(FEnemyPlayer as TPlayer);
  FEnemyPlayer.SetEnemy(FPlayer);
end;

destructor TBattleShipGame.Destroy;
begin
  FPlayer.Free;
  FEnemyPlayer.Free;
  inherited;
end;

procedure TBattleShipGame.DoBegin;
begin
  if Assigned(FOnBegin) then
    FOnBegin(Self, FPlayerAttackFirst);
end;

procedure TBattleShipGame.DoEnd(Sender: TObject);
begin
  if Assigned(FOnEnd) then
    FOnEnd(Self, (Sender is TEnemyPlayer));
end;

procedure TBattleShipGame.New;
begin
  FPlayer.Prepare;
  FEnemyPlayer.Prepare;



end;

procedure TBattleShipGame.ProcessPlayerAttack(Sender: TObject);
begin
  FEnemyPlayer.Attack;
end;

procedure TBattleShipGame.Start;
begin
  FPlayerAttackFirst := Random(2) = 1;

  DoBegin;

  if not FPlayerAttackFirst then
    FEnemyPlayer.Attack;


end;

{ TLastDamagedCells }

procedure TLastDamagedCells.Add(const Point: TPoint);
begin
  FList := FList + [Point];
end;

procedure TLastDamagedCells.Clear;
begin
  FList := [];
end;

function TLastDamagedCells.GetCount: Integer;
begin
  Result := Length(FList);
end;

function TLastDamagedCells.GetShipInfo: TShipInfo;
begin
  if GetCount = 1 then
    Result := siOneCell
  else
    if FList[0].X = FList[1].X then
      Result := siVertical
    else
      Result := siHorizontal
end;

procedure TLastDamagedCells.RemoveCellsAround;
var
  StartPos, EndPos: TPoint;
  Points: TPointList;
  i: Integer;
begin
  if GetCount > 0 then
  begin
    if GetShipInfo = siVertical then
    begin
      StartPos := GetPoint(FList, pcLowestY);
      EndPos := GetPoint(FList, pcHighestY);
    end
      else
    begin
      StartPos := GetPoint(FList, pcLowestX);
      EndPos := GetPoint(FList, pcHighestX);
    end;

    Points := GetCellsAroundShip(StartPos, EndPos);

    if Length(Points) > 0 then
      for i := 0 to High(Points) do
        if IsValidCell(Points[i]) then
        begin
          FCellsForAttack.Remove(Points[i]);
        end;

  end;
end;

procedure TLastDamagedCells.SetCellsForAttack(Value: PCellsList);
begin
  FCellsForAttack := Value;
end;

{ TShip }

function TShip.ApplyAttack(const Point: TPoint): TAttackResult;
var
  i: Integer;
begin
  Result := arOffTarget;

  if GetStatus = ssDestroyed then
  begin
    Result := arOffTarget;
  end
    else
  if ContainsPoint(Point, i) then
  begin
    if FCells[i].Alive then
      FCells[i].Alive := False;

    if GetStatus = ssDamaged then
      Result := arOnTarget
    else
      Result := arDestroyed;
  end;
end;

function TShip.CanPlaceTo(const StartPos: TPoint; Side: TSide): Boolean;

  function IsFreeCell(const Point: TPoint): Boolean;
  begin
    Result := FFreeCells.Contains(Point);
  end;

  function IsValidAndFreeCell(const Point: TPoint): Boolean;
  begin
    Result := IsValidCell(Point) and IsFreeCell(Point);
  end;

begin
  case Side of
    sdUp:
      Result := IsValidAndFreeCell(Point(StartPos.X, StartPos.Y - Len + 1));
    sdRight:
      Result := IsValidAndFreeCell(Point(StartPos.X + Len - 1, StartPos.Y));
    sdDown:
      Result := IsValidAndFreeCell(Point(StartPos.X, StartPos.Y + Len - 1));
    sdLeft:
      Result := IsValidAndFreeCell(Point(StartPos.X - Len + 1, StartPos.Y));
  end;

end;

function TShip.ContainsPoint(const Point: TPoint): Boolean;
var
  i: Integer;
begin
  Result := ContainsPoint(Point, i);
end;

function TShip.ContainsPoint(const Point: TPoint; out Index: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  Index := -1;

  for i := 0 to High(FCells) do
    if FCells[i].Point = Point then
    begin
      Result := True;
      Index := i;
      Exit;
    end;
end;

function TShip.GetLen: Integer;
begin
  Result := Length(FCells)
end;

function TShip.GetStatus: TShipStatus;
var
  i: Integer;
  AliveCount: Integer;
begin
  AliveCount := 0;
  for i := 0 to High(FCells) do
    if FCells[i].Alive then
      Inc(AliveCount);

  if AliveCount = 0 then
    Result := ssDestroyed
  else
    if AliveCount = GetLen then
      Result := ssFull
    else
      Result := ssDamaged;
end;

procedure TShip.New(Len: Byte; const FreeCells: PCellsList);
begin
  SetLength(FCells, Len);
  FFreeCells := FreeCells;
end;

procedure TShip.PlaceTo(StartPos: TPoint; Side: TSide);
var
  i: ShortInt;
  x, y: Byte;
  PointList: TPointList;
  EndPos: TPoint;
  TempPoint: TPoint;

  procedure AddToPointList(const X, Y: ShortInt);
  begin
    PointList := PointList + [Point(X, Y)];
  end;

begin

  case Side of
    sdUp:
      EndPos := Point(StartPos.X, StartPos.Y - Len + 1);
    sdRight:
      EndPos := Point(StartPos.X + Len - 1, StartPos.Y);
    sdDown:
      EndPos := Point(StartPos.X, StartPos.Y + Len - 1);
    sdLeft:
      EndPos := Point(StartPos.X - Len + 1, StartPos.Y);
  end;

  if (EndPos.X < StartPos.X) or (EndPos.Y < StartPos.Y) then
  begin
    TempPoint := StartPos;
    StartPos := EndPos;
    EndPos := TempPoint;
  end;

  PointList := [];

  if StartPos.X < EndPos.X then
  begin
    for i := StartPos.X to EndPos.X do
    begin
      AddToPointList(i, StartPos.Y);
    end;
  end
    else
  begin
    for i := StartPos.Y to EndPos.Y do
    begin
      AddToPointList(StartPos.X, i);
    end;
  end;

  for i := 0 to High(PointList) do
  begin
    FCells[i].Point := PointList[i];
    FCells[i].Alive := True;
  end;

  PointList := PointList + GetCellsAroundShip(StartPos, EndPos);

  for i := 0 to High(PointList) do
    if IsValidCell(PointList[i]) then
      FFreeCells.Remove(PointList[i]);

end;

end.
